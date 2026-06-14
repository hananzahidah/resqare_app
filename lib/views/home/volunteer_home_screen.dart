import 'dart:io';

import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/repositories/user_repository.dart';
import 'package:resqare_app/utils/time.dart';
import 'package:resqare_app/views/home/widgets/current_rescue_section.dart';
import 'package:resqare_app/views/home/widgets/location_card_section.dart';
import 'package:resqare_app/views/home/widgets/nearby_report_section.dart';
import 'package:resqare_app/views/home/widgets/quick_action_section.dart';

class VolunteerHomeScreen extends StatefulWidget {
  const VolunteerHomeScreen({super.key});

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  String _userName = "";
  String? _imgProfile;
  bool _isVolunteerActive = false;

  final GlobalKey<NearbyReportSectionState> _nearbyKey = GlobalKey();
  final GlobalKey<CurrentRescueSectionState> _currentRescueKey = GlobalKey();

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
          _userName = user.fullName;
          _imgProfile = user.imgProfile;
        });
      }
    }
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
                    backgroundColor: AppColors.softBlue,
                    radius: 22,
                    backgroundImage:
                        (_imgProfile != null && _imgProfile!.isNotEmpty)
                        ? FileImage(File(_imgProfile!))
                        : null,
                    child: (_imgProfile == null || _imgProfile!.isEmpty)
                        ? Icon(Icons.person)
                        : null,
                  ),
                  Column(
                    spacing: 2,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getGreeting(), style: TextStyle(fontSize: 12)),
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
                  _currentRescueKey.currentState?.loadVolunteerData();
                  if (_isVolunteerActive) {
                    _nearbyKey.currentState?.loadReports();
                  }
                },
              ),
              SizedBox(height: 16),

              // Current Rescue & Toggle active status
              CurrentRescueSection(
                key: _currentRescueKey,
                onActiveStatusChanged: (isActive) {
                  if (mounted && _isVolunteerActive != isActive) {
                    setState(() {
                      _isVolunteerActive = isActive;
                    });
                  }
                },
              ),
              SizedBox(height: 16),

              QuickActionSection(),
              SizedBox(height: 16),

              // Conditional Report List
              _isVolunteerActive
                  ? NearbyReportSection(key: _nearbyKey)
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFFFEF3C7), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.nightlight_round_sharp,
                            color: AppColors.primaryBlue,
                            size: 28,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mode Istirahat Aktif",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Aktifkan mode Relawan untuk melihat laporan masuk terdekat dari posisi Anda saat ini.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}
