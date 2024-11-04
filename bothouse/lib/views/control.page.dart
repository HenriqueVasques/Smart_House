// control page

import 'package:flutter/material.dart';
import 'dart:math';

class ControlPage extends StatelessWidget {
  final String nomeComodo; // Adicione esta linha
  final Random random = Random();
  
  ControlPage({
    Key? key, 
    required this.nomeComodo // Adicione esta linha
  }) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF211D1D),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Expanded(
                    flex: 6,
                    child: _buildScrollableGrid(),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildFixedRectangle(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: (){
              Navigator.pop(context); 
              },
          ),
          Expanded(
            child: Center(
              child: Text(
                 nomeComodo,
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 48),  // Para balancear o botão de voltar
        ],
      ),
    );
  }

  Widget _buildScrollableGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        bool isConnected = random.nextBool();
        return _buildDeviceCard(isConnected);
      },
    );
  }

  Widget _buildDeviceCard(bool isConnected) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF222834), Color(0xFF001524)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dispositivo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      isConnected ? 'Conectado' : 'Desconectado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isConnected ? 'ON' : 'OFF',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: isConnected,
                    onChanged: (value) {},
                    activeColor: Color(0xFF0161FA).withOpacity(0.7),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Color(0xFF0161FA).withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedRectangle() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A2129),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}