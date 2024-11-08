import 'package:bothouse/servicos/autenticacao_servicos.dart';
import 'package:bothouse/views/control.page.dart';
import 'package:flutter/material.dart';
import 'package:bothouse/servicos/firebase_servicos.dart';
import 'package:bothouse/widgets/bluetooth_dialog.dart';
import 'package:bothouse/servicos/bluetooth_servicos.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final FirebaseServicos _firebaseServicos = FirebaseServicos();
  final BluetoothServicos _bluetoothServicos = BluetoothServicos();

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
                    image: AssetImage('images/background_image.png'),
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
        _buildText('Bem-vindo à sua casa inteligente', 16, Colors.white70),
        const SizedBox(height: 20),
        _buildTemperatureHumidityCard(),
        const SizedBox(height: 20),
        _buildActiveDevicesCard(),
        const SizedBox(height: 20),
        _buildText('Selecione o Cômodo', 18, Colors.white, isBold: true),
        const SizedBox(height: 10),
        _buildRoomGrid(context),
      ],
    );
  }
  ///#endregion

  ///#region Serviços e Métodos de Dados
  Future<int> _calculaTotalDispositivos() => _firebaseServicos.calcularTotalDispositivos();
  Future<List<Map<String, dynamic>>> _buscaComodos() => _firebaseServicos.buscarComodos();
  ///#endregion

  ///#region Componentes de UI Base
  Widget _buildText(String text, double size, Color color, {bool isBold = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size, 
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
        color: color
      ),
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
          icon: const Icon(Icons.logout_rounded, color: Color.fromARGB(255, 131, 131, 131)),
          onPressed: () {
            Navigator.pop(context);
            AutenticacaoServicos().deslogar(context);
          }
        ),
        FutureBuilder<String>(
          future: _firebaseServicos.buscarNomeUsuario(),
          builder: (context, snapshot) => _buildText(
            'Oi ${snapshot.data ?? 'Usuário'}',
            20,
            Colors.white,
            isBold: true
          ),
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
          _buildInfoColumn('Temperatura', '20°C', Icons.wb_sunny, Colors.yellow),
          _buildInfoColumn('Umidade', '69%', null, null),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData? icon, Color? iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) Row(
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
              Switch(
                value: totalDispositivos > 0,
                onChanged: (value) {
                  // TODO: Implementar lógica para ligar/desligar todos os dispositivos
                },
                activeColor: Colors.blue,
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
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        } 
        
        if (snapshot.hasError) {
          print('Erro no FutureBuilder: ${snapshot.error}');
          return const Center(
            child: Text('Erro ao carregar cômodos', style: TextStyle(color: Colors.white))
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Nenhum cômodo encontrado', style: TextStyle(color: Colors.white))
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: snapshot.data!.map((comodo) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _buildRoomCard(
                context, 
                comodo['id'], 
                comodo['nome'], 
                'images/quarto.png'
              ),
            )).toList(),
          ),
        );
      },
    );
  }

  Widget _buildRoomCard(BuildContext context, String comodoId, String name, String imagePath) {
    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
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
                    name,
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
                          comodoId: comodoId, 
                          nomeComodo: name
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

///#region Barra de Navegação
  Widget _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
      height: 65, // Aumentada para acomodar o botão flutuante
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white54),
                      onPressed: () => print('Configurações pressionado'),
                    ),
                  ),
                  const SizedBox(width: 60),
                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: IconButton(
                      icon: const Icon(Icons.person, color: Colors.white54),
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                        print('Perfil pressionado');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  try {
                    if (_bluetoothServicos.isConnected) {
                      await _bluetoothServicos.desconectar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dispositivo desconectado'))
                      );
                    } else {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => const BluetoothDialog(),
                      );
                      if (result == true) {
                        // Conexão bem-sucedida, o feedback já foi mostrado no diálogo
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro: $e'))
                    );
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                    child: Icon(
                    _bluetoothServicos.isConnected ? Icons.bluetooth_connected : Icons.wifi,
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