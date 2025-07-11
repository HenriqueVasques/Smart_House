  //#region Imports
  #include <WiFi.h>
  #include <WebServer.h>
  #include <ESP32Servo.h>
  #include <Base64.h>
  #include "mbedtls/sha256.h"
  #include <WiFiClientSecure.h>
  #include "DHT.h"
  //#endregion

  //#region Configurações de Rede
  const char* ssid = "Agropesca";
  const char* password = "12345677";
  //#endregion

  //#region Definição de Pinos
  #define PINO_JANELA 4
  #define PINO_LED_VENTILADOR 5
  #define PINO_LAMPADA 18UOHIUJIKOHB
  #define PINO_SERVO_FECHADURA 25
  #define PINO_SERVO_JANELA 13
  #define PINO_AR 27
  #define PINO_LED_AR 2
  #define PINO_SENSOR_CHUVA 34
  #define PINO_DHT 32
  #define TIPO_DHT DHT11
  DHT dht(PINO_DHT, TIPO_DHT);
  //#endregion

  //#region Objetos Globais
  WebServer server(80);
  Servo servoFechadura;
  Servo servoJanela;
  const int keyPosition = 12;
  int temperaturaAlvo = 16;
  //#endregion

  //#region Controle de Nonces e Segurança
  #define MAX_NONCES 10
  String noncesRecentes[MAX_NONCES];
  int nonceIndex = 0;

  const char* chaveSecreta = "5fA9#zL3pW!c@Kq*4tE1vX8g^mN0dRb2";

  bool nonceValido(String nonce) {
    for (int i = 0; i < MAX_NONCES; i++) {
      if (noncesRecentes[i] == nonce) return false;
    }
    noncesRecentes[nonceIndex] = nonce;
    nonceIndex = (nonceIndex + 1) % MAX_NONCES;
    return true;
  }

  bool verificarAssinatura(String comando, String nonce, String assinaturaRecebida) {
    String mensagem = comando + nonce;

    const char* key = chaveSecreta;
    int keyLen = strlen(key);
    int blockSize = 64;

    uint8_t k_ipad[blockSize];
    uint8_t k_opad[blockSize];
    uint8_t keyBlock[blockSize];
    memset(keyBlock, 0, blockSize);

    memcpy(keyBlock, key, keyLen > blockSize ? blockSize : keyLen);

    for (int i = 0; i < blockSize; i++) {
      k_ipad[i] = keyBlock[i] ^ 0x36;
      k_opad[i] = keyBlock[i] ^ 0x5C;
    }

    uint8_t innerHash[32];
    mbedtls_sha256_context ctx;

    mbedtls_sha256_init(&ctx);
    mbedtls_sha256_starts(&ctx, 0);
    mbedtls_sha256_update(&ctx, k_ipad, blockSize);
    mbedtls_sha256_update(&ctx, (const unsigned char*)mensagem.c_str(), mensagem.length());
    mbedtls_sha256_finish(&ctx, innerHash);
    mbedtls_sha256_free(&ctx);

    uint8_t finalHash[32];
    mbedtls_sha256_init(&ctx);
    mbedtls_sha256_starts(&ctx, 0);
    mbedtls_sha256_update(&ctx, k_opad, blockSize);
    mbedtls_sha256_update(&ctx, innerHash, 32);
    mbedtls_sha256_finish(&ctx, finalHash);
    mbedtls_sha256_free(&ctx);

    String assinaturaCalculada = "";
    for (int i = 0; i < 32; i++) {
      if (finalHash[i] < 16) assinaturaCalculada += "0";
      assinaturaCalculada += String(finalHash[i], HEX);
    }

    return assinaturaRecebida.equalsIgnoreCase(assinaturaCalculada);
  }

  bool validarSeguranca(String& comando, String& nonce, String& assinatura) {
    if (nonce == "" || assinatura == "") {
      server.send(403, "application/json", "{\"status\":\"Faltando segurança\"}");
      return false;
    }

    if (!nonceValido(nonce)) {
      server.send(403, "application/json", "{\"status\":\"Nonce Repetido\"}");
      return false;
    }

    if (!verificarAssinatura(comando, nonce, assinatura)) {
      server.send(403, "application/json", "{\"status\":\"Assinatura Inválida\"}");
      return false;
    }

    return true;
  }
  //#endregion

  //#region Tokens
  const char* TOKEN_FECHADURA_ABERTA = "W9#Z8@";
  const char* TOKEN_FECHADURA_FECHADA = "T4^mL2";
  const char* TOKEN_JANELA_ABERTA = "V%8PD+";
  const char* TOKEN_JANELA_FECHADA = "H01gL@";
  const char* TOKEN_LAMPADA_LIGADA = "Q6?nY7";
  const char* TOKEN_LAMPADA_DESLIGADA = "U4!pR0";
  const char* TOKEN_VENTILADOR_LIGADO = "W9Y=7+";
  const char* TOKEN_VENTILADOR_DESLIGADO = "mLjiL@";
  const char* TOKEN_AR_LIGADO = "ahjY=7";
  const char* TOKEN_AR_DESLIGADO = "ji!d52";
  const char* TOKEN_COMANDO_INVALIDO = "X1!K3a";
  const char* TOKEN_REFORCO_SENSOR = "RfS8!#";
  //#endregion

  //#region Tokens de Autorização
  const char* abrirFechadura[] = {"G", "M", "!", "0", "@", "a", "&"};
  const char* fecharFechadura[] = {"Z", "#", "9", "x", "$", "%", "2"};
  const char* abrirJanela[] = {"U", "V", "W", "*", "b", "N", "^"};
  const char* fecharJanela[] = {"Q", "E", "L", "1", "(", "=", "]"};
  const char* ligarLampada[] = {"T", "K", "3", "P", "r", "+", "H"};
  const char* desligarLampada[] = {"D", "8", "!", "~", "Y", "{", "4"};
  const char* ligarVentilador[] = {"h", "o", "9", "#", "r", "6", "F"};
  const char* desligarVentilador[] = {"G", ",", "%", "~", "T", "j", "5"};
  const char* ligarAr[] = {"F", "K", "9", "!", "r", "+", "k"};
  const char* desligarAr[] = {"p", "8", "%", "~", "s", "{", "4"};
  const char* reforcarSensor[] = {"R", "8", "#", "s", "@", "Z", "!"};
  //#endregion

  //#region Funções de Validação de Comando
  bool comandoValido(String payload, const char* validos[], int tamanho) {
    if (payload.length() > keyPosition) {
      char chave = payload.charAt(keyPosition);
      for (int i = 0; i < tamanho; i++) {
        if (chave == validos[i][0]) return true;
      }
    }
    return false;
  }
  //#endregion

  // #region Sensor Umidade + Firestore + Controle de Janela (LED)
  bool ultimoEstadoMolhado = false;
  unsigned long ultimaVerificacao = 0;

  void atualizarFirestoreUmidade(bool molhado) {
    const char* FIREBASE_HOST = "firestore.googleapis.com";
    const char* PROJECT_ID = "smart-house-ac3b4";
    const char* API_KEY = "AIzaSyDMwO29Cc2x3-unEmMynTU3b8mm_Ov-Ydg";
    const char* USER_UID = "ZtEDG3Q9B8V41yDM55Pos4zpPhy2";
    const char* COMODO_ID = "QAAHEAQFnnXsCofyytPT";

    WiFiClientSecure client;
    client.setInsecure();

    if (!client.connect(FIREBASE_HOST, 443)) {
      Serial.println("Falha ao conectar com o Firestore");
      return;
    }

    String url = "/v1/projects/" + String(PROJECT_ID) + "/databases/(default)/documents/usuarios/" +
                 USER_UID + "/comodos/" + COMODO_ID + "?updateMask.fieldPaths=sensor_umidade.molhado&key=" + API_KEY;

    String payload = "{ \"fields\": { \"sensor_umidade\": { \"mapValue\": { \"fields\": { \"molhado\": { \"booleanValue\": ";
    payload += molhado ? "true" : "false";
    payload += "} } } } } }";

    client.println("PATCH " + url + " HTTP/1.1");
    client.println("Host: " + String(FIREBASE_HOST));
    client.println("Content-Type: application/json");
    client.println("Content-Length: " + String(payload.length()));
    client.println();
    client.println(payload);

    while (client.connected()) {
      String line = client.readStringUntil('\n');
      if (line == "\r") break;
    }

    String resposta = client.readString();
    Serial.println("Firestore atualizado: " + resposta);
  }


 void verificarSensorUmidade() {
  if (millis() - ultimaVerificacao < 3000) return;
  ultimaVerificacao = millis();

  bool molhado = digitalRead(PINO_SENSOR_CHUVA) == HIGH;
  Serial.println("Valor bruto do sensor: " + String(digitalRead(PINO_SENSOR_CHUVA)));

  if (molhado) {
    // Sempre fecha a janela se estiver molhado, mesmo se já estava
    digitalWrite(PINO_JANELA, LOW);
    servoJanela.write(0);
    Serial.println("Chuva detectada — janela fechada (LED OFF e SERVO)");
  }

  if (molhado != ultimoEstadoMolhado) {
    ultimoEstadoMolhado = molhado;
    atualizarFirestoreUmidade(molhado);
  }
}

  // #endregion

  //#region handle sensor
  void handleReforcoSensor() {  
    String pacote = server.arg("d1");
    if (pacote.length() < 35 + 16 + 64) {
      server.send(403, "application/json", "{\"status\":\"pacote_invalido\"}");
      return;
    }

    String comando = pacote.substring(0, 35);
    String nonce = pacote.substring(35, 51);
    String assinatura = pacote.substring(51, 115);

    if (!validarSeguranca(comando, nonce, assinatura)) return;

    if (!comandoValido(comando, reforcarSensor, 7)) {
      server.send(403, "application/json", "{\"status\":\"caractere_invalido\"}");
      return;
    }

    bool molhado = digitalRead(PINO_SENSOR_CHUVA) == LOW;

    if (molhado) {
      digitalWrite(PINO_JANELA, LOW);
      Serial.println("Reforço: sensor ainda molhado — janela fechada (LED OFF)");
    } else {
      Serial.println("Reforço: sensor seco");
    }

    atualizarFirestoreUmidade(molhado);

    server.send(200, "application/json", "{\"status\":\"reforco_ok\"}");
  }
  //#endregion

  //#region Handler Servo Motor 
  void handleServoFechadura() {
    String pacoteRecebido = server.arg("d1");
    if (pacoteRecebido.length() < 1 + 16 + 64) {
      server.send(403, "application/json", "{\"status\":\"Pacote inválido\"}");
      return;
    }

    String comando = pacoteRecebido.substring(0, pacoteRecebido.length() - 80);
    String nonce = pacoteRecebido.substring(pacoteRecebido.length() - 80, pacoteRecebido.length() - 64);
    String assinatura = pacoteRecebido.substring(pacoteRecebido.length() - 64);

    Serial.println("Servo | Valor: " + comando);
    Serial.println("Nonce: " + nonce);
    Serial.println("Assinatura: " + assinatura);

    if (!validarSeguranca(comando, nonce, assinatura)) return;

    comando.trim(); // remove espaços da própria string
    int angulo = comando.toInt(); // converte depois
    if (angulo == 0 || angulo == 90 || angulo == 180) {
      servoFechadura.write(angulo);
      server.send(200, "application/json", "{\"status\":\"servo_ok\"}");
    } else {
      server.send(403, "application/json", "{\"status\":\"angulo_invalido\"}");
    }
  }

  void handleServoJanela() {
  String pacoteRecebido = server.arg("d1");
  if (pacoteRecebido.length() < 1 + 16 + 64) {
    server.send(403, "application/json", "{\"status\":\"Pacote inválido\"}");
    return;
  }

  String comando = pacoteRecebido.substring(0, pacoteRecebido.length() - 80);
  String nonce = pacoteRecebido.substring(pacoteRecebido.length() - 80, pacoteRecebido.length() - 64);
  String assinatura = pacoteRecebido.substring(pacoteRecebido.length() - 64);

  Serial.println("Servo JANELA | Valor: " + comando);
  Serial.println("Nonce: " + nonce);
  Serial.println("Assinatura: " + assinatura);

  if (!validarSeguranca(comando, nonce, assinatura)) return;

  comando.trim(); // remove espaços da própria string
  int angulo = comando.toInt(); // converte depois
  if (angulo == 0 || angulo == 90 || angulo == 180) {
    servoJanela.write(angulo);
    server.send(200, "application/json", "{\"status\":\"servo_ok\"}");
  } else {
    server.send(403, "application/json", "{\"status\":\"angulo_invalido\"}");
  }
}

  //#endregion
  //reggion sensor temperatura
  unsigned long ultimaLeituraTemp = 0;
  bool arLigado = false;

