// serviços de sutenticação

import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';

class AutenticacaoServicos {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // criarUsuario({
  //   required String email, 
  //   required String senha,
  //   }){
  //     await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: senha);
  //     return null;
  //   }

    Future<String?> logarUsuario(
      {required String email, required String senha,}) async{
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: senha);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> deslogar() async {
    try {
      await FirebaseAuth.instance.signOut();
    }catch (erro) {
      print('Erro ao fazer logout: $erro');
    }
  }
}





  
