import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/models/report_model.dart';
import 'package:resqare_app/repositories/report_repository.dart';
import 'package:resqare_app/repositories/user_repository.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/report/create/edit_form_screen.dart';

class BottomActionSection extends StatefulWidget {
  final ReportModel report;
  final VoidCallback onActionCompleted;

  const BottomActionSection({
    super.key,
    required this.report,
    required this.onActionCompleted,
  });

  @override
  State<BottomActionSection> createState() => _BottomActionSectionState();
}

class _BottomActionSectionState extends State<BottomActionSection> {
  final ReportRepository _reportRepository = ReportRepository();
  final UserRepository _userRepository = UserRepository();
  bool _isSubmitting = false;
  bool _hasActiveMission = false;
  bool _isLoadingActiveMission = true;

  @override
  void initState() {
    super.initState();
    _checkActiveMission();
  }

  @override
  void didUpdateWidget(covariant BottomActionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.report.status != widget.report.status ||
        oldWidget.report.rescuedBy != widget.report.rescuedBy) {
      _checkActiveMission();
    }
  }

  Future<void> _checkActiveMission() async {
    try {
      final currentUserId = PreferenceHandler.userId;
      final currentUserRole = PreferenceHandler.userRole.toLowerCase();
      if (currentUserRole == 'volunteer') {
        final activeMission = await _reportRepository.getActiveMission(
          currentUserId,
        );
        if (mounted) {
          setState(() {
            _hasActiveMission = activeMission != null;
            _isLoadingActiveMission = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingActiveMission = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking active mission: $e");
      if (mounted) {
        setState(() {
          _isLoadingActiveMission = false;
        });
      }
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(confirmText),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _updateStatus(
    String status, {
    bool isVolunteerCancel = false,
  }) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUserId = PreferenceHandler.userId;

      // Verification checks before assigning a volunteer to a report
      if (status == 'assigned') {
        // 1 volunteer hanya bisa menangani 1 laporan aktif.
        final activeMission = await _reportRepository.getActiveMission(
          currentUserId,
        );
        if (activeMission != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Anda masih memiliki laporan aktif yang sedang ditangani.",
                ),
                backgroundColor: AppColors.emergency,
              ),
            );
          }
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        // 1 laporan hanya bisa ditangani oleh 1 volunteer.
        // Volunteer hanya bisa ambil laporan jika status laporan “pending” dan rescuedBy kosong.
        final latestReport = await _reportRepository.getReportById(
          reportId: widget.report.id ?? 0,
        );
        if (latestReport == null ||
            latestReport.status.toLowerCase() != 'pending' ||
            latestReport.rescuedBy != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Laporan ini sudah ditangani oleh relawan lain atau tidak tersedia.",
                ),
                backgroundColor: AppColors.emergency,
              ),
            );
          }
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
      }

      final Map<String, dynamic> updateData = {
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (status == 'assigned') {
        updateData['status'] = 'assigned';
        updateData['rescuedBy'] = currentUserId;
        updateData['assignedAt'] = DateTime.now().toIso8601String();
      } else if (status == 'on rescue') {
        updateData['status'] = 'on rescue';
        updateData['onRescueAt'] = DateTime.now().toIso8601String();
      } else if (status == 'completed') {
        updateData['status'] = 'completed';
        updateData['completedAt'] = DateTime.now().toIso8601String();
      } else if (status == 'cancelled') {
        if (isVolunteerCancel) {
          updateData['status'] = 'pending';
          updateData['cancelledAt'] = DateTime.now().toIso8601String();
          updateData['cancelledBy'] = currentUserId;
          updateData['rescuedBy'] = null;
          updateData['assignedAt'] = null;
          updateData['onRescueAt'] = null;
        } else {
          updateData['status'] = 'cancelled';
          updateData['cancelledAt'] = DateTime.now().toIso8601String();
        }
      }

      final success = await _reportRepository.updateReport(
        reportId: widget.report.id ?? 0,
        data: updateData,
      );

      if (success) {
        if (status == 'completed') {
          await _userRepository.incrementVolunteerRescueCount(currentUserId);
        }
        await _checkActiveMission();
        widget.onActionCompleted();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal memperbarui status laporan.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error updating report status: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final normalizedStatus = report.status.toLowerCase();
    final currentUserId = PreferenceHandler.userId;
    final currentUserRole = PreferenceHandler.userRole.toLowerCase();
    final isMyReport = report.createdBy == currentUserId;
    final isAssignedToMe = report.rescuedBy == currentUserId;

    final isFinished =
        normalizedStatus == 'completed' ||
        normalizedStatus == 'rescued' ||
        normalizedStatus == 'cancelled';

    if (isFinished) {
      return const SizedBox.shrink();
    }

    if (currentUserRole == 'volunteer' && _isLoadingActiveMission) {
      return const SizedBox.shrink();
    }

    Widget actionWidget;

    if (currentUserRole == 'volunteer') {
      if (normalizedStatus == 'pending') {
        if (_hasActiveMission) {
          actionWidget = Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.emergency.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.emergency.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.emergency,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Saat ini Anda masih memiliki laporan aktif",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.emergency,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        } else {
          actionWidget = ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    final confirm = await _showConfirmationDialog(
                      title: "Terima Tugas",
                      content:
                          "Apakah Anda yakin ingin menerima tugas penyelamatan ini?",
                      confirmText: "Terima",
                      confirmColor: AppColors.primaryBlue,
                    );
                    if (confirm) {
                      _updateStatus('assigned');
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Terima Tugas Penyelamatan",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          );
        }
      } else if (normalizedStatus == 'assigned') {
        if (isAssignedToMe) {
          actionWidget = Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          final confirm = await _showConfirmationDialog(
                            title: "Batalkan Tugas",
                            content:
                                "Apakah Anda yakin ingin membatalkan tugas penyelamatan ini?",
                            confirmText: "Batalkan",
                            confirmColor: AppColors.emergency,
                          );
                          if (confirm) {
                            _updateStatus('cancelled', isVolunteerCancel: true);
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.emergency,
                    side: const BorderSide(
                      color: AppColors.emergency,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    "Batalkan Tugas",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          final confirm = await _showConfirmationDialog(
                            title: "Mulai Evakuasi",
                            content:
                                "Apakah Anda yakin ingin mulai melakukan evakuasi?",
                            confirmText: "Mulai",
                            confirmColor: AppColors.primaryBlue,
                          );
                          if (confirm) {
                            _updateStatus('on rescue');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    "Mulai Evakuasi",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        } else {
          actionWidget = Container(
            width: double.infinity,
            height: 48,
            alignment: Alignment.center,
            child: const Text(
              "Laporan sedang ditangani oleh relawan lain",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
      } else if (normalizedStatus == 'on rescue') {
        if (isAssignedToMe) {
          actionWidget = ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    final confirm = await _showConfirmationDialog(
                      title: "Selesaikan Laporan",
                      content:
                          "Apakah Anda yakin laporan penyelamatan ini telah selesai ditangani?",
                      confirmText: "Selesaikan",
                      confirmColor: AppColors.primaryBlue,
                    );
                    if (confirm) {
                      _updateStatus('completed');
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Selesaikan",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
          );
        } else {
          actionWidget = Container(
            width: double.infinity,
            height: 48,
            alignment: Alignment.center,
            child: const Text(
              "Laporan sedang ditangani oleh relawan lain",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
      } else {
        actionWidget = const SizedBox.shrink();
      }
    } else {
      if (normalizedStatus == 'pending' && isMyReport) {
        actionWidget = Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        final confirm = await _showConfirmationDialog(
                          title: "Batalkan Laporan",
                          content:
                              "Apakah Anda yakin ingin membatalkan laporan penyelamatan ini?",
                          confirmText: "Batalkan",
                          confirmColor: AppColors.emergency,
                        );
                        if (confirm) {
                          _updateStatus('cancelled');
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.emergency,
                  side: const BorderSide(
                    color: AppColors.emergency,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.emergency,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Batalkan Laporan",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        final updated = await context.push(
                          EditFormScreen(report: report),
                        );
                        if (updated == true) {
                          widget.onActionCompleted();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  "Edit Laporan",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      } else if (normalizedStatus == 'on rescue' ||
          normalizedStatus == 'assigned') {
        actionWidget = Container(
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.directions_run_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Relawan sedang dalam perjalanan...",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      } else {
        actionWidget = const SizedBox.shrink();
      }
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
          border: const Border(top: BorderSide(color: Color(0xFFEDEEF1))),
        ),
        child: actionWidget,
      ),
    );
  }
}
