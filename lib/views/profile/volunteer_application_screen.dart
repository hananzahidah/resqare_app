import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/models/user_model_sql.dart';
import 'package:resqare_app/repositories/user_repository.dart';
import 'package:resqare_app/utils/date_formater.dart';

class VolunteerApplicationScreen extends StatefulWidget {
  final UserModelSql user;

  const VolunteerApplicationScreen({super.key, required this.user});

  @override
  State<VolunteerApplicationScreen> createState() =>
      _VolunteerApplicationScreenState();
}

class _VolunteerApplicationScreenState
    extends State<VolunteerApplicationScreen> {
  final UserRepository _userRepository = UserRepository();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  final List<File> _certificateFiles = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String _status = '';
  UserModelSql? _currentUser;
  String? _reviewedAt;
  String? _createdAt;
  String? _updatedAt;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _phoneController.text = _currentUser?.phone ?? '';
    _loadApplicationData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _experienceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadApplicationData() async {
    setState(() {
      _isLoading = true;
    });

    final updatedUser = await _userRepository.getUserById(widget.user.id!);
    if (updatedUser != null) {
      _currentUser = updatedUser;
      _phoneController.text = _currentUser?.phone ?? '';
    }

    final app = await _userRepository.getVolunteerApplication(
      _currentUser!.id!,
    );
    if (app != null) {
      _status = (app['status'] as String).toLowerCase();
      _experienceController.text = app['experience'] ?? '';
      _reasonController.text = app['reason'] ?? '';
      _reviewedAt = app['reviewedAt'];
      _createdAt = app['createdAt'];
      _updatedAt = app['updatedAt'];
      _isEditMode = false;

      _certificateFiles.clear();
      if (app['image1'] != null && app['image1'].toString().isNotEmpty) {
        _certificateFiles.add(File(app['image1']));
      }
      if (app['image2'] != null && app['image2'].toString().isNotEmpty) {
        _certificateFiles.add(File(app['image2']));
      }
      if (app['image3'] != null && app['image3'].toString().isNotEmpty) {
        _certificateFiles.add(File(app['image3']));
      }
    } else {
      _status = 'none';
      _reviewedAt = null;
      _createdAt = null;
      _updatedAt = null;
      _isEditMode = true;
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Camera & Gallery bottom sheet trigger
  Future<void> _pickCertificateImage(ImageSource source) async {
    if (_certificateFiles.length >= 3) {
      _showSnackBar('Maksimal hanya dapat mengunggah 3 sertifikat.');
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _certificateFiles.add(File(image.path));
        });
      }
    } catch (e) {
      debugPrint("Error picking certificate image: $e");
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Unggah Sertifikat Pendukung",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _pickCertificateImage(ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.primaryBlue,
                                size: 28,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Kamera",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _pickCertificateImage(ImageSource.gallery);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.photo_library_rounded,
                                color: AppColors.primaryBlue,
                                size: 28,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Galeri",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeCertificateImage(int index) {
    setState(() {
      _certificateFiles.removeAt(index);
    });
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.emergency,
      ),
    );
  }

  Future<void> _submitOrUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final experience = _experienceController.text.trim();
    final reason = _reasonController.text.trim();

    // Verification check for phone number
    if (phone.isEmpty) {
      _showSnackBar('Nomor telepon wajib diisi untuk menjadi relawan.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Validate phone uniqueness if changed
      if (phone != _currentUser!.phone) {
        final phoneExists = await _userRepository.checkPhoneExists(phone);
        if (phoneExists) {
          _showSnackBar('Nomor telepon sudah terdaftar pada akun lain!');
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
      }

      // Save local certificate files if they are newly added
      final appDir = await getApplicationDocumentsDirectory();
      final List<String> savedPaths = [];
      for (int i = 0; i < _certificateFiles.length; i++) {
        final file = _certificateFiles[i];
        if (file.path.startsWith(appDir.path)) {
          savedPaths.add(file.path);
        } else {
          // Copy new file
          final ext = p.extension(file.path);
          final fileName =
              'volunteer_cert_${_currentUser!.id}_$i${DateTime.now().millisecondsSinceEpoch}$ext';
          final savedFile = await file.copy('${appDir.path}/$fileName');
          savedPaths.add(savedFile.path);
        }
      }

      bool success = false;
      if (_status == 'none') {
        success = await _userRepository.submitVolunteerApplication(
          userId: _currentUser!.id!,
          experience: experience,
          reason: reason,
          certificateImages: savedPaths,
          newPhone: phone != _currentUser!.phone ? phone : null,
        );
      } else if (_status == 'pending') {
        success = await _userRepository.updateVolunteerApplicationWithTxn(
          userId: _currentUser!.id!,
          experience: experience,
          reason: reason,
          certificateImages: savedPaths,
          newPhone: phone != _currentUser!.phone ? phone : null,
        );
      }

      if (success) {
        _showSnackBar(
          _status == 'none'
              ? 'Pengajuan relawan berhasil dikirim!'
              : 'Pengajuan relawan berhasil diperbarui!',
          isSuccess: true,
        );
        _loadApplicationData();
      } else {
        _showSnackBar('Terjadi kesalahan saat memproses data ke database.');
      }
    } catch (e) {
      debugPrint("Error submitting/updating volunteer application: $e");
      _showSnackBar('Terjadi kesalahan sistem: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _showConfirmDialog() async {
    if (!_formKey.currentState!.validate()) return;

    final isNew = _status == 'none';
    final title = isNew ? "Kirim Pengajuan" : "Simpan Perubahan";
    final content = isNew
        ? "Apakah Anda yakin ingin mengirim pengajuan relawan Anda?"
        : "Apakah Anda yakin ingin menyimpan perubahan pada pengajuan relawan Anda?";

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
            content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Batal",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Ya, Yakin",
                style: TextStyle(
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
      _submitOrUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditable =
        _status == 'none' || (_status == 'pending' && _isEditMode);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _status == 'none'
              ? "Daftar Menjadi Relawan"
              : "Status Pengajuan Relawan",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_status == 'pending')
            IconButton(
              icon: Icon(
                _isEditMode ? Icons.close_rounded : Icons.edit_rounded,
                color: _isEditMode
                    ? AppColors.emergency
                    : AppColors.primaryBlue,
              ),
              onPressed: () {
                if (_isEditMode) {
                  _loadApplicationData();
                } else {
                  setState(() {
                    _isEditMode = true;
                  });
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue,
                ),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Header Card if application exists
                      if (_status != 'none') _buildStatusCard(),

                      const SizedBox(height: 20),

                      // Form Input Container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFEDEEF1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.volunteer_activism_rounded,
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Formulir Pendaftaran",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),

                            // Phone field
                            const Text(
                              "Nomor Telepon (Wajib untuk Relawan)",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              enabled: isEditable,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Nomor telepon wajib diisi.";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Contoh: 081234567890",
                                prefixIcon: const Icon(
                                  Icons.phone_rounded,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: isEditable
                                    ? AppColors.background
                                    : Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Experience field
                            const Text(
                              "Pengalaman Terkait Penanganan Hewan",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _experienceController,
                              enabled: isEditable,
                              maxLines: 4,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Ceritakan pengalaman Anda.";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText:
                                    "Ceritakan pengalaman Anda merawat atau mengevakuasi hewan...",
                                filled: true,
                                fillColor: isEditable
                                    ? AppColors.background
                                    : Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Reason field
                            const Text(
                              "Alasan Ingin Bergabung",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _reasonController,
                              enabled: isEditable,
                              maxLines: 4,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Tuliskan alasan bergabung.";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText:
                                    "Mengapa Anda tertarik menjadi relawan ResQare...",
                                filled: true,
                                fillColor: isEditable
                                    ? AppColors.background
                                    : Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Certificates list
                            const Text(
                              "Foto Sertifikat Pendukung (Maksimal 3)",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              spacing: 12,
                              children: [
                                ...List.generate(_certificateFiles.length, (
                                  index,
                                ) {
                                  final file = _certificateFiles[index];
                                  final exists = file.existsSync();

                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border,
                                          ),
                                          image: exists
                                              ? DecorationImage(
                                                  image: FileImage(file),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: !exists
                                            ? const Center(
                                                child: Icon(
                                                  Icons.broken_image_rounded,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              )
                                            : null,
                                      ),
                                      if (isEditable)
                                        Positioned(
                                          top: -6,
                                          right: -6,
                                          child: GestureDetector(
                                            onTap: () =>
                                                _removeCertificateImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                }),

                                if (isEditable && _certificateFiles.length < 3)
                                  GestureDetector(
                                    onTap: _showImageSourceBottomSheet,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.border,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color: AppColors.textSecondary,
                                            size: 28,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Unggah',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Actions Button
                      if (isEditable)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isSubmitting
                                ? null
                                : _showConfirmDialog,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _status == 'none'
                                            ? Icons.send_rounded
                                            : Icons.save_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _status == 'none'
                                            ? "Kirim Pengajuan Relawan"
                                            : "Simpan Perubahan",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    Color cardColor;
    Color textColor;
    IconData icon;
    String title;
    String desc;
    String? dateInfo;

    switch (_status) {
      case 'pending':
        cardColor = AppColors.waitingRescue.withOpacity(0.1);
        textColor = AppColors.waitingRescue;
        icon = Icons.hourglass_empty_rounded;
        title = "Pengajuan Sedang Ditinjau";
        desc =
            "Tim kami sedang memeriksa data pengajuan Anda. Anda masih dapat memperbarui data pengajuan Anda selagi status masih pending.";
        if (_createdAt != null) {
          dateInfo =
              "Diajukan pada: ${DateFormatter.toReadableDateTime(_createdAt!)}";
        }
        break;
      case 'approved':
        cardColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        title = "Pengajuan Disetujui";
        desc =
            "Selamat! Pengajuan relawan Anda telah disetujui. Akun Anda kini memiliki hak akses penuh sebagai Relawan Penyelamat.";
        final reviewDate = _reviewedAt ?? _updatedAt;
        if (reviewDate != null) {
          dateInfo =
              "Diterima pada: ${DateFormatter.toReadableDateTime(reviewDate)}";
        }
        break;
      case 'rejected':
        cardColor = AppColors.emergency.withOpacity(0.1);
        textColor = AppColors.emergency;
        icon = Icons.cancel_rounded;
        title = "Pengajuan Ditolak";
        desc =
            "Maaf, pengajuan relawan Anda belum dapat disetujui saat ini. Silakan hubungi pusat bantuan kami untuk informasi selengkapnya.";
        final reviewDate = _reviewedAt ?? _updatedAt;
        if (reviewDate != null) {
          dateInfo =
              "Ditolak pada: ${DateFormatter.toReadableDateTime(reviewDate)}";
        }
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (dateInfo != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_filled_rounded,
                          color: textColor,
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateInfo,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