void verificarSensorTemperatura() {
  if (millis() - ultimaLeituraTemp < 5000) return;
  ultimaLeituraTemp = millis();

  if (!arLigado) {
    Serial.println("Ar desligado, sensor não será lido.");
    return;
  }

  float temperatura = dht.readTemperature();

  if (isnan(temperatura)) {
    Serial.println("Falha na leitura do DHT11.");
    return;
  }

  Serial.print("Temperatura lida: ");
  Serial.println(temperatura);

  if (temperatura > temperaturaAlvo) {
    atualizarFirestoreModoCool(true);  // Ativa modo COOL
    Serial.println("Modo COOL ativado no Firestore.");
  } else {
    atualizarFirestoreModoCool(false); // Ativa modo ventilador
    Serial.println("Modo VENTILADOR ativado no Firestore.");
  }
}

void atualizarFirestoreModoCool(bool modoCool) {
  const char* FIREBASE_HOST = "firestore.googleapis.com";
  const char* PROJECT_ID = "smart-house-ac3b4";
  const char* API_KEY = "AIzaSyDMwO29Cc2x3-unEmMynTU3b8mm_Ov-Ydg";
  const char* USER_UID = "ZtEDG3Q9B8V41yDM55Pos4zpPhy2";
  const char* COMODO_ID = "1llmWgwbXtpI2VH0KjE7";

  WiFiClientSecure client;
  client.setInsecure();

  if (!client.connect(FIREBASE_HOST, 443)) {
    Serial.println("Falha ao conectar com o Firestore para modo_cool");
    return;
  }

  String url = "/v1/projects/" + String(PROJECT_ID) + "/databases/(default)/documents/usuarios/" +
               USER_UID + "/comodos/" + COMODO_ID + "?updateMask.fieldPaths=sensor_temp.modo_cool&key=" + API_KEY;

  String payload = "{ \"fields\": { \"sensor_temp\": { \"mapValue\": { \"fields\": { \"modo_cool\": { \"booleanValue\": ";
  payload += modoCool ? "true" : "false";
  payload += "} } } } } }";

  client.println("PATCH " + url + " HTTP/1.1");
  client.println("Host: " + String(FIREBASE_HOST));
  client.println("Content-Type: application/json");
  client.println("Content-Length: " + String(payload.length()));
  client.println();
  client.println(payload);

  while (client.connected()) {
    String line = client.readStringUntil('\n');
    if (line == "\r") break;
  }

  String resposta = client.readString();
  Serial.println("Firestore (modo_cool) atualizado: " + resposta);
}

  //#region Handlers
  void handleDispositivo(
    const char* tokenLigar, const char* tokenDesligar,
    const char* listaLigar[], const char* listaDesligar[],
    int pinoControle, bool usarPWM = false
  ) {
    String pacoteRecebido = server.arg("d1");
    Serial.println(pacoteRecebido);

    if (pacoteRecebido.length() < 35 + 16 + 64) {
      server.send(403, "application/json", "{\"status\":\"Pacote inválido\"}");
      return;
    }

    String comando = pacoteRecebido.substring(0, 35);
    String nonce = pacoteRecebido.substring(35, 51);
    String assinatura = pacoteRecebido.substring(51, 115);

    Serial.println("Comando: " + comando);
    Serial.println("Nonce: " + nonce);
    Serial.println("Assinatura: " + assinatura);

    if (!validarSeguranca(comando, nonce, assinatura)) return;

    if (comandoValido(comando, listaLigar, 7)) {
      digitalWrite(pinoControle, HIGH);
      server.send(200, "application/json", "{\"status\":\"" + String(tokenLigar) + "\"}");
    } else if (comandoValido(comando, listaDesligar, 7)) {
      digitalWrite(pinoControle, LOW);
      server.send(200, "application/json", "{\"status\":\"" + String(tokenDesligar) + "\"}");
    } else {
      server.send(403, "application/json", "{\"status\":\"" + String(TOKEN_COMANDO_INVALIDO) + "\"}");
    }
  }

  void tocarBuzzer(int duracaoMs = 200, int frequenciaHz = 1000) {
    tone(PINO_AR, frequenciaHz, duracaoMs);
  }

  void handleJanela() {
    handleDispositivo(TOKEN_JANELA_ABERTA, TOKEN_JANELA_FECHADA, abrirJanela, fecharJanela, PINO_JANELA);
  }

  void handleLampada() {
    handleDispositivo(TOKEN_LAMPADA_LIGADA, TOKEN_LAMPADA_DESLIGADA, ligarLampada, desligarLampada, PINO_LAMPADA, false);
  }

  void handleVentilador() {
    handleDispositivo(TOKEN_VENTILADOR_LIGADO, TOKEN_VENTILADOR_DESLIGADO, ligarVentilador, desligarVentilador, PINO_LED_VENTILADOR);
  }

