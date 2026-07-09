import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/models/user_model_firebase.dart';
import 'package:resqare_app/providers/theme_provider.dart';
import 'package:resqare_app/repositories/user_repository_firebase.dart';
import 'package:resqare_app/utils/image_loader_helper.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/auth/login_screen.dart';
import 'package:resqare_app/views/profile/edit_profile_screen.dart';
import 'package:resqare_app/views/profile/volunteer_application_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isActive;
  const ProfileScreen({super.key, this.isActive = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepositoryFirebase _userRepository = UserRepositoryFirebase();
  UserModelFirebase? _user;
  int _reportsCreated = 0;
  int _rescueCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) {
      setState(() {
        _isLoading = true;
      });
    }

    final userId = PreferenceHandler.userId;
    if (userId.isNotEmpty) {
      final user = await _userRepository.getUserById(userId);
      if (user != null) {
        _user = user;
        if (user.id != null) {
          final stats = await _userRepository.getUserStats(user.id!);
          _reportsCreated = stats['reportsCreated'] ?? 0;
          _rescueCount = stats['rescueCount'] ?? 0;
        }
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
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        bool obscureOldPassword = true;
        bool obscureNewPassword = true;
        bool obscureConfirmPassword = true;
        bool dialogLoading = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
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
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Kata Sandi Lama",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: oldPasswordController,
                      obscureText: obscureOldPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Masukkan kata sandi lama";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Kata sandi lama Anda",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureOldPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF727785),
                          ),
                          onPressed: () {
                            setModalState(() {
                              obscureOldPassword = !obscureOldPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Kata Sandi Baru",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: obscureNewPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Masukkan kata sandi baru";
                        }
                        if (value.length < 8) {
                          return 'Password minimal 8 karakter';
                        }
                        if (!value.contains(RegExp(r'[A-Z]'))) {
                          return 'Password harus memiliki huruf besar';
                        }
                        if (!value.contains(RegExp(r'[0-9]'))) {
                          return 'Password harus memiliki angka';
                        }
                        if (!value.contains(RegExp(r'[^a-zA-Z0-9\s]'))) {
                          return 'Password harus memiliki simbol';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Kata sandi baru (min. 8 karakter)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNewPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF727785),
                          ),
                          onPressed: () {
                            setModalState(() {
                              obscureNewPassword = !obscureNewPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Konfirmasi Kata Sandi Baru",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF727785),
                          ),
                          onPressed: () {
                            setModalState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                        onPressed: dialogLoading
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  final confirm = await _showConfirmationAlert(
                                    "Apakah Anda yakin ingin mengganti kata sandi akun Anda?",
                                  );
                                  if (!confirm) return;

                                  setModalState(() {
                                    dialogLoading = true;
                                  });

                                  final oldPassword =
                                      oldPasswordController.text;
                                  final newPassword =
                                      newPasswordController.text;

                                  final errorMsg = await _userRepository
                                      .changePassword(
                                        oldPassword: oldPassword,
                                        newPassword: newPassword,
                                      );

                                  if (!context.mounted) return;

                                  setModalState(() {
                                    dialogLoading = false;
                                  });

                                  if (errorMsg == null) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          "Kata sandi berhasil diperbarui",
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                    _loadUserProfile();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(errorMsg),
                                        backgroundColor: AppColors.emergency,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: dialogLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Ganti Kata Sandi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _showConfirmationAlert(String message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                Icons.warning_rounded,
                color: AppColors.primaryBlue,
                size: 36,
              ),
              SizedBox(height: 10),
              Text(
                "Konfirmasi Perubahan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCCCCCC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Yakin",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  // Logout dialog confirmation
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.emergency, size: 36),
              SizedBox(height: 10),
              Text(
                "Konfirmasi Keluar",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            "Apakah Anda yakin ingin keluar dari akun ResQare saat ini?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCCCCCC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await PreferenceHandler.logOut();
                      if (!context.mounted) return;
                      Navigator.pop(context); // Close dialog
                      context.pushAndRemoveAll(LoginScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emergency,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Keluar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showHelpCenterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                Icons.support_agent_rounded,
                color: AppColors.primaryBlue,
                size: 36,
              ),
              SizedBox(height: 10),
              Text(
                "Pusat Bantuan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.45,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pertanyaan yang Sering Diajukan (FAQ):",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFaqItem(
                    "Bagaimana cara melaporkan hewan liar/terluka?",
                    "Buka halaman utama, tekan tombol tambah laporan (+), ambil foto kondisi hewan, tentukan lokasi koordinat, lalu unggah laporan Anda.",
                  ),
                  const Divider(height: 20),
                  _buildFaqItem(
                    "Bagaimana cara bergabung menjadi Relawan?",
                    "Masuk ke halaman Profil Anda, tekan 'Daftar sebagai Relawan', lalu lengkapi dokumen sertifikat kemahiran atau pengalaman penyelamatan Anda.",
                  ),
                  const Divider(height: 20),
                  _buildFaqItem(
                    "Bagaimana cara koordinasi dengan Relawan?",
                    "Gunakan fitur Live Chat yang tersedia di halaman detail laporan Anda untuk terhubung langsung dengan relawan yang menangani kasus tersebut.",
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Punya pertanyaan lain?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Hubungi tim dukungan kami kapan saja melalui email berikut:",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: AppColors.primaryBlue,
                            ),
                            SizedBox(width: 8),
                            SelectableText(
                              "resqare@support.com",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Tutup",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                Icons.security_rounded,
                color: AppColors.primaryBlue,
                size: 36,
              ),
              SizedBox(height: 10),
              Text(
                "Kebijakan Privasi",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.45,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Text(
                "Kebijakan Privasi ini menjelaskan bagaimana ResQare mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda:\n\n"
                "1. Informasi yang Kami Kumpulkan:\n"
                "Kami memerlukan Nama, Email, Nomor Telepon, dan data Koordinat GPS lokasi Anda untuk mendaftarkan akun dan mempermudah pencarian lokasi hewan liar/terluka.\n\n"
                "2. Penggunaan Informasi:\n"
                "Informasi lokasi GPS hanya dibagikan secara transparan untuk memetakan koordinat laporan hewan liar di peta, agar relawan terdekat dapat melakukan tindakan penyelamatan secara presisi.\n\n"
                "3. Keamanan Data:\n"
                "Sandi Anda dikelola secara terenkripsi menggunakan Firebase Authentication. Kami berkomitmen penuh menjaga kerahasiaan data pengguna dari akses tidak sah.\n\n"
                "4. Layanan Pengguna & Pertanyaan:\n"
                "Apabila Anda ingin menghapus data akun atau memiliki pertanyaan seputar privasi data pribadi, silakan hubungi tim kami di: resqare@support.com",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Saya Mengerti",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showAboutUsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(Icons.pets_rounded, color: AppColors.primaryBlue, size: 36),
              SizedBox(height: 10),
              Text(
                "Tentang ResQare",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.45,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Text(
                    "Versi 1.0.0",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "ResQare adalah platform berbasis komunitas yang didesain untuk menjembatani pelapor dan relawan dalam menyelamatkan hewan liar maupun peliharaan yang terlantar, tersesat, atau terluka.\n\n"
                    "Melalui integrasi laporan instan dan peta sebaran, kami memfasilitasi tindakan evakuasi cepat yang transparan dan kolaboratif demi masa depan hewan yang lebih layak.\n\n"
                    "Hubungi kami di: resqare@support.com",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Tutup",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
    final isAdmin = _user?.role.toLowerCase() == 'admin';

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
                    backgroundColor: AppColors.white.withOpacity(0.08),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: -20,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.white.withOpacity(0.05),
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
                          color: AppColors.white,
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
                                    ImageLoaderHelper.getImageProvider(
                                      _user?.imgProfile,
                                    ),
                                child:
                                    !ImageLoaderHelper.hasImage(
                                      _user?.imgProfile,
                                    )
                                    ? const Icon(
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withOpacity(
                                        0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isAdmin
                                              ? Icons
                                                    .admin_panel_settings_rounded
                                              : isVolunteer
                                              ? Icons.shield_rounded
                                              : Icons.person_pin_rounded,
                                          size: 12,
                                          color: AppColors.primaryBlue,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isAdmin
                                              ? "Admin / Pengelola"
                                              : isVolunteer
                                              ? "Volunteer / Relawan"
                                              : "Reporter / Pelapor",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue,
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

            if (!isAdmin) ...[
              const SizedBox(height: 12),
              // 2. Statistic
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    // Stat Card 1: Reports
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFEDEEF1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.softBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                color: AppColors.primaryBlue,
                                size: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
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
                    const SizedBox(width: 14),
                    // Stat Card 2: Rescues
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFEDEEF1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
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
            ],

            // 3. Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isAdmin) ...[
                    const SizedBox(height: 12),
                    // Group 1: Akun & Keamanan
                    Text(
                      "Akun & Keamanan",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1),
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
                          if (_user?.role.toLowerCase() != 'admin') ...[
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
                    const SizedBox(height: 20),
                  ] else
                    const SizedBox(height: 20),

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
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.help_outline_rounded,
                          title: "Pusat Bantuan",
                          subtitle: "Tanya jawab & kontak admin",
                          onTap: _showHelpCenterDialog,
                        ),
                        Divider(height: 1, color: AppColors.divider),
                        _buildMenuTile(
                          icon: Icons.policy_outlined,
                          title: "Kebijakan Privasi",
                          subtitle: "Pelajari bagaimana data Anda dikelola",
                          onTap: _showPrivacyPolicyDialog,
                        ),
                        Divider(height: 1, color: AppColors.divider),
                        _buildMenuTile(
                          icon: Icons.info_outline_rounded,
                          title: "Tentang ResQare",
                          subtitle: "Versi 1.0.0",
                          onTap: _showAboutUsDialog,
                        ),
                        // Divider(height: 1, color: AppColors.divider),
                        // _buildToggleMenuTile(
                        //   icon: Icons.dark_mode_outlined,
                        //   title: "Mode Gelap",
                        //   value: themeProvider.isDarkMode,
                        //   onChanged: (newValue) {
                        //     themeProvider.toggleTheme(newValue);
                        //   },
                        // ),
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
