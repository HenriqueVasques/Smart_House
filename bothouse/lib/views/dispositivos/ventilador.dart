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
  double _velocidadeSlider = 2; // 1-3 representando Baixa, Média, Alta
  String _modo = 'Normal';
  String _timer = 'Desligado';
  bool _isPowerOn = false;
  bool _isOscilando = false;
  //#endregion

  //#region Métodos de Atualização
  void _atualizarVelocidade(double novaVelocidade) {
    setState(() {
      _velocidadeSlider = novaVelocidade;
    });
  }

  void _alternarOscilacao() {
    setState(() {
      _isOscilando = !_isOscilando;
    });
  }

  void _atualizarTimer(String novoTimer) {
    setState(() {
      _timer = novoTimer;
    });
  }

  void _atualizarModo(String novoModo) {
    setState(() {
      _modo = novoModo;
    });
  }

  void _alternarPower() {
    setState(() {
      _isPowerOn = !_isPowerOn;
    });
  }

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
            const SizedBox(height: 50),
            _buildIconePrincipal(),
            const SizedBox(height: 60),
            _buildInfoText(),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGridBotoes(),
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

  Widget _buildIconePrincipal() {
    return AnimatedRotation(
      duration: const Duration(seconds: 3),
      turns: _isPowerOn && _isOscilando ? 1 : 0,
      child: const Icon(
        Icons.air,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildGridBotoes() {
    return Container(
      height: 280,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildBotaoGrid('Modo', _modo, ['Normal', 'Natural', 'Noturno', 'Eco'], _atualizarModo),
                _buildBotaoOscilacao(),
                _buildBotaoGrid('Timer', _timer, ['Desligado', '30min', '1h', '2h', '4h'], _atualizarTimer),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildBotaoOscilacao() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onTap: _alternarOscilacao,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
              border: _isOscilando ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Oscilação',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.sync,
                  color: _isOscilando ? Colors.blue : Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  _isOscilando ? 'ON' : 'OFF',
                  style: TextStyle(
                    color: _isOscilando ? Colors.blue : Colors.white,
                    fontSize: 16,
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

  Widget _buildInfoText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Modo: $_modo | Velocidade: $_velocidadeTexto | Timer: $_timer | Oscilação: ${_isOscilando ? "On" : "Off"}',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
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