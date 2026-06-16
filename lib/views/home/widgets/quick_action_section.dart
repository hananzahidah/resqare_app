import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/navigator/bottom_navigator.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickActionSection extends StatefulWidget {
  final bool isReporter;
  const QuickActionSection({super.key, this.isReporter = false});

  @override
  State<QuickActionSection> createState() => _QuickActionSectionState();
}

class _QuickActionSectionState extends State<QuickActionSection> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> volunteerActions = [
      {
        "title": "Explore",
        "subtitle": "Lihat maps",
        "icon": Icons.assignment_turned_in_rounded,
        "color": Color(0xFFEBF3FF),
        "iconColor": AppColors.primaryBlue,
        "onTap": () {
          context.pushAndRemoveAll(BottomNavigator(initialIndex: 1));
        },
      },
      {
        "title": "Kontak SOS",
        "subtitle": "Telp damkar",
        "icon": Icons.contact_phone_rounded,
        "color": Color(0xFFFFF2F2),
        "iconColor": AppColors.emergency,
        "onTap": () async {
          final Uri url = Uri.parse('tel:113');
          try {
            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              debugPrint('Could not launch $url');
            }
          } catch (e) {
            debugPrint('Error launching $url: $e');
          }
        },
      },
      {
        "title": "Statistik",
        "subtitle": "Evaluasi rescue",
        "icon": Icons.query_stats,
        "color": Color(0xFFE6F9F3),
        "iconColor": AppColors.success,
        "onTap": () {
          context.pushAndRemoveAll(BottomNavigator(initialIndex: 3));
        },
      },
      {
        "title": "Laporkan",
        "subtitle": "Kirim info",
        "icon": Icons.add_circle_rounded,
        "color": Color(0xFFFFF7E6),
        "iconColor": AppColors.waitingRescue,
        "onTap": () {
          context.pushAndRemoveAll(BottomNavigator(initialIndex: 2));
        },
      },
    ];

    final List<Map<String, dynamic>> reporterActions = [
      {
        "title": "Laporkan",
        "subtitle": "Kirim info",
        "icon": Icons.add_alert_rounded,
        "color": Color(0xFFFFF7E6),
        "iconColor": AppColors.waitingRescue,
        "onTap": () {
          context.pushAndRemoveAll(BottomNavigator(initialIndex: 2));
        },
      },
      {
        "title": "Kontak SOS",
        "subtitle": "Telp damkar",
        "icon": Icons.phone_in_talk_rounded,
        "color": Color(0xFFFFF2F2),
        "iconColor": AppColors.emergency,
        "onTap": () async {
          final Uri url = Uri.parse('tel:113');
          try {
            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              debugPrint('Could not launch $url');
            }
          } catch (e) {
            debugPrint('Error launching $url: $e');
          }
        },
      },
      {
        "title": "Riwayat",
        "subtitle": "Pantau status",
        "icon": Icons.assignment_rounded,
        "color": Color(0xFFEBF3FF),
        "iconColor": AppColors.primaryBlue,
        "onTap": () {
          context.pushAndRemoveAll(BottomNavigator(initialIndex: 3));
        },
      },
      {
        "title": "Panduan",
        "subtitle": "Tips bantuan",
        "icon": Icons.health_and_safety_rounded,
        "color": Color(0xFFE6F9F3),
        "iconColor": AppColors.success,
        "onTap": () {},
      },
    ];

    final actions = widget.isReporter ? reporterActions : volunteerActions;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 2.4,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return InkWell(
                onTap: action["onTap"] as VoidCallback,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFEDEEF1), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: action["color"],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          action["icon"],
                          color: action["iconColor"],
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action["title"],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              action["subtitle"],
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
