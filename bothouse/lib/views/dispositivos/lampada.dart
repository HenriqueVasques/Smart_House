import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Necessário para o CupertinoSwitch

class LampadaPage extends StatefulWidget {
  final String comodoId;
  final String dispositivoNome;

  const LampadaPage({
    Key? key, 
    required this.comodoId,
    required this.dispositivoNome,
  }) : super(key: key);

  @override
  State<LampadaPage> createState() => _LampadaPageState();
}

class _LampadaPageState extends State<LampadaPage> {
  //#region Variáveis de Estado
  String _corSelecionada = 'Branco';
  String _efeito = 'Nenhum';
  String _programacao = 'Off';
  double _intensidade = 70;
  bool _isPowerOn = false;
  //#endregion

  //#region Métodos de Atualização
  void _atualizarIntensidade(double novaIntensidade) {
    setState(() {
      _intensidade = novaIntensidade.clamp(0, 100);
    });
  }

  void _alternarPower() {
    setState(() {
      _isPowerOn = !_isPowerOn;
    });
  }

  void _atualizarCor(String cor) {
    setState(() {
      _corSelecionada = cor;
    });
  }

  void _atualizarEfeito(String efeito) {
    setState(() {
      _efeito = efeito;
    });
  }

  void _atualizarProgramacao(String programacao) {
    setState(() {
      _programacao = programacao;
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
            _buildInfoText(),
            const SizedBox(height: 0),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGridBotoes(),
                  _buildSliderIntensidade(),
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
          Icon(Icons.lightbulb, color: Colors.white),
          SizedBox(width: 10),
          Text(
            'Lâmpada',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildIconePrincipal() {
    return const Icon(
      Icons.lightbulb_outline,
      size: 60,
      color: Colors.white,
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
                _buildBotaoGrid('Cor', _corSelecionada, ['Branco', 'Amarelo', 'Azul', 'Verde'], _atualizarCor),
                _buildBotaoGrid('Efeito', _efeito, ['Nenhum', 'Pulsar', 'Rainbow', 'Festa'], _atualizarEfeito),
                _buildBotaoGrid('Timer', _programacao, ['Off', '30min', '1h', '2h'], _atualizarProgramacao),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildBotaoIntensidade(),
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

  Widget _buildBotaoIntensidade() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Intensidade',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                onPressed: () => _atualizarIntensidade(_intensidade - 10),
              ),
              Text(
                '${_intensidade.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () => _atualizarIntensidade(_intensidade + 10),
              ),
            ],
          ),
        ],
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
        'Cor: $_corSelecionada | Efeito: $_efeito | Timer: $_programacao',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSliderIntensidade() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_intensidade.toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFFFFEB3B),
            inactiveTrackColor: Colors.grey[800],
            thumbColor: Colors.white,
            overlayColor: Colors.yellow.withOpacity(0.3),
            trackHeight: 4.0,
          ),
          child: Slider(
            min: 0,
            max: 100,
            value: _intensidade,
            onChanged: _atualizarIntensidade,
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