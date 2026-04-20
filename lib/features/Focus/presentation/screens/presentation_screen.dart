import 'package:flutter/material.dart';

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  PresentationScreenState createState() => PresentationScreenState();
}

class PresentationScreenState extends State<PresentationScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          child: const Center(
            child: Text(
              "Presentation Screen",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
