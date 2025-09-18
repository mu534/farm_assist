import 'package:flutter/material.dart';
import 'package:farmer_asist/ui/screens/result_screen.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;

  const ImagePreviewScreen({super.key, required this.imagePath});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  @override
  void initState() {
    super.initState();

    // Redirect immediately to ResultScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(imagePath: widget.imagePath),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a simple loader while redirecting
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
