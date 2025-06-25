// ar_condicionado.dart
// ar_condicionado.dart
//#region Imports
import 'package:bothouse/servicos/wifi_servicos.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//#endregion

//#region ArCondicionadoPage
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
//#endregion

//#region State
class _ArCondicionadoPageState extends State<ArCondicionadoPage> {
  //#region Variáveis de Estado
  final WifiServicos _wifiServicos = WifiServicos();

  String _modoSelecionado = 'Cool';
  String _velocidade = 'Média';
  String _timer = 'Off';
  double _temperatura = 23;
  bool _isPowerOn = false;
  late SharedPreferences _prefs; // Adicionada variável para SharedPreferences
  late String _powerKey; // Chave para salvar o estado de power
  late String _temperaturaKey; // Chave para salvar a temperatura
  //#endregion
  
  //#region Ciclo de Vida
  @override
  void initState() {
    super.initState();
    _powerKey = 'power_${widget.comodoId}_${widget.dispositivoNome}';
    _temperaturaKey = 'temperatura_${widget.comodoId}_${widget.dispositivoNome}';
    _carregarEstado();
    _carregarTemperatura();
  }

  Future<void> _carregarEstado() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPowerOn = _prefs.getBool(_powerKey) ?? false;
    });
  }

  Future<void> _carregarTemperatura() async {
    final prefs = await SharedPreferences.getInstance();
    final valorSalvo = prefs.getDouble(_temperaturaKey);
    if (valorSalvo != null) {
      setState(() {
        _temperatura = valorSalvo.clamp(16.0, 30.0);
      });
    }
  }
  //#endregion

  //#region Métodos de Atualização
  Future<void> _atualizarTemperatura(double novaTemp) async {
    if (novaTemp < 16 || novaTemp > 30) return; 
    setState(() {
      _temperatura = novaTemp;
    });

    await _salvarTemperatura(novaTemp);

    // Enviar temperatura atual para o ESP32 (aciona o buzzer também)
    await _wifiServicos.enviarValor(
      rotaCodificada: 'vit22', 
      valor: novaTemp.toInt(), 
    );
  }

  Future<void> _salvarTemperatura(double valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_temperaturaKey, valor);
  }

  //#region Alternar Power com comando dinâmico
  Future<void> _alternarPower() async {
    setState(() {
      _isPowerOn = !_isPowerOn;
    });

    // Salva o estado localmente
    await _prefs.setBool(_powerKey, _isPowerOn);

    List<String> listaCaracteres = _isPowerOn
        ? ['F', 'K', '9', '!', 'r', '+', 'k'] 
        : ['p', '8', '%', '~', 's', '{', '4']; 

    // Escolhe um caractere aleatório da lista
    String caractereSelecionado = (listaCaracteres.toList()..shuffle()).first;

    await _wifiServicos.enviarComando(
      rotaCodificada: 'dr38', 
      caractereChave: caractereSelecionado,
    );
  }
  //#endregion
  
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
                    _buildSliderTemperatura(),
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
            Icon(Icons.ac_unit, color: Colors.white),
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
        Icons.ac_unit,
        size: 60, 
        color: Colors.white,
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
          'Modo: $_modoSelecionado | Velocidade: $_velocidade | Timer: $_timer | Temperatura: ${_temperatura.toStringAsFixed(0)}°C',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
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

    Widget _buildBotaoTemperatura() {
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
              'Temperatura',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                  onPressed: () => _atualizarTemperatura(_temperatura - 1),
                ),
                Text(
                  '${_temperatura.toStringAsFixed(0)}°C',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
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

    Widget _buildHeaderSection() {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo: $_modoSelecionado',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Velocidade: $_velocidade',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const Icon(
                Icons.ac_unit,
                size: 60,
                color: Colors.white,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Timer: $_timer',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_temperatura.toStringAsFixed(0)}°C',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
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
        child: GestureDetector(
          onTap: _alternarPower,
          child: Container(
            height: 60, // Botão maior
            decoration: BoxDecoration(
              color: _isPowerOn ? Colors.blue : Colors.grey[850],
              borderRadius: BorderRadius.circular(30), // Mais arredondado
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