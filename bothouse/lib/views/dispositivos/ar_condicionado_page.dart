import 'package:flutter/material.dart';

class ArCondicionadoPage extends StatefulWidget {
  final String comodoId;
  final String dispositivoNome;

  const ArCondicionadoPage({
    Key? key, 
    required this.comodoId,
    required this.dispositivoNome,
  }) : super(key: key);

  @override
  State<ArCondicionadoPage> createState() => _ArCondicionadoPageState();
}

class _ArCondicionadoPageState extends State<ArCondicionadoPage> {
  //#region Variáveis de Estado
  String _modoSelecionado = 'Cool';
  String _velocidade = 'Média';
  String _timer = 'Off';
  double _temperatura = 23;
  bool _isPowerOn = false;
  //#endregion

  //#region Métodos de Atualização
  void _atualizarTemperatura(double novaTemp) {
    setState(() {
      _temperatura = novaTemp;
    });
  }

  void _alternarPower() {
    setState(() {
      _isPowerOn = !_isPowerOn;
    });
  }

  void _atualizarModo(String modo) {
    setState(() {
      _modoSelecionado = modo;
    });
  }

  void _atualizarVelocidade(String velocidade) {
    setState(() {
      _velocidade = velocidade;
    });
  }

  void _atualizarTimer(String timer) {
    setState(() {
      _timer = timer;
    });
  }
  //#endregion

  //#region Método Principal de Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildIconePrincipal(),
              const SizedBox(height: 120),
              _buildGridBotoes(),
              const SizedBox(height: 20),
              _buildInfoText(),
              const SizedBox(height: 30),
              _buildSliderTemperatura(),
              const SizedBox(height: 30),
              _buildBotaoPower(),
            ],
          ),
        ),
      ),
    );
  }
  //#endregion

  //#region Componentes da Interface
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E1E1E),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.ac_unit, color: Colors.white), // TODO: Substituir pelo ícone real
          SizedBox(width: 10),
          Text(
            'Ar Condicionado',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildIconePrincipal() {
    return const Icon(
      Icons.ac_unit, // TODO: Substituir pelo ícone real do ar condicionado
      size: 85,
      color: Colors.white,
    );
  }

  Widget _buildGridBotoes() {
    return Container(
      height: 480,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildBotaoGrid('Modo', _modoSelecionado, ['Cool', 'Heat', 'Fan', 'Auto'], _atualizarModo),
                _buildBotaoGrid('Velocidade', _velocidade, ['Baixa', 'Média', 'Alta'], _atualizarVelocidade),
                _buildBotaoGrid('Timer', _timer, ['Off', '30min', '1h', '2h'], _atualizarTimer),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildBotaoTemperatura(),
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
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  valorAtual,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoTemperatura() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Temperatura',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                onPressed: () => _atualizarTemperatura(_temperatura - 1),
              ),
              Text(
                '${_temperatura.toStringAsFixed(0)}°C',
                style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () => _atualizarTemperatura(_temperatura + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        'Modo: $_modoSelecionado | Velocidade: $_velocidade | Timer: $_timer',
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  Widget _buildSliderTemperatura() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_temperatura.toStringAsFixed(0)}°C',
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
            min: 16,
            max: 30,
            value: _temperatura,
            onChanged: _atualizarTemperatura,
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoPower() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isPowerOn ? Colors.blue : Colors.grey[850],
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _alternarPower,
        child: Text(
          _isPowerOn ? 'ON' : 'OFF',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  //#endregion
}