import 'package:flutter/material.dart';

class DiagnosisResultScreen extends StatelessWidget {
  final String diagnosisResult;

  DiagnosisResultScreen({required this.diagnosisResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diagnosis Result')),
      body: Center(
        child: Text(diagnosisResult, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
