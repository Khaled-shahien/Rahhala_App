import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_assets.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/features/auth/presentation/pages/home_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/login_page.dart';
import 'package:rahhala_app/features/profile/presentation/pages/profile_page.dart';
import 'package:rahhala_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    void navigateToLogin() {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ));
    }

    void continueAsGuest() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomePage(isGuest: true)),
      );
    }

    void navigateToProfile() {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    }

    return Scaffold(
      body: BackgroundDecorator(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with improved styling
            Image.asset(
              AppAssets.imagesWelcomeImage,
              fit: BoxFit.cover,
            ),

            // Gradient overlay with improved styling
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),

            // Content with improved layout
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App title with improved styling
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [ThemeColor.amber, ThemeColor.orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'RAHHALA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 58.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                                blurRadius: 20.0,
                                color: Colors.black87,
                                offset: Offset(3.0, 3.0)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Subtitle with improved styling
                    Text(
                      'Egyptian trips with a personal touch!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                        height: 1.4,
                        shadows: const [
                          Shadow(
                              blurRadius: 8.0,
                              color: Colors.black54,
                              offset: Offset(1.0, 2.0))
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Buttons with improved styling
                    CustomButton(text: 'Get Started', onTap: navigateToLogin),
                    SizedBox(height: 20.h),

                    OutlinedButton(
                      onPressed: continueAsGuest,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                                blurRadius: 8.0,
                                color: Colors.black45,
                                offset: Offset(1.5, 1.5))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
