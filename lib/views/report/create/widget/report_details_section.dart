import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';

class ReportDetailsSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController customCategoryController;
  final TextEditingController descriptionController;
  final String selectedCategory;
  final List<String> animalCategories;
  final ValueChanged<String?> onCategoryChanged;

  const ReportDetailsSection({
    super.key,
    required this.titleController,
    required this.customCategoryController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.animalCategories,
    required this.onCategoryChanged,
  });

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
                Icons.pets_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Detail Hewan & Laporan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Report Title
          const Text(
            "Judul Kejadian Laporan",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: titleController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Harap masukkan judul laporan.";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Contoh: Kucing Terjebak di Atap Toko",
              hintStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              fillColor: AppColors.background,
              filled: true,
              prefixIcon: const Icon(
                Icons.edit_note_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Category Dropdown
          const Text(
            "Kategori Hewan",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryBlue,
            ),
            decoration: InputDecoration(
              fillColor: AppColors.background,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            items: animalCategories.map((String cat) {
              return DropdownMenuItem<String>(
                value: cat,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      cat,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onCategoryChanged,
          ),

          // If "Lainnya" is selected, show field
          if (selectedCategory == "Lainnya") ...[
            const SizedBox(height: 14),
            const Text(
              "Tulis Jenis Hewan Lainnya",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: customCategoryController,
            validator: (value) {
              if (selectedCategory == "Lainnya" && (value == null || value.trim().isEmpty)) {
                return "Harap tentukan jenis hewan.";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Contoh: Musang, Iguana, Tupai...",
              hintStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              fillColor: AppColors.background,
              filled: true,
              prefixIcon: const Icon(
                Icons.category_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],

          const SizedBox(height: 16),

          // Description
          const Text(
            "Deskripsi Kondisi Hewan",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: descriptionController,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Harap masukkan deskripsi kondisi hewan.";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Jelaskan keadaan fisik hewan, cedera, atau bahaya di sekitarnya.",
              hintStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              fillColor: AppColors.background,
              filled: true,
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
