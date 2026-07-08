import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/repositories/notification_repository_firebase.dart';
import 'package:resqare_app/views/notification/notification_screen.dart';

class NotificationBell extends StatelessWidget {
  final Color? color;

  const NotificationBell({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = PreferenceHandler.userId;
    final repo = NotificationRepositoryFirebase();

    if (currentUserId.isEmpty) {
      return const SizedBox.shrink();
    }

    final iconColor = color ?? AppColors.textPrimary;

    return StreamBuilder<int>(
      stream: repo.streamUnreadCount(currentUserId),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                color: iconColor,
                size: 26,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.emergency,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
