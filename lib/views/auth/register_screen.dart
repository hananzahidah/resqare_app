import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_image.dart';
import 'package:resqare_app/models/user_model_sql.dart';
import 'package:resqare_app/repositories/user_repository.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/auth/helper/form_field.dart';
import 'package:resqare_app/views/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController roleController = TextEditingController(
    text: 'reporter',
  );
  bool passVisible = false;

  final UserRepository repository = UserRepository();

  void register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final inputEmail = emailController.text.trim();
    final inputPass = passwordController.text.trim();
    final inputFullname = nameController.text.trim();
    final inputPhone = phoneController.text.isEmpty
        ? null
        : phoneController.text.trim();
    final inputRole = roleController.text.trim().toLowerCase();

    if (inputEmail.isEmpty ||
        inputPass.isEmpty ||
        inputFullname.isEmpty ||
        inputRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Isi field yang wajib!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF005BBF),
        ),
      );
      return;
    }

    final emailExists = await repository.checkEmailExists(inputEmail);

    if (emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email sudah terdaftar!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF005BBF),
        ),
      );
      return;
    }

    if (inputPhone != null) {
      final phoneExists = await repository.checkPhoneExists(inputPhone);

      if (phoneExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No. Telephone sudah digunakan!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF005BBF),
          ),
        );
        return;
      }
    }

    if (inputRole.toLowerCase() != 'general' &&
        inputRole.toLowerCase() != 'volunteer') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Role hanya boleh general atau volunteer!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF005BBF),
        ),
      );

      return;
    }

    final user = UserModelSql(
      email: inputEmail,
      password: inputPass,
      fullName: inputFullname,
      phone: inputPhone,
      role: inputRole,
      isVerified: 0,
    );

    bool success = await repository.registerUser(user);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Akun berhasil dibuat',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF005BBF),
        ),
      );
      context.push(LoginScreen());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email sudah terdaftar!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF005BBF),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF9FD),

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
                  Image.asset("assets/images/logo_blue.png", height: 80),
                  Text(
                    "Buat Akun Anda",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "Bergabunglah bersama kami & bantu lebih banyak hewan.",
                    style: TextStyle(fontSize: 14, color: Color(0xFF414754)),
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
                        Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nama Lengkap",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            FormFieldTemplate(
                              typeForm: "Name",
                              controllerType: nameController,
                            ),
                          ],
                        ),

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

                        Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "No. Telepon (Opsional)",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),

                            FormFieldTemplate(
                              typeForm: "Phone",
                              controllerType: phoneController,
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
                            onPressed: register,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF005BBF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(12),
                              ),
                            ),
                            child: Text(
                              "Daftar",
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
                        child: Container(height: 1, color: Color(0xFFC1C6D6)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "atau",
                          style: TextStyle(
                            color: Color(0xFF414754),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: Color(0xFFC1C6D6)),
                      ),
                    ],
                  ),

                  // Button Regist with
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        // side: BorderSide(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                      ),
                      child: Row(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(AppImages.google),
                          Text(
                            "Daftar dengan Google",
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

              SizedBox(height: 32),

              // Login
              Text.rich(
                TextSpan(
                  text: "Sudah memiliki akun?",
                  style: TextStyle(color: Color(0xFF414754), fontSize: 14),

                  children: [
                    TextSpan(text: "   "),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => context.push(LoginScreen()),
                      text: "Masuk",
                      style: TextStyle(
                        color: Color(0xFF005BBF),
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
