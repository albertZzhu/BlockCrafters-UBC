import 'package:blockercrafter/config/app_colors.dart';
import 'package:flutter/material.dart';
import '../../widgets/top_nav_bar.dart';
import '../../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        color: const Color.fromARGB(225, 248, 252, 254),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Be Part of the Next Big Thing.',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: AppColors.orange,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'CFD empowers the future of decentralized fundraising — giving builders the tools to launch, and backers the power to invest transparently.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.skyBlue,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
                          label: 'Explore Projects',
                          onPressed :() { Navigator.pushNamed(context, '/projects');},
                          styleType: ButtonStyleType.orange,
                        ),
            
          ],
        ),
      ),
    );
  }
}
