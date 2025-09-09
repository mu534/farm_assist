import 'package:flutter/material.dart';
import 'package:farmer_asist/core/themes.dart';

class ResultScreen extends StatelessWidget {
  final String result;
  const ResultScreen({super.key, this.result = 'Processing...'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Result'),
        backgroundColor: AppColors.backgroundLight,
        elevation: 2,
      ),
      body: Center(
        child: Text(
          result,
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
