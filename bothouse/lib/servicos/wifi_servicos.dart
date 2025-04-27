import 'dart:convert';
import 'package:http/http.dart' as http;

class WifiServicos {
  final String baseUrl = "http://192.168.4.1"; // IP fixo do ESP32

  final List<String> caracteresValidos = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
    'a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z',
    '0','1','2','3','4','5','6','7','8','9',
    '@', '#', '\$', '%', '&', '*', '!', '+', '^', '(', ')', '-', '_', '=', '~'
  ];

  final int keyPosition = 12;

  /// Gera um comando seguro codificado
  String gerarComandoSeguro(String caractereChave) {
    List<String> comando = List.generate(35, (index) {
      return caracteresValidos[(DateTime.now().microsecond + index) % caracteresValidos.length];
    });
    comando[keyPosition] = caractereChave;
    return comando.join();
  }

  /// Testa conexão com o ESP32
  Future<bool> testarConexao() async {
    try {
      final resposta = await http.get(Uri.parse(baseUrl));
      return resposta.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Envia comando codificado (ex: ligar ou desligar dispositivo)
  Future<String?> enviarComando({
    required String rotaCodificada,
    required String caractereChave,
  }) async {
    String comandoSeguro = gerarComandoSeguro(caractereChave);

    try {
      final resposta = await http.post(
        Uri.parse("$baseUrl/$rotaCodificada"),
        body: {"msg": comandoSeguro},
      );

      if (resposta.statusCode == 200) {
        final dados = json.decode(resposta.body);
        return dados["status"]; // Retorna o token de sucesso (ex: W9#Z8@)
      } else {
        print("Erro na resposta HTTP: ${resposta.statusCode}");
        return null;
      }
    } catch (e) {
      print("Erro ao enviar comando: $e");
      return null;
    }
  }

  /// Envia valor simples (ex: valor de slider de intensidade)
  Future<void> enviarValor({
    required String rotaCodificada,
    required int valor,
  }) async {
    try {
      final resposta = await http.post(
        Uri.parse("$baseUrl/$rotaCodificada"),
        body: {"msg": valor.toString()},
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
}
