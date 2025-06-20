//#region Imports
import 'package:bothouse/servicos/firebase_servicos.dart';
import 'package:bothouse/servicos/wifi_servicos.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:bothouse/servicos/sensor_umidade_controller.dart';
//#endregion

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
  final WifiServicos _wifiServicos = WifiServicos();
  final SensorUmidadeController _sensorController = SensorUmidadeController();

  String _abertura = '50%';
  bool _isClosed = true;
  double _aberturaSlider = 50;
  late SharedPreferences _prefs;
  late String _closedKey;
  late String _aberturaKey;
  late String _ignorarSensorKey;
  //#endregion

  //#region Ciclo de Vida
  @override
  void initState() {
    super.initState();
    _closedKey = 'closed_${widget.comodoId}_${widget.dispositivoNome}';
    _aberturaKey = 'abertura_${widget.comodoId}_${widget.dispositivoNome}';
    _ignorarSensorKey = 'ignorarSensor_${widget.comodoId}_${widget.dispositivoNome}';
    _carregarEstado().then((_) {
      _sensorController.escutarSensorUmidade(
        comodoId: widget.comodoId,
        onSensorMolhado: () {
          if (!_isClosed) {
            _alternarJanela();
          }
        },
      );
    });
  }
  //#endregion

  //#region Firestore Helper
  DocumentReference<Map<String, dynamic>> get _comodoRef {
    final user = FirebaseServicos().currentUser;
    if (user == null) {
      throw Exception("Usuário não logado");
    }
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('comodos')
        .doc(widget.comodoId);
  }
  //#endregion

  //#region Estado da Janela
  Future<void> _carregarEstado() async {
    _prefs = await SharedPreferences.getInstance();
    final aberturaValor = _prefs.getDouble(_aberturaKey);
    if (aberturaValor != null) {
      setState(() {
        _aberturaSlider = aberturaValor.clamp(0, 100);
        _abertura = '${_aberturaSlider.toInt()}%';
      });
    }
    final fechadoSalvo = _prefs.getBool(_closedKey);
    if (fechadoSalvo != null) {
      setState(() {
        _isClosed = fechadoSalvo;
        if (_isClosed && _aberturaSlider > 0) {
          _aberturaSlider = 0;
          _abertura = '0%';
          _salvarAbertura(0);
        } else if (!_isClosed && _aberturaSlider == 0) {
          _aberturaSlider = 100;
          _abertura = '100%';
          _salvarAbertura(100);
        }
      });
    } else {
      setState(() {
        _isClosed = _aberturaSlider == 0;
      });
    }
  }

  Future<void> _salvarAbertura(double valor) async {
    await _prefs.setDouble(_aberturaKey, valor);
  }

  void _atualizarAbertura(double novoValor) async {
    setState(() {
      _aberturaSlider = novoValor;
      _abertura = '${novoValor.toInt()}%';
      _isClosed = novoValor == 0;
    });
    await _salvarAbertura(novoValor);
    await _prefs.setBool(_closedKey, _isClosed);
  }
  //#endregion

  //#region Abertura Manual com Verificação
  void _verificarSensorAntesDeAbrir() async {
    final molhado = await _sensorController.consultarSensorNoFirebase(widget.comodoId);
    final agora = DateTime.now().millisecondsSinceEpoch;
    final ignorarAte = _prefs.getInt(_ignorarSensorKey) ?? 0;
    final estaIgnorando = agora < ignorarAte;

    if (!molhado || estaIgnorando) {
      _alternarJanela();
      return;
    }

    final desejaAbrir = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Possível chuva detectada'),
        content: const Text('O sensor detectou umidade. Deseja abrir a janela mesmo assim?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );

    if (desejaAbrir == true) {
      final ignorarAte = DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch;
      await _prefs.setInt(_ignorarSensorKey, ignorarAte);
      _alternarJanela();
      Future.delayed(const Duration(minutes: 10), () async {
        await _sensorController.verificarSensorUmidadeESP32();
      });
    }
  }
  //#endregion

  //#region Abertura e Fechamento
  Future<void> _alternarJanela() async {
    setState(() {
      _isClosed = !_isClosed;
      _aberturaSlider = _isClosed ? 0 : 100;
      _abertura = '${_aberturaSlider.toInt()}%';
    });
    await _prefs.setBool(_closedKey, _isClosed);
    await _salvarAbertura(_aberturaSlider);

    List<String> listaCaracteres = _isClosed
        ? ['Q', 'E', 'L', '1', '(', '=', ']']
        : ['U', 'V', 'W', '*', 'b', 'N', '^'];

    String caractereSelecionado = (listaCaracteres.toList()..shuffle()).first;

    await _wifiServicos.enviarComando(
      rotaCodificada: 'gh77',
      caractereChave: caractereSelecionado,
    );
  }
  //#endregion

  //#region Interface (UI)
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
          Text('Janela Inteligente', style: TextStyle(color: Colors.white)),
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

  Widget _buildSliderAbertura() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Nível de Abertura: $_abertura', style: const TextStyle(color: Colors.white)),
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
