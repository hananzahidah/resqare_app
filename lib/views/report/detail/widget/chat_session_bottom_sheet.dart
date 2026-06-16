import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/models/report_model.dart';
import 'package:resqare_app/models/user_model_sql.dart';
import 'package:resqare_app/repositories/user_repository.dart';

class ChatSessionBottomSheet extends StatefulWidget {
  final ReportModel report;
  final List<int> volunteerIds;
  final Function(int volunteerId, String volunteerName) onSessionSelected;

  const ChatSessionBottomSheet({
    super.key,
    required this.report,
    required this.volunteerIds,
    required this.onSessionSelected,
  });

  @override
  State<ChatSessionBottomSheet> createState() => _ChatSessionBottomSheetState();
}

class _ChatSessionBottomSheetState extends State<ChatSessionBottomSheet> {
  final UserRepository _userRepository = UserRepository();
  final Map<int, UserModelSql> _volunteersData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVolunteersData();
  }

  Future<void> _loadVolunteersData() async {
    try {
      for (final id in widget.volunteerIds) {
        final user = await _userRepository.getUserById(id);
        if (user != null) {
          _volunteersData[id] = user;
        }
      }
    } catch (e) {
      debugPrint("Error loading volunteers data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: MainContentWidget(
        isLoading: _isLoading,
        widget: widget,
        volunteersData: _volunteersData,
      ),
    );
  }
}

class MainContentWidget extends StatelessWidget {
  const MainContentWidget({
    super.key,
    required bool isLoading,
    required this.widget,
    required Map<int, UserModelSql> volunteersData,
  }) : _isLoading = isLoading,
       _volunteersData = volunteersData;

  final bool _isLoading;
  final ChatSessionBottomSheet widget;
  final Map<int, UserModelSql> _volunteersData;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Pilih Sesi Obrolan",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Laporan ini ditangani oleh beberapa relawan. Pilih sesi obrolan yang ingin Anda lihat.",
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.volunteerIds.length,
            separatorBuilder: (context, index) =>
                const Divider(color: AppColors.border, height: 1),
            itemBuilder: (context, index) {
              final vId = widget.volunteerIds[index];
              final volunteer = _volunteersData[vId];
              final name = volunteer?.fullName ?? "Relawan #$vId";

              final isRescuer = widget.report.rescuedBy == vId;
              final reportStatus = widget.report.status.toLowerCase();
              final isCompleted =
                  reportStatus == 'completed' || reportStatus == 'rescued';

              final String subtitleText;
              final String badgeText;
              final Color badgeColor;
              final Color badgeBgColor;
              final Color avatarBgColor;
              final Color avatarTextColor;

              if (isRescuer) {
                if (isCompleted) {
                  subtitleText = "Telah menyelesaikan laporan Anda";
                  badgeText = "Selesai";
                  badgeColor = AppColors.success;
                  badgeBgColor = AppColors.success.withValues(alpha: 0.12);
                  avatarBgColor = AppColors.primaryBlue;
                  avatarTextColor = Colors.white;
                } else {
                  subtitleText = "Sedang menangani laporan Anda";
                  badgeText = "Aktif";
                  badgeColor = AppColors.success;
                  badgeBgColor = AppColors.success.withValues(alpha: 0.12);
                  avatarBgColor = AppColors.primaryBlue;
                  avatarTextColor = Colors.white;
                }
              } else {
                subtitleText = "Telah membatalkan penugasan";
                badgeText = "Riwayat";
                badgeColor = AppColors.textSecondary;
                badgeBgColor = AppColors.border;
                avatarBgColor = AppColors.textSecondary.withValues(alpha: 0.15);
                avatarTextColor = AppColors.textSecondary;
              }

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: avatarBgColor,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: avatarTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  subtitleText,
                  style: TextStyle(
                    fontSize: 11,
                    color: isRescuer
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                onTap: () => widget.onSessionSelected(vId, name),
              );
            },
          ),
        ),
      ],
    );
  }
}
