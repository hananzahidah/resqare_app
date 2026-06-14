import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/models/report_model.dart';
import 'package:resqare_app/repositories/report_repository.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/utils/string_exntension.dart';
import 'package:resqare_app/views/report/create/success_report_screen.dart';
import 'package:resqare_app/views/report/create/widget/location_selection_section.dart';
import 'package:resqare_app/views/report/create/widget/photo_upload_section.dart';
import 'package:resqare_app/views/report/create/widget/report_details_section.dart';
import 'package:resqare_app/views/report/create/widget/urgency_section.dart';

class EditFormScreen extends StatefulWidget {
  final ReportModel report;

  const EditFormScreen({super.key, required this.report});

  @override
  State<EditFormScreen> createState() => _EditFormScreenState();
}

class _EditFormScreenState extends State<EditFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _customCategoryController;

  final ReportRepository _reportRepository = ReportRepository();

  // Selected image files (max 3)
  final List<File> _selectedImages = [];
  final List<String> _initialImagePaths = [];
  final ImagePicker _picker = ImagePicker();
  final int _maxPhotos = 3;

  // Animal categories dropdown
  late String _selectedCategory;
  final List<String> _animalCategories = [
    "Kucing",
    "Anjing",
    "Burung",
    "Ular",
    "Lainnya",
  ];

  // Urgency check flags
  late bool _hasInjury;
  late bool _hasBleeding;
  late bool _cannotWalk;
  late bool _isTrapped;
  late bool _isSick;
  late bool _isAbandoned;

  // Location parameters
  Position? _currentPosition;
  late String _locationAddress;
  bool _isLoadingLocation = false;
  final MapController _mapController = MapController();

  bool _isSubmitting = false;
  bool _isLoadingImages = true;

  // Calculated Urgency Level
  int get _totalPoints {
    int points = 0;
    if (_hasInjury) points += 2;
    if (_hasBleeding) points += 3;
    if (_cannotWalk) points += 2;
    if (_isTrapped) points += 2;
    if (_isSick) points += 1;
    if (_isAbandoned) points += 1;
    return points;
  }

  String get _priorityLevel {
    int points = _totalPoints;
    if (points >= 5) return "Urgent";
    if (points >= 2) return "Medium";
    return "Low";
  }

  Color get _priorityColor {
    int points = _totalPoints;
    if (points >= 5) return AppColors.emergency;
    if (points >= 2) return AppColors.waitingRescue;
    return AppColors.success;
  }

  String get _priorityName {
    int points = _totalPoints;
    if (points >= 5) return "Mendesak / Urgent";
    if (points >= 2) return "Sedang / Medium";
    return "Rendah / Low";
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title);
    _descriptionController = TextEditingController(text: widget.report.description);
    _customCategoryController = TextEditingController();

    if (_animalCategories.contains(widget.report.animalCategory)) {
      _selectedCategory = widget.report.animalCategory;
    } else {
      _selectedCategory = "Lainnya";
      _customCategoryController.text = widget.report.animalCategory;
    }

    _hasInjury = widget.report.hasInjury;
    _hasBleeding = widget.report.hasBleeding;
    _cannotWalk = widget.report.cannotWalk;
    _isTrapped = widget.report.isTrapped;
    _isSick = widget.report.isSick;
    _isAbandoned = widget.report.isAbandoned;

    _locationAddress = widget.report.address;
    _currentPosition = Position(
      latitude: widget.report.latitude,
      longitude: widget.report.longitude,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

    _loadReportImages();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _loadReportImages() async {
    try {
      final images = await _reportRepository.getReportImages(
        reportId: widget.report.id ?? 0,
      );
      if (mounted) {
        setState(() {
          _initialImagePaths.addAll(images);
          _selectedImages.addAll(images.map((path) => File(path)));
          _isLoadingImages = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading report images: $e");
      if (mounted) {
        setState(() {
          _isLoadingImages = false;
        });
      }
    }
  }

  // Camera & Gallery handler
  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Maksimal hanya dapat mengunggah $_maxPhotos foto."),
          backgroundColor: AppColors.emergency,
        ),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      debugPrint("ERROR picking image: $e");
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
                  "Unggah Foto Hewan",
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
                          _pickImage(ImageSource.camera);
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
                                "Ambil Foto",
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
                          _pickImage(ImageSource.gallery);
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
                                "Pilih Galeri",
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

  // Location handler (GPS)
  Future<void> _getCurrentLocation() async {
    final bool wasMapRendered = _currentPosition != null;
    setState(() {
      _isLoadingLocation = true;
      _locationAddress = "Sedang mendapatkan lokasi...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _locationAddress =
              "Layanan lokasi dinonaktifkan. Silakan aktifkan GPS.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _locationAddress = "Izin lokasi ditolak.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _locationAddress = "Izin lokasi ditolak secara permanen.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
      });

      // Reverse geocoding
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final List<String> addressParts = [];
          if (place.street != null && place.street!.isNotEmpty) {
            addressParts.add(place.street!);
          }
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            addressParts.add(place.subLocality!);
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            addressParts.add(place.locality!);
          }
          if (place.subAdministrativeArea != null &&
              place.subAdministrativeArea!.isNotEmpty) {
            addressParts.add(place.subAdministrativeArea!);
          }

          setState(() {
            _locationAddress = addressParts.isEmpty
                ? "${place.locality ?? ''}, ${place.country ?? ''}"
                : addressParts.join(", ");
          });
        } else {
          setState(() {
            _locationAddress =
                "Koordinat: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}";
          });
        }
      } catch (e) {
        setState(() {
          _locationAddress =
              "Koordinat: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}";
        });
      }

      if (wasMapRendered) {
        try {
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            16.0,
          );
        } catch (e) {
          debugPrint("Failed to move map controller: $e");
        }
      }
    } catch (e) {
      setState(() {
        _locationAddress = "Gagal memuat lokasi: $e";
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // Database Logic
  Future<void> _updateReport() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final reportId = widget.report.id ?? 0;
      final animalCategory = _selectedCategory == "Lainnya"
          ? _customCategoryController.text.trim().capitalizeFirst()
          : _selectedCategory;

      // Prepare updated report map
      final Map<String, dynamic> updateData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'animalCategory': animalCategory,
        'priorityLevel': _priorityLevel,
        'latitude': _currentPosition?.latitude ?? widget.report.latitude,
        'longitude': _currentPosition?.longitude ?? widget.report.longitude,
        'address': _locationAddress,
        'hasInjury': _hasInjury ? 1 : 0,
        'hasBleeding': _hasBleeding ? 1 : 0,
        'cannotWalk': _cannotWalk ? 1 : 0,
        'isTrapped': _isTrapped ? 1 : 0,
        'isSick': _isSick ? 1 : 0,
        'isAbandoned': _isAbandoned ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // 1. Identify deleted images (in _initialImagePaths but not in _selectedImages)
      for (final initialPath in _initialImagePaths) {
        final stillSelected = _selectedImages.any((file) => file.path == initialPath);
        if (!stillSelected) {
          // Delete from local file system
          try {
            final file = File(initialPath);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            debugPrint("Error physically deleting file: $e");
          }
          // Delete database record
          await _reportRepository.deleteReportImage(
            reportId: reportId,
            imagePath: initialPath,
          );
        }
      }

      // 2. Add newly added images (in _selectedImages but not in _initialImagePaths)
      final appDir = await getApplicationDocumentsDirectory();
      for (int i = 0; i < _selectedImages.length; i++) {
        final file = _selectedImages[i];
        if (!_initialImagePaths.contains(file.path)) {
          final ext = p.extension(file.path);
          final fileName =
              'report_${reportId}_img_${i}_${DateTime.now().millisecondsSinceEpoch}$ext';
          final savedImageFile = await file.copy('${appDir.path}/$fileName');

          await _reportRepository.addReportImage(
            reportId: reportId,
            imagePath: savedImageFile.path,
          );
        }
      }

      // 3. Update the SQLite record
      final success = await _reportRepository.updateReport(
        reportId: reportId,
        data: updateData,
      );

      if (success) {
        if (!mounted) return;
        // Redirect to Success Screen
        context.pushReplacement(SuccessReportScreen(
          reportId: reportId,
          isUpdate: true,
        ));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memperbarui data laporan ke database SQLite."),
            backgroundColor: AppColors.emergency,
          ),
        );
      }
    } catch (e) {
      debugPrint("ERROR updating report: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Kesalahan saat memperbarui: $e"),
            backgroundColor: AppColors.emergency,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Summary & Confirmation Dialog
  void _showConfirmationSummary() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap unggah minimal 1 foto keadaan."),
          backgroundColor: AppColors.emergency,
        ),
      );
      return;
    }
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap tentukan lokasi penemuan hewan."),
          backgroundColor: AppColors.emergency,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.primaryBlue,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                "Konfirmasi Pembaruan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            "Apakah Anda yakin ingin memperbarui data laporan ini?",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Periksa Kembali",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
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
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _updateReport();
              },
              child: const Text(
                "Perbarui Laporan",
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Edit Laporan Rescue",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isSubmitting || _isLoadingImages
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSubmitting
                        ? "Memperbarui laporan darurat..."
                        : "Memuat data laporan...",
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. FOTO KEADAAN (PHOTO UPLOAD CARD)
                      PhotoUploadSection(
                        selectedImages: _selectedImages,
                        maxPhotos: _maxPhotos,
                        onAddPhotoTap: _showImageSourceBottomSheet,
                        onRemovePhoto: (index) {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // 2. HEWAN & DETAIL LAPORAN
                      ReportDetailsSection(
                        titleController: _titleController,
                        customCategoryController: _customCategoryController,
                        descriptionController: _descriptionController,
                        selectedCategory: _selectedCategory,
                        animalCategories: _animalCategories,
                        onCategoryChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCategory = val;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // 3. TINGKAT URGENSI (URGENCY CHIP GRID)
                      UrgencySection(
                        hasInjury: _hasInjury,
                        hasBleeding: _hasBleeding,
                        cannotWalk: _cannotWalk,
                        isTrapped: _isTrapped,
                        isSick: _isSick,
                        isAbandoned: _isAbandoned,
                        onInjuryChanged: (val) =>
                            setState(() => _hasInjury = val),
                        onBleedingChanged: (val) =>
                            setState(() => _hasBleeding = val),
                        onCannotWalkChanged: (val) =>
                            setState(() => _cannotWalk = val),
                        onTrappedChanged: (val) =>
                            setState(() => _isTrapped = val),
                        onSickChanged: (val) => setState(() => _isSick = val),
                        onAbandonedChanged: (val) =>
                            setState(() => _isAbandoned = val),
                        totalPoints: _totalPoints,
                        priorityColor: _priorityColor,
                        priorityName: _priorityName,
                      ),

                      const SizedBox(height: 20),

                      // 4. LOKASI PENEMUAN (MAPS CARD)
                      LocationSelectionSection(
                        currentPosition: _currentPosition,
                        locationAddress: _locationAddress,
                        isLoadingLocation: _isLoadingLocation,
                        mapController: _mapController,
                        onLoadLocationTap: _getCurrentLocation,
                      ),

                      const SizedBox(height: 32),

                      // SUBMIT ACTION BUTTON
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
                          onPressed: _showConfirmationSummary,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Simpan Perubahan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