void handleArCondicionado() {
  String pacoteRecebido = server.arg("d1");
  Serial.println(pacoteRecebido);

  if (pacoteRecebido.length() < 35 + 16 + 64) {
    server.send(403, "application/json", "{\"status\":\"Pacote inválido\"}");
    return;
  }

  String comando = pacoteRecebido.substring(0, 35);
  String nonce = pacoteRecebido.substring(35, 51);
  String assinatura = pacoteRecebido.substring(51, 115);

  Serial.println("Comando: " + comando);
  Serial.println("Nonce: " + nonce);
  Serial.println("Assinatura: " + assinatura);

  if (!validarSeguranca(comando, nonce, assinatura)) return;

  if (comandoValido(comando, ligarAr, 7)) {
    digitalWrite(PINO_LED_AR, HIGH);
    arLigado = true; // ← AQUI
    server.send(200, "application/json", "{\"status\":\"" + String(TOKEN_AR_LIGADO) + "\"}");
  } else if (comandoValido(comando, desligarAr, 7)) {
    digitalWrite(PINO_LED_AR, LOW);
    arLigado = false; // ← AQUI
    server.send(200, "application/json", "{\"status\":\"" + String(TOKEN_AR_DESLIGADO) + "\"}");
  }
}

  void handleTemperaturaAr() {
    String pacoteRecebido = server.arg("d1");

    if (pacoteRecebido.length() < 1 + 16 + 64) {
      server.send(403, "application/json", "{\"status\":\"Pacote inválido\"}");
      return;
    }

    String valorTexto = pacoteRecebido.substring(0, pacoteRecebido.length() - 80);
    String nonce = pacoteRecebido.substring(pacoteRecebido.length() - 80, pacoteRecebido.length() - 64);
    String assinatura = pacoteRecebido.substring(pacoteRecebido.length() - 64);

    Serial.println("Temperatura | Valor: " + valorTexto);
    Serial.println("Nonce: " + nonce);
    Serial.println("Assinatura: " + assinatura);

    if (!validarSeguranca(valorTexto, nonce, assinatura)) return;

    int temperatura = valorTexto.toInt();
    if (temperatura >= 16 && temperatura <= 30) {
      temperaturaAlvo = temperatura;  // <-- Salva globalmente
      Serial.println("Temperatura ajustada para: " + String(temperaturaAlvo));
      tocarBuzzer();
      server.send(200, "application/json", "{\"status\":\"temp_ok\"}");
    } else {
      server.send(403, "application/json", "{\"status\":\"temp_invalida\"}");
    }

  }
  //#endregion

