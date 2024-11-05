import 'package:bothouse/views/login.page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AutenticacaoServicos {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> logarUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuário não encontrado';
        case 'wrong-password':
          return 'Senha incorreta';
        case 'invalid-email':
          return 'Email inválido';
        default:
          return 'Erro ao fazer login: ${e.message}';
      }
    } catch (e) {
      return 'Erro inesperado ao fazer login';
    }
  }

  Future<void> deslogar(BuildContext context) async {
    try {
      await _firebaseAuth.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (erro) {
      debugPrint('Erro ao fazer logout: $erro');
      rethrow;
    }
  }
}