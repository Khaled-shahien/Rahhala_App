
## Section 3 — SOLID Principles Audit

### 3.1 Single Responsibility Principle

| Status | Violations | Recommended fix |
|---|---|---|
| ❌ | `TripDaySection` and nested `_FullScreenDayRouteMap` handle rendering, routing, GPS, TTS, route polling, recentering, and error messaging in one place [lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart](lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart#L21), [lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart](lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart#L474) | Split into separate widgets plus a navigation service |
| ❌ | `EditProfilePage` handles prefill, photo picking, photo upload, local session sync, and UI state [lib/features/profile/presentation/pages/edit_profile_page.dart](lib/features/profile/presentation/pages/edit_profile_page.dart#L108), [lib/features/profile/presentation/pages/edit_profile_page.dart](lib/features/profile/presentation/pages/edit_profile_page.dart#L227) | Move orchestration into a Cubit/use case layer |
| ⚠️ | `LoginPage` saves session, fetches profile details, patches missing display data, and shows success notifications [lib/features/auth/presentation/pages/login_page.dart](lib/features/auth/presentation/pages/login_page.dart#L98) | Move post-login session hydration into the auth layer |

### 3.2 Open/Closed Principle

| Status | Violations | Recommended fix |
|---|---|---|
| ⚠️ | AI trip options are hardcoded in [lib/features/ai_recommendation/domain/ai_trip_options.dart](lib/features/ai_recommendation/domain/ai_trip_options.dart#L1) | Move trip taxonomies into config or backend data |
| ⚠️ | Nearby category and filter logic is encoded in UI/state in several screens | Use metadata-driven category definitions |
| ⚠️ | Some URLs are centralized, but specific endpoints are still duplicated in implementation files | Keep endpoint constants in one place only |
| ❌ | `debugMode = true` is a compile-time flag in [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart#L139) | Replace with environment/flavor driven feature flags |

### 3.3 Liskov Substitution Principle

| Status | Violations | Recommended fix |
|---|---|---|
| ⚠️ | Some repository contracts still expose data-layer model classes, such as auth/profile/home/nearby/trip-history interfaces | Promote domain entities or DTO boundaries owned by domain |

### 3.4 Interface Segregation Principle

| Status | Violations | Recommended fix |
|---|---|---|
| ⚠️ | `TripDaySection` becomes a monolith for several mini-features instead of consuming smaller interfaces | Split services and view models |
| ⚠️ | `AuthRepo` is broad, but still reasonable for current scope | Consider separating verification, registration, and password flows if the feature set grows |

### 3.5 Dependency Inversion Principle

| Status | Violations | Recommended fix |
|---|---|---|
| ⚠️ | `ImageSearchCubit` depends directly on `ImagePicker` [lib/features/image_search/domain/image_search_cubit.dart](lib/features/image_search/domain/image_search_cubit.dart#L2) | Inject an image acquisition abstraction |
| ⚠️ | `SplashScreen` and some feature pages depend directly on `SharedPreferences` and `GetIt` | Move to injected services |
| ✅ | Nearby location has an abstraction in place | Keep the same pattern for image search and route/navigation services |

---

## Section 4 — Features Inventory

### 4.1 Core Features

| Feature | Status | Files involved | Known issues | Missing functionality |
|---|---|---|---|---|
| App bootstrap and startup routing | ✅ Complete | [lib/main.dart](lib/main.dart#L13), [lib/core/routing/app_router.dart](lib/core/routing/app_router.dart#L22), [lib/features/splash/presentation/pages/splash_screen.dart](lib/features/splash/presentation/pages/splash_screen.dart#L14) | Splash still reads `SharedPreferences` directly | None critical |
| Localization (AR/EN) | ✅ Complete | [lib/core/localization/app_locale_controller.dart](lib/core/localization/app_locale_controller.dart#L6), [lib/l10n/generated/app_localizations.dart](lib/l10n/generated/app_localizations.dart#L1) | `web` branding is stale | None critical |
| Theme switching | ✅ Complete | [lib/core/theme/theme_controller.dart](lib/core/theme/theme_controller.dart#L4), [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart#L4) | Theme colors are duplicated across two systems | Unify palette source |
| Secure session storage | ✅ Complete | [lib/core/utils/token_storage.dart](lib/core/utils/token_storage.dart#L1), [lib/core/auth/auth_session_service.dart](lib/core/auth/auth_session_service.dart#L24) | Session data is still read in UI | Route guards and a single session service are enough for now |

### 4.2 Premium/Monetization Features

| Feature | Status | Files involved | Known issues | Missing functionality |
|---|---|---|---|---|
| Subscriptions | ❌ Not implemented | None | No entitlement layer exists | Plans, purchase flow, server verification |
| One-time lifetime unlock | ❌ Not implemented | None | No pricing UI | Billing and receipt validation |
| Premium paywall | ❌ Not implemented | None | No paywall screens | Offer screens and analytics hooks |

### 4.3 Ad System Features

| Feature | Status | Files involved | Known issues | Missing functionality |
|---|---|---|---|---|
| Interstitial ads | ❌ Not implemented | None | No ad SDKs in `pubspec.yaml` | Placement strategy |
| Rewarded ads | ❌ Not implemented | None | No reward flow | Reward state machine |
| App open ads | ❌ Not implemented | None | No lifecycle hook | Startup ad management |

### 4.4 Offline/Download Features

| Feature | Status | Files involved | Known issues | Missing functionality |
|---|---|---|---|---|
| Cached images | ✅ Partial | [pubspec.yaml](pubspec.yaml#L27), [lib/features/home/presentation/widgets/place_card.dart](lib/features/home/presentation/widgets/place_card.dart#L1) | Only images are cached | Structured offline trip cache |
| Offline trip storage | ❌ Not implemented | None | No local DB or download queue | Local persistence for trips and maps |
| Offline navigation | ❌ Not implemented | None | Route logic depends on network | Offline map tiles and routing cache |

### 4.5 Social/Sharing Features

| Feature | Status | Files involved | Known issues | Missing functionality |
|---|---|---|---|---|
| Share links | ⚠️ Partial | [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart#L157), [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart#L161) | Share URLs are only static constants | Actual share intents |
| Social login | ⚠️ Partial | [lib/features/auth/presentation/pages/login_page.dart](lib/features/auth/presentation/pages/login_page.dart#L159) | UI section exists, but no backend/social SDK wiring is visible in dependencies | Google/Apple/Facebook integration |

### 4.6 Settings & Preferences

| Feature | Status | Files involved | Known issues | Missing functionality |
|---|---|---|---|---|
| Language picker | ✅ Complete | [lib/features/profile/presentation/widgets/language_picker_bottom_sheet.dart](lib/features/profile/presentation/widgets/language_picker_bottom_sheet.dart#L8) | Uses GetIt from presentation | None critical |
| Theme preferences | ✅ Complete | [lib/core/theme/theme_controller.dart](lib/core/theme/theme_controller.dart#L4) | None significant | None critical |
| Notification preference key | ⚠️ Partial | [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart#L39) | Key exists, but no notifications pipeline or scheduling layer | Real notification settings panel |

### 4.7 Onboarding Flow

| Feature | Status | Files involved | Known issues | Missing functionality |
|---|---|---|---|---|
| Onboarding pages | ✅ Complete | [lib/features/onboarding/presentation/pages/onboarding_screen.dart](lib/features/onboarding/presentation/pages/onboarding_screen.dart#L15), [lib/features/onboarding/presentation/widgets/onboarding_page_widget.dart](lib/features/onboarding/presentation/widgets/onboarding_page_widget.dart#L6) | Uses `SharedPreferences` directly | None critical |

### 4.8 Notification System

| Feature | Status | Files involved | Known issues | Missing functionality |
|---|---|---|---|---|
| In-app snackbars | ✅ Complete | [lib/core/utils/app_notifications.dart](lib/core/utils/app_notifications.dart#L1) | Styling is simple | Centralized notification service |
| Push/local notifications | ❌ Not implemented | None | No notification SDK or scheduler | Firebase/local notifications |

### 4.9 Analytics & Tracking

| Feature | Status | Files involved | Known issues | Missing functionality |
|---|---|---|---|---|
| Analytics | ❌ Not implemented | None | `enableAnalytics` is false in [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart#L145) | Event tracking and funnel metrics |
| Crash reporting | ❌ Not implemented | None | `enableCrashReporting` is false in [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart#L148) | Crashlytics/Sentry |

---

## Section 5 — Security Analysis

### 5.1 Authentication & Authorization

| Item | Finding |
|---|---|
| Premium access verification | Not implemented; access is currently based on app-side session presence only via [lib/core/auth/auth_session_service.dart](lib/core/auth/auth_session_service.dart#L24) |
| Route protection | GoRouter redirect logic gates protected routes in [lib/core/routing/app_router.dart](lib/core/routing/app_router.dart#L195) and [lib/core/routing/app_router.dart](lib/core/routing/app_router.dart#L204) |
| Bypass risk | Moderate for any future premium feature because the app does not yet have server-verified entitlements |

### 5.2 Data Storage Security

| Item | Finding |
|---|---|
| SharedPreferences usage | Used for non-sensitive preferences and legacy migration; splash/onboarding still read prefs directly [lib/features/splash/presentation/pages/splash_screen.dart](lib/features/splash/presentation/pages/splash_screen.dart#L33), [lib/features/onboarding/presentation/pages/onboarding_screen.dart](lib/features/onboarding/presentation/pages/onboarding_screen.dart#L50) |
| Sensitive tokens | Stored in secure storage with Android encrypted shared prefs and iOS Keychain via [lib/core/di/service_locator.dart](lib/core/di/service_locator.dart#L74) and [lib/core/utils/token_storage.dart](lib/core/utils/token_storage.dart#L1) |
| Encryption status | Good for tokens; no custom encryption for other local data |

### 5.3 Network Security

| Item | Finding |
|---|---|
| API calls | Centralized through `EndPoints` in [lib/core/network/end_points.dart](lib/core/network/end_points.dart#L1) |
| Transport security | Base URLs are HTTPS in [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart#L21) and [lib/core/network/end_points.dart](lib/core/network/end_points.dart#L2) |
| Certificate pinning | Not implemented |
| Sensitive data in transit | Tokens are sent via Dio interceptor stack; no direct pinning or mTLS |

### 5.4 IAP / Subscription Security

| Item | Finding |
|---|---|
| Purchase verification | Not implemented |
| Receipt validation | Not implemented |
| Restore/reconcile risk | Not applicable yet because subscriptions are absent |

### 5.5 Ad System Security

| Item | Finding |
|---|---|
| Rewarded ad bypass risk | Not applicable; there is no ad SDK |
| Single-flight guard | Not applicable; there is no rewarded ad flow |

---

## Section 6 — UI/UX Analysis

### 6.1 Design System

#### Color palette

| Token | Hex |
|---|---|
| `ThemeColor.primary` | `#CDAE8A` |
| `ThemeColor.secondary` | `#36454F` |
| `ThemeColor.surface` | `#FFFFFF` |
| `ThemeColor.background` | `#F8F9FA` |
| `ThemeColor.error` | `#B00020` |
| `AppColors.primary` | `#CDAE8A` |
| `AppColors.primaryDark` | `#B5996F` |
| `AppColors.darkBrown` | `#423528` |
| `AppColors.mediumBrown` | `#755F47` |
| `AppColors.lightBrown` | `#A88866` |
| `AppColors.screenBackground` | `#F0EBE9` |
| `AppColors.charcoal` | `#36454F` |
| `AppColors.darkGreen` | `#006400` |
| `AppColors.neutralGray` | `#8E8E8E` |
| `AppColors.success` | `#4CAF50` |
| `AppColors.error` | `#D32F2F` |
| `AppColors.warning` / `amber` | `#FFC107` |
| `AppColors.info` | `#2196F3` |
| `AppColors.backgroundWhite` | `#FFFFFF` |
| `AppColors.backgroundGray` | `#F5F5F5` |
| `AppColors.cardBackground` | `#FAFAFA` |

#### Typography

| Token | Finding |
|---|---|
| Font family | Cairo in [lib/core/constants/app_fonts.dart](lib/core/constants/app_fonts.dart#L1) |
| Text scale | Semantic styles in [lib/core/constants/app_text_styles.dart](lib/core/constants/app_text_styles.dart#L6) and [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart#L4) |
| Headline/body support | Present; uses Material 3-like naming in theme plus Cairo semantic helpers |

#### Spacing / icon / component system

| Item | Finding |
|---|---|
| Spacing system | Mostly fixed constants in AppConstants plus `flutter_screenutil` scaling |
| Icon system | Material icons dominate; SVGs are used for branding and some assets |
| Component library | Present and reusable, but not all screens consistently use it |

### 6.2 Screen Inventory

| Screen | File path | Purpose | Entry points | Known UI issues |
|---|---|---|---|---|
| SplashScreen | [lib/features/splash/presentation/pages/splash_screen.dart](lib/features/splash/presentation/pages/splash_screen.dart#L14) | Startup routing decision | App start, router splash route | Uses `SharedPreferences` directly |
| OnboardingScreen | [lib/features/onboarding/presentation/pages/onboarding_screen.dart](lib/features/onboarding/presentation/pages/onboarding_screen.dart#L15) | First-run onboarding | Splash flow | Direct local storage usage |
| WelcomePage | [lib/features/auth/presentation/pages/welcome_page.dart](lib/features/auth/presentation/pages/welcome_page.dart#L9) | Authentication entry | Router/public nav | No major issue observed |
| LoginPage | [lib/features/auth/presentation/pages/login_page.dart](lib/features/auth/presentation/pages/login_page.dart#L26) | Login form | Welcome, router | Session hydration is heavy |
| SignUpPage | [lib/features/auth/presentation/pages/signup_page.dart](lib/features/auth/presentation/pages/signup_page.dart#L26) | Registration flow | Login/welcome | Large page, session persistence in UI |
| ForgotPasswordPage | [lib/features/auth/presentation/pages/forgot_password_page.dart](lib/features/auth/presentation/pages/forgot_password_page.dart#L19) | Password reset request | Login | Normal |
| OtpVerificationPage | [lib/features/auth/presentation/pages/otp_verification_page.dart](lib/features/auth/presentation/pages/otp_verification_page.dart#L18) | OTP verification | Forgot password/register flow | Normal |
| ResetPasswordPage | [lib/features/auth/presentation/pages/reset_password_page.dart](lib/features/auth/presentation/pages/reset_password_page.dart#L18) | Reset password after OTP | OTP flow | Normal |
| ResetPasswordLoggedInPage | [lib/features/auth/presentation/pages/reset_password_logged_in_page.dart](lib/features/auth/presentation/pages/reset_password_logged_in_page.dart#L20) | Change password while logged in | Profile/account | Large screen |
| HomePage | [lib/features/auth/presentation/pages/home_page.dart](lib/features/auth/presentation/pages/home_page.dart#L17) | Shell with bottom navigation | Post-login entry | Session checks in UI |
| HomeScreen | [lib/features/home/presentation/pages/home_screen.dart](lib/features/home/presentation/pages/home_screen.dart#L14) | Discover feed | HomePage tab | Duplicated auth gating and repo access |
| PlaceDetailsScreen | [lib/features/home/presentation/pages/place_details_screen.dart](lib/features/home/presentation/pages/place_details_screen.dart#L17) | Place detail and review editing | Home/feed | Large, mixed responsibilities |
| FavouritesScreen | [lib/features/home/presentation/pages/favourites_screen.dart](lib/features/home/presentation/pages/favourites_screen.dart#L13) | Saved places | Home tab | Auth checks in UI |
| NearbyScreen | [lib/features/nearby/presentation/pages/nearby_screen.dart](lib/features/nearby/presentation/pages/nearby_screen.dart#L13) | Nearby places shell | Bottom nav / router | Normal |
| NearbyPermissionPage | [lib/features/nearby/presentation/pages/nearby_permission_page.dart](lib/features/nearby/presentation/pages/nearby_permission_page.dart#L14) | Prompt for location permission | Nearby flow | Reads auth session in UI |
| NearbyPlacesPage | [lib/features/nearby/presentation/pages/nearby_places_page.dart](lib/features/nearby/presentation/pages/nearby_places_page.dart#L16) | Nearby list and map | Permission flow | Uses hardcoded tile caching TODO |
| TripTypeSelectionScreen | [lib/features/trip_type_selection/presentation/pages/trip_type_selection_screen.dart](lib/features/trip_type_selection/presentation/pages/trip_type_selection_screen.dart#L10) | Choose AI vs custom trip path | Home/action entry | Normal |
| TripSplashScreen | [lib/features/ai_recommendation/presentation/pages/trip_splash_screen.dart](lib/features/ai_recommendation/presentation/pages/trip_splash_screen.dart#L13) | AI trip loading | AI flow | Normal |
| TripBudgetRangeScreen | [lib/features/ai_recommendation/presentation/pages/trip_budget_range_screen.dart](lib/features/ai_recommendation/presentation/pages/trip_budget_range_screen.dart#L9) | Select budget | AI flow | Hardcoded option set |
| TripInterestsScreen | [lib/features/ai_recommendation/presentation/pages/trip_interests_screen.dart](lib/features/ai_recommendation/presentation/pages/trip_interests_screen.dart#L10) | Select interests | AI flow | Hardcoded option set |
| TripInfoScreen | [lib/features/ai_recommendation/presentation/pages/trip_info_screen.dart](lib/features/ai_recommendation/presentation/pages/trip_info_screen.dart#L12) | Trip info step | AI flow | Normal |
| AIRecommendationFlowScreen | [lib/features/ai_recommendation/presentation/pages/ai_recommendation_flow_screen.dart](lib/features/ai_recommendation/presentation/pages/ai_recommendation_flow_screen.dart#L10) | Wizard host | AI entry | Multi-step but still centralized |
| TripDetailsScreen | [lib/features/ai_recommendation/presentation/pages/trip_details_screen.dart](lib/features/ai_recommendation/presentation/pages/trip_details_screen.dart#L19) | Display and regenerate trip | AI flow | Large, service-locator driven |
| CustomTripSplashScreen | [lib/features/custom_trip/presentation/pages/custom_trip_splash_screen.dart](lib/features/custom_trip/presentation/pages/custom_trip_splash_screen.dart#L15) | Custom trip loading | Custom flow | Normal |
| CustomTripFlowScreen | [lib/features/custom_trip/presentation/pages/custom_trip_flow_screen.dart](lib/features/custom_trip/presentation/pages/custom_trip_flow_screen.dart#L8) | Custom trip planner | Trip type selection | Normal |
| ChatBotScreen | [lib/features/chatbot/presentation/pages/chat_bot_screen.dart](lib/features/chatbot/presentation/pages/chat_bot_screen.dart#L14) | Conversational assistant | Router/home | Large but more manageable than trip details |
| ImageSearchResultsScreen | [lib/features/image_search/presentation/pages/image_search_results_screen.dart](lib/features/image_search/presentation/pages/image_search_results_screen.dart#L12) | Image search results | Camera/search | Normal |
| PinterestCameraScreen | [lib/features/image_search/presentation/pages/pinterest_camera_screen.dart](lib/features/image_search/presentation/pages/pinterest_camera_screen.dart#L14) | Camera + photo library browsing | Image search | Large |
| ProfilePage | [lib/features/profile/presentation/pages/profile_page.dart](lib/features/profile/presentation/pages/profile_page.dart#L27) | Profile dashboard | Home shell | Large |
| EditProfilePage | [lib/features/profile/presentation/pages/edit_profile_page.dart](lib/features/profile/presentation/pages/edit_profile_page.dart#L22) | Edit and upload profile | Profile | Large |
| TripHistoryScreen | [lib/features/trip_history/presentation/pages/trip_history_screen.dart](lib/features/trip_history/presentation/pages/trip_history_screen.dart#L17) | Saved trip list | Home/profile | Large |
| TripHistoryDetailScreen | [lib/features/trip_history/presentation/pages/trip_history_detail_screen.dart](lib/features/trip_history/presentation/pages/trip_history_detail_screen.dart#L13) | Saved trip detail | Trip history | Large |

### 6.3 Component Inventory

| Component | File path | Used by | Props/parameters | Known issues |
|---|---|---|---|---|
| BackgroundDecorator | [lib/core/widgets/background_decorator.dart](lib/core/widgets/background_decorator.dart#L5) | Login and other auth screens | Child widget | Simple wrapper, fine |
| RahhalaBottomBar | [lib/core/widgets/rahhala_bottom_bar.dart](lib/core/widgets/rahhala_bottom_bar.dart#L7) | Bottom navigation shell | `currentIndex`, `onTap` | Uses manual layout with hardcoded center gap |
| AppAppBar | [lib/core/components/app_app_bar.dart](lib/core/components/app_app_bar.dart#L5) | Many screens | Title/action parameters | Good reusable widget |
| HomeAppBar | [lib/core/components/app_app_bar.dart](lib/core/components/app_app_bar.dart#L61) | Home | Search/profile UI | Good |
| SearchAppBar | [lib/core/components/app_app_bar.dart](lib/core/components/app_app_bar.dart#L96) | Search contexts | Search callback fields | Stateful but acceptable |
| PrimaryButton | [lib/core/components/primary_button.dart](lib/core/components/primary_button.dart#L5) | Auth/profile/trip screens | Label, loading, sizing | Good reusable action button |
| AppCard | [lib/core/components/app_card.dart](lib/core/components/app_card.dart#L5) | Multiple screens | Card styling | Good |
| FeatureCard | [lib/core/components/app_card.dart](lib/core/components/app_card.dart#L53) | Feature collections | Icon/title/description | Good |
| StatCard | [lib/core/components/app_card.dart](lib/core/components/app_card.dart#L124) | Dashboard summaries | Value/label | Good |
| AppTextField | [lib/core/components/app_text_field.dart](lib/core/components/app_text_field.dart#L4) | Forms | Controller, hint, validators | Good |
| EmailTextField | [lib/core/components/app_text_field.dart](lib/core/components/app_text_field.dart#L80) | Auth forms | Email validation | Good |
| PasswordTextField | [lib/core/components/app_text_field.dart](lib/core/components/app_text_field.dart#L130) | Auth forms | Password input | Good |
| OnboardingPageWidget | [lib/features/onboarding/presentation/widgets/onboarding_page_widget.dart](lib/features/onboarding/presentation/widgets/onboarding_page_widget.dart#L6) | Onboarding | Page content fields | Fine |
| ChatBubble | [lib/features/chatbot/presentation/widgets/chat_bubble.dart](lib/features/chatbot/presentation/widgets/chat_bubble.dart#L11) | ChatBotScreen | Message bubble content | Fine |
| ChatInputField | [lib/features/chatbot/presentation/widgets/chat_input_field.dart](lib/features/chatbot/presentation/widgets/chat_input_field.dart#L11) | ChatBotScreen | Text controller/send handlers | Fine |
| TypingIndicator | [lib/features/chatbot/presentation/widgets/typing_indicator.dart](lib/features/chatbot/presentation/widgets/typing_indicator.dart#L6) | ChatBotScreen | None | Fine |
| ImageSearchBar | [lib/features/image_search/presentation/widgets/image_search_bar.dart](lib/features/image_search/presentation/widgets/image_search_bar.dart#L10) | Image search | Search callback / launcher | Fine |
| PlaceCard | [lib/features/image_search/presentation/widgets/place_card.dart](lib/features/image_search/presentation/widgets/place_card.dart#L11) | Search results | Place model | Good |
| NearbyPlaceCard | [lib/features/nearby/presentation/widgets/nearby_place_card.dart](lib/features/nearby/presentation/widgets/nearby_place_card.dart#L1) | Nearby places | Nearby place data | Good |

### 6.4 UX Flow Analysis

| Journey | Flow summary | Notes |
|---|---|---|
| Onboarding | Splash → onboarding → welcome/login/signup | Flow exists and is understandable, but onboarding persistence is handled directly in the UI layer |
| Free user | Welcome → login/signup → home → browse/search/chat | Free mode is functional; access gating is mostly session-based |
| Premium conversion | Not present | No paywalls or premium UI yet |
| Sound playback | AI navigation only via TTS | This is not a sleep/audio app; TTS is only used for route guidance |
| Mix creation | Custom trip and AI trip wizards | Flow is split across several screens and Cubits |
| Download/offline | Not present | No downloads or offline queues |
| Settings | Profile → language/theme/logout | Basic settings are present and functional |

### 6.5 UX Issues Found

| Issue | Finding |
|---|---|
| Friction points | Several large screens combine multiple sub-flows and slow down mental parsing, especially `EditProfilePage`, `TripHistoryDetailScreen`, and `TripDaySection` |
| Confusing interactions | Some session-based gating lives in the view layer rather than in one guard service |
| Missing feedback states | Some `catch` blocks swallow errors without escalating user-visible details |
| Loading states | Generally present, but the heaviest screens still manage too many states manually |
| Error states | Basic error banners and snackbars exist, but there is no global error surface |
| Empty states | Present in several screens, but not uniform across features |

---

## Section 7 — Performance Analysis

### 7.1 Build Performance

| Item | Finding |
|---|---|
| Widget rebuild frequency | Large widgets rebuild more than necessary because state and UI are tightly coupled in some features |
| Expensive work in build() | The biggest risk is in trip details and profile pages rather than in `main.dart` |
| Missing const constructors | Many widgets are const-friendly, but very large pages still contain numerous non-const branches |
| setState overuse | Present in large stateful screens like profile editing and navigation/map views |

### 7.2 Memory Management

| Item | Finding |
|---|---|
| Player disposal | `TripDaySection` stops TTS and cancels location subscriptions in `dispose()` [lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart](lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart#L474) |
| Memory leak risk | Moderate risk in large map/navigation widgets due to many state variables and streams |
| Large asset loading | Images are mostly cached where it matters; some `Image.network()` usages still exist |
| Image caching strategy | Mixed; `CachedNetworkImage` is used in several screens, but not everywhere |

### 7.3 Audio Performance

| Item | Finding |
|---|---|
| AudioPlayerManager | Not present; there is no generic audio player manager because the app is not a media app |
| Player lifecycle | TTS lifecycle is managed directly in trip navigation widgets |
| Background playback | Not implemented |

### 7.4 Network Performance

| Item | Finding |
|---|---|
| API call frequency | Retry interceptor exists, but there is no aggressive cache layer outside image caching |
| Caching strategy | HTTP caching is not explicit; image caching is the main optimization |
| Offline handling | Limited |

---

## Section 8 — Code Quality Analysis

### 8.1 Clean Code Metrics

| Metric | Finding |
|---|---|
| Average method length | Not statically computed for every method in this audit; the codebase contains several long imperative handlers inside large screens |
| Longest handwritten files | [lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart](lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart#L1) at 1667 lines, [lib/features/profile/presentation/pages/edit_profile_page.dart](lib/features/profile/presentation/pages/edit_profile_page.dart#L1) at 840, [lib/features/trip_history/presentation/pages/trip_history_detail_screen.dart](lib/features/trip_history/presentation/pages/trip_history_detail_screen.dart#L1) at 817, [lib/features/profile/presentation/pages/profile_page.dart](lib/features/profile/presentation/pages/profile_page.dart#L1) at 632, [lib/features/nearby/presentation/pages/nearby_places_page.dart](lib/features/nearby/presentation/pages/nearby_places_page.dart#L1) at 599 |
| Largest generated files | [lib/l10n/generated/app_localizations.dart](lib/l10n/generated/app_localizations.dart#L1) at 1819 lines, but this is generated and not a maintenance concern |
| Code duplication | Theme colors are duplicated between `AppColors` and `ThemeColor`; there are repeated session hydration patterns after auth/profile operations |
| Magic strings / numbers | Hardcoded route labels, option strings, and dimensions appear in AI and profile flows |
| Dead code | Web branding is stale (`auth_app`); some routes are coming-soon placeholders |

### 8.2 Error Handling

| Item | Finding |
|---|---|
| Try-catch coverage | Present in network and repository layers; UI layers also catch errors around profile/photo and login flows |
| Silent failures | Several `catch (_) {}` blocks remain in [lib/features/auth/data/repositories/auth_repository_impl.dart](lib/features/auth/data/repositories/auth_repository_impl.dart#L53), [lib/features/home/presentation/cubit/favourites_cubit.dart](lib/features/home/presentation/cubit/favourites_cubit.dart#L35), [lib/features/profile/presentation/pages/edit_profile_page.dart](lib/features/profile/presentation/pages/edit_profile_page.dart#L172), [lib/features/ai_recommendation/presentation/pages/trip_details_screen.dart](lib/features/ai_recommendation/presentation/pages/trip_details_screen.dart#L95) |
| User-facing errors | Usable snackbars and notifications exist, but some branches still suppress detail |
| Crashlytics | Not implemented |

### 8.3 Logging

| Item | Finding |
|---|---|
| Current strategy | `logger` wrapper exists in [lib/core/logging/app_logger.dart](lib/core/logging/app_logger.dart#L1) |
| Debug prints in production | No `print()`/`debugPrint()` calls were found in `lib/` during this audit |
| Structured logging | Partial; logger exists, but many catches are silent rather than logged |

### 8.4 Code Documentation

| Item | Finding |
|---|---|
| Public API docs | Mixed; some core classes are documented, many feature widgets are not |
| Missing dartdoc | Present across most feature screens and widgets |
| Inline comments | Used sparingly; useful in some files, but also contains stale TODO comments |

---

## Section 9 — Testing Analysis

### 9.1 Current Test Coverage

| Metric | Value |
|---|---|
| Total test files | 10 Dart test files under `test/` |
| Visible test case declarations | 33 declarations found by scan |
| Passing vs failing | 28 passed, 11 skipped, 0 failed |
| Coverage percentage | 52.17% by the generated lcov summary in `coverage/lcov.info` |

### 9.2 Test Quality

| Area | Status | Notes |
|---|---|---|
| Unit tests | Good for login/register/profile/session helpers | See [test/features/auth/login_cubit_test.dart](test/features/auth/login_cubit_test.dart#L1) and [test/features/profile/profile_cubit_test.dart](test/features/profile/profile_cubit_test.dart#L1) |
| Widget tests | Very limited | [test/widget_test.dart](test/widget_test.dart#L1) is small and only checks app constants |
| Integration tests | Present | Endpoint tests exist for chatbot and trip features |
| Missing critical tests | Large UI flows, route guards, error states, permission paths, and map/navigation behavior |

### 9.3 Testing Infrastructure

| Item | Finding |
|---|---|
| Mock/fake setup | Good use of `mocktail`, `bloc_test`, and lightweight fakes in feature tests |
| Test utilities | Present and practical for Cubits and session helpers |
| CI/CD integration | Not visible in this repository snapshot |

---

## Section 10 — Dependencies Analysis

### 10.1 Pubspec Audit

| Package | Version | Purpose | Necessary? | Correct section? | Freshness note |
|---|---|---|---|---|---|
| `country_picker` | `^2.0.27` | Country picker in auth/profile flows | Yes | dependencies | Reasonable |
| `cupertino_icons` | `^1.0.8` | iOS-style icons | Yes | dependencies | Standard |
| `curved_navigation_bar` | `^1.0.6` | Decorative navigation | Maybe | dependencies | Present but not critical |
| `dartz` | `^0.10.1` | Either/failure handling | Yes | dependencies | Reasonable |
| `dio` | `^5.9.0` | HTTP client | Yes | dependencies | Reasonable |
| `elegant_notification` | `^2.5.1` | UI notifications | Yes | dependencies | Reasonable |
| `equatable` | `^2.0.7` | State equality | Yes | dependencies | Reasonable |
| `flutter` | SDK | Framework | Yes | dependencies | N/A |
| `flutter_localizations` | SDK | Localization | Yes | dependencies | N/A |
| `flutter_bloc` | `^9.1.1` | Cubit/BLoC state management | Yes | dependencies | Reasonable |
| `flutter_screenutil` | `^5.9.3` | Responsive sizing | Yes | dependencies | Reasonable |
| `flutter_svg` | `^2.2.1` | SVG rendering | Yes | dependencies | Reasonable |
| `get_it` | `^8.2.0` | DI | Yes | dependencies | Reasonable |
| `go_router` | `^16.3.0` | Navigation | Yes | dependencies | Reasonable |
| `image_picker` | `^1.2.0` | Photo picker | Yes | dependencies | Reasonable |
| `lottie` | `^3.3.2` | Animations | Yes | dependencies | Reasonable |
| `shared_preferences` | `^2.5.3` | Non-sensitive local prefs | Yes | dependencies | Reasonable |
| `flutter_secure_storage` | `^9.2.4` | Secure token/session storage | Yes | dependencies | Reasonable |
| `logger` | `^2.6.1` | Logging | Yes | dependencies | Reasonable |
| `smooth_page_indicator` | `^1.2.1` | Onboarding indicator | Yes | dependencies | Reasonable |
| `intl` | `^0.20.2` | Date/locale formatting | Yes | dependencies | Reasonable |
| `cached_network_image` | `^3.3.1` | Image caching | Yes | dependencies | Reasonable |
| `shimmer` | `^3.0.0` | Loading placeholders | Yes | dependencies | Reasonable |
| `camera` | `^0.10.5+9` | Camera preview and capture | Yes | dependencies | Reasonable |
| `photo_manager` | `^3.0.0` | Gallery browsing | Yes | dependencies | Reasonable |
| `timeago` | `^3.7.0` | Relative timestamps | Yes | dependencies | Reasonable |
| `flutter_map` | `^7.0.2` | Maps | Yes | dependencies | Reasonable |
| `latlong2` | `^0.9.1` | Map coordinates | Yes | dependencies | Reasonable |
| `geolocator` | `^13.0.2` | GPS and permission handling | Yes | dependencies | Reasonable |
| `flutter_tts` | `^4.2.2` | Navigation voice prompts | Maybe | dependencies | Specific to trip navigation only |
| `url_launcher` | `^6.3.0` | External URLs | Yes | dependencies | Reasonable |
| `flutter_lints` | `^4.0.0` | Static lint rules | Yes | dev_dependencies | Correct |
| `flutter_test` | SDK | Testing | Yes | dev_dependencies | Correct |
| `bloc_test` | `^10.0.0` | Cubit tests | Yes | dev_dependencies | Correct |
| `mocktail` | `^1.0.4` | Mocking | Yes | dev_dependencies | Correct |
| `flutter_launcher_icons` | `^0.14.3` | App icon generation | Yes | dev_dependencies | Correct |

### 10.2 Dependency Risks

| Risk | Finding |
|---|---|
| Unmaintained packages | None obvious from the current package set |
| Known security vulnerabilities | None directly visible in this audit snapshot |
| Replaceable with native Flutter | `curved_navigation_bar` and some decorative helpers could be replaced by pure Flutter if simplification is desired |

---

## Section 11 — Monetization Analysis

### 11.1 Revenue Streams

| Stream | Status | Current pricing |
|---|---|---|
| Monthly subscription | Not implemented | N/A |
| Annual subscription | Not implemented | N/A |
| Lifetime plan | Not implemented | N/A |
| Interstitial ads | Not implemented | N/A |
| Rewarded ads | Not implemented | N/A |
| App open ads | Not implemented | N/A |

### 11.2 Conversion Funnel

| Item | Finding |
|---|---|
| Paywall locations | None |
| Paywall quality | N/A |
| A/B testing | Not implemented |

### 11.3 Subscriber Protection

| Item | Finding |
|---|---|
| Subscriber count | No subscriber system exists in this codebase |
| Risks to access | Not applicable yet |
| Safety measures | None needed until premium is introduced |

---

## Section 12 — Known Bugs & Issues

| # | Bug Description | Severity | File + Line | Status |
|---|---|---|---|---|
| 1 | Release APK cannot be built in this environment because `android/key.properties` is missing | Major | [android/app/build.gradle.kts](android/app/build.gradle.kts#L39) | Open |
| 2 | `debugMode` is still enabled in app constants | Major | [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart#L139) | Open |
| 3 | `TripDaySection` mixes rendering, route requests, GPS permission handling, and TTS | Major | [lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart](lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart#L474) | Open |
| 4 | `ImageSearchCubit` still depends on `ImagePicker` directly | Major | [lib/features/image_search/domain/image_search_cubit.dart](lib/features/image_search/domain/image_search_cubit.dart#L2) | Open |
| 5 | Splash screen reads `SharedPreferences` directly | Minor | [lib/features/splash/presentation/pages/splash_screen.dart](lib/features/splash/presentation/pages/splash_screen.dart#L33) | Open |
| 6 | Web branding still says `auth_app` | Minor | [web/manifest.json](web/manifest.json#L2), [web/index.html](web/index.html#L21) | Open |
| 7 | Some repository and UI branches still swallow exceptions with empty catches | Minor | [lib/features/auth/data/repositories/auth_repository_impl.dart](lib/features/auth/data/repositories/auth_repository_impl.dart#L53), [lib/features/home/presentation/cubit/favourites_cubit.dart](lib/features/home/presentation/cubit/favourites_cubit.dart#L35) | Open |

---

## Section 13 — Technical Debt

| # | Issue | Priority | Effort | Impact |
|---|---|---|---|---|
| 1 | Split `TripDaySection` into smaller widgets/services | High | Large | High |
| 2 | Remove direct `GetIt` usage from presentation layer | High | Medium | High |
| 3 | Move image picking out of `ImageSearchCubit` | High | Small | Medium |
| 4 | Replace `SharedPreferences` reads in splash/onboarding with a startup/session service | Medium | Small | Medium |
| 5 | Centralize repeated colors into one design token source | Medium | Medium | Medium |
| 6 | Remove stale web branding | Medium | Small | Medium |
| 7 | Add global error reporting and structured logging | Medium | Medium | Medium |
| 8 | Grow tests around route guards, permission flows, and map/navigation behavior | High | Medium | High |

---

## Section 14 — Improvement Roadmap

### 14.1 Immediate (Before Next Release)

- Fix the release signing setup so `flutter build apk --release` works with real credentials.
- Turn off `debugMode` in [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart#L139) or gate it by flavor.
- Keep the Android and iOS permission declarations as they are; those are now in good shape.

### 14.2 Short Term (Next 2–4 Weeks)

- Extract `ImagePicker` from `ImageSearchCubit` into a service abstraction.
- Split `TripDaySection` into presentation and navigation services.
- Move splash/onboarding persistence into one session/bootstrap service.
- Remove stale web branding and replace `auth_app` with Rahhala branding.

### 14.3 Medium Term (Next 1–3 Months)

- Normalize repository interfaces so domain stays domain-centric.
- Replace duplicated design tokens with a single source of truth.
- Add route guard tests, location permission tests, and widget tests for top flows.
- Introduce analytics and crash reporting if the app is meant for production monitoring.

### 14.4 Long Term (3+ Months)

- Introduce a premium entitlement model only if a monetization strategy is required.
- Add downloadable/offline trip support if travel usage demands it.
- Add map route caching and offline fallbacks.
- Refactor the heaviest screens into smaller composable modules.

---

## Section 15 — Executive Summary

| Item | Finding |
|---|---|
| App health score | 6.9/10 |
| Top 5 strengths | 1) Flutter + BLoC + GetIt stack is consistent. 2) Secure token storage is in place. 3) GoRouter and route guards exist. 4) The test suite now passes. 5) Nearby location access has a proper abstraction. |
| Top 5 critical issues | 1) `debugMode` is still enabled. 2) Release build is blocked without signing properties. 3) `TripDaySection` is a god widget. 4) `ImageSearchCubit` still depends on `ImagePicker`. 5) Web metadata is stale. |
| Top 5 recommended actions | 1) Fix release signing. 2) Turn off debug mode. 3) Extract image and navigation services. 4) Clean up stale web branding. 5) Expand tests around route/session/permission flows. |
| Overall risk assessment for current subscribers | Moderate. The current runtime state is usable, but long-term maintainability and release readiness are still constrained by architecture debt and release configuration gaps. |

---

## Appendix — Evidence Highlights

- App bootstraps with `MaterialApp.router` in [lib/main.dart](lib/main.dart#L42).
- Route protection exists in [lib/core/routing/app_router.dart](lib/core/routing/app_router.dart#L195) and [lib/core/routing/app_router.dart](lib/core/routing/app_router.dart#L204).
- Secure session storage is handled in [lib/core/utils/token_storage.dart](lib/core/utils/token_storage.dart#L1).
- `NearbyCubit` uses the `LocationService` abstraction in [lib/features/nearby/domain/cubit/nearby_cubit.dart](lib/features/nearby/domain/cubit/nearby_cubit.dart#L8).
- `TripDaySection` directly calls Geolocator at [lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart](lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart#L568), [lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart](lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart#L593), and [lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart](lib/features/ai_recommendation/presentation/widgets/trip_details/trip_day_section.dart#L603).
- The heaviest handwritten files are `TripDaySection`, `EditProfilePage`, `TripHistoryDetailScreen`, `ProfilePage`, and `NearbyPlacesPage`.
