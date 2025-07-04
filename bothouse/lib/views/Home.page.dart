  import 'package:bothouse/servicos/autenticacao_servicos.dart';
  import 'package:bothouse/views/control.page.dart';
  import 'package:flutter/material.dart';
  import 'package:bothouse/servicos/firebase_servicos.dart';
  import 'package:bothouse/servicos/wifi_servicos.dart';
  import 'package:bothouse/servicos/clima_servico.dart';

  double? _temperaturaCidade;
  ClimaModel? _climaAtual;

  ///#region Classes
  class RoomData {
    final String id;
    final String nome;
    final String imagePath;

    RoomData({
      required this.id,
      required this.nome,
    }) : imagePath =
              'assets/images/${nome.toLowerCase()}.png'; 
  }

  class HomePage extends StatefulWidget {
    HomePage({Key? key}) : super(key: key);

    @override
    _HomePageState createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
    final FirebaseServicos _firebaseServicos = FirebaseServicos();
    final ClimaServico _climaServico = ClimaServico();

    @override
    void initState() {
      super.initState();
      _carregarTemperatura();
    }

    ///#endregion

    ///#region clima API
    Future<void> _carregarTemperatura() async {
      final clima = await _climaServico.buscarClimaAtual();
      setState(() {
        _climaAtual = clima;
      });
    }

    ///#endregion
    
    ///#region função capitalize
    String capitalize(String? text) {
      if (text == null || text.isEmpty) return '';
      return text[0].toUpperCase() + text.substring(1);
    }
   ///#endregion

    ///#region Construtores e Build Principal
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background_image.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildMainContent(context),
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      );
    }

    Widget _buildMainContent(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context),
          const SizedBox(height: 20),
          _buildText('Bem-vindo à sua casa inteligente', 16,
              const Color.fromARGB(179, 0, 0, 0)),
          const SizedBox(height: 20),
          _buildTemperatureHumidityCard(),
          const SizedBox(height: 20),
          _buildActiveDevicesCard(),
          const SizedBox(height: 20),
          _buildText('Selecione o Cômodo', 18, const Color.fromARGB(255, 0, 0, 0),
              isBold: true),
          const SizedBox(height: 10),
          _buildRoomGrid(context),
        ],
      );
    }

    ///#endregion

    ///#region Serviços e Métodos de Dados
    Future<int> _calculaTotalDispositivos() =>
        _firebaseServicos.calcularTotalDispositivos();
    Future<List<Map<String, dynamic>>> _buscaComodos() =>
        _firebaseServicos.buscarComodos();

    ///#endregion

    ///#region Componentes de UI Base
    Widget _buildText(String text, double size, Color color,
        {bool isBold = false}) {
      return Text(
        text,
        style: TextStyle(
            fontSize: size,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color),
      );
    }

    Widget _buildCard({required Widget child}) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );
    }

    ///#endregion

    ///#region Componentes do Cabeçalho
    Widget _buildTopBar(BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              icon: const Icon(Icons.logout_rounded,
                  color: Color.fromARGB(255, 131, 131, 131)),
              onPressed: () {
                Navigator.pop(context);
                AutenticacaoServicos().deslogar(context);
              }),
          FutureBuilder<String>(
            future: _firebaseServicos.buscarNomeUsuario(),
            builder: (context, snapshot) => _buildText(
                'Olá ${capitalize(snapshot.data ?? 'Usuário')}',
                20, Colors.white,
                isBold: true),
          ),
        ],
      );
    }

    ///#endregion

    ///#region Cards de Informação
    Widget _buildTemperatureHumidityCard() {
      return _buildCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoColumn(
              'Temperatura',
              _climaAtual != null
                ? '${_climaAtual!.temperatura.toStringAsFixed(1)}°C\n${capitalize(_climaAtual!.descricao)}'
                : 'Carregando...',
              Icons.wb_sunny,
              Colors.yellow
            )

          ],
        ),
      );
    }

    Widget _buildInfoColumn(
        String label, String value, IconData? icon, Color? iconColor) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                _buildText(value, 18, Colors.white, isBold: true),
              ],
            ),
          _buildText(label, 14, Colors.white70),
        ],
      );
    }

    Widget _buildActiveDevicesCard() {
      return FutureBuilder<int>(
        future: _calculaTotalDispositivos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Calculando dispositivos...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ],
              ),
            );
          }

          final totalDispositivos = snapshot.data ?? 0;
          return _buildCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalDispositivos ${totalDispositivos == 1 ? 'Dispositivo Ativo' : 'Dispositivos Ativos'}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          );
        },
      );
    }

    ///#endregion

    ///#region Grid de Cômodos
    Widget _buildRoomGrid(BuildContext context) {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _buscaComodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text('Erro ao carregar cômodos',
                    style: TextStyle(color: Colors.white)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Nenhum cômodo encontrado',
                    style: TextStyle(color: Colors.white)));
          }

          List<RoomData> comodos = snapshot.data!
              .map((comodo) => RoomData(
                    id: comodo['id'],
                    nome: comodo['nome'],
                  ))
              .toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: comodos
                  .map((comodo) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _buildRoomCard(context, comodo),
                      ))
                  .toList(),
            ),
          );
        },
      );
    }

    Widget _buildRoomCard(BuildContext context, RoomData comodo) {
      return Container(
        width: 120,
        height: 180,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  comodo.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child:
                          const Icon(Icons.home, color: Colors.white, size: 40),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comodo.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ControlPage(
                            comodoId: comodo.id,
                            nomeComodo: comodo.nome,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Ver'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    ///#endregion

///#region Wi-Fi Services
Future<void> _handleWifiStatus(BuildContext context) async {
  try {
    final wifiServicos = WifiServicos();
    final testeConexao = await wifiServicos.testarConexao();

    if (testeConexao) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conectado ao ESP32 com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Não foi possível alcançar o ESP32')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro de Wi-Fi: $e')),
    );
  }
}
///#endregion

///#region Bottom Navigation Bar
Widget _buildBottomNavigationBar(BuildContext context) {
  return SizedBox(
    height: 65,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 70,
            decoration: BoxDecoration(color: Colors.grey[900]),
            // Ícones laterais removidos
            child: const SizedBox.shrink(),
          ),
        ),
        Positioned(
          top: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleWifiStatus(context),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: const Icon(
                  Icons.wifi, 
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

///#endregion

  }