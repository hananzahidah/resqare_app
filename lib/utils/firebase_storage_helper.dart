import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class FirebaseStorageHelper {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage and returns the download URL.
  /// [destinationPath] is the path inside Firebase Storage (e.g. 'profiles/userId.jpg')
  static Future<String?> uploadFile(File file, String destinationPath) async {
    try {
      final ref = _storage.ref().child(destinationPath);
      final snapshot = await ref.putFile(file);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log("Error uploading file to storage: ${e.toString()}");
      return null;
    }
  }

  /// Uploads a profile image and returns its download URL.
  static Future<String?> uploadProfileImage(File file, String userId) async {
    final ext = p.extension(file.path);
    final destination = 'profiles/${userId}_${DateTime.now().millisecondsSinceEpoch}$ext';
    return uploadFile(file, destination);
  }

  /// Uploads a report image and returns its download URL.
  static Future<String?> uploadReportImage(File file, String reportId, int index) async {
    final ext = p.extension(file.path);
    final destination = 'reports/$reportId/img_${index}_${DateTime.now().millisecondsSinceEpoch}$ext';
    return uploadFile(file, destination);
  }

  /// Uploads a certificate image and returns its download URL.
  static Future<String?> uploadCertificateImage(File file, String userId, int index) async {
    final ext = p.extension(file.path);
    final destination = 'volunteer_certs/${userId}_img_${index}_${DateTime.now().millisecondsSinceEpoch}$ext';
    return uploadFile(file, destination);
  }

  /// Deletes a file from Firebase Storage using its download URL.
  static Future<void> deleteFile(String url) async {
    try {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      }
    } catch (e) {
      log("Error deleting file from storage: ${e.toString()}");
    }
  }
}
