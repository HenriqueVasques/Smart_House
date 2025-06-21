//controladorDispositos.dart

//#region Imports
import 'package:http/http.dart' as http;
import 'dart:math';
//#endregion

//#region Controlador de Dispositivos
class ControladorDispositivos {
  //#region Configurações
  final String baseUrl = 'http://192.168.0.16'; // IP fixo do ESP32
  final int payloadLength = 35; // Tamanho total da mensagem
  final int keyPosition = 12; // Posição fixa do caractere-chave
  final Random random = Random();
  //#endregion

  //#region Caracteres válidos por ação
  final List<String> abrirPortaChars = ['G', 'M', '!', '0', '@', 'a', '&'];
  final List<String> fecharPortaChars = ['Z', '#', '9', 'x', '\$', '%', '2'];

  final List<String> abrirJanelaChars = ['U', 'V', 'W', '*', 'b', 'N', '^'];
  final List<String> fecharJanelaChars = ['Q', 'E', 'L', '1', '(', '=', ']'];

  final List<String> ligarLuzChars = ['T', 'K', '3', 'P', 'r', '+', 'H'];
  final List<String> desligarLuzChars = ['D', '8', '!', '~', 'Y', '{', '4'];
  //#endregion

  //#region Gerador de Mensagens
  String _gerarPayload(String caractereChave) {
    const caracteresPermitidos =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#\$%&*!+';
    String payload = '';

    for (int i = 0; i < payloadLength; i++) {
      if (i == keyPosition) {
        payload += caractereChave;
      } else {
        payload += caracteresPermitidos[random.nextInt(caracteresPermitidos.length)];
      }
    }
    return payload;
  }
  //#endregion

  //#region Funções principais
  Future<void> abrirPorta() async {
    await _enviarComando('/by03', abrirPortaChars);
  }

  Future<void> fecharPorta() async {
    await _enviarComando('/by03', fecharPortaChars);
  }

  Future<void> abrirJanela() async {
    await _enviarComando('/gh77', abrirJanelaChars);
  }

  Future<void> fecharJanela() async {
    await _enviarComando('/gh77', fecharJanelaChars);
  }

  Future<void> ligarLuz() async {
    await _enviarComando('/tf52', ligarLuzChars);
  }

  Future<void> desligarLuz() async {
    await _enviarComando('/tf52', desligarLuzChars);
  }
  //#endregion

  //#region Função de envio
  Future<void> _enviarComando(String rota, List<String> listaCaracteres) async {
    final caractereSelecionado = listaCaracteres[random.nextInt(listaCaracteres.length)];
    final payload = _gerarPayload(caractereSelecionado);

    final url = Uri.parse('$baseUrl$rota');

    try {
      final resposta = await http.post(url, body: {'msg': payload});
      if (resposta.statusCode == 200) {
        print('✅ Comando enviado com sucesso!');
      } else {
        print('⚠️ Erro ao enviar comando: ${resposta.statusCode}');
      }
    } catch (e) {
      print('❌ Erro de conexão: $e');
    }
  }
  //#endregion
}
//#endregion
