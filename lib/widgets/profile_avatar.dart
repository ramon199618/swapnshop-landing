import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ProfileAvatar extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;
  final String? imageUrl;

  const ProfileAvatar({
    super.key,
    required this.imageFile,
    required this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;
    if (imageFile != null && imageFile!.existsSync()) {
      provider = FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      provider = NetworkImage(imageUrl!);
    }
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: provider,
            child: provider == null
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
