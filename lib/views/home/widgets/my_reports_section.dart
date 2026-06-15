import 'dart:io';

import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/models/report_model.dart';
import 'package:resqare_app/repositories/report_repository.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/utils/time.dart';
import 'package:resqare_app/views/navigator/bottom_navigator.dart';
import 'package:resqare_app/views/report/detail/detail_report_screen.dart';

class MyReportsSection extends StatefulWidget {
  const MyReportsSection({super.key});

  @override
  State<MyReportsSection> createState() => MyReportsSectionState();
}

class MyReportsSectionState extends State<MyReportsSection> {
  final ReportRepository _reportRepository = ReportRepository();
  List<ReportModel> myReports = [];
  bool isLoading = true;

  Future<void> loadMyReports() async {
    try {
      final userId = PreferenceHandler.userId;
      if (userId > 0) {
        final reports = await _reportRepository.getMyActiveReports(userId);
        if (mounted) {
          setState(() {
            myReports = reports;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            myReports = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading my active reports: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadMyReports();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (myReports.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Status Laporan Saya",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.pushAndRemoveAll(BottomNavigator(initialIndex: 3));
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
        SizedBox(height: 12),
        ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: myReports.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = myReports[index];

            // Color settings for statuses
            Color statusBgColor;
            Color statusTextColor;
            String statusLabel = report.status;

            switch (report.status.toLowerCase()) {
              case 'on rescue':
                statusBgColor = Color(0xFFEFF6FF);
                statusTextColor = AppColors.onRescue;
                statusLabel = "Sedang Ditangani";
                break;
              case 'assigned':
                statusBgColor = Color(0xFFEEF2F6);
                statusTextColor = AppColors.primaryBlue;
                statusLabel = "Telah Ditugaskan";
                break;
              case 'completed':
                statusBgColor = Color(0xFFECFDF5);
                statusTextColor = AppColors.rescued;
                statusLabel = "Selesai";
                break;
              case 'cancelled':
                statusBgColor = Color(0xFFFEF2F2);
                statusTextColor = AppColors.emergency;
                statusLabel = "Dibatalkan";
                break;
              case 'pending':
              default:
                statusBgColor = Color(0xFFFFF7ED);
                statusTextColor = AppColors.waitingRescue;
                statusLabel = "Menunggu";
                break;
            }
            return GestureDetector(
              onTap: () async {
                await context.push(DetailReportScreen(reportId: report.id ?? 0));
                loadMyReports();
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                children: [
                  // Image Preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: FutureBuilder<List<String>>(
                        future: _reportRepository.getReportImages(
                          reportId: report.id ?? 0,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            final file = File(snapshot.data!.first);
                            if (file.existsSync()) {
                              return Image.file(file, fit: BoxFit.cover);
                            }
                          }
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.pets_rounded,
                              color: Color(0xFF9CA3AF),
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 14),
                  // Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                report.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                report.address,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Status & Created time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Status
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBgColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: statusTextColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        statusLabel,
                                        style: TextStyle(
                                          color: statusTextColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Time
                            Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 12,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  timeAgo(DateTime.parse(report.createdAt)),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
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
      ],
    );
  }
}
