import 'dart:io';

import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';

class PhotoUploadSection extends StatelessWidget {
  final List<File> selectedImages;
  final int maxPhotos;
  final VoidCallback onAddPhotoTap;
  final Function(int) onRemovePhoto;

  const PhotoUploadSection({
    super.key,
    required this.selectedImages,
    required this.maxPhotos,
    required this.onAddPhotoTap,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEDEEF1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Foto Keadaan Hewan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                "${selectedImages.length}/$maxPhotos",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Photos List
          SizedBox(
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length + (selectedImages.length < maxPhotos ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == selectedImages.length) {
                  // Clickable card to add photo
                  return InkWell(
                    onTap: onAddPhotoTap,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 95,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            color: AppColors.primaryBlue,
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Tambah",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final file = selectedImages[index];
                return Stack(
                  children: [
                    Container(
                      width: 95,
                      height: 95,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        image: DecorationImage(
                          image: FileImage(file),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: InkWell(
                        onTap: () => onRemovePhoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