void setup() {
  Serial.begin(115200);
  delay(2000);
  Serial.println("Iniciando setup...");

  dht.begin();
  pinMode(PINO_JANELA, OUTPUT);
  pinMode(PINO_LAMPADA, OUTPUT);
  pinMode(PINO_LED_VENTILADOR, OUTPUT);
  pinMode(PINO_AR, OUTPUT);
  pinMode(PINO_LED_AR, OUTPUT);
  pinMode(PINO_SENSOR_CHUVA, INPUT);

  servoFechadura.attach(PINO_SERVO_FECHADURA);
  servoJanela.attach(PINO_SERVO_JANELA);

  Serial.println("Configurando Wi-Fi...");
  WiFi.begin(ssid, password);

  Serial.print("Conectando ao Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWi-Fi conectado!");
  Serial.println(WiFi.localIP());

  server.on("/gh77", HTTP_POST, handleJanela);
  server.on("/tf52", HTTP_POST, handleLampada);
  server.on("/hv21", HTTP_POST, handleVentilador);
  server.on("/dr38", HTTP_POST, handleArCondicionado);
  server.on("/rg46", HTTP_POST, handleServoFechadura); 
  server.on("/vit22", HTTP_POST, handleTemperaturaAr); 
  server.on("/fk77", HTTP_POST, handleReforcoSensor);
  server.on("/op63", HTTP_POST, handleServoJanela); 

  server.begin();
  Serial.println("Servidor HTTP iniciado!");
  Serial.println(WiFi.localIP());
}


  void loop() {
    verificarSensorUmidade();
    verificarSensorTemperatura();
    server.handleClient();
  }
  //#endregion
