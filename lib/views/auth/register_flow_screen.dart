import 'dart:developer';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resqare_app/constant/app_image.dart';
import 'package:resqare_app/models/user_model_sql.dart';
import 'package:resqare_app/repositories/user_repository.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/auth/helper/icon_form.dart';
import 'package:resqare_app/views/auth/login_screen.dart';

class RegisterFlowScreen extends StatefulWidget {
  const RegisterFlowScreen({super.key});

  @override
  State<RegisterFlowScreen> createState() => _RegisterFlowScreenState();
}

class _RegisterFlowScreenState extends State<RegisterFlowScreen> {
  int _currentStep = 0;
  String _selectedRole = 'reporter'; // 'reporter' or 'volunteer'

  // Forms and Controllers
  final _accountFormKey = GlobalKey<FormState>();
  final _volunteerFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Volunteer Certificate Images
  final List<File> _certificateFiles = [];
  final ImagePicker _picker = ImagePicker();

  final UserRepository _userRepository = UserRepository();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _experienceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // Pick Certificate Image
  Future<void> _pickCertificateImage(ImageSource source) async {
    if (_certificateFiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal 3 foto sertifikat.'),
          backgroundColor: Color(0xFF005BBF),
        ),
      );
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _certificateFiles.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  // Show bottom sheet to choose Camera or Gallery
  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF005BBF),
                ),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickCertificateImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF005BBF),
                ),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickCertificateImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Remove Certificate Image
  void _removeCertificateImage(int index) {
    setState(() {
      _certificateFiles.removeAt(index);
    });
  }

  // Handle register for Reporter
  void _registerReporter() async {
    if (!_accountFormKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim().isEmpty
        ? null
        : _phoneController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      // Validate unique fields
      final emailExists = await _userRepository.checkEmailExists(email);
      if (emailExists) {
        _showSnackBar('Email sudah terdaftar!');
        setState(() => _isLoading = false);
        return;
      }

      if (phone != null) {
        final phoneExists = await _userRepository.checkPhoneExists(phone);
        if (phoneExists) {
          _showSnackBar('No. Telepon sudah digunakan!');
          setState(() => _isLoading = false);
          return;
        }
      }

      // Create reporter user
      final user = UserModelSql(
        email: email,
        password: password,
        fullName: name,
        phone: phone,
        role: 'reporter',
        isVerified: 0,
      );

      final success = await _userRepository.registerUser(user);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        _showSnackBar('Pendaftaran berhasil! Silakan masuk.', isSuccess: true);
        context.pushReplacement(const LoginScreen());
      } else {
        _showSnackBar('Pendaftaran gagal. Silakan coba lagi.');
      }
    } catch (e) {
      log(e.toString());
      setState(() => _isLoading = false);
      _showSnackBar('Terjadi kesalahan pada database.');
    }
  }

  // Validate Step 2 for Volunteer before moving to Step 3
  void _proceedToVolunteerDetails() async {
    if (!_accountFormKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    setState(() => _isLoading = true);

    try {
      // Validate unique email and phone (phone is mandatory for volunteer)
      final emailExists = await _userRepository.checkEmailExists(email);
      if (emailExists) {
        _showSnackBar('Email sudah terdaftar!');
        setState(() => _isLoading = false);
        return;
      }

      final phoneExists = await _userRepository.checkPhoneExists(phone);
      if (phoneExists) {
        _showSnackBar('No. Telepon sudah digunakan!');
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _isLoading = false;
        _currentStep = 2; // Go to Step 3
      });
    } catch (e) {
      log(e.toString());
      setState(() => _isLoading = false);
      _showSnackBar('Terjadi kesalahan koneksi.');
    }
  }

  // Handle final register for Volunteer
  void _registerVolunteer() async {
    if (!_volunteerFormKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    final experience = _experienceController.text.trim();
    final reason = _reasonController.text.trim();
    final certificatePaths = _certificateFiles.map((f) => f.path).toList();

    setState(() => _isLoading = true);

    try {
      // Create user data. Note: primary role in users table is 'reporter' initially!
      final user = UserModelSql(
        email: email,
        password: password,
        fullName: name,
        phone: phone,
        role: 'reporter', // registered as reporter first
        isVerified: 0,
      );

      final success = await _userRepository.registerVolunteerWithApplication(
        user: user,
        experience: experience,
        reason: reason,
        certificateImages: certificatePaths,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        _showSnackBar(
          'Pendaftaran berhasil! pengajuan relawan Anda sedang ditinjau.',
          isSuccess: true,
        );
        context.pushReplacement(const LoginScreen());
      } else {
        _showSnackBar('Pendaftaran gagal. Silakan coba lagi.');
      }
    } catch (e) {
      log(e.toString());
      setState(() => _isLoading = false);
      _showSnackBar('Terjadi kesalahan pada database.');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isSuccess
            ? const Color(0xFF2E7D32)
            : const Color(0xFF005BBF),
      ),
    );
  }

  // Helper Widget for custom input field
  Widget _buildTextField({
    required String label,
    required String typeForm,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int? maxLines = 1,
    String? hintText,
  }) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          obscuringCharacter: '*',
          maxLines: maxLines,
          keyboardType: typeForm == 'Email'
              ? TextInputType.emailAddress
              : typeForm == 'Phone'
              ? TextInputType.phone
              : maxLines != 1
              ? TextInputType.multiline
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: hintText ?? _getHintTextForType(typeForm),
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC1C6D6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC1C6D6)),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffixIcon,
            prefixIcon: typeForm.isEmpty
                ? null
                : Icon(
                    iconForm(typeForm.toLowerCase()),
                    color: const Color(0xFF727785),
                  ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC1C6D6)),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  String _getHintTextForType(String typeForm) {
    switch (typeForm) {
      case 'Email':
        return 'nama@mail.com';
      case 'Password':
        return 'Masukkan password anda';
      case 'Confirm Password':
        return 'Konfirmasi password anda';
      case 'Name':
        return 'Contoh: Budi Santoso';
      case 'Phone':
        return '08xxxxxxxxxx';
      default:
        return 'Masukkan input';
    }
  }

  // Step Indicators
  Widget _buildStepIndicator(int stepIndex, String title) {
    final bool isActive = _currentStep == stepIndex;
    final bool isCompleted = _currentStep > stepIndex;

    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  color: stepIndex == 0
                      ? Colors.transparent
                      : (isCompleted || isActive
                            ? const Color(0xFF005BBF)
                            : const Color(0xFFE5E7EB)),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF005BBF)
                      : isActive
                      ? const Color(0xFF005BBF)
                      : Colors.white,
                  border: Border.all(
                    color: isCompleted || isActive
                        ? const Color(0xFF005BBF)
                        : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isActive || isCompleted
                                ? Colors.white
                                : const Color(0xFF6B7280),
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: stepIndex == (_selectedRole == 'volunteer' ? 2 : 1)
                      ? Colors.transparent
                      : (isCompleted
                            ? const Color(0xFF005BBF)
                            : const Color(0xFFE5E7EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive || isCompleted
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isActive || isCompleted
                  ? const Color(0xFF1F2937)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _currentStep--;
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9FD),

        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 70),

                    Column(
                      spacing: 6,
                      children: [
                        Image.asset(AppImages.logoBlue, height: 80),
                        Text(
                          "Buat Akun Anda",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          "Bergabung bersama kami & bantu hewan.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF414754),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStepIndicator(0, 'Pilih Peran'),
                          _buildStepIndicator(1, 'Data Akun'),
                          if (_selectedRole == 'volunteer')
                            _buildStepIndicator(2, 'Detail Relawan'),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF005BBF),
                        ),
                      )
                    else ...[
                      if (_currentStep == 0) _buildStep0RoleSelection(),
                      if (_currentStep == 1) _buildStep1AccountForm(),
                      if (_currentStep == 2) _buildStep2VolunteerForm(),
                    ],

                    SizedBox(height: 32),

                    if (_currentStep < 2)
                      Text.rich(
                        TextSpan(
                          text: "Sudah memiliki akun?",
                          style: TextStyle(
                            color: Color(0xFF414754),
                            fontSize: 14,
                          ),

                          children: [
                            TextSpan(text: "   "),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => context.pushReplacement(
                                  const LoginScreen(),
                                ),
                              text: "Masuk",
                              style: TextStyle(
                                color: Color(0xFF005BBF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- STEP 0: ROLE SELECTION ---
  Widget _buildStep0RoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role Pelapor Card
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedRole = 'reporter';
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedRole == 'reporter'
                    ? const Color(0xFF005BBF)
                    : const Color(0xFFE5E7EB),
                width: _selectedRole == 'reporter' ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _selectedRole == 'reporter'
                      ? const Color(0xFF005BBF).withOpacity(0.05)
                      : Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedRole == 'reporter'
                        ? const Color(0xFF005BBF).withOpacity(0.1)
                        : const Color(0xFFF3F4F6),
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: _selectedRole == 'reporter'
                        ? const Color(0xFF005BBF)
                        : const Color(0xFF4B5563),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Menjadi Pelapor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Laporkan hewan telantar, terluka, atau membutuhkan bantuan penyelamatan di sekitar Anda.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Role Volunteer Card
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedRole = 'volunteer';
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedRole == 'volunteer'
                    ? const Color(0xFF005BBF)
                    : const Color(0xFFE5E7EB),
                width: _selectedRole == 'volunteer' ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _selectedRole == 'volunteer'
                      ? const Color(0xFF005BBF).withOpacity(0.05)
                      : Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedRole == 'volunteer'
                        ? const Color(0xFF005BBF).withOpacity(0.1)
                        : const Color(0xFFF3F4F6),
                  ),
                  child: Icon(
                    Icons.volunteer_activism_rounded,
                    color: _selectedRole == 'volunteer'
                        ? const Color(0xFF005BBF)
                        : const Color(0xFF4B5563),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Menjadi Relawan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Daftar sebagai anggota penyelamat hewan dan ikut serta dalam misi penyelamatan secara langsung.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Lanjut Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005BBF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Lanjut',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- STEP 1: ACCOUNT FORM ---
  Widget _buildStep1AccountForm() {
    final isVolunteer = _selectedRole == 'volunteer';

    return Form(
      key: _accountFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Full Name
          _buildTextField(
            label: 'Nama Lengkap',
            typeForm: 'Name',
            controller: _nameController,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Nama lengkap harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Email
          _buildTextField(
            label: 'Email',
            typeForm: 'Email',
            controller: _emailController,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Email harus diisi';
              }
              if (!val.contains('@')) {
                return 'Format email salah';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Phone Number (Optional for Reporter, Mandatory for Volunteer)
          _buildTextField(
            label: isVolunteer ? 'No. Telepon' : 'No. Telepon (Opsional)',
            typeForm: 'Phone',
            controller: _phoneController,
            validator: (val) {
              if (isVolunteer) {
                if (val == null || val.trim().isEmpty) {
                  return 'No. telepon wajib diisi untuk Relawan';
                }
                if (val.trim().length < 11 || val.trim().length > 13) {
                  return 'No. telepon harus berukuran 11-13 karakter';
                }
              } else {
                if (val != null && val.trim().isNotEmpty) {
                  if (val.trim().length < 11 || val.trim().length > 13) {
                    return 'No. telepon harus berukuran 11-13 karakter';
                  }
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Password
          _buildTextField(
            label: 'Password',
            typeForm: 'Password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF727785),
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Password harus diisi';
              }
              if (val.length < 8) {
                return 'Password minimal 8 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Confirm Password
          _buildTextField(
            label: 'Konfirmasi Password',
            typeForm: 'Confirm Password',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF727785),
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Konfirmasi password harus diisi';
              }
              if (val != _passwordController.text) {
                return 'Konfirmasi password tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Button Daftar (Reporter) or Lanjut (Volunteer)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isVolunteer
                  ? _proceedToVolunteerDetails
                  : _registerReporter,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005BBF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isVolunteer ? 'Lanjut' : 'Daftar',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Divider "atau"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(height: 1, color: const Color(0xFFC1C6D6)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'atau',
                  style: TextStyle(color: Color(0xFF414754), fontSize: 12),
                ),
              ),
              Expanded(
                child: Container(height: 1, color: const Color(0xFFC1C6D6)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Button Regist with Google
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                _showSnackBar(
                  'Fitur pendaftaran dengan Google akan segera hadir!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFC1C6D6)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppImages.google, height: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Daftar dengan Google',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 2: VOLUNTEER ADDITIONAL QUESTIONS ---
  Widget _buildStep2VolunteerForm() {
    return Form(
      key: _volunteerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Certificate Upload Section
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Sertifikat Pendukung (Opsional, Maksimal 3)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),

          // Selected Certificate Grid
          Row(
            spacing: 12,
            children: [
              ...List.generate(_certificateFiles.length, (index) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC1C6D6)),
                        image: DecorationImage(
                          image: FileImage(_certificateFiles[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => _removeCertificateImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              // Upload Button Placeholder
              if (_certificateFiles.length < 3)
                GestureDetector(
                  onTap: _showImageSourceBottomSheet,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFC1C6D6),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Color(0xFF727785),
                          size: 28,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Unggah',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF727785),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          // Experience
          _buildTextField(
            label: 'Pengalaman Terkait',
            typeForm: '',
            controller: _experienceController,
            maxLines: 4,
            hintText:
                'Ceritakan pengalaman Anda dalam merawat, menangani, atau menyelamatkan hewan...',
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Pengalaman harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Reason
          _buildTextField(
            label: 'Alasan Bergabung',
            typeForm: '',
            controller: _reasonController,
            maxLines: 4,
            hintText:
                'Tuliskan alasan Anda ingin bergabung menjadi relawan ResQare...',
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Alasan bergabung harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _registerVolunteer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005BBF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Daftar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
