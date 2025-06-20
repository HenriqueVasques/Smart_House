//#region Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bothouse/servicos/firebase_servicos.dart';
import 'package:bothouse/servicos/wifi_servicos.dart';
//#endregion

class SensorUmidadeController {
  final FirebaseServicos _firebaseServicos = FirebaseServicos();
  final WifiServicos _wifiServicos = WifiServicos();

  Future<bool> consultarSensorNoFirebase(String comodoId) async {
    final user = _firebaseServicos.currentUser;

    if (user == null) {
      print('⚠️ Usuário não logado ao consultar o sensor.');
      return false;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('comodos')
        .doc(comodoId)
        .get();

    final dados = snapshot.data();
    final molhado = dados?['sensor_umidade']?['molhado'] ?? false;

    return molhado == true;
  }

  void escutarSensorUmidade({
    required String comodoId,
    required Function onSensorMolhado,
  }) {
    final user = _firebaseServicos.currentUser;
    if (user == null) {
      print('Nenhum usuário logado.');
      return;
    }

    FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('comodos')
        .doc(comodoId)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data();
      final sensorMolhado = data?['sensor_umidade']?['molhado'];
      if (sensorMolhado == true) {
        onSensorMolhado();
      }
    });
  }

  Future<void> verificarSensorUmidadeESP32() async {
    List<String> listaCaracteresSensor = ['R', '8', '#', 's', '@', 'Z', '!'];
    String caractereSelecionado = (listaCaracteresSensor.toList()..shuffle()).first;

    await _wifiServicos.enviarComando(
      rotaCodificada: 'fk77',
      caractereChave: caractereSelecionado,
    );
  }
}
