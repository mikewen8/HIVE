import 'package:flutter/material.dart';
import 'package:HIVE/pages/home_screen.dart';
//import 'package:hive/pages/inprogress.dart';
//import 'package:hive/pages/home_screen.dart';
//import 'package:hive/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}