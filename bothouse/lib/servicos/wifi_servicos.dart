//#region Imports
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
//#endregion

class WifiServicos {
  //#region Configurações
  final String baseUrl = "http://172.20.10.2"; // IP fixo do ESP32
  final String chaveSecreta = "5fA9#zL3pW!c@Kq*4tE1vX8g^mN0dRb2";

  final List<String> caracteresValidos = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
    'a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z',
    '0','1','2','3','4','5','6','7','8','9',
    '@', '#', '\$', '%', '&', '*', '!', '+', '^', '(', ')', '-', '_', '=', '~'
  ];

  final int keyPosition = 12;
  //#endregion

  //#region Funções de Segurança
  String gerarComandoSeguro(String caractereChave) {
    List<String> comando = List.generate(35, (index) {
      return caracteresValidos[(DateTime.now().microsecond + index) % caracteresValidos.length];
    });
    comando[keyPosition] = caractereChave;
    return comando.join();
  }

  String gerarNonce() {
    final random = Random.secure();
    return List<int>.generate(8, (_) => random.nextInt(256))
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join();
  }

String gerarAssinatura(String comando, String nonce) {
  final key = utf8.encode(chaveSecreta); // chave secreta
  final message = utf8.encode(comando + nonce); // comando + nonce
  final hmacSha256 = Hmac(sha256, key); // novo objeto HMAC-SHA256
  final digest = hmacSha256.convert(message);
  return digest.toString();
}
  //#endregion

  //#region Funções Principais
  Future<bool> testarConexao() async {
    try {
      final resposta = await http.get(Uri.parse(baseUrl));
      return resposta.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Envia comando seguro (ligar/desligar dispositivo)
  Future<void> enviarComando({
    required String rotaCodificada,
    required String caractereChave,
  }) async {
    String comandoSeguro = gerarComandoSeguro(caractereChave);
    String nonce = gerarNonce();
    String assinatura = gerarAssinatura(comandoSeguro, nonce);
    String pacoteUnico = comandoSeguro + nonce + assinatura;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$rotaCodificada'),
        body: {
          "d1": pacoteUnico,
        },
      );

      if (response.statusCode == 200) {
        print('✅ Comando enviado com sucesso!');
        print('Resposta do ESP: ${response.body}');
      } else {
        print('⚠️ Erro ao enviar comando: ${response.statusCode}, $pacoteUnico');
      }
    } catch (e) {
      print('❌ Erro de conexão: $e');
    }
  }

  /// Envia valor seguro (ex: intensidade do slider)
  Future<void> enviarValor({
    required String rotaCodificada,
    required int valor,
  }) async {
    String valorTexto = valor.toString();
    String nonce = gerarNonce();
    String assinatura = gerarAssinatura(valorTexto, nonce);
    String pacoteUnico = valorTexto + nonce + assinatura;

    try {
      final resposta = await http.post(
        Uri.parse('$baseUrl/$rotaCodificada'),
        body: {
          "d1": pacoteUnico,
        },
      );

      if (resposta.statusCode == 200) {
        print('✅ Valor enviado com sucesso: $valor');
      } else {
        print('⚠️ Erro ao enviar valor: ${resposta.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao enviar valor: $e');
    }
  }
  //#endregion
}
