// 2- welcome.page:

import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo (estendida até o início do lorem ipsum)
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.21, // Ajustado para cobrir até o início do lorem ipsum
            child: Image.asset(
              'images/welcome.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícone centralizado
                    Image.asset(
                      'images/logoWelcome.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    // Label "Ninja Bot"
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF001C30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _buildText('Ninja Bot', 24, Colors.white, isBold: true),
                    ),
                  ],
                ),
              ),
              // Retângulo inferior
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: const BoxDecoration(
                  color: Color(0xFF001C30),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildText('Bem vindo', 28, Colors.white, isBold: true),
                          const SizedBox(height: 10),
                          _buildText(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                            16,
                            Colors.white.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          height: 60,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF3276E2), Color(0xFF4B4CED)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              bottomLeft: Radius.circular(30), // Adicionado arredondamento na parte inferior esquerda
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  bottomLeft: Radius.circular(30), // Adicionado arredondamento na parte inferior esquerda
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF030092),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 36, // Aumentado o tamanho do círculo interno
                                      height: 36, // Aumentado o tamanho do círculo interno
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromARGB(255, 0, 93, 232),
                                      ),
                                      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                                _buildText('Começar', 18, Colors.white, isBold: true),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildText(String text, double size, Color color, {bool isBold = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color,
      ),
    );
  }
}