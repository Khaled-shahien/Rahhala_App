# Rahhala App

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

A travel companion Flutter application that provides personalized travel recommendations using AI.

<p align="center">
  <img src="assets/images/logo.svg" width="200" alt="Rahhala Logo" />
</p>

## Project Architecture

The Rahhala App follows a modular architecture with a clear separation of concerns across different layers.

### Core Directory Structure

The `/lib/core` directory contains foundational components:
- `constants`: App assets, colors, text styles
- `di`: Service locator for dependency injection
- `errors`: Error handling models and exceptions
- `network`: API consumer using Dio with interceptors and endpoints
- `routing`: App router setup
- `theme`: App theme definition
- `utils`: Token storage, session, notifications, validators
- `widgets`: Reusable UI components

### Feature Module Organization

Features are modular under `/lib/features/`:
- `ai_recommendation`: AI-driven suggestions with logic and presentation layers
- `auth`: Authentication flow with data, logic, and presentation
- `onboarding`: Onboarding models and UI
- `profile`: User profile management
- `splash`: Splash screen implementation

Each feature follows a clean separation of concerns with data, business logic, and presentation layers.

### Technical Components

1. **Dependency Injection**: Uses GetIt for service location
2. **Network Layer**: API communication using Dio
3. **State Management**: Cubit pattern for state management
4. **Routing**: Simple navigation approach
5. **Error Handling**: Custom exception hierarchy

### Platform Support

The project supports all major platforms:
- Android
- iOS
- Web
- Desktop (Windows, macOS, Linux)

## Complete File Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_assets.dart
│   │   ├── app_colors.dart
│   │   ├── app_constants.dart
│   │   └── app_text_styles.dart
│   ├── di/
│   │   └── service_locator.dart
│   ├── errors/
│   │   ├── error_model.dart
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_consumer.dart
│   │   ├── api_interceptors.dart
│   │   ├── dio_consumer.dart
│   │   └── end_points.dart
│   ├── routing/
│   │   └── app_router.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── app_notifications.dart
│   │   ├── app_validators.dart
│   │   ├── token_storage.dart
│   │   └── user_session.dart
│   └── widgets/
│       ├── rahhala_bottom_bar.dart
│       └── soft_arc_notch.dart
├── features/
│   ├── ai_recommendation/
│   │   ├── data/
│   │   ├── logic/
│   │   │   ├── budget_cubit.dart
│   │   │   ├── interests_cubit.dart
│   │   │   └── trib_cubit.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── ai_recommendation_flow_screen.dart
│   │       │   ├── trip_budget_range_screen.dart
│   │       │   ├── trip_details_screen.dart
│   │       │   ├── trip_info_screen.dart
│   │       │   ├── trip_interests_screen.dart
│   │       │   └── trip_splash_screen.dart
│   │       └── widgets/
│   │           ├── ai_recommendation_tab_flow.dart
│   │           ├── button.dart
│   │           └── progress_indicator_bar.dart
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── login_model.dart
│   │   │   │   └── success_message_model.dart
│   │   │   └── repositories/
│   │   │       ├── auth_repository.dart
│   │   │       └── auth_repository_impl.dart
│   │   ├── logic/
│   │   │   ├── forgot_password/
│   │   │   │   ├── forgot_password_cubit.dart
│   │   │   │   └── forgot_password_state.dart
│   │   │   ├── login/
│   │   │   │   ├── login_cubit.dart
│   │   │   │   └── login_state.dart
│   │   │   ├── register/
│   │   │   │   ├── register_cubit.dart
│   │   │   │   └── register_state.dart
│   │   │   ├── reset_password/
│   │   │   │   ├── reset_password_cubit.dart
│   │   │   │   └── reset_password_state.dart
│   │   │   └── verify_otp/
│   │   │       ├── verify_otp_cubit.dart
│   │   │       └── verify_otp_state.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── forgot_password_page.dart
│   │       │   ├── home_page.dart
│   │       │   ├── login_page.dart
│   │       │   ├── otp_verification_page.dart
│   │       │   ├── reset_password_logged_in_page.dart
│   │       │   ├── reset_password_page.dart
│   │       │   ├── signup_page.dart
│   │       │   └── welcome_page.dart
│   │       └── widgets/
│   │           ├── custom_button.dart
│   │           ├── custom_country_dropdown.dart
│   │           ├── custom_form_text_field.dart
│   │           ├── or_divider.dart
│   │           ├── profile_list_tile.dart
│   │           └── social_login_section.dart
│   ├── home/
│   │   ├── data/
│   │   ├── logic/
│   │   └── presentation/
│   ├── onboarding/
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── onboarding_model.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── onboarding_screen.dart
│   │       └── widgets/
│   │           └── onboarding_page_widget.dart
│   ├── profile/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model_details.dart
│   │   │   └── repositories/
│   │   │       ├── user_repository.dart
│   │   │       └── user_repository_impl.dart
│   │   ├── logic/
│   │   │   ├── edit_profile/
│   │   │   │   ├── edit_profile_cubit.dart
│   │   │   │   └── edit_profile_state.dart
│   │   │   └── profile/
│   │   │       ├── profile_cubit.dart
│   │   │       └── profile_state.dart
│   │   └── presentation/
│   │       └── pages/
│   │           ├── edit_profile_page.dart
│   │           └── profile_page.dart
│   └── splash/
│       ├── data/
│       ├── logic/
│       └── presentation/
│           └── pages/
│               └── splash_screen.dart
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.3.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) for mobile development
- [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio) with Flutter and Dart plugins

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/rahhala_app.git
   ```

2. Navigate to the project directory:
   ```bash
   cd rahhala_app
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Building for Production

