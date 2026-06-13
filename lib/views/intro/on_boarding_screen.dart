import 'package:flutter/material.dart';
import 'package:resqare_app/constant/app_color.dart';
import 'package:resqare_app/utils/navigator.dart';
import 'package:resqare_app/views/auth/login_screen.dart';
import 'package:resqare_app/views/intro/on_boarding_data.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  int index = 0;

  void nextPage() {
    if (index < onBoardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pushReplacement(LoginScreen());
    }
  }

  void skip() {
    context.pushReplacement(LoginScreen());

    _pageController.animateToPage(
      onBoardingData.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Skip
              SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: index == onBoardingData.length - 1
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: skip,
                          child: const Text(
                            "Lewati",
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ),

              // Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onBoardingData.length,
                  onPageChanged: (value) {
                    setState(() {
                      index = value;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    final item = onBoardingData[pageIndex];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        SizedBox(
                          width: 240,
                          child: Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        SizedBox(
                          width: 260,
                          child: Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Image
                        SizedBox(
                          height: 280,
                          width: double.infinity,
                          child: Image.asset(
                            item.image,
                            fit: BoxFit.contain,
                            frameBuilder:
                                (
                                  context,
                                  child,
                                  frame,
                                  wasSynchronouslyLoaded,
                                ) {
                                  if (wasSynchronouslyLoaded) return child;

                                  return AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: const Duration(milliseconds: 300),
                                    child: child,
                                  );
                                },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onBoardingData.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == i ? 24 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: index == i
                          ? AppColors.primaryBlue
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    index == onBoardingData.length - 1
                        ? "Mulai"
                        : "Selanjutnya",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
