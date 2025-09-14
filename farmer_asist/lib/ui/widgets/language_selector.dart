import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final VoidCallback onEnglish;
  final VoidCallback onAmharic;
  final VoidCallback onOromo;

  const LanguageSelector({
    super.key,
    required this.onEnglish,
    required this.onAmharic,
    required this.onOromo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(onPressed: onEnglish, child: const Text('EN')),
        TextButton(onPressed: onAmharic, child: const Text('AM')),
        TextButton(onPressed: onOromo, child: const Text('OR')),
      ],
    );
  }
}
