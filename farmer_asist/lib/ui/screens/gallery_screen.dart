import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farmer_asist/core/themes.dart';

class GalleryScreen extends StatefulWidget {
  final XFile? initialImage; // Captured image from CameraScreen

  const GalleryScreen({super.key, this.initialImage});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  /// Load gallery images and insert captured image first if exists
  Future<void> _loadImages() async {
    final pickedImages = await _picker.pickMultiImage();
    setState(() {
      _images = pickedImages ?? [];

      // Insert captured image at the beginning
      if (widget.initialImage != null) {
        _images.insert(0, widget.initialImage!);
        _selectedIndex = 0; // highlight captured image
      } else if (_images.isNotEmpty) {
        _selectedIndex = 0; // highlight first gallery image
      } else {
        _selectedIndex = -1;
      }
    });
  }

  void _onSelectImage(int index) {
    setState(() => _selectedIndex = index);
    final selectedImage = _images[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected image: ${selectedImage.path}')),
    );
    // Here you can add logic to send the image to another screen or process it
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
      body: _images.isEmpty
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
