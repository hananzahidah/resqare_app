import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/models/notification_model_firebase.dart';
import 'package:resqare_app/repositories/notification_repository_firebase.dart';
import 'package:resqare_app/repositories/report_repository_firebase.dart';
import 'package:resqare_app/repositories/user_repository_firebase.dart';
import 'package:resqare_app/views/profile/volunteer_application_screen.dart';
import 'package:resqare_app/views/report/detail/detail_report_screen.dart';
import 'package:resqare_app/views/report/detail/widget/chat_room_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationRepositoryFirebase _notificationRepository =
      NotificationRepositoryFirebase();
  final ReportRepositoryFirebase _reportRepository = ReportRepositoryFirebase();
  final UserRepositoryFirebase _userRepository = UserRepositoryFirebase();

  late final String _currentUserId;
  late Stream<List<NotificationModelFirebase>> _notificationsStream;
  bool _isHandlingTap = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = PreferenceHandler.userId;
    _refreshNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      _notificationsStream = _notificationRepository.streamNotifications(
        _currentUserId,
      );
    });
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final localDate = date.toLocal();
      final now = DateTime.now();
      final diff = now.difference(localDate);

      if (diff.inMinutes < 1) {
        return "Baru saja";
      } else if (diff.inMinutes < 60) {
        return "${diff.inMinutes} menit yang lalu";
      } else if (diff.inHours < 24) {
        return "${diff.inHours} jam yang lalu";
      } else {
        return "${localDate.day}/${localDate.month}/${localDate.year}";
      }
    } catch (e) {
      return "";
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'report_created':
        return Icons.post_add_rounded;
      case 'report_claimed':
        return Icons.assignment_ind_rounded;
      case 'rescue_status':
        return Icons.healing_rounded;
      case 'volunteer_status':
        return Icons.verified_user_rounded;
      case 'new_chat':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'report_created':
        return AppColors.waitingRescue;
      case 'report_claimed':
        return AppColors.primaryBlue;
      case 'rescue_status':
        return AppColors.success;
      case 'volunteer_status':
        return const Color(0xFF3F51B5);
      case 'new_chat':
        return const Color(0xFFE91E63);
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _handleNotificationTap(NotificationModelFirebase notif) async {
    if (_isHandlingTap) return;
    setState(() {
      _isHandlingTap = true;
    });

    try {
      // Mark notification as read
      if (!notif.isRead && notif.id != null) {
        await _notificationRepository.markAsRead(notif.id!);
      }

      if (!mounted) return;

      // Navigate based on type
      if (notif.type == 'new_chat') {
        final report = await _reportRepository.getReportById(
          reportId: notif.referenceId,
        );
        if (report == null) return;

        final isReporter = report.createdBy == _currentUserId;
        final otherUserId = isReporter
            ? (report.rescuedBy ?? "")
            : report.createdBy;
        final otherUser = await _userRepository.getUserById(otherUserId);
        final otherUserName = otherUser?.fullName ?? "Pengguna ResQare";

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              report: report,
              volunteerId: report.rescuedBy ?? "",
              otherUserName: otherUserName,
            ),
          ),
        );
      } else if (notif.type == 'volunteer_status') {
        final user = await _userRepository.getUserById(_currentUserId);
        if (user == null) return;

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VolunteerApplicationScreen(user: user),
          ),
        );
      } else {
        // report_created, report_claimed, rescue_status
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailReportScreen(reportId: notif.referenceId),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error handling notification tap: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isHandlingTap = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Pengguna tidak terautentikasi")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Notifikasi",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _notificationRepository.markAllAsRead(_currentUserId);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Semua notifikasi ditandai sebagai dibaca."),
                ),
              );
            },
            child: const Text(
              "Tandai Dibaca",
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshNotifications();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: AppColors.primaryBlue,
        child: StreamBuilder<List<NotificationModelFirebase>>(
          stream: _notificationsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlue,
                  ),
                ),
              );
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: constraints.maxHeight,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.primaryBlue,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Belum Ada Notifikasi",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Aktivitas penyelamatan & pesan Anda\nakan tampil di sini.",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final iconColor = _getColorForType(notif.type);

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFEDEEF1), width: 1),
                  ),
                  color: notif.isRead
                      ? AppColors.white
                      : AppColors.softBlue.withOpacity(0.1),
                  child: InkWell(
                    onTap: () => _handleNotificationTap(notif),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon indicator
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForType(notif.type),
                              color: iconColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontWeight: notif.isRead
                                              ? FontWeight.bold
                                              : FontWeight.w900,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (!notif.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryBlue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.body,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDate(notif.createdAt),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary.withOpacity(
                                      0.8,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
