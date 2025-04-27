//#region Imports
import 'package:bothouse/servicos/wifi_servicos.dart';
import 'package:flutter/material.dart';
//#endregion

class FechaduraPage extends StatefulWidget {
  final String comodoId;
  final String dispositivoNome;

  const FechaduraPage({
    Key? key,
    required this.comodoId,
    required this.dispositivoNome,
  }) : super(key: key);

  @override
  State<FechaduraPage> createState() => _FechaduraPageState();
}

class _FechaduraPageState extends State<FechaduraPage> {
  //#region Variáveis de Estado
  final WifiServicos _wifiServicos = WifiServicos();

  String _autoLock = '30s';
  bool _isLocked = true;
  bool _silentMode = false;
  double _volumeSlider = 2;
  //#endregion

  //#region Métodos de Atualização
  Future<void> _alternarFechadura() async {
    setState(() {
      _isLocked = !_isLocked;
    });

    List<String> listaCaracteres = _isLocked
        ? ['Z', '#', '9', 'x', '\$', '%', '2'] // Trancar (fechar)
        : ['G', 'M', '!', '0', '@', 'a', '&']; // Destrancar (abrir)

    String caractereSelecionado = (listaCaracteres.toList()..shuffle()).first;

    await _wifiServicos.enviarComando(
      rotaCodificada: 'by03', // Rota codificada da fechadura no ESP32
      caractereChave: caractereSelecionado,
    );
  }

  void _alternarModoSilencioso() {
    setState(() {
      _silentMode = !_silentMode;
    });
  }

  void _atualizarAutoLock(String novoTimer) {
    setState(() {
      _autoLock = novoTimer;
    });
  }

  void _atualizarVolume(double novoVolume) {
    setState(() {
      _volumeSlider = novoVolume;
    });
  }

  String get _volumeTexto {
    if (_volumeSlider == 0) return 'Mudo';
    if (_volumeSlider <= 1) return 'Baixo';
    if (_volumeSlider <= 2) return 'Médio';
    return 'Alto';
  }
  //#endregion

  //#region Build
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
                  _buildSliderVolume(),
                  _buildBotaoFechadura(),
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

  //#region AppBar
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
          Icon(Icons.lock, color: Colors.white),
          SizedBox(width: 10),
          Text('Fechadura', style: TextStyle(color: Colors.white)),
        ],
      ),
      centerTitle: true,
    );
  }
  //#endregion

  //#region Widgets da Tela
  Widget _buildIconePrincipal() {
    return Icon(
      _isLocked ? Icons.lock : Icons.lock_open,
      size: 60,
      color: _isLocked ? Colors.red : Colors.green,
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
                _buildBotaoSilencioso(),
                _buildBotaoGrid('Auto Lock', _autoLock, ['Off', '30s', '1min', '5min'], _atualizarAutoLock),
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

  Widget _buildBotaoSilencioso() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onTap: _alternarModoSilencioso,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
              border: _silentMode ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Modo Silencioso', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 2),
                Icon(
                  _silentMode ? Icons.volume_off : Icons.volume_up,
                  color: _silentMode ? Colors.blue : Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  _silentMode ? 'ON' : 'OFF',
                  style: TextStyle(
                    color: _silentMode ? Colors.blue : Colors.white,
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
    );
  }

  Widget _buildSliderVolume() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Volume do Beep: $_volumeTexto',
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
            min: 0,
            max: 3,
            divisions: 3,
            value: _volumeSlider,
            onChanged: _atualizarVolume,
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoFechadura() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: _alternarFechadura,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: _isLocked ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _isLocked ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
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
                  _isLocked ? Icons.lock : Icons.lock_open,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  _isLocked ? 'TRANCADO' : 'DESTRANCADO',
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
