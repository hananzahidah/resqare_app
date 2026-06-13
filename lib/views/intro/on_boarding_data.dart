import 'package:resqare_app/constant/app_image.dart';

class OnBoardingData {
  final String title;
  final String image;
  final String description;

  OnBoardingData({
    required this.title,
    required this.image,
    required this.description,
  });
}

List<OnBoardingData> onBoardingData = [
  OnBoardingData(
    title: "Report animals in need instantly",
    image: AppImages.onBoard1,
    description: "Help us quickly know when animals need help.",
  ),

  OnBoardingData(
    title: "Find nearby rescue cases",
    image: AppImages.onBoard2,
    description: "See real-time cases around you on the map.",
  ),

  OnBoardingData(
    title: "Help save lives together",
    image: AppImages.onBoard3,
    description: "Join our volunteer community and make a difference.",
  ),
];
