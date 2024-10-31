// 6-app.dart
import 'package:flutter/material.dart';
import 'welcome.page.dart';
import 'login.page.dart';
import 'control.page.dart';
import 'home.page.dart';


class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      routes: {
        "/login": (context) => LoginPage(),
        "/welcome": (context) => WelcomePage(),
        "/home": (context) => HomePage(),
        "/control": (context) => ControlPage(),
      },
      initialRoute: "/welcome",
    );
  }
}