import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farmer_asist/core/themes.dart';
import 'package:farmer_asist/ui/screens/image_preview_screen.dart';
import 'package:farmer_asist/ui/services/ai_service.dart';

class GalleryScreen extends StatefulWidget {
  final XFile? initialImage;

  const GalleryScreen({super.key, this.initialImage});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  int _selectedIndex = -1;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  /// Loads images from device gallery
  Future<void> _loadImages() async {
    try {
      final pickedImages = await _picker.pickMultiImage();
      setState(() {
        _images = pickedImages ?? [];

        // Insert captured image at the beginning
        if (widget.initialImage != null) {
          _images.insert(0, widget.initialImage!);
          _selectedIndex = 0;
        } else if (_images.isNotEmpty) {
          _selectedIndex = 0;
        } else {
          _selectedIndex = -1;
        }
      });
    } catch (e) {
      debugPrint("Error loading images: $e");
    }
  }

  /// Select an image and run AI analysis
  Future<void> _onSelectImage(int index) async {
    setState(() => _loading = true);
    final selectedImage = _images[index];

    try {
      // Run AI service on selected image
      final aiResult = await AIService().analyzeImage(File(selectedImage.path));

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ImagePreviewScreen(imagePath: selectedImage.path),
        ),
      );
    } catch (e) {
      debugPrint("AI analysis failed: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to analyze image")));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Choose Photo'),
        backgroundColor: AppColors.backgroundLight,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadImages,
            tooltip: 'Refresh Gallery',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
          ? const Center(child: Text('No images found'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onSelectImage(index),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: index == _selectedIndex
                            ? AppColors.accentEmerald
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Image.file(
                      File(_images[index].path),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
