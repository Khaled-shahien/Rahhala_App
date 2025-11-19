

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:rahhala_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:rahhala_app/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:rahhala_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/login_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/signup_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/reset_password_logged_in_page.dart';
import 'package:rahhala_app/features/auth/presentation/pages/home_page.dart';
import 'package:rahhala_app/features/profile/presentation/pages/profile_page.dart';
import 'package:rahhala_app/features/profile/presentation/pages/edit_profile_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true, 
    routes: [

      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(
        path: AppRoutes.welcome,
        name: AppRouteNames.welcome,
        builder: (context, state) => const WelcomePage(),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.signup,
        name: AppRouteNames.signup,
        builder: (context, state) => const SignUpPage(),
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      GoRoute(
        path: AppRoutes.otpVerification,
        name: AppRouteNames.otpVerification,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpVerificationPage(email: email);
        },
      ),

      GoRoute(
        path: AppRoutes.resetPassword,
        name: AppRouteNames.resetPassword,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final otp = state.uri.queryParameters['otp'] ?? '';
          return ResetPasswordPage(email: email, otp: otp);
        },
      ),

      GoRoute(
        path: AppRoutes.resetPasswordLoggedIn,
        name: AppRouteNames.resetPasswordLoggedIn,
        builder: (context, state) => const ResetPasswordLoggedInPage(),
      ),

      GoRoute(
        path: AppRoutes.home,
        name: AppRouteNames.home,
        builder: (context, state) {
          final isGuest = state.uri.queryParameters['guest'] == 'true';
          return HomePage(isGuest: isGuest);
        },
      ),

      GoRoute(
        path: AppRoutes.profile,
        name: AppRouteNames.profile,
        builder: (context, state) => const ProfilePage(),
      ),

      GoRoute(
        path: AppRoutes.editProfile,
        name: AppRouteNames.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),

      GoRoute(
        path: AppRoutes.wishlist,
        name: AppRouteNames.wishlist,
        builder: (context, state) => _comingSoonPage(context, 'Wishlist'),
      ),

      GoRoute(
        path: AppRoutes.search,
        name: AppRouteNames.search,
        builder: (context, state) => _comingSoonPage(context, 'Search'),
      ),

      GoRoute(
        path: AppRoutes.tripPlanner,
        name: AppRouteNames.tripPlanner,
        builder: (context, state) => _comingSoonPage(context, 'Trip Planner'),
      ),

      GoRoute(
        path: AppRoutes.destinations,
        name: AppRouteNames.destinations,
        builder: (context, state) => _comingSoonPage(context, 'Destinations'),
      ),

      GoRoute(
        path: '${AppRoutes.destinationDetails}/:id',
        name: AppRouteNames.destinationDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _comingSoonPage(context, 'Destination Details ($id)');
        },
      ),
    ],
    
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: const Color(0xFFCDAE8A),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Error: ${state.error?.message ?? 'Unknown error'}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    },
  );

  static Widget _comingSoonPage(BuildContext context, String featureName) {
    return Scaffold(
      appBar: AppBar(
        title: Text(featureName),
        backgroundColor: const Color(0xFFCDAE8A),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 80,
              color: Color(0xFFCDAE8A),
            ),
            const SizedBox(height: 16),
            Text(
              featureName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String resetPasswordLoggedIn = '/reset-password-logged-in';

  static const String home = '/home';

  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  static const String wishlist = '/wishlist';
  static const String search = '/search';
  static const String tripPlanner = '/trip-planner';

  static const String destinations = '/destinations';
  static const String destinationDetails = '/destination-details';
}

class AppRouteNames {
  AppRouteNames._();

  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgotPassword = 'forgotPassword';
  static const String otpVerification = 'otpVerification';
  static const String resetPassword = 'resetPassword';
  static const String resetPasswordLoggedIn = 'resetPasswordLoggedIn';
  static const String home = 'home';
  static const String profile = 'profile';
  static const String editProfile = 'editProfile';
  static const String wishlist = 'wishlist';
  static const String search = 'search';
  static const String tripPlanner = 'tripPlanner';
  static const String destinations = 'destinations';
  static const String destinationDetails = 'destinationDetails';
}

extension NavigationExtension on BuildContext {
  
  void navigateTo(String path) => go(path);

  void navigateToNamed(String name,
      {Map<String, String>? params, Map<String, dynamic>? queryParams}) {
    goNamed(name,
        pathParameters: params ?? {}, queryParameters: queryParams ?? {});
  }

  void navigateBack() => pop();

  void navigateReplace(String path) => pushReplacement(path);

  void navigateAndRemoveUntil(String path) => go(path);
}
