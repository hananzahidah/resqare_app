import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/constant/app_image.dart';
import 'package:resqare_app/database/preference_handler.dart';
import 'package:resqare_app/models/login_model.dart';
import 'package:resqare_app/repositories/user_repository_firebase.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/auth/helper/form_field.dart';
import 'package:resqare_app/views/auth/register_flow_screen.dart';
import 'package:resqare_app/views/navigator/bottom_navigator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passVisible = false;
  bool _isLoading = false;
  final UserRepositoryFirebase repository = UserRepositoryFirebase();

  void login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final inputEmail = emailController.text.trim();
    final inputPass = passwordController.text.trim();

    if (inputEmail.isEmpty || inputPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Isi semua field!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF005BBF),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await repository.loginUser(
        LoginModel(email: inputEmail, password: inputPass),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        await PreferenceHandler.setLogin(true);
        await PreferenceHandler.setUserId(user.id!);
        await PreferenceHandler.setUserRole(user.role);
        if (!mounted) return;
        context.pushAndRemoveAll(BottomNavigator());
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login gagal! Email atau Password salah.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF005BBF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF005BBF),
          ),
        );
      }
    }
  }

  void loginWithGoogle() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = await repository.signInWithGoogle();

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading dialog

      if (user != null) {
        await PreferenceHandler.setLogin(true);
        await PreferenceHandler.setUserId(user.id!);
        await PreferenceHandler.setUserRole(user.role);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Selamat Datang, ${user.fullName}!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF005BBF),
          ),
        );

        context.pushAndRemoveAll(BottomNavigator());
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal masuk dengan Google.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF005BBF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF005BBF),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 70),
              Column(
                spacing: 6,
                children: [
                  Image.asset(AppImages.logoBlue, height: 80),

                  Text(
                    "Selamat Datang",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "Masuk untuk melanjutkan aksi penyelamatan",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              SizedBox(height: 32),

              Column(
                spacing: 24,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      spacing: 24,
                      children: [
                        // Form Email
                        Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Email",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),

                            FormFieldTemplate(
                              typeForm: "Email",
                              controllerType: emailController,
                            ),
                          ],
                        ),

                        // Form Pasword
                        Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Password",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                // Text(
                                //   "Lupa Password?",
                                //   style: TextStyle(
                                //     fontSize: 12,
                                //     fontWeight: FontWeight.bold,
                                //     color: Color(0xFF005BBF),
                                //   ),
                                // ),
                              ],
                            ),

                            FormFieldTemplate(
                              typeForm: "Password",
                              controllerType: passwordController,
                            ),
                          ],
                        ),

                        // Button Login
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : login,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    "Masuk",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      Expanded(
                        child: Container(height: 1, color: AppColors.divider),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "atau",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: AppColors.divider),
                      ),
                    ],
                  ),

                  // Button Login with
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 56,
                  //   child: ElevatedButton(
                  //     onPressed: _isLoading ? null : loginWithGoogle,
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: AppColors.white,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadiusGeometry.circular(12),
                  //       ),
                  //     ),
                  //     child: Row(
                  //       spacing: 16,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Image.asset(AppImages.google),
                  //         Text(
                  //           "Masuk dengan Google",
                  //           style: TextStyle(
                  //             color: Colors.black,
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 14,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              SizedBox(height: 32),

              // Sign Up
              Text.rich(
                TextSpan(
                  text: "Belum memiliki akun?",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),

                  children: [
                    TextSpan(text: "   "),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => context.push(RegisterFlowScreen()),
                      text: "Daftar",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
