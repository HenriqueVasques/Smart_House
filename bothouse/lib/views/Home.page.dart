//homepage

import 'package:bothouse/servicos/autenticacao_servicos.dart';
import 'package:bothouse/views/control.page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
                    child: Column(
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
                    ),
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

  BoxDecoration _buildBackgroundImage() {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/background_image.png'),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
        icon: Icon(Icons.logout_rounded,
         color: const Color.fromARGB(255, 131, 131, 131)
         ),
          onPressed: () {
            Navigator.pop(context);
            AutenticacaoServicos().deslogar(context);
          } 
        ),
        _buildText('Oi Henrique', 20, Colors.white, isBold: true),
      ],
    );
  }

  Widget _buildText(String text, double size, Color color, {bool isBold = false}) {
    return Text(
      text,
      style: TextStyle(fontSize: size, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color),
    );
  }

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
    return _buildCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildText('5 Dispositivos Ativos', 16, Colors.white),
          Switch(value: true, onChanged: (value) {}, activeColor: Colors.blue),
        ],
      ),
    );
  }
//metodo que constroi os cards da pagina inicial

Widget _buildRoomGrid(BuildContext context) {
  return FutureBuilder(
    future: _buscaComodos(), // Chama a função que busca os cômodos do usuário logado
    builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator()); // Exibe um indicador de carregamento enquanto espera
      } else if (snapshot.hasError) {
        return Center(child: Text('Erro ao carregar cômodos')); // Exibe uma mensagem de erro, se houver
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text('Nenhum cômodo encontrado')); // Exibe uma mensagem caso não encontre cômodos
      } else {
        // Adiciona rolagem horizontal
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: snapshot.data!.map((comodo) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildRoomCard(context, comodo['nome'], 'images/bedroom.png'), // Usa uma imagem padrão
              );
            }).toList(),
          ),
        );
      }
    },
  );
}


// Função para buscar os cômodos do usuário logado no Firestore
Future<List<Map<String, dynamic>>> _buscaComodos() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(user.uid)
      .collection('comodos')
      .get();
  
  return snapshot.docs.map((doc) {
    return {'nome': doc['nomeComodo'] ?? 'Sem nome'};
  }).toList();
}



Widget _buildRoomCard(BuildContext context, String name, String imagePath) {
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
                _buildText(name, 16, Colors.white, isBold: true),
                SizedBox(height: 5),
                ElevatedButton(
                  child: Text('Ver'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ControlPage(nomeComodo: name),
                      ),
                    );
                  },
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
        // Ícone de configurações à esquerda
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: _buildNavIcon(
            Icons.settings,
            Colors.white54,
            () {
              
              print('Configurações pressionado');
            },
          ),
        ),
        // Espaço central ocupado pelo botão de Wi-Fi
        SizedBox(width: 60), // Espaço para o botão Wi-Fi acima
        // Ícone de perfil à direita
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
        onPressed: () {
          print('Parear pressionado');
        },
      ),
    );
  }
}