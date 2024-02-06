import 'package:battleships/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Battleships',
      home: LoginScreen(),
    ),
  );
}
