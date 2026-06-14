import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';

class QuickActionSection extends StatefulWidget {
  const QuickActionSection({super.key});

  @override
  State<QuickActionSection> createState() => _QuickActionSectionState();
}

class _QuickActionSectionState extends State<QuickActionSection> {
  final List<Map<String, dynamic>> actions = [
    {
      "title": "Misi Rescue",
      "subtitle": "Lihat tugas aktif",
      "icon": Icons.assignment_turned_in_rounded,
      "color": const Color(0xFFEBF3FF),
      "iconColor": AppColors.primaryBlue,
      "onTap": () {},
    },
    {
      "title": "Kontak SOS",
      "subtitle": "Hubungi damkar",
      "icon": Icons.contact_phone_rounded,
      "color": const Color(0xFFFFF2F2),
      "iconColor": AppColors.emergency,
      "onTap": () {},
    },
    {
      "title": "Statistik",
      "subtitle": "Evaluasi rescue",
      "icon": Icons.query_stats,
      "color": const Color(0xFFE6F9F3),
      "iconColor": AppColors.success,
      "onTap": () {},
    },
    {
      "title": "Laporkan",
      "subtitle": "Kirim info baru",
      "icon": Icons.add_circle_rounded,
      "color": const Color(0xFFFFF7E6),
      "iconColor": AppColors.waitingRescue,
      "onTap": () {},
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEDEEF1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action["title"],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              action["subtitle"],
                              style: const TextStyle(
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
