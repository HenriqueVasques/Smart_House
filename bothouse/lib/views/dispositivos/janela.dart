import 'package:flutter/material.dart';

class JanelaPage extends StatefulWidget {
  final String comodoId;
  final String dispositivoNome;

  const JanelaPage({
    Key? key, 
    required this.comodoId,
    required this.dispositivoNome,
  }) : super(key: key);

  @override
  State<JanelaPage> createState() => _JanelaPageState();
}

class _JanelaPageState extends State<JanelaPage> {
  //#region Variáveis de Estado
  String _abertura = '50%';
  bool _isClosed = true;
  double _aberturaSlider = 50; 
  //#endregion

  //#region Métodos de Atualização
  void _alternarJanela() {
    setState(() {
      _isClosed = !_isClosed;
      if (_isClosed) {
        _aberturaSlider = 0;
        _abertura = '0%';
      } else {
        _aberturaSlider = 100;
        _abertura = '100%';
      }
    });
  }

  void _atualizarAbertura(double novoValor) {
    setState(() {
      _aberturaSlider = novoValor;
      _abertura = '${novoValor.toInt()}%';
      _isClosed = novoValor == 0;
    });
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSliderAbertura(),
                  _buildBotaoJanela(),
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
          Icon(Icons.window, color: Colors.white),
          SizedBox(width: 10),
          Text(
            'Janela Inteligente',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildIconePrincipal() {
    return Icon(
      _isClosed ? Icons.window : Icons.window_outlined,
      size: 60,
      color: _isClosed ? Colors.red : Colors.green,
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

  Widget _buildSliderAbertura() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nível de Abertura: $_abertura',
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
            max: 100,
            value: _aberturaSlider,
            onChanged: _atualizarAbertura,
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoJanela() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: _alternarJanela,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: _isClosed ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _isClosed ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
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
                  _isClosed ? Icons.window : Icons.window_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  _isClosed ? 'FECHADA' : 'ABERTA',
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