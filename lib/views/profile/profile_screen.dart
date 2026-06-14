import 'dart:io';

import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/models/user_model_sql.dart';
import 'package:resqare_app/repositories/user_repository.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/auth/login_screen.dart';
import 'package:resqare_app/views/profile/edit_profile_screen.dart';
import 'package:resqare_app/views/profile/volunteer_application_screen.dart';
import 'package:sqlite_viewer2/sqlite_viewer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  UserModelSql? _user;
  int _reportsCreated = 0;
  int _rescueCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final userId = PreferenceHandler.userId;
    final user = await _userRepository.getUserById(userId);
    if (user != null) {
      _user = user;
      if (user.id != null) {
        final stats = await _userRepository.getUserStats(user.id!);
        _reportsCreated = stats['reportsCreated'] ?? 0;
        _rescueCount = stats['rescueCount'] ?? 0;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Change Password Bottom Sheet
  void _showChangePasswordBottomSheet() {
    if (_user == null) return;

    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ganti Kata Sandi",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  "Kata Sandi Lama",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Masukkan kata sandi lama";
                    }
                    if (value != _user!.password) {
                      return "Kata sandi lama salah";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Kata sandi lama Anda",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Kata Sandi Baru",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Masukkan kata sandi baru";
                    }
                    if (value.length < 6) {
                      return "Kata sandi baru minimal 6 karakter";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Kata sandi baru (min. 6 karakter)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Konfirmasi Kata Sandi Baru",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Konfirmasi kata sandi baru Anda";
                    }
                    if (value != newPasswordController.text) {
                      return "Konfirmasi kata sandi tidak cocok";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Ulangi kata sandi baru",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final newPassword = newPasswordController.text;

                        final success = await _userRepository.updateUser(
                          userId: _user!.id!,
                          data: {'password': newPassword},
                        );

                        if (!context.mounted) return;

                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Kata sandi berhasil diperbarui"),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          _loadUserProfile();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Gagal memperbarui kata sandi"),
                              backgroundColor: AppColors.emergency,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      "Ganti Kata Sandi",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // Logout dialog confirmation
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Konfirmasi Keluar",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            "Apakah Anda yakin ingin keluar dari akun ResQare saat ini?",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergency,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                await PreferenceHandler.logOut();
                if (!context.mounted) return;
                Navigator.pop(context); // Close dialog
                context.pushAndRemoveAll(LoginScreen());
              },
              child: Text(
                "Keluar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      );
    }

    final isVolunteer = _user?.role.toLowerCase() == 'volunteer';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Profile
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Top Cover Background Gradient
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF327AF4), Color(0xFF0D47A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Decorative Circle Shapes
                Positioned(
                  top: -20,
                  right: -30,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white.withOpacity(0.08),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: -20,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.05),
                  ),
                ),
                // Content of Header
                SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: 8),
                      // Screen Title
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Profil Pengguna",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      // Floating Card Profile Details
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.softBlue,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: AppColors.softBlue,
                                backgroundImage:
                                    _user?.imgProfile != null &&
                                        _user!.imgProfile!.isNotEmpty &&
                                        File(_user!.imgProfile!).existsSync()
                                    ? FileImage(File(_user!.imgProfile!))
                                    : null,
                                child:
                                    _user?.imgProfile == null ||
                                        _user!.imgProfile!.isEmpty ||
                                        !File(_user!.imgProfile!).existsSync()
                                    ? Icon(
                                        Icons.person_rounded,
                                        size: 40,
                                        color: AppColors.primaryBlue,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(width: 16),
                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _user?.fullName ?? "Hanan Zahidah",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (_user?.isVerified == 1) ...[
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.verified,
                                          color: AppColors.primaryBlue,
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _user?.email ?? "email@resqare.com",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  // Role Badge
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isVolunteer
                                          ? AppColors.primaryBlue.withOpacity(
                                              0.12,
                                            )
                                          : AppColors.success.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isVolunteer
                                              ? Icons.shield_rounded
                                              : Icons.person_pin_rounded,
                                          size: 12,
                                          color: isVolunteer
                                              ? AppColors.primaryBlue
                                              : AppColors.success,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          isVolunteer
                                              ? "Volunteer / Relawan"
                                              : "Reporter / Pelapor",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isVolunteer
                                                ? AppColors.primaryBlue
                                                : AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // 2. Statistic
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  // Stat Card 1: Reports
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFFEDEEF1), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.softBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.campaign_rounded,
                              color: AppColors.primaryBlue,
                              size: 18,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "$_reportsCreated",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            "Laporan Dibuat",
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 14),
                  // Stat Card 2: Rescues
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFFEDEEF1), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 18,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "$_rescueCount",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            "Penyelamatan",
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Settings
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  // Group 1: Akun & Keamanan
                  Text(
                    "Akun & Keamanan",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFFEDEEF1), width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: "Edit Profil",
                          subtitle: "Nama, nomor HP, detail kontak",
                          onTap: () {
                            if (_user != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfileScreen(user: _user!),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  _loadUserProfile();
                                }
                              });
                            }
                          },
                        ),
                        Divider(height: 1, color: AppColors.divider),
                        _buildMenuTile(
                          icon: Icons.lock_outline_rounded,
                          title: "Ganti Kata Sandi",
                          subtitle: "Perbarui kata sandi akun Anda",
                          onTap: _showChangePasswordBottomSheet,
                        ),
                        if (!isVolunteer) ...[
                          Divider(height: 1, color: AppColors.divider),
                          _buildMenuTile(
                            icon: Icons.volunteer_activism_outlined,
                            title: "Relawan",
                            subtitle: "Pantau pengajuan relawan Anda",
                            onTap: () {
                              if (_user != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VolunteerApplicationScreen(
                                          user: _user!,
                                        ),
                                  ),
                                ).then((_) {
                                  _loadUserProfile();
                                });
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Group 3: Dukungan & Lainnya
                  Text(
                    "Dukungan & Lainnya",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFFEDEEF1), width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.help_outline_rounded,
                          title: "Pusat Bantuan",
                          subtitle: "Tanya jawab & kontak admin",
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Bantuan akan segera hadir"),
                              ),
                            );
                          },
                        ),
                        Divider(height: 1, color: AppColors.divider),
                        _buildMenuTile(
                          icon: Icons.policy_outlined,
                          title: "Kebijakan Privasi",
                          subtitle: "Pelajari bagaimana data Anda dikelola",
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Kebijakan Privasi")),
                            );
                          },
                        ),
                        Divider(height: 1, color: AppColors.divider),
                        _buildMenuTile(
                          icon: Icons.info_outline_rounded,
                          title: "Tentang ResQare",
                          subtitle: "Versi 1.0.0",
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: "ResQare",
                              applicationVersion: "v1.0.0",
                              applicationIcon: Icon(
                                Icons.pets_rounded,
                                color: AppColors.primaryBlue,
                                size: 36,
                              ),
                              children: [
                                Text(
                                  "Aplikasi Penyelamatan Hewan Terlantar & Terluka.",
                                ),
                              ],
                            );
                          },
                        ),
                        Divider(height: 1, color: AppColors.divider),
                        _buildMenuTile(
                          icon: Icons.storage_rounded,
                          title: "Database Aplikasi",
                          subtitle: "Lihat seluruh data aplikasi",
                          onTap: () {
                            context.push(DatabaseList());
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Logout Button
                  InkWell(
                    onTap: _showLogoutConfirmation,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.emergency.withOpacity(0.08),
                        border: Border.all(
                          color: AppColors.emergency.withOpacity(0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: AppColors.emergency,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Keluar Akun",
                            style: TextStyle(
                              color: AppColors.emergency,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for custom Menu Tile
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // Helper Widget for Toggle Menu Tile
  Widget _buildToggleMenuTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: AppColors.primaryBlue,
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
