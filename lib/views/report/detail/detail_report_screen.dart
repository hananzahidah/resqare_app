import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/models/report_model.dart';
import 'package:resqare_app/models/user_model_sql.dart';
import 'package:resqare_app/repositories/report_repository.dart';
import 'package:resqare_app/repositories/user_repository.dart';
import 'package:resqare_app/utils/color_badge.dart';
import 'package:resqare_app/utils/date_formater.dart';
import 'package:resqare_app/utils/string_exntension.dart';
import 'package:resqare_app/views/report/detail/widget/bottom_action_section.dart';
import 'package:resqare_app/views/report/detail/widget/maps_section.dart';
import 'package:resqare_app/views/report/detail/widget/status_bar_section.dart';

class DetailReportScreen extends StatefulWidget {
  final int reportId;
  const DetailReportScreen({super.key, required this.reportId});

  @override
  State<DetailReportScreen> createState() => _DetailReportScreenState();
}

class _DetailReportScreenState extends State<DetailReportScreen> {
  final ReportRepository _reportRepository = ReportRepository();
  final UserRepository _userRepository = UserRepository();

  ReportModel? _report;
  UserModelSql? _reporter;
  UserModelSql? _volunteer;
  List<String> _images = [];
  bool _isLoading = true;

  bool _isLoadingImages = true;
  int _currentImageIndex = 0;

  double? _userLat;
  double? _userLng;

  String? _distanceText;

  String? _reporterProfilePath;
  bool _isLoadingReporter = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('GPS tidak aktif.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Izin lokasi ditolak.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Izin lokasi ditolak secara permanen.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // Akurasi tinggi
      );

