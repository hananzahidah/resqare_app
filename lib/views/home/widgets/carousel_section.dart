import 'dart:async';

import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/navigator/bottom_navigator.dart';

class CarouselSection extends StatefulWidget {
  const CarouselSection({super.key});

  @override
  State<CarouselSection> createState() => _CarouselSectionState();
}

class _CarouselSectionState extends State<CarouselSection> {
  final PageController _pageController = PageController();
  int _currentCarousel = 0;
  Timer? _carouselTimer;

  final List<Map<String, dynamic>> _carouselBanners = [
    {
      "title": "Lakukan Laporan",
      "subtitle":
          "Lihat hewan terluka atau dalam bahaya? Laporkan segera untuk diselamatkan!",
      "icon": Icons.campaign_rounded,
      "buttonText": "Laporkan Sekarang",
      "gradient": LinearGradient(
        colors: [Color(0xFFFF5252), Color(0xFFFF7A00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      "title": "Jadilah Volunteer",
      "subtitle":
          "Bantu evakuasi hewan di sekitarmu dan jadilah pahlawan bagi mereka.",
      "icon": Icons.handshake_rounded,
      "buttonText": "Gabung Volunteer",
      "gradient": LinearGradient(
        colors: [Color(0xFF327AF4), Color(0xFF00C6FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      "title": "Panduan Penyelamatan",
      "subtitle":
          "Pelajari langkah pertama yang aman saat menemukan hewan terlantar atau terluka.",
      "icon": Icons.menu_book_rounded,
      "buttonText": "Baca Panduan",
      "gradient": const LinearGradient(
        colors: [Color(0xFF14B8A6), Color(0xFF0F766E)], // Warna Teal / Tosca
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextCarousel = _currentCarousel + 1;
        if (nextCarousel >= _carouselBanners.length) {
          nextCarousel = 0;
        }
        _pageController.animateToPage(
          nextCarousel,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 175,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                _currentCarousel = index;
              });
            },
            itemCount: _carouselBanners.length,
            itemBuilder: (context, index) {
              final banner = _carouselBanners[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: banner["gradient"],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (banner["gradient"] as LinearGradient)
                              .colors
                              .first
                              .withOpacity(0.35),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -15,
                          bottom: -15,
                          child: Icon(
                            banner["icon"],
                            size: 130,
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    banner["title"],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Text(
                                      banner["subtitle"],
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor:
                                      (banner["gradient"] as LinearGradient)
                                          .colors
                                          .first,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () {
                                  if (index == 0) {
                                    context.pushReplacement(
                                      BottomNavigator(initialIndex: 2),
                                    );
                                  }
                                },
                                child: Text(
                                  banner["buttonText"],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _carouselBanners.length,
            (index) => AnimatedContainer(
              duration: Duration(milliseconds: 400),
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: _currentCarousel == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentCarousel == index
                    ? AppColors.primaryBlue
                    : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
