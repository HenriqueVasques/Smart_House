//ventilador.dart
import 'package:bothouse/servicos/wifi_servicos.dart';
import 'package:flutter/material.dart';

class VentiladorPage extends StatefulWidget {
  final String comodoId;
  final String dispositivoNome;

  const VentiladorPage({
    Key? key, 
    required this.comodoId,
    required this.dispositivoNome,
  }) : super(key: key);

  @override
  State<VentiladorPage> createState() => _VentiladorPageState();
}

class _VentiladorPageState extends State<VentiladorPage> {
  //#region Variáveis de Estado
  final WifiServicos _wifiServicos = WifiServicos(); 
  double _velocidadeSlider = 1; // 1-3 representando Baixa, Média, Alta
  bool _isPowerOn = false;
  //#endregion

  //#region Métodos de Atualização
  void _atualizarVelocidade(double novaVelocidade) async {
  setState(() {
    _velocidadeSlider = novaVelocidade;
  });

  int valorVelocidade = novaVelocidade.toInt(); // 1, 2 ou 3

  await _wifiServicos.enviarValor(
    rotaCodificada: 'hv21', // rota do ventilador
    valor: valorVelocidade,
  );
}

  //#region Alternar Power com comando dinâmico
    Future<void> _alternarPower() async {
      setState(() {
        _isPowerOn = !_isPowerOn;
      });

      List<String> listaCaracteres = _isPowerOn
          ? ['h', 'o', '9', '#', 'r', '6', 'F'] // Caracteres para LIGAR o ventilador
          : ['G', ',', '%', '~','T', 'j', '5']; // Caracteres para DESLIGAR o ventilador

      // Escolhe um caractere aleatório da lista
      String caractereSelecionado = (listaCaracteres.toList()..shuffle()).first;

      await _wifiServicos.enviarComando(
        rotaCodificada: 'hv21', // Rota codificada do ar-condicionado no ESP32
        caractereChave: caractereSelecionado,
      );
    }
    //#endregion

  String get _velocidadeTexto {
    if (_velocidadeSlider <= 1.5) return 'Baixa';
    if (_velocidadeSlider <= 2.5) return 'Média';
    return 'Alta';
  }
  //#endregion

  //#region Método Principal de Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 32, 32),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildInfoText(),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSliderVelocidade(),
                  _buildBotaoPower(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  //#endregion

  //#region Componentes da Interface
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 39, 32, 32),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.air, color: Colors.white),
          SizedBox(width: 10),
          Text(
            'Ventilador',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildBotaoGrid(String titulo, String valorAtual, List<String> opcoes, Function(String) onChanged) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onTap: () {
            int index = opcoes.indexOf(valorAtual);
            String novoValor = opcoes[(index + 1) % opcoes.length];
            onChanged(novoValor);          
          },
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  valorAtual,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildSliderVelocidade() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Velocidade: $_velocidadeTexto',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF4FDFFF),
            inactiveTrackColor: Colors.grey[800],
            thumbColor: Colors.white,
            overlayColor: Colors.blue.withOpacity(0.3),
            trackHeight: 4.0,
          ),
          child: Slider(
            min: 1,
            max: 3,
            divisions: 2,
            value: _velocidadeSlider,
            onChanged: _atualizarVelocidade,
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoPower() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: _alternarPower,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: _isPowerOn ? Colors.blue : Colors.grey[850],
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _isPowerOn ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  _isPowerOn ? 'LIGADO' : 'DESLIGADO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  //#endregion
}