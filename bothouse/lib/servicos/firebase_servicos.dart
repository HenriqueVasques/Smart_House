// firebase_servicos.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServicos {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Verifica se há usuário logado
  User? get currentUser => _auth.currentUser;

  // método para buscar o nome do usuário
  
  Future<String> buscarNomeUsuario() async {
    try {
      User? user = currentUser;
      if (user == null) {
        return 'Visitante';
      }

      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        return user.email?.split('@')[0] ?? 'Usuário';
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return userData['nome'] ?? user.email?.split('@')[0] ?? 'Usuário';
    } catch (e) {
      print('Erro ao buscar nome do usuário: $e');
      return 'Usuário';
    }
  }

  // Busca todos os cômodos do usuário
  Future<List<Map<String, dynamic>>> buscarComodos() async {
    try {
      User? user = currentUser;
      if (user == null) {
        print('Nenhum usuário logado');
        return [];
      }

      print('Buscando cômodos para o usuário: ${user.uid}');

      DocumentReference userRef = _firestore
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

  // Calcula total de dispositivos do usuário
  Future<int> calcularTotalDispositivos() async {
    try {
      User? user = currentUser;
      if (user == null) {
        print('Nenhum usuário logado');
        return 0;
      }

      QuerySnapshot comodosSnapshot = await _firestore
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

  // Busca dispositivos de um cômodo específico
  Future<List<String>> buscarDispositivosComodo(String comodoId) async {
    try {
      User? user = currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      DocumentSnapshot comodoSnapshot = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .collection('comodos')
          .doc(comodoId)
          .get();
          
      Map<String, dynamic> data = comodoSnapshot.data() as Map<String, dynamic>;
      
      if (!data.containsKey('dispositivos')) {
        print('Nenhum dispositivo encontrado para o cômodo ID: $comodoId');
        return [];
      }

      List<dynamic> dispositivosData = data['dispositivos'] as List<dynamic>;
      return dispositivosData.map((nome) => nome.toString()).toList();

    } catch (e) {
      print('Erro ao buscar dispositivos: $e');
      return [];
    }
  }
}