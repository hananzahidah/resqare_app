import 'dart:io';
import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';

class ImageLoaderHelper {
  static bool isNetwork(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  static bool isAsset(String path) {
    return path.startsWith('assets/');
  }

  static bool hasImage(String? path) {
    if (path == null || path.isEmpty) return false;
    if (isNetwork(path) || isAsset(path)) return true;
    return File(path).existsSync();
  }

  static ImageProvider? getImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    if (isNetwork(path)) {
      return NetworkImage(path);
    }
    if (isAsset(path)) {
      return AssetImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }

  static Widget loadImage(
    String? path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    final defaultPlaceholder = placeholder ??
        Container(
          width: width,
          height: height,
          color: AppColors.border,
          child: Icon(Icons.pets_rounded, color: AppColors.textSecondary, size: 24),
        );

    final defaultError = errorWidget ??
        Container(
          width: width,
          height: height,
          color: AppColors.border,
          child: Icon(Icons.broken_image_rounded, color: AppColors.textSecondary, size: 24),
        );

    if (path == null || path.isEmpty) {
      return defaultPlaceholder;
    }

    if (isNetwork(path)) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.border,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => defaultError,
      );
    }

    if (isAsset(path)) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => defaultError,
      );
    }

    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => defaultError,
      );
    }

    return defaultError;
  }
}