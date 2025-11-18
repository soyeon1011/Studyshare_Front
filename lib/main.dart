import 'package:flutter/material.dart';
import 'package:study_note/screens/home_main_screen.dart'; // MainScreen이 있는 파일

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(), // 앱이 처음 시작될 때 보여줄 화면
    );
  }
}