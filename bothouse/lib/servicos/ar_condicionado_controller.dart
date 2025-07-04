//#region Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bothouse/servicos/firebase_servicos.dart';
//#endregion

class ArCondicionadoController {
  final FirebaseServicos _firebaseServicos = FirebaseServicos();
  /// Escuta mudanças no campo sensor_temp.modo_cool e chama a função quando ele mudar
  void escutarModoCool({
    required String comodoId,
    required Function(bool modoCool) onModoAlterado,
  }) {
    final user = _firebaseServicos.currentUser;
    if (user == null) {
      print('⚠️ Usuário não logado para escutar modo_cool.');
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
      final modoCool = data?['sensor_temp']?['modo_cool'] == true;
      onModoAlterado(modoCool);
    });
  }

  /// Atualiza manualmente o campo sensor_temp.modo_cool no banco
  Future<void> alterarModoCool(String comodoId, bool novoValor) async {
    final user = _firebaseServicos.currentUser;
    if (user == null) {
      print('⚠️ Usuário não logado para alterar modo_cool.');
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('comodos')
        .doc(comodoId);

    await docRef.set({
      'sensor_temp': {
        'modo_cool': novoValor,
      }
    }, SetOptions(merge: true));
  }
}
