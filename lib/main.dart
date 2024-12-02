import 'package:flutter/material.dart';
import 'screens/setup_screen.dart';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SetupScreen(),
      debugShowCheckedModeBanner: false, // Hides the debug banner
    );
  }
}