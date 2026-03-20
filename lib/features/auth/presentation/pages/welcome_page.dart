import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/constants/app_assets.dart';
import 'package:rahhala_app/features/auth/presentation/pages/home_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/login_page.dart';
import 'package:rahhala_app/core/widgets/background_decorator.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // درجة الأزرق الغامق جداً المتناسقة مع اللوجو
    const Color brandDarkBlue = Color(0xFF0D1B2A);

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
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
      ));
    }

    void continueAsGuest() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomePage(isGuest: true)),
      );
    }

    return Scaffold(
      body: BackgroundDecorator(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // الصورة اللي فيها اللوجو جاهز
            Image.asset(
              AppAssets.imagesWelcomerahhla,
              fit: BoxFit.cover,
            ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
                child: Column(
                  children: [
                    // مساحة اللوجو
                    SizedBox(height: 210.h),

                    // النص الصغير تحت اللوجو
                    Text(
                      'Every place has a story..Start yours today!',
                      //'Every place, every moment..made for you',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: brandDarkBlue.withOpacity(0.8),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    // صف الزراير (Side by Side)
                    Row(
                      children: [
                        // زر الدخول (Get Started)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: navigateToLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandDarkBlue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              elevation: 2,
                              // --- التعديل هنا (إضافة البوردر) ---
                              side: const BorderSide(
                                color: Colors
                                    .white24, // لون بوردر خفيف عشان ينطق الزرار
                                width: 1.5,
                              ),
                              // ---------------------------------
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                  fontSize: 23.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        SizedBox(width: 30.w), // مسافة بين الزرارين

                        // زر الزائر (Guest)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: continueAsGuest,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              side: const BorderSide(
                                  color: brandDarkBlue, width: 1.5),
                              backgroundColor: Colors.white
                                  .withOpacity(0.5), // خلفية شفافة بسيطة
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            child: Text(
                              'Guest',
                              style: TextStyle(
                                color: brandDarkBlue,
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // SizedBox(height: 5.h),
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
