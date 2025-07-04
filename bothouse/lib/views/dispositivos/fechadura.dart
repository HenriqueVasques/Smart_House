//#region Imports
import 'package:bothouse/servicos/wifi_servicos.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Adicionado import do SharedPreferences
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

  bool _isLocked = true;
  late SharedPreferences _prefs; // Adicionada variável para SharedPreferences
  late String _lockKey; // Chave para salvar o estado da fechadura
  //#endregion

  //#region Ciclo de Vida
  @override
  void initState() {
    super.initState();
    _lockKey = 'lock_${widget.comodoId}_${widget.dispositivoNome}';
    _carregarEstado();
  }

  Future<void> _carregarEstado() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocked = _prefs.getBool(_lockKey) ?? true; // Por padrão a fechadura está trancada
    });
  }
  //#endregion

  //#region Métodos de Atualização
  Future<void> _alternarFechadura() async {
    setState(() {
      _isLocked = !_isLocked;
    });

    // Salva o estado localmente
    await _prefs.setBool(_lockKey, _isLocked);

    // Define o ângulo do servo motor
    int angulo = _isLocked ? 90 : 180;

    await _wifiServicos.enviarValor(
      rotaCodificada: 'rg46',
      valor: angulo,
    );
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