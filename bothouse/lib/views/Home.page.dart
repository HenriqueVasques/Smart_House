import 'package:bothouse/servicos/autenticacao_servicos.dart';
import 'package:bothouse/views/control.page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  ///#region Construtores e Build Principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Container(
                  decoration: _buildBackgroundImage(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildMainContent(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
  
  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopBar(context),
        SizedBox(height: 20),
        _buildText('Bem-vindo à sua casa inteligente', 16, Colors.white70),
        SizedBox(height: 20),
        _buildTemperatureHumidityCard(),
        SizedBox(height: 20),
        _buildActiveDevicesCard(),
        SizedBox(height: 20),
        _buildText('Selecione o Cômodo', 18, Colors.white, isBold: true),
        SizedBox(height: 10),
        _buildRoomGrid(context),
      ],
    );
  }
  ///#endregion

  ///#region Serviços e Métodos de Dados
  Future<int> _calculaTotalDispositivos() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Nenhum usuário logado');
        return 0;
      }

      QuerySnapshot comodosSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('comodos')
          .get();

      int totalDispositivos = 0;

      for (var comodo in comodosSnapshot.docs) {
        Map<String, dynamic> data = comodo.data() as Map<String, dynamic>;
        
        if (data.containsKey('dispositivos')) {
          List<dynamic> dispositivos = data['dispositivos'];
          totalDispositivos += dispositivos.length;
          print('Cômodo: ${data['nomeComodo']} - ${dispositivos.length} dispositivos');
        }
      }

      print('Total de dispositivos encontrados: $totalDispositivos');
      return totalDispositivos;
    } catch (e) {
      print('Erro ao calcular total de dispositivos: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _buscaComodos() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Nenhum usuário logado');
        return [];
      }

      print('Buscando cômodos para o usuário: ${user.uid}');

      DocumentReference userRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid);

      DocumentSnapshot userDoc = await userRef.get();
      if (!userDoc.exists) {
        print('Documento do usuário não existe');
        return [];
      }

      QuerySnapshot comodosSnapshot = await userRef
          .collection('comodos')
          .get();

      print('Número de cômodos encontrados: ${comodosSnapshot.docs.length}');

      return comodosSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Dados do cômodo ${doc.id}: $data');
        
        return {
          'id': doc.id,
          'nome': data['nomeComodo'],
          'dispositivos': data['dispositivos'] ?? []
        };
      }).toList();
    } catch (e) {
      print('Erro ao buscar cômodos: $e');
      return [];
    }
  }
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  BoxDecoration _buildBackgroundImage() {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/background_image.png'),
        fit: BoxFit.cover,
      ),
    );
  }
  ///#endregion

  ///#region Componentes do Cabeçalho
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.logout_rounded, color: Color.fromARGB(255, 131, 131, 131)),
          onPressed: () {
            Navigator.pop(context);
            AutenticacaoServicos().deslogar(context);
          }
        ),
        _buildText('Oi Henrique', 20, Colors.white, isBold: true),
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
            SizedBox(width: 8),
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
              children: [
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

        int totalDispositivos = snapshot.data ?? 0;
        return _buildCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalDispositivos ${totalDispositivos == 1 ? 'Dispositivo Ativo' : 'Dispositivos Ativos'}',
                style: TextStyle(color: Colors.white, fontSize: 16),
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
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.blue)
          );
        } 
        
        if (snapshot.hasError) {
          print('Erro no FutureBuilder: ${snapshot.error}');
          return Center(
            child: Text(
              'Erro ao carregar cômodos',
              style: TextStyle(color: Colors.white),
            )
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyRoomState();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: snapshot.data!.map((comodo) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildRoomCard(
                  context, 
                  comodo['id'], 
                  comodo['nome'], 
                  'images/quarto.png'
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyRoomState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Nenhum cômodo encontrado',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar adição de novo cômodo
            },
            child: Text('Adicionar Cômodo'),
          )
        ],
      )
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
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  ElevatedButton(
                    child: Text('Ver'),
                    onPressed: () => _navegarParaControlPage(context, comodoId, name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navegarParaControlPage(BuildContext context, String comodoId, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ControlPage(
          comodoId: comodoId, 
          nomeComodo: name
        ),
      ),
    );
  }
  ///#endregion

  ///#region Barra de Navegação
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        _buildNavigationBar(context),
        Positioned(
          top: -30,
          child: _buildWifiButton(),
        ),
      ],
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[900],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: _buildNavIcon(
              Icons.settings,
              Colors.white54,
              () => print('Configurações pressionado'),
            ),
          ),
          SizedBox(width: 60),
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: _buildNavIcon(
              Icons.person,
              Colors.white54,
              () {
                Navigator.pushNamed(context, '/');
                print('Perfil pressionado');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }

  Widget _buildWifiButton() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      child: IconButton(
        icon: Icon(Icons.wifi, color: Colors.white, size: 30),
        onPressed: () => print('Parear pressionado'),
      ),
    );
  }
  ///#endregion
}