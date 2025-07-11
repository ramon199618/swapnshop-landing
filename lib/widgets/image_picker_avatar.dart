import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerAvatar extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;

  const ImagePickerAvatar({
    super.key,
    required this.imageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[300],
        backgroundImage: (imageFile != null && imageFile!.existsSync())
            ? FileImage(imageFile!)
            : null,
        child: imageFile == null
            ? const Icon(Icons.add_a_photo, size: 40)
            : null,
      ),
    );
  }
}
