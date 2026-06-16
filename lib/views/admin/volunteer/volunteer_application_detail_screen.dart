import 'dart:io';

import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/repositories/admin_repository.dart';
import 'package:resqare_app/utils/date_formater.dart';

class VolunteerApplicationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> application;

  const VolunteerApplicationDetailScreen({
    super.key,
    required this.application,
  });

  @override
  State<VolunteerApplicationDetailScreen> createState() =>
      _VolunteerApplicationDetailScreenState();
}

class _VolunteerApplicationDetailScreenState
    extends State<VolunteerApplicationDetailScreen> {
  final AdminRepository _adminRepository = AdminRepository();
  bool _isSubmitting = false;

  late final Map<String, dynamic> _app;

  @override
  void initState() {
    super.initState();
    _app = widget.application;
  }

  Future<void> _processReview(String newStatus) async {
    final title = newStatus == 'approved'
        ? "Setujui Pengajuan"
        : "Tolak Pengajuan";
    final message = newStatus == 'approved'
        ? "Apakah Anda yakin ingin menyetujui pengajuan relawan dari ${_app['fullName']}? Akun pengguna ini akan diubah menjadi Relawan."
        : "Apakah Anda yakin ingin menolak pengajuan relawan dari ${_app['fullName']}?";

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Batal",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus == 'approved'
                    ? AppColors.primaryBlue
                    : AppColors.emergency,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                newStatus == 'approved' ? "Ya, Setujui" : "Ya, Tolak",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isSubmitting = true;
      });

      final success = await _adminRepository.reviewVolunteerApplication(
        applicationId: _app['id'],
        userId: _app['userId'],
        newStatus: newStatus,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newStatus == 'approved'
                    ? "Pengajuan relawan berhasil disetujui!"
                    : "Pengajuan relawan berhasil ditolak.",
              ),
              backgroundColor: newStatus == 'approved'
                  ? AppColors.success
                  : AppColors.waitingRescue,
            ),
          );
          Navigator.pop(context, true); // Pop with true to reload list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Gagal memperbarui status pengajuan. Silakan coba lagi.",
              ),
              backgroundColor: AppColors.emergency,
            ),
          );
        }
      }
    }
  }

  void _openImageViewer(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            title: Text(
              imagePath.split('/').last,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: _buildImageViewerContent(imagePath),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageViewerContent(String imagePath) {
    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(file);
    }
    // Fallback template design
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.card_membership_rounded,
            color: AppColors.primaryBlue,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            imagePath,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "(Berkas simulasi/seed data database)",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateThumbnail(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const SizedBox.shrink();
    }

    final file = File(imagePath);
    final exists = file.existsSync();

    return GestureDetector(
      onTap: () => _openImageViewer(imagePath),
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.softBlue.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          image: exists
              ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
              : null,
        ),
        child: !exists
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.card_membership_rounded,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        imagePath.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = _app['fullName'] ?? '-';
    final String email = _app['email'] ?? '-';
    final String phone = _app['phone'] ?? '-';
    final String experience = _app['experience'] ?? '';
    final String reason = _app['reason'] ?? '';
    final String status = (_app['status'] as String).toLowerCase();
    final String createdAt = _app['createdAt'] ?? '';
    final String? imgProfile = _app['imgProfile'];

    Color statusColor;
    String statusText;
    switch (status) {
      case 'pending':
        statusColor = AppColors.waitingRescue;
        statusText = "Menunggu Persetujuan";
        break;
      case 'approved':
        statusColor = AppColors.success;
        statusText = "Disetujui";
        break;
      case 'rejected':
        statusColor = AppColors.emergency;
        statusText = "Ditolak";
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = status.toUpperCase();
    }

    final bool hasCertificates =
        (_app['image1'] != null && _app['image1'].toString().isNotEmpty) ||
        (_app['image2'] != null && _app['image2'].toString().isNotEmpty) ||
        (_app['image3'] != null && _app['image3'].toString().isNotEmpty);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Detail Pengajuan Relawan",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 20.0,
                bottom: 100.0, // Space for bottom action buttons
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Applicant Profile Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.01),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.softBlue,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.softBlue,
                            backgroundImage:
                                imgProfile != null &&
                                    imgProfile.isNotEmpty &&
                                    File(imgProfile).existsSync()
                                ? FileImage(File(imgProfile))
                                : null,
                            child:
                                imgProfile == null ||
                                    imgProfile.isEmpty ||
                                    !File(imgProfile).existsSync()
                                ? const Icon(
                                    Icons.person_rounded,
                                    size: 32,
                                    color: AppColors.primaryBlue,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "No. HP: $phone",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Detail form card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.01),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Status Dokumen",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (createdAt.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            "Diajukan pada: ${DateFormatter.toReadableDateTime(createdAt)}",
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const Divider(height: 24),

                        // Experience Section
                        const Row(
                          children: [
                            Icon(
                              Icons.pets_rounded,
                              color: AppColors.primaryBlue,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Pengalaman Terkait Hewan",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          experience.isNotEmpty ? experience : "-",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const Divider(height: 24),

                        // Reason Section
                        const Row(
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              color: AppColors.primaryBlue,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Alasan Bergabung",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reason.isNotEmpty ? reason : "-",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Supporting Certificates
                  if (hasCertificates) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 10),
                      child: Text(
                        "Sertifikat Pendukung",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ketuk gambar untuk melihat pratinjau penuh atau memperbesar sertifikat.",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              if (_app['image1'] != null &&
                                  _app['image1'].toString().isNotEmpty)
                                _buildCertificateThumbnail(_app['image1']),
                              if (_app['image2'] != null &&
                                  _app['image2'].toString().isNotEmpty)
                                _buildCertificateThumbnail(_app['image2']),
                              if (_app['image3'] != null &&
                                  _app['image3'].toString().isNotEmpty)
                                _buildCertificateThumbnail(_app['image3']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom sticky action buttons (for pending applications only)
          if (status == 'pending')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  border: const Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.emergency),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () => _processReview('rejected'),
                          child: const Text(
                            "Tolak Pengajuan",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.emergency,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () => _processReview('approved'),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Setujui Relawan",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
