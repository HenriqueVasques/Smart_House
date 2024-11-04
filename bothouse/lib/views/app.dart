// app.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'welcome.page.dart';
import 'login.page.dart';
import 'control.page.dart';
import 'home.page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const RoteadorTela(), // Adicione isso para usar o roteador
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
        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}