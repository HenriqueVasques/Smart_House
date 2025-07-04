//#region Imports
import 'package:bothouse/servicos/wifi_servicos.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bothouse/servicos/ar_condicionado_controller.dart';
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
  final ArCondicionadoController _controller = ArCondicionadoController();
  bool _modoCool = true;
  double _temperatura = 23;
  bool _isPowerOn = false;
  late SharedPreferences _prefs;
  late String _powerKey;
  late String _temperaturaKey;
  late String _modoKey;
  //#endregion

  //#region Ciclo de Vida
  @override
void initState() {
  super.initState();
  _powerKey = 'power_${widget.comodoId}_${widget.dispositivoNome}';
  _temperaturaKey = 'temperatura_${widget.comodoId}_${widget.dispositivoNome}';
  _modoKey = 'modo_${widget.comodoId}_${widget.dispositivoNome}';

  _inicializarPreferencias();
}

Future<void> _inicializarPreferencias() async {
  _prefs = await SharedPreferences.getInstance();

  setState(() {
    _modoCool = _prefs.getBool(_modoKey) ?? true;
    _isPowerOn = _prefs.getBool(_powerKey) ?? false;
    _temperatura = (_prefs.getDouble(_temperaturaKey) ?? 23).clamp(16.0, 30.0);
  });

  _controller.escutarModoCool(
    comodoId: widget.comodoId,
    onModoAlterado: (modo) {
      setState(() {
        _modoCool = modo;
      });
    },
  );
}

  Future<void> _carregarModo() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _modoCool = _prefs.getBool(_modoKey) ?? true;
    });
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

    await _wifiServicos.enviarValor(
      rotaCodificada: 'vit22',
      valor: novaTemp.toInt(),
    );
  }

  Future<void> _salvarTemperatura(double valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_temperaturaKey, valor);
  }

  Future<void> _alternarPower() async {
    setState(() {
      _isPowerOn = !_isPowerOn;
    });

    await _prefs.setBool(_powerKey, _isPowerOn);

    List<String> listaCaracteres = _isPowerOn
        ? ['F', 'K', '9', '!', 'r', '+', 'k']
        : ['p', '8', '%', '~', 's', '{', '4'];

    String caractereSelecionado = (listaCaracteres.toList()..shuffle()).first;

    await _wifiServicos.enviarComando(
      rotaCodificada: 'dr38',
      caractereChave: caractereSelecionado,
    );
  }

  Future<void> _alternarModo() async {
    setState(() {
      _modoCool = !_modoCool;
    });
    await _prefs.setBool(_modoKey, _modoCool);
    await _controller.alterarModoCool(widget.comodoId, _modoCool); // <- agora salva no Firebase
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
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBotaoModo(),
                  _buildBotaoTemperatura(),
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

  //#region Widgets
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
          Text('Ar Condicionado', style: TextStyle(color: Colors.white)),
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

  Widget _buildBotaoModo() {
    return GestureDetector(
      onTap: _alternarModo,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _modoCool ? Colors.teal : Colors.deepOrange,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: _modoCool
                  ? Colors.tealAccent.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mode, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              _modoCool ? 'Modo: COOL' : 'Modo: VENTILADOR',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
                const Icon(Icons.power_settings_new, color: Colors.white, size: 28),
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
