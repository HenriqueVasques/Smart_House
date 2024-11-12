// control page
import 'package:bothouse/servicos/firebase_servicos.dart';
import 'package:flutter/material.dart';

class ControlPage extends StatefulWidget {
  final String comodoId;
  final String nomeComodo;

  const ControlPage({Key? key, required this.comodoId, required this.nomeComodo}) : super(key: key);

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  late Future<List<Dispositivo>> dispositivosFuture;
  final FirebaseServicos firebaseServicos = FirebaseServicos();

  @override
  void initState() {
    super.initState();
    dispositivosFuture = _fetchDispositivos();
  }

  //#region Fetch Dispositivos
  Future<List<Dispositivo>> _fetchDispositivos() async {
    try {
      return await firebaseServicos.buscarDispositivosComodo(widget.comodoId).then((dispositivosData) {
        return dispositivosData.map((nome) => Dispositivo(nome: nome)).toList();
      });
    } catch (e) {
      print('Erro ao buscar dispositivos: $e');
      return [];
    }
  }
  //#endregion

  //#region Build Methods
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
  //#endregion

  //#region Device Card
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                dispositivo.nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Image.asset(
                dispositivo.imagePath,
                width: 85,
                height: 85,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.device_unknown,
                    color: Colors.white,
                    size: 85,
                  );
                },
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
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
                value: false,
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
      ],
    ),
  );
}
  //#endregion
}

class Dispositivo {
  final String nome;
  final String imagePath;

  Dispositivo({
    required this.nome,
  }) : imagePath = 'icones_dispositivos/${nome.toLowerCase()}.png';
}
