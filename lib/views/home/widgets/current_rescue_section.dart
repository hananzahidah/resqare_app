import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/models/report_model.dart';
import 'package:resqare_app/repositories/report_repository.dart';
import 'package:resqare_app/repositories/user_repository.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/report/detail/detail_report_screen.dart';

class CurrentRescueSection extends StatefulWidget {
  final ValueChanged<bool> onActiveStatusChanged;
  final VoidCallback? onRefreshRequired;

  const CurrentRescueSection({
    super.key,
    required this.onActiveStatusChanged,
    this.onRefreshRequired,
  });

  @override
  State<CurrentRescueSection> createState() => CurrentRescueSectionState();
}

class CurrentRescueSectionState extends State<CurrentRescueSection> {
  final UserRepository _userRepository = UserRepository();
  final ReportRepository _reportRepository = ReportRepository();

  bool _isActive = false;
  bool _isLoading = true;
  ReportModel? _activeMission;

  Future<void> loadVolunteerData() async {
    try {
      final userId = PreferenceHandler.userId;
      if (userId > 0) {
        final active = await _userRepository.isVolunteerActive(userId);
        final mission = await _reportRepository.getActiveMission(userId);

        if (mounted) {
          setState(() {
            _isActive = active;
            _activeMission = mission;
            _isLoading = false;
          });
          widget.onActiveStatusChanged(active);
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading volunteer data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadVolunteerData();
  }

  Future<void> _toggleStatus(bool newValue) async {
    final userId = PreferenceHandler.userId;
    if (userId > 0) {
      final success = await _userRepository.updateVolunteerActive(
        userId,
        newValue,
      );
      if (success) {
        setState(() {
          _isActive = newValue;
        });
        widget.onActiveStatusChanged(newValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEDEEF1), width: 1),
        ),
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, Color(0xFF5A94F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: _isActive ? 0.25 : 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isActive
                          ? Icons.wifi_tethering
                          : Icons.portable_wifi_off_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mode Relawan",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isActive
                            ? "Aktif (Siaga Penyelamatan)"
                            : "Offline (Sedang Istirahat)",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              CupertinoSwitch(
                value: _isActive,
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                thumbColor: _isActive ? AppColors.primaryBlue : Colors.white,
                onChanged: _toggleStatus,
              ),
            ],
          ),

          // Active Rescue Section
          if (_isActive && _activeMission != null) ...[
            Divider(height: 24, color: Colors.white.withValues(alpha: 0.2)),
            Text(
              "Tugas Penyelamatan Aktif",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () async {
                await context.push(
                  DetailReportScreen(reportId: _activeMission!.id ?? 0),
                );
                loadVolunteerData();
                widget.onRefreshRequired?.call();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title and Location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeMission!.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors
                                  .textPrimary, // Coklat gelap, bukan hitam pekat
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.near_me_rounded,
                                size: 11,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _activeMission!.address,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.primaryBlue,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_isActive) ...[
            Divider(height: 24, color: Colors.white.withValues(alpha: 0.2)),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.radar_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Memindai area sekitar untuk tugas...",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Divider(height: 24, color: Colors.white.withValues(alpha: 0.2)),
            Text(
              "Tugas Penyelamatan Aktif",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Saat ini Anda istirahat",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
