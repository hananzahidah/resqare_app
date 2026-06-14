import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
// Pastikan Anda mengimpor file AppColors Anda di sini
// import 'package:resqare_app/constant/app_color.dart';

class ColorUtils {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'waiting':
      case 'waiting rescue':
      case 'pending':
        return AppColors.waitingRescue;
      case 'assigned':
        return AppColors.primaryBlue;
      case 'on progress':
      case 'on rescue':
        return AppColors.onRescue;
      case 'completed':
      case 'rescued':
        return AppColors.rescued;
      case 'cancelled':
        return AppColors.emergency;
      default:
        return AppColors.textSecondary;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
      case 'emergency':
        return AppColors.emergency;
      case 'medium':
        return AppColors.waitingRescue;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }
}
