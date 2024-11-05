import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bothouse/views/welcome.page.dart';
import 'package:bothouse/views/login.page.dart';
import 'package:bothouse/views/home.page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const RoteadorTela(), // Usa o RoteadorTela como home
      routes: {
        "/login": (context) => LoginPage(),
        "/welcome": (context) => WelcomePage(),
        "/home": (context) => HomePage(),
      },
    );
  }
}

class RoteadorTela extends StatelessWidget {
  const RoteadorTela({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Mostra um loading enquanto verifica o estado
        } else if (snapshot.hasData) {
          return const HomePage();
        } else {
          return  LoginPage();
        }
      },
    );
  }
}
