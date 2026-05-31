import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/localization/app_localization_extensions.dart';
import 'package:rahhala_app/core/startup/app_bootstrap_cubit.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';
import 'package:rahhala_app/features/onboarding/presentation/cubit/onboarding_cubit.dart';
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
    debugLogDiagnostics: kDebugMode,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AppBootstrapCubit>()..initialize(),
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRouteNames.onboarding,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<OnboardingCubit>(),
          child: const OnboardingScreen(),
        ),
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
        builder: (context, state) =>
            _comingSoonPage(context, context.l10n.homeWishlist),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: AppRouteNames.search,
        builder: (context, state) =>
            _comingSoonPage(context, context.l10n.homeSearch),
      ),
      GoRoute(
        path: AppRoutes.tripPlanner,
        name: AppRouteNames.tripPlanner,
        builder: (context, state) =>
            _comingSoonPage(context, context.l10n.routerTripPlanner),
      ),
      GoRoute(
        path: AppRoutes.destinations,
        name: AppRouteNames.destinations,
        builder: (context, state) =>
            _comingSoonPage(context, context.l10n.routerDestinations),
      ),
      GoRoute(
        path: '${AppRoutes.destinationDetails}/:id',
        name: AppRouteNames.destinationDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _comingSoonPage(
            context,
            context.l10n.routerDestinationDetails(id),
          );
        },
      ),
    ],
    errorBuilder: (context, state) {
      final l10n = context.l10n;
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.commonError),
          backgroundColor: ThemeColor.primary,
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
                l10n.routerPageNotFound,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.commonError}: ${state.error?.message ?? l10n.commonUnknownError}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(l10n.routerGoHome),
              ),
            ],
          ),
        ),
      );
    },
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final path = state.uri.path;
    final publicRoutes = <String>{
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.welcome,
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.forgotPassword,
      AppRoutes.otpVerification,
      AppRoutes.resetPassword,
    };

    if (publicRoutes.contains(path)) return null;

    final authSession = sl<AuthSessionService>();
    final isGuestHome =
        path == AppRoutes.home && state.uri.queryParameters['guest'] == 'true';
    if (path == AppRoutes.home && (authSession.hasToken || isGuestHome)) {
      return null;
    }

    final protectedRoutes = <String>{
      AppRoutes.home,
      AppRoutes.profile,
      AppRoutes.editProfile,
      AppRoutes.resetPasswordLoggedIn,
      AppRoutes.wishlist,
      AppRoutes.tripPlanner,
    };

    if (!authSession.hasToken && protectedRoutes.contains(path)) {
      return AppRoutes.welcome;
    }
    return null;
  }

  static Widget _comingSoonPage(BuildContext context, String featureName) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.routerFeatureTitle(featureName)),
        backgroundColor: ThemeColor.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 80,
              color: ThemeColor.primary,
            ),
            const SizedBox(height: 16),
            Text(
              featureName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.commonComingSoon,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(l10n.commonBack),
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
