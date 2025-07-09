import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bothouse/segredos.dart';

class ClimaModel {
  final double temperatura;
  final String descricao;

  ClimaModel({required this.temperatura, required this.descricao});
}

class ClimaServico {
  final String apiKey = Segredos.openWeatherApiKey;
  final String cidade = 'Mirassol,BR';
  final String unidade = 'metric';

  Future<ClimaModel?> buscarClimaAtual() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$cidade&units=$unidade&lang=pt_br&appid=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        final temp = dados['main']['temp']?.toDouble();
        final desc = dados['weather'][0]['description'];
        return ClimaModel(temperatura: temp, descricao: desc);
      } else {
        print('Erro API: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return null;
    }
  }
}