      _userLat = position.latitude;
      _userLng = position.longitude;
    } catch (e) {
      debugPrint("Gagal mengambil lokasi: $e");
    }
  }

  // Fetch All Data
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _isLoadingImages = true;
      _isLoadingReporter = true;
    });

    try {
      // Fetch Data Report by ReportID
      final reportData = await _reportRepository.getReportById(
        reportId: widget.reportId,
      );
      if (reportData != null) {
        // Fetch Reporter
        final reporterData = await _userRepository.getUserById(
          reportData.createdBy,
        );

        // Fetch Volunteer
        UserModelSql? volunteerData;
        if (reportData.rescuedBy != null) {
          volunteerData = await _userRepository.getUserById(
            reportData.rescuedBy!,
          );
        }

        // Fetch Report Images
        final imagesData = await _reportRepository.getReportImages(
          reportId: widget.reportId,
        );

        await _getUserLocation();

        // Calculate distance
        String? newDistanceText;
        if (_userLat != null && _userLng != null) {
          final dist = Geolocator.distanceBetween(
            _userLat!,
            _userLng!,
            reportData.latitude,
            reportData.longitude,
          );
          newDistanceText = dist >= 1000
              ? "${(dist / 1000).toStringAsFixed(1)} km"
              : "${dist.toStringAsFixed(0)} m";
        }

        // Save current fetch data to current data
        if (mounted) {
          setState(() {
            _report = reportData;
            _reporter = reporterData;
            _volunteer = volunteerData;
            _images = imagesData;
            _distanceText = newDistanceText;
            _isLoading = false;
            _isLoadingImages = false;
            _isLoadingReporter = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isLoadingImages = false;
            _isLoadingReporter = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading report details: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingImages = false;
          _isLoadingReporter = false;
        });
      }
    }
  }

  bool _shouldShowChatButton() {
    if (_report == null) return false;
    final status = _report!.status.toLowerCase();
    final currentUserId = PreferenceHandler.userId;
    final isReporter = _report!.createdBy == currentUserId;
    final isVolunteer = _report!.rescuedBy == currentUserId;

    final isActiveStatus = status == 'assigned' || status == 'on rescue';
    final isParticipant = isReporter || isVolunteer;

    return isActiveStatus && isParticipant;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final report = _report;
    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Detail Laporan")),
        body: Center(child: Text("Laporan tidak ditemukan.")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomActionSection(
        report: report,
        onActionCompleted: _loadAllData,
      ),
      floatingActionButton: _shouldShowChatButton()
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fitur live chat akan datang segera!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: AppColors.primaryBlue,
              shape: const CircleBorder(),
              child: const Icon(Icons.chat_rounded, color: Colors.white),
            )
          : null,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel Image
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      height: 340,
                      width: double.infinity,
                      child: _isLoadingImages
                          ? Center(child: CircularProgressIndicator())
                          : _images.isEmpty
                          ? Container(
                              color: AppColors.border,
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                            )
                          : PageView.builder(
                              itemCount: _images.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final img = _images[index];
                                final isAsset = img.startsWith('assets/');
                                return isAsset
                                    ? Image.asset(img, fit: BoxFit.cover)
                                    : Image.file(
                                        File(img),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) {
                                          return Container(
                                            color: AppColors.border,
                                            child: Icon(
                                              Icons.broken_image_rounded,
                                              size: 64,
                                              color: AppColors.textSecondary,
                                            ),
                                          );
                                        },
                                      );
                              },
                            ),
                    ),

                    // Gradient
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.background,
                            AppColors.background.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),

                    // Indicator for multiple images
                    if (_images.length > 1)
                      Positioned(
                        bottom: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _images.length,
                            (index) => AnimatedContainer(
                              duration: Duration(milliseconds: 250),
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              height: 6,
                              width: _currentImageIndex == index ? 20 : 6,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index
                                    ? AppColors.primaryBlue
                                    : Colors.white70,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category, Urgency
                      Row(
                        spacing: 10,
                        children: [
                          // level
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ColorUtils.getPriorityColor(
                                report.priorityLevel,
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              report.priorityLevel,
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),

                          // animal category
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 6,
                              children: [
                                Icon(
                                  Icons.pets,
                                  size: 13,
                                  color: AppColors.primaryBlue,
                                ),
                                Text(
                                  report.animalCategory,
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 14),

                      // Title, Date & Distance
                      Column(
                        spacing: 12,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            spacing: 20,
                            children: [
                              Row(
                                spacing: 6,
                                children: [
                                  Icon(Icons.access_time_filled, size: 12),
                                  Text(
                                    DateFormatter.toReadableDateTime(
                                      report.createdAt,
                                    ),
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),

                              Row(
                                spacing: 6,

                                children: [
                                  Icon(Icons.navigation, size: 12),
                                  Text(
                                    _distanceText ?? '-',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 14),

                      // Status Bar
                      StatusBarSection(status: report.status),
                      SizedBox(height: 14),

                      // Description
                      Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Deskripsi Laporan",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            report.description!,
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Animal Condition
                      Column(
                        spacing: 12,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kondisi Hewan",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (report.hasInjury)
                                _buildConditionTag("Luka Fisik"),
                              if (report.hasBleeding)
                                _buildConditionTag("Berdarah"),
                              if (report.cannotWalk)
                                _buildConditionTag("Sulit Bergerak"),
                              if (report.isTrapped)
                                _buildConditionTag("Terjebak"),
                              if (report.isSick)
                                _buildConditionTag("Sakit / Lemas"),
                              if (report.isAbandoned)
                                _buildConditionTag("Terlantar"),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 32),

                      // Reporter Account
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFFEDEEF1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Row(
                          spacing: 14,
                          children: [
                            _buildReporterAvatar(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    spacing: 6,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          text: "Dilaporkan oleh",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),

                                          children: [
                                            TextSpan(
                                              text:
                                                  PreferenceHandler.userId ==
                                                      _reporter!.id
                                                  ? " (Anda)"
                                                  : "",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _reporter!.fullName.toTitleCase(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Volunteer Account
                      if (_volunteer != null) ...[
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(0xFFEDEEF1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Row(
                            spacing: 14,
                            children: [
                              _buildReporterAvatar(),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        text: "Ditangani oleh",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),

                                        children: [
                                          TextSpan(
                                            text:
                                                PreferenceHandler.userId ==
                                                    _volunteer!.id
                                                ? " (Anda)"
                                                : "",
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _volunteer!.fullName.toTitleCase(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                      ] else ...[
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(0xFFEDEEF1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 14,
                            children: [
                              Text(
                                "Laporan belum ditugaskan",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                      SizedBox(height: 16),

                      // Maps
                      MapsSection(report: report),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 48,
            left: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReporterAvatar() {
    if (_reporterProfilePath != null && _reporterProfilePath!.isNotEmpty) {
      final file = File(_reporterProfilePath!);
      if (file.existsSync()) {
        return CircleAvatar(radius: 20, backgroundImage: FileImage(file));
      }
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primaryBlue,
      child: Icon(Icons.person_rounded, color: Colors.white),
    );
  }

  Widget _buildConditionTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.06),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
