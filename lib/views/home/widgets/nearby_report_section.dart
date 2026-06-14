import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/models/report_model.dart';
import 'package:resqare_app/repositories/report_repository.dart';
import 'package:resqare_app/repositories/user_repository.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/utils/string_exntension.dart';
import 'package:resqare_app/utils/time.dart';
import 'package:resqare_app/views/navigator/bottom_navigator.dart';

class NearbyReportSection extends StatefulWidget {
  const NearbyReportSection({super.key});

  @override
  State<NearbyReportSection> createState() => NearbyReportSectionState();
}

class NearbyReportSectionState extends State<NearbyReportSection> {
  final ReportRepository _reportRepository = ReportRepository();
  final UserRepository _userRepository = UserRepository();
  List<ReportModel> dbReports = [];
  bool isLoadingReports = true;
  double? _userLat;
  double? _userLng;

  Future<void> loadReports() async {
    try {
      final reports = await _reportRepository.getAllReports();

      double userLat = -6.1754;
      double userLng = 106.8271;

      final userId = PreferenceHandler.userId;
      if (userId > 0) {
        final user = await _userRepository.getUserById(userId);
        if (user != null &&
            user.currentLatitude != null &&
            user.currentLongitude != null) {
          userLat = user.currentLatitude!;
          userLng = user.currentLongitude!;
        }
      }

      List<ReportModel> targetedReports = reports;
      final userRole = PreferenceHandler.userRole.toLowerCase();
      if (userRole == 'volunteer') {
        targetedReports = reports
            .where(
              (report) =>
                  report.rescuedBy == null ||
                  report.status.toLowerCase() == 'pending',
            )
            .toList();
      }

      targetedReports.sort((a, b) {
        final distA = Geolocator.distanceBetween(
          userLat,
          userLng,
          a.latitude,
          a.longitude,
        );
        final distB = Geolocator.distanceBetween(
          userLat,
          userLng,
          b.latitude,
          b.longitude,
        );
        return distA.compareTo(distB);
      });

      final limited = targetedReports.take(5).toList();
      if (mounted) {
        setState(() {
          dbReports = limited;
          _userLat = userLat;
          _userLng = userLng;
          isLoadingReports = false;
        });
      }
    } catch (e, stack) {
      debugPrint("Error loading reports in nearby: $e\n$stack");
      if (mounted) {
        setState(() {
          isLoadingReports = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Laporan Terdekat",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.pushAndRemoveAll(BottomNavigator(initialIndex: 1));
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      "Lainnya",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14),
        SizedBox(
          height: 215,
          child: isLoadingReports
              ? Center(child: CircularProgressIndicator())
              : dbReports.isEmpty
              ? Center(
                  child: Text(
                    "Tidak ada laporan penyelamatan baru.",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  itemCount: dbReports.length,
                  separatorBuilder: (_, _) => SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final data = dbReports[index];
                    String distanceText = "";
                    if (_userLat != null && _userLng != null) {
                      final dist = Geolocator.distanceBetween(
                        _userLat!,
                        _userLng!,
                        data.latitude,
                        data.longitude,
                      );
                      if (dist >= 1000) {
                        distanceText = "${(dist / 1000).toStringAsFixed(1)} km";
                      } else {
                        distanceText = "${dist.toStringAsFixed(0)} m";
                      }
                    }

                    final isUrgent =
                        data.priorityLevel.toLowerCase() == "urgent" ||
                        data.priorityLevel.toLowerCase() == "emergency";
                    final isMedium =
                        data.priorityLevel.toLowerCase() == "medium";

                    Color levelColor = Colors.grey;
                    if (isUrgent) {
                      levelColor = AppColors.emergency;
                    } else if (isMedium) {
                      levelColor = AppColors.waitingRescue;
                    } else if (data.priorityLevel.toLowerCase() == "low") {
                      levelColor = AppColors.success;
                    }

                    return GestureDetector(
                      onTap: () {
                        // context.push(DetailReportScreen(data: data));
                      },
                      child: Container(
                        width: 155,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    topRight: Radius.circular(14),
                                  ),
                                  child: SizedBox(
                                    height: 105,
                                    width: double.infinity,
                                    child: FutureBuilder<List<String>>(
                                      future: _reportRepository.getReportImages(
                                        reportId: data.id ?? 0,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data!.isNotEmpty) {
                                          final file = File(
                                            snapshot.data!.first,
                                          );
                                          if (file.existsSync()) {
                                            return Image.file(
                                              file,
                                              fit: BoxFit.cover,
                                            );
                                          }
                                        }
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: levelColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      data.priorityLevel.capitalizeFirst(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          data.address,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (distanceText.isNotEmpty) ...[
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.navigation_rounded,
                                          size: 12,
                                          color: AppColors.primaryBlue,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          distanceText,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        timeAgo(DateTime.parse(data.createdAt)),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
