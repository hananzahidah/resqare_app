import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/home/home_wrapper_screen.dart';
import 'package:resqare_app/views/report/detail/detail_report_screen.dart';

class SuccessReportScreen extends StatelessWidget {
  final int reportId;
  final bool isUpdate;

  const SuccessReportScreen({
    super.key,
    required this.reportId,
    this.isUpdate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Icon Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              // Success Header
              Text(
                isUpdate ? "Data Laporan Berhasil Diperbarui!" : "Laporan Berhasil Dikirim!",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                isUpdate
                    ? "Perubahan pada laporan darurat Anda telah berhasil disimpan."
                    : "Laporan darurat Anda telah sukses terdaftar di sistem. Relawan terdekat akan segera menerima notifikasi untuk memulai proses penyelamatan.",
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.pushReplacement(DetailReportScreen(
                      reportId: reportId,
                      backToHome: true,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Lihat Detail Laporan",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    context.pushAndRemoveAll(RoleHomeWrapper());
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Kembali ke Beranda",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
