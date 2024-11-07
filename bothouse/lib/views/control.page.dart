import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ControlPage extends StatefulWidget {
  final String comodoId;
  final String nomeComodo;

  const ControlPage({Key? key, required this.comodoId, required this.nomeComodo}) : super(key: key);

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  late Future<List<Dispositivo>> dispositivosFuture;

  @override
  void initState() {
    super.initState();
    dispositivosFuture = _fetchDispositivos();
  }

  Future<List<Dispositivo>> _fetchDispositivos() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Busca o documento do cômodo
      DocumentSnapshot comodoSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('comodos')
          .doc(widget.comodoId)
          .get();
          
      // Converte o snapshot para Map
      Map<String, dynamic> data = comodoSnapshot.data() as Map<String, dynamic>;
      
      // Verifica se existe a lista de dispositivos
      if (!data.containsKey('dispositivos')) {
        print('Nenhum dispositivo encontrado para o cômodo: ${widget.nomeComodo}');
        return [];
      }

      // Converte a lista de dispositivos
      List<dynamic> dispositivosData = data['dispositivos'] as List<dynamic>;
      
      // Cria objetos Dispositivo a partir das strings
      return dispositivosData.map((nome) => Dispositivo(nome: nome.toString())).toList();

    } catch (e) {
      print('Erro ao buscar dispositivos: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controle do ${widget.nomeComodo}'),
      ),
      backgroundColor: const Color(0xFF211D1D),
      body: SafeArea(
        child: FutureBuilder<List<Dispositivo>>(
          future: dispositivosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao carregar dispositivos',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Nenhum dispositivo encontrado em ${widget.nomeComodo}',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return _buildScrollableGrid(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildScrollableGrid(List<Dispositivo> dispositivos) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: dispositivos.length,
      itemBuilder: (context, index) {
        return _buildDeviceCard(context, dispositivos[index]);
      },
    );
  }

  Widget _buildDeviceCard(BuildContext context, Dispositivo dispositivo) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
                  dispositivo.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Desconectado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'OFF',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: false, // Sempre começa desligado
                    onChanged: (value) {
                      // Implementar lógica de controle aqui
                    },
                    activeColor: const Color(0xFF0161FA).withOpacity(0.7),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFF0161FA).withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Dispositivo {
  final String nome;
  final bool isConnected = false; // Sempre false por padrão

  Dispositivo({required this.nome});
}