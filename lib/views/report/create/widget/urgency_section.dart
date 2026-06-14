import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';

class UrgencySection extends StatelessWidget {
  final bool hasInjury;
  final bool hasBleeding;
  final bool cannotWalk;
  final bool isTrapped;
  final bool isSick;
  final bool isAbandoned;

  final ValueChanged<bool> onInjuryChanged;
  final ValueChanged<bool> onBleedingChanged;
  final ValueChanged<bool> onCannotWalkChanged;
  final ValueChanged<bool> onTrappedChanged;
  final ValueChanged<bool> onSickChanged;
  final ValueChanged<bool> onAbandonedChanged;

  final int totalPoints;
  final Color priorityColor;
  final String priorityName;

  const UrgencySection({
    super.key,
    required this.hasInjury,
    required this.hasBleeding,
    required this.cannotWalk,
    required this.isTrapped,
    required this.isSick,
    required this.isAbandoned,
    required this.onInjuryChanged,
    required this.onBleedingChanged,
    required this.onCannotWalkChanged,
    required this.onTrappedChanged,
    required this.onSickChanged,
    required this.onAbandonedChanged,
    required this.totalPoints,
    required this.priorityColor,
    required this.priorityName,
  });

  Widget _buildUrgencyCard({
    required String title,
    required IconData icon,
    required bool selected,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!selected),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.softBlue.withValues(alpha: 0.4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.border,
            width: selected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primaryBlue.withValues(alpha: 0.05)
                  : Colors.transparent,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryBlue.withValues(alpha: 0.12)
                    : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.primaryBlue : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEDEEF1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.emergency_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Identifikasi Tingkat Urgensi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Pilih kondisi darurat yang dialami hewan saat ini.",
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Urgency Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.1,
            children: [
              _buildUrgencyCard(
                title: "Luka Fisik (+2)",
                icon: Icons.personal_injury_rounded,
                selected: hasInjury,
                onChanged: onInjuryChanged,
              ),
              _buildUrgencyCard(
                title: "Berdarah (+3)",
                icon: Icons.bloodtype_rounded,
                selected: hasBleeding,
                onChanged: onBleedingChanged,
              ),
              _buildUrgencyCard(
                title: "Sulit Bergerak (+2)",
                icon: Icons.accessible_rounded,
                selected: cannotWalk,
                onChanged: onCannotWalkChanged,
              ),
              _buildUrgencyCard(
                title: "Terjebak (+2)",
                icon: Icons.grid_goldenratio_rounded,
                selected: isTrapped,
                onChanged: onTrappedChanged,
              ),
              _buildUrgencyCard(
                title: "Sakit / Lemas (+1)",
                icon: Icons.sick_rounded,
                selected: isSick,
                onChanged: onSickChanged,
              ),
              _buildUrgencyCard(
                title: "Terlantar (+1)",
                icon: Icons.home_rounded,
                selected: isAbandoned,
                onChanged: onAbandonedChanged,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Score & Level display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Poin Urgensi",
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$totalPoints Poin",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: priorityColor,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  priorityName,
                  style: TextStyle(
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
