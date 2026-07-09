import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';

class RescueGuideScreen extends StatefulWidget {
  const RescueGuideScreen({super.key});

  @override
  State<RescueGuideScreen> createState() => _RescueGuideScreenState();
}

class _RescueGuideScreenState extends State<RescueGuideScreen> {
  String _selectedCategory = "Semua";

  final List<String> _categories = [
    "Semua",
    "Pertolongan Pertama",
    "Penanganan Khusus",
    "Alat & Bahan",
  ];

  final List<Map<String, dynamic>> _guides = [
    {
      "title": "Mendekati Hewan Liar atau Ketakutan",
      "category": "Penanganan Khusus",
      "icon": Icons.pets_rounded,
      "summary":
          "Langkah aman mendekati kucing atau anjing liar yang takut agar tidak menyerang.",
      "steps": [
        "Jaga ketenangan: Jangan melakukan gerakan tiba-tiba atau bersuara keras.",
        "Merendahkan posisi tubuh: Jongkok perlahan agar Anda terlihat tidak mengintimidasi.",
        "Hindari kontak mata langsung: Kontak mata langsung dapat dianggap sebagai ancaman.",
        "Biarkan hewan mencium aroma Anda: Ulurkan punggung tangan dengan santai dari jarak aman.",
        "Gunakan makanan penarik: Letakkan makanan kering/basah di dekatnya secara perlahan.",
      ],
    },
    {
      "title": "Pertolongan Pertama pada Pendarahan",
      "category": "Pertolongan Pertama",
      "icon": Icons.healing_rounded,
      "summary":
          "Cara menghentikan pendarahan luar akibat luka sayat atau gigitan.",
      "steps": [
        "Pastikan keamanan diri sendiri menggunakan sarung tangan jika ada.",
        "Gunakan kain bersih atau kassa steril untuk menekan langsung pada luka.",
        "Terapkan tekanan lembut secara konstan selama 3-5 menit.",
        "Jangan melepas kain jika darah menembusnya; tambahkan kain baru di atasnya.",
        "Segera buat laporan penyelamatan di aplikasi ResQare untuk evakuasi medis lanjut.",
      ],
    },
    {
      "title": "Menolong Hewan Dehidrasi & Lemas",
      "category": "Pertolongan Pertama",
      "icon": Icons.water_drop_rounded,
      "summary":
          "Tindakan awal mengatasi lemas akibat kekurangan cairan dan cuaca panas.",
      "steps": [
        "Pindahkan hewan ke tempat yang teduh, sejuk, dan memiliki sirkulasi udara baik.",
        "Sediakan air bersih bersuhu ruang. Jangan paksa minum jika hewan setengah sadar.",
        "Basahi telapak kaki dan telinga hewan dengan air biasa (bukan air es) untuk menurunkan suhu.",
        "Biarkan hewan beristirahat dan pantau pernapasannya.",
        "Kirim laporan ResQare dengan tanda tingkat urgensi darurat.",
      ],
    },
    {
      "title": "Perlengkapan Rescue Mandiri",
      "category": "Alat & Bahan",
      "icon": Icons.backpack_rounded,
      "summary":
          "Daftar alat sederhana yang wajib ada di kendaraan untuk evakuasi darurat.",
      "steps": [
        "Handuk besar atau selimut tebal untuk memegang kucing liar yang agresif.",
        "Tali leash (penuntun) cadangan untuk mengamankan anjing terlantar.",
        "Makanan kering / camilan wangi (wet food) sebagai penarik perhatian.",
        "Plester, kassa gulung, dan cairan antiseptik pembersih luka ringan.",
        "Pet cargo / kandang jinjing portabel berukuran sedang.",
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredGuides = _selectedCategory == "Semua"
        ? _guides
        : _guides.where((g) => g["category"] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Panduan Penyelamatan",
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F766E).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Tips & Edukasi Medis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Panduan penanganan pertama bagi hewan jalanan yang terlantar dan terluka dengan aman.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white30,
                  size: 60,
                ),
              ],
            ),
          ),

          // Horizontal Category Tabs
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20, right: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : const Color(0xFFEDEEF1),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Search Guides Results List
          Expanded(
            child: filteredGuides.isEmpty
                ? Center(
                    child: Text(
                      "Belum ada panduan di kategori ini.",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredGuides.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = filteredGuides[index];
                      return _buildGuideCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(Map<String, dynamic> item) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEDEEF1), width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.softBlue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item["icon"] as IconData,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          title: Text(
            item["title"] as String,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              item["summary"] as String,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          childrenPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
          ),
          children: [
            const Divider(color: Color(0xFFEDEEF1), height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (item["steps"] as List<String>).asMap().entries.map((
                entry,
              ) {
                final idx = entry.key + 1;
                final text = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "$idx",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
