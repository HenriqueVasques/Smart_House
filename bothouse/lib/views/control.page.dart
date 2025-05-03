//#region Imports
import 'package:bothouse/servicos/firebase_servicos.dart';
import 'package:flutter/material.dart';
import 'package:bothouse/views/dispositivos/ar_condicionado_page.dart';
import 'package:bothouse/views/dispositivos/fechadura.dart';
import 'package:bothouse/views/dispositivos/janela.dart';
import 'package:bothouse/views/dispositivos/lampada.dart';
import 'package:bothouse/views/dispositivos/ventilador.dart';
//#endregion
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Controle do ${widget.nomeComodo}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF211D1D),
        elevation: 0,
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
  return GestureDetector(
    onTap: () => _handleDispositivo(dispositivo.nome),
    child: Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF222834), Color(0xFF001524)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              dispositivo.nome,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Image.asset(
            dispositivo.imagePath,
            width: 67,
            height: 67,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.device_unknown, color: Colors.white, size: 60);
            },
          ),
        ],
      ),
    ),
  );
}


 //#region Handler dos Dispositivos
  void _handleDispositivo(String nome) {
    switch (nome) {
      case "Fechadura":
        Navigator.push(context, MaterialPageRoute(builder: (context) => FechaduraPage(comodoId: widget.comodoId, dispositivoNome: nome)));
        break;
      case "Janela":
        Navigator.push(context, MaterialPageRoute(builder: (context) => JanelaPage(comodoId: widget.comodoId, dispositivoNome: nome)));
        break;
      case "Lampada":
        Navigator.push(context, MaterialPageRoute(builder: (context) => LampadaPage(comodoId: widget.comodoId, dispositivoNome: nome)));
        break;
      case "Ventilador":
        Navigator.push(context, MaterialPageRoute(builder: (context) => VentiladorPage(comodoId: widget.comodoId, dispositivoNome: nome)));
        break;
      case "Ar_Condicionado":
        Navigator.push(context, MaterialPageRoute(builder: (context) => ArCondicionadoPage(comodoId: widget.comodoId, dispositivoNome: nome)));
        break;
      default:
        print('⚠️ Dispositivo não reconhecido: $nome');
    }
  }
  //#endregion

  //#endregion
}

class Dispositivo {
  final String nome;
  late String imagePath;

  Dispositivo({
    required this.nome,
  }) {
    imagePath = 'assets/icones_dispositivos/${_normalizarNome(nome)}.png';
  }

  // Função para normalizar o nome removendo acentos e caracteres especiais
  String _normalizarNome(String nome) {
    String semAcento = nome
        .replaceAll(RegExp(r'[áàâãäå]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[ÁÀÂÃÄÅ]'), 'A')
        .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
        .replaceAll(RegExp(r'[ÍÌÎÏ]'), 'I')
        .replaceAll(RegExp(r'[ÓÒÔÕÖ]'), 'O')
        .replaceAll(RegExp(r'[ÚÙÛÜ]'), 'U')
        .replaceAll(RegExp(r'[Ç]'), 'C');

    return semAcento.toLowerCase().replaceAll(' ', '_');
  }
}
