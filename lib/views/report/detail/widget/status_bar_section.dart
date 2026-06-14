import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';

class StatusBarSection extends StatefulWidget {
  final String status;
  const StatusBarSection({super.key, required this.status});

  @override
  State<StatusBarSection> createState() => _StatusBarSectionState();
}

class _StatusBarSectionState extends State<StatusBarSection> {
  @override
  Widget build(BuildContext context) {
    int currentStep = 0;
    final normalizedStatus = widget.status.toLowerCase();

    if (normalizedStatus == 'waiting' ||
        normalizedStatus == 'waiting rescue' ||
        normalizedStatus == 'pending') {
      currentStep = 0;
    } else if (normalizedStatus == 'assigned') {
      currentStep = 1;
    } else if (normalizedStatus == 'on progress' ||
        normalizedStatus == 'on rescue' ||
        normalizedStatus == 'on progress rescue') {
      currentStep = 2;
    } else if (normalizedStatus == 'completed' ||
        normalizedStatus == 'rescued') {
      currentStep = 3;
    } else if (normalizedStatus == 'cancelled') {
      currentStep = -1;
    }

    if (currentStep == -1) {
      return Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.emergency.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.emergency.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_rounded, color: AppColors.emergency),
            SizedBox(width: 8),
            Text(
              "Laporan ini telah dibatalkan",
              style: TextStyle(
                color: AppColors.emergency,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      {"label": "Dilaporkan", "icon": Icons.campaign_rounded},
      {"label": "Diterima", "icon": Icons.handshake_rounded},
      {"label": "Evakuasi", "icon": Icons.directions_run_rounded},
      {"label": "Selesai", "icon": Icons.check_circle_rounded},
    ];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFEDEEF1)),
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
          Text(
            "Status Penyelamatan",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final stepLabel = step["label"] as String;
              final stepIcon = step["icon"] as IconData;

              final isCompleted = index < currentStep;
              final isActive = index == currentStep;

              Color circleColor;
              Color iconColor;
              Color textColor;

              if (isCompleted) {
                circleColor = AppColors.primaryBlue;
                iconColor = Colors.white;
                textColor = AppColors.textPrimary;
              } else if (isActive) {
                circleColor = AppColors.primaryBlue;
                iconColor = Colors.white;
                textColor = AppColors.primaryBlue;
              } else {
                circleColor = AppColors.border;
                iconColor = AppColors.textSecondary;
                textColor = AppColors.textSecondary;
              }

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 3,
                            color: index == 0
                                ? Colors.transparent
                                : (index <= currentStep
                                      ? AppColors.primaryBlue
                                      : AppColors.border),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: circleColor,
                            shape: BoxShape.circle,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : stepIcon,
                            size: 16,
                            color: iconColor,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 3,
                            color: index == steps.length - 1
                                ? Colors.transparent
                                : (index < currentStep
                                      ? AppColors.primaryBlue
                                      : AppColors.border),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      stepLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
