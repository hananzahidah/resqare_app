import 'dart:io';

import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/repositories/user_repository.dart';
import 'package:resqare_app/utils/string_exntension.dart';
import 'package:resqare_app/views/home/widgets/carousel_section.dart';
import 'package:resqare_app/views/home/widgets/location_card_section.dart';
import 'package:resqare_app/views/home/widgets/my_reports_section.dart';
import 'package:resqare_app/views/home/widgets/nearby_report_section.dart';

class ReporterHomeScreen extends StatefulWidget {
  const ReporterHomeScreen({super.key});

  @override
  State<ReporterHomeScreen> createState() => _ReporterHomeScreenState();
}

class _ReporterHomeScreenState extends State<ReporterHomeScreen> {
  String _userName = "";
  String? _imgProfile;
  final GlobalKey<NearbyReportSectionState> _nearbyKey = GlobalKey();
  final GlobalKey<MyReportsSectionState> _myReportsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userId = PreferenceHandler.userId;
    if (userId > 0) {
      final user = await UserRepository().getUserById(userId);
      if (user != null && mounted) {
        setState(() {
          _userName = user.fullName.toTitleCase();
          _imgProfile = user.imgProfile;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return "Selamat Pagi,";
    } else if (hour >= 11 && hour < 15) {
      return "Selamat Siang,";
    } else if (hour >= 15 && hour < 19) {
      return "Selamat Sore,";
    } else {
      return "Selamat Malam,";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                spacing: 12,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],

                    radius: 22,
                    backgroundImage:
                        (_imgProfile != null && _imgProfile!.isNotEmpty)
                        ? FileImage(File(_imgProfile!))
                        : null,
                    child: (_imgProfile == null || _imgProfile!.isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  Column(
                    spacing: 2,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getGreeting(), style: TextStyle(fontSize: 12)),
                      Text(
                        _userName,
                        style: TextStyle(
                          // color: AppColors.primaryBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_none_outlined),
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.white,
        toolbarHeight: 75,
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Column(
            children: [
              SizedBox(height: 16),

              // User Current Location
              LocationCardSection(
                onLocationUpdated: () {
                  _nearbyKey.currentState?.loadReports();
                  _myReportsKey.currentState?.loadMyReports();
                },
              ),
              SizedBox(height: 18),

              // Carousel Banner
              CarouselSection(),
              SizedBox(height: 30),

              NearbyReportSection(key: _nearbyKey),
              SizedBox(height: 30),

              MyReportsSection(key: _myReportsKey),
              SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}
