import 'dart:io';

import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/models/report_model.dart';
import 'package:resqare_app/repositories/report_repository.dart';
import 'package:resqare_app/utils/color_badge.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/utils/time.dart';
import 'package:resqare_app/views/report/detail/detail_report_screen.dart';

class RescueHistoryScreen extends StatefulWidget {
  const RescueHistoryScreen({super.key});

  @override
  State<RescueHistoryScreen> createState() => _RescueHistoryScreenState();
}

class _RescueHistoryScreenState extends State<RescueHistoryScreen> {
  final ReportRepository _reportRepository = ReportRepository();
  List<ReportModel> _rescueReports = [];
  List<ReportModel> _userReports = [];
  bool _showRescueHistory = true; // true = Riwayat Rescue, false = Laporan Saya
  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedStatus = 'Semua';

  final List<String> _statuses = [
    'Semua',
    'Pending',
    'Assigned',
    'On Rescue',
    'Completed',
    'Cancelled',
  ];

  bool _matchStatus(String reportStatus, String selectedStatus) {
    if (selectedStatus == 'Semua') return true;
    final rStatus = reportStatus.toLowerCase().trim();
    final sStatus = selectedStatus.toLowerCase().trim();

    if (sStatus == 'pending') {
      return rStatus == 'pending' ||
          rStatus == 'waiting' ||
          rStatus == 'waiting rescue';
    }
    if (sStatus == 'assigned') {
      return rStatus == 'assigned';
    }
    if (sStatus == 'on rescue') {
      return rStatus == 'on rescue' ||
          rStatus == 'on progress' ||
          rStatus == 'on progress rescue';
    }
    if (sStatus == 'completed') {
      return rStatus == 'completed' || rStatus == 'rescued';
    }
    if (sStatus == 'cancelled') {
      return rStatus == 'cancelled';
    }
    return rStatus == sStatus;
  }

  @override
  void initState() {
    super.initState();
    _loadRescueReports();
  }

  Future<void> _loadRescueReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = PreferenceHandler.userId;
      final rescueList = await _reportRepository.getVolunteerReports(userId);
      final userList = await _reportRepository.getUserReports(userId);

      setState(() {
        _rescueReports = rescueList;
        _userReports = userList;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeReportsList = _showRescueHistory
        ? _rescueReports
        : _userReports;

    // Filter the reports based on status & search query using _matchStatus helper
    final filteredReports = activeReportsList.where((report) {
      final matchesStatus = _matchStatus(report.status, _selectedStatus);
      final matchesSearch =
          report.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          report.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (report.description ?? "").toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesStatus && matchesSearch;
    }).toList();

    // Stats calculations dynamically
    final totalReports = activeReportsList.length;
    final activeReports = activeReportsList.where((r) {
      final st = r.status.toLowerCase();
      return st == 'pending' ||
          st == 'waiting' ||
          st == 'waiting rescue' ||
          st == 'assigned' ||
          st == 'on progress' ||
          st == 'on rescue' ||
          st == 'on progress rescue';
    }).length;
    final finishedReports = activeReportsList.where((r) {
      final st = r.status.toLowerCase();
      return st == 'completed' || st == 'rescued' || st == 'cancelled';
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rescue History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRescueReports,
              child: Column(
                children: [
                  // History Category Switcher (Riwayat Rescue vs Laporan Saya)
                  _buildHistorySelector(),

                  // Stats Card Header
                  _buildStatsHeader(
                    _showRescueHistory
                        ? 'Ringkasan Kontribusi'
                        : 'Ringkasan Laporan Anda',
                    totalReports,
                    activeReports,
                    finishedReports,
                  ),

                  // Search & Filter Row
                  _buildSearchAndFilters(),

                  // Reports List
                  Expanded(
                    child: filteredReports.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filteredReports.length,
                            itemBuilder: (context, index) {
                              final report = filteredReports[index];
                              return _buildHistoryCard(report);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHistorySelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 15, 20, 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEF1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showRescueHistory = true;
                  _selectedStatus = 'Semua';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _showRescueHistory ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _showRescueHistory
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Riwayat Rescue',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _showRescueHistory
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showRescueHistory = false;
                  _selectedStatus = 'Semua';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_showRescueHistory
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_showRescueHistory
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Laporan Saya',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: !_showRescueHistory
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(String title, int total, int active, int finished) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildStatItem('Total', total.toString())),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(child: _buildStatItem('Aktif', active.toString())),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(child: _buildStatItem('Selesai', finished.toString())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Cari laporan rescue...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _statuses.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = _statuses[index];
                final isSelected = _selectedStatus == status;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.border,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ReportModel report) {
    final statusColor = ColorUtils.getStatusColor(report.status);
    final isUrgent = report.priorityLevel.toLowerCase() == 'urgent';
    final isMedium = report.priorityLevel.toLowerCase() == 'medium';
    final levelColor = isUrgent
        ? AppColors.emergency
        : isMedium
        ? AppColors.waitingRescue
        : AppColors.rescued;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await context.push(DetailReportScreen(reportId: report.id!));
            _loadRescueReports();
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: FutureBuilder<List<String>>(
                    future: _reportRepository.getReportImages(
                      reportId: report.id ?? 0,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final file = File(snapshot.data!.first);
                        if (file.existsSync()) {
                          return Image.file(
                            file,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          );
                        }
                      }
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppColors.border,
                        child: const Icon(
                          Icons.broken_image,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Urgency
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              report.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: levelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              report.priorityLevel,
                              style: TextStyle(
                                color: levelColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              report.address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Status & Created time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  report.status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Time
                          Text(
                            timeAgo(DateTime.parse(report.createdAt)),
                            style: const TextStyle(
                              fontSize: 11,
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
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _showRescueHistory
                ? 'Tidak ada riwayat rescue'
                : 'Tidak ada riwayat laporan',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Coba ganti filter atau cari kata kunci lain.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