- **Android**:
  ```bash
  flutter build apk
  ```

- **iOS**:
  ```bash
  flutter build ios
  ```

- **Web**:
  ```bash
  flutter build web
  ```

- **Desktop**:
  ```bash
  flutter build windows
  # or
  flutter build macos
  # or
  flutter build linux
  ```

## Project Architecture

The Rahhala App follows a modular architecture with a clear separation of concerns across different layers, based on the principles of Clean Architecture.

### Core Directory Structure

The `/lib/core` directory contains foundational components:
- `constants`: App assets, colors, text styles, and other constants
- `di`: Service locator for dependency injection using GetIt
- `errors`: Error handling models and exceptions
- `network`: API consumer using Dio with interceptors and endpoints
- `routing`: App router setup using GoRouter
- `theme`: App theme definition
- `utils`: Utility classes for token storage, session management, notifications, and validators
- `widgets`: Reusable UI components

### Feature Module Organization

Features are modular under `/lib/features/`:
- `ai_recommendation`: AI-driven travel suggestions with data, logic, and presentation layers
- `auth`: Authentication flow with data, logic, and presentation
- `onboarding`: Onboarding flow with models and UI
- `profile`: User profile management
- `splash`: Splash screen implementation

Each feature follows a clean separation of concerns with data, business logic, and presentation layers.

### Technical Components

1. **Dependency Injection**: Uses [GetIt](https://pub.dev/packages/get_it) for service location
2. **Network Layer**: API communication using [Dio](https://pub.dev/packages/dio)
3. **State Management**: [Bloc/Cubit](https://pub.dev/packages/flutter_bloc) pattern for state management
4. **Routing**: [GoRouter](https://pub.dev/packages/go_router) for navigation
5. **Error Handling**: Custom exception hierarchy
6. **UI Components**: [ScreenUtil](https://pub.dev/packages/flutter_screenutil) for responsive design

### Data Flow

```
Presentation Layer (UI) → Logic Layer (Cubit) → Data Layer (Repository) → Network/API
```

## Platform Support

The project supports all major platforms:
- Android
- iOS
- Web
- Desktop (Windows, macOS, Linux)

## Key Features

- **AI-Powered Travel Recommendations**: Personalized travel plans based on user preferences
- **User Authentication**: Secure login and registration system
- **Profile Management**: User profile editing and management
- **Onboarding Experience**: Guided introduction for new users
- **Responsive Design**: Works across all device sizes and platforms

## Contributing

We welcome contributions to the Rahhala App! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Keep functions small and focused
- Write documentation for public APIs
- Run `flutter analyze` to check for linting issues

### Testing

- Write unit tests for business logic
- Write widget tests for UI components
- Ensure all tests pass before submitting a PR

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to all contributors who have helped shape Rahhala App
- Inspired by modern travel applications and AI technologies

## Contact

For questions or support, please open an issue on GitHub.