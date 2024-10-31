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
                        _buildTopBar(),
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

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.menu, color: Colors.white),
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

  Widget _buildRoomGrid(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildRoomCard(context, 'Sala de Estar', 'images/living_room.png'),
          SizedBox(width: 10),
          _buildRoomCard(context, 'Cozinha', 'images/kitchen.png'),
          SizedBox(width: 10),
          _buildRoomCard(context, 'Quarto', 'images/bedroom.png'),
        ],
      ),
    );
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
                      Navigator.pushReplacementNamed(context, '/control');
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