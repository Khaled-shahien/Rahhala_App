import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:rahhala_app/core/analytics/analytics_service.dart';
import 'package:rahhala_app/core/analytics/firebase_analytics_service.dart';
import 'package:rahhala_app/core/auth/auth_session_service.dart';
import 'package:rahhala_app/core/constants/app_constants.dart';
import 'package:rahhala_app/core/crash/app_error_reporter.dart';
import 'package:rahhala_app/core/crash/crash_reporting_service.dart';
import 'package:rahhala_app/core/crash/firebase_crash_reporting_service.dart';
import 'package:rahhala_app/core/logging/app_logger.dart';
import 'package:rahhala_app/core/network/end_points.dart';
import 'package:rahhala_app/core/services/image_picker_service.dart';
import 'package:rahhala_app/core/services/image_picker_service_impl.dart';
import 'package:rahhala_app/core/theme/theme_controller.dart';
import 'package:rahhala_app/features/home/data/datasource/home_remote_data_source.dart';
import 'package:rahhala_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:rahhala_app/features/home/domain/repositories/home_repository.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/place_details_cubit.dart';
import 'package:rahhala_app/features/home/presentation/details_cubit/review_cubit.dart';
import 'package:rahhala_app/features/home/presentation/cubit/favourites_cubit.dart';
import 'package:rahhala_app/features/image_search/data/repositories/image_search_repository_impl.dart';
import 'package:rahhala_app/features/image_search/data/services/image_acquisition_service_impl.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_cubit.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_repository.dart';
import 'package:rahhala_app/features/image_search/domain/services/image_acquisition_service.dart';
import 'package:rahhala_app/features/nearby/data/datasource/nearby_remote_data_source.dart';
import 'package:rahhala_app/features/nearby/data/repositories/nearby_repository_impl.dart';
import 'package:rahhala_app/features/nearby/data/services/geolocator_location_service.dart';
import 'package:rahhala_app/features/nearby/domain/cubit/nearby_cubit.dart';
import 'package:rahhala_app/features/nearby/domain/repositories/nearby_repository.dart';
import 'package:rahhala_app/features/nearby/domain/services/location_service.dart';
import 'package:rahhala_app/features/trip_history/data/repositories/trip_history_repository_impl.dart';
import 'package:rahhala_app/features/trip_history/domain/cubits/trip_history_cubit.dart';
import 'package:rahhala_app/features/trip_history/domain/trip_history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rahhala_app/core/localization/app_locale_controller.dart';
import 'package:rahhala_app/core/startup/startup_preferences_service.dart';
import 'package:rahhala_app/core/startup/app_bootstrap_cubit.dart';
import 'package:rahhala_app/core/startup/app_bootstrap_service.dart';

import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/dio_consumer.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rahhala_app/features/auth/domain/forgot_password/forgot_password_cubit.dart';
import 'package:rahhala_app/features/auth/domain/login/login_cubit.dart';
import 'package:rahhala_app/features/auth/domain/register/register_cubit.dart';
import 'package:rahhala_app/features/auth/domain/reset_password/reset_password_cubit.dart';
import 'package:rahhala_app/features/auth/domain/usecases/post_login_session_use_case.dart';
import 'package:rahhala_app/features/auth/domain/verify_otp/verify_otp_cubit.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/core/utils/user_session.dart';
import 'package:rahhala_app/core/network/api_interceptors.dart';
import 'package:rahhala_app/core/network/retry_interceptor.dart';

import 'package:rahhala_app/features/profile/data/repositories/user_repository.dart';
import 'package:rahhala_app/features/profile/data/repositories/user_repository_impl.dart';
import 'package:rahhala_app/features/profile/domain/profile/profile_cubit.dart';
import 'package:rahhala_app/features/profile/domain/edit_profile/edit_profile_cubit.dart';
import 'package:rahhala_app/features/profile/domain/usecases/profile_photo_upload_use_case.dart';
import 'package:rahhala_app/features/onboarding/data/repositories/shared_preferences_onboarding_repository.dart';
import 'package:rahhala_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:rahhala_app/features/onboarding/presentation/cubit/onboarding_cubit.dart';

import 'package:rahhala_app/features/ai_recommendation/data/repositories/gemini_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/data/repositories/gemini_repository_impl.dart';
import 'package:rahhala_app/features/ai_recommendation/data/repositories/trip_options/local_trip_options_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/data/repositories/trip_options/remote_trip_options_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/data/services/navigation_service_impl.dart';
import 'package:rahhala_app/features/ai_recommendation/data/services/route_polling_service_impl.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/navigation_service.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/route_polling_service.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/navigation/trip_navigation_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/repositories/trip_options_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/cubit/navigation_voice_cubit.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_location_tracking_service.dart';
import 'package:rahhala_app/features/ai_recommendation/presentation/widgets/trip_details/trip_navigation_voice_service.dart';

// Custom Trip imports
import 'package:rahhala_app/features/custom_trip/data/sources/trip_api_service.dart';
import 'package:rahhala_app/features/custom_trip/data/repositories/trip_repository.dart';
import 'package:rahhala_app/features/custom_trip/domain/repositories/trip_repository_interface.dart';
import 'package:rahhala_app/features/custom_trip/domain/usecases/generate_trip_plan_usecase.dart';
import 'package:rahhala_app/features/custom_trip/presentation/cubit/custom_trip_cubit.dart';

// ChatBot imports
import 'package:rahhala_app/features/chatbot/data/sources/chat_bot_api_service.dart';
import 'package:rahhala_app/features/chatbot/data/repositories/chat_bot_repository_impl.dart';
import 'package:rahhala_app/features/chatbot/domain/repositories/chat_bot_repository.dart';
import 'package:rahhala_app/features/chatbot/domain/usecases/send_message_usecase.dart';
import 'package:rahhala_app/features/chatbot/domain/usecases/stream_message_usecase.dart';
import 'package:rahhala_app/features/chatbot/domain/usecases/create_context_usecase.dart';
import 'package:rahhala_app/features/chatbot/domain/usecases/update_context_items_usecase.dart';
import 'package:rahhala_app/features/chatbot/domain/usecases/get_context_usecase.dart';
import 'package:rahhala_app/features/chatbot/domain/usecases/discard_context_usecase.dart';
import 'package:rahhala_app/features/chatbot/presentation/cubit/chat_bot_cubit.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final firebaseObservabilityReady = await _initializeFirebaseObservability();

  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  final tokenStorage = TokenStorage(
    secureStorage: secureStorage,
    legacyPrefs: prefs,
  );
  await tokenStorage.initialize();
  sl.registerSingleton<AppLocaleController>(
    AppLocaleController(preferences: prefs),
  );
  sl.registerSingleton<StartupPreferencesService>(
    StartupPreferencesService(preferences: prefs),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => SharedPreferencesOnboardingRepository(preferences: prefs),
  );
  sl.registerSingleton<TokenStorage>(tokenStorage);
  sl.registerLazySingleton<UserSession>(() => UserSession());
  sl.registerLazySingleton<AuthSessionService>(
    () => AuthSessionService(
      tokenStorage: sl<TokenStorage>(),
      userSession: sl<UserSession>(),
    ),
  );
  sl.registerLazySingleton<AppBootstrapService>(
    () => AppBootstrapService(
      onboardingRepository: sl<OnboardingRepository>(),
      authSessionService: sl<AuthSessionService>(),
    ),
  );
  sl.registerFactory<AppBootstrapCubit>(
    () => AppBootstrapCubit(service: sl<AppBootstrapService>()),
  );
  sl.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(repository: sl<OnboardingRepository>()),
  );
  sl.registerLazySingleton<ImagePickerService>(() => ImagePickerServiceImpl());
  sl.registerLazySingleton<AnalyticsService>(
    () => AppConstants.enableAnalytics && firebaseObservabilityReady
        ? FirebaseAnalyticsService()
        : const NoopAnalyticsService(),
  );
  sl.registerLazySingleton<CrashReportingService>(
    () => AppConstants.enableCrashReporting && firebaseObservabilityReady
        ? FirebaseCrashReportingService()
        : const NoopCrashReportingService(),
  );
  AppErrorReporter.configure(sl<CrashReportingService>());

  final dio = Dio();
  dio.interceptors.add(ApiInterceptors());
  dio.interceptors.add(RetryInterceptor(dio: dio));
  sl.registerLazySingleton<Dio>(() => dio);
  sl.registerLazySingleton<ApiConsumer>(() => DioConsumer(dio: sl<Dio>()));

  // ChatBot Dio instance with its own base URL
  final chatBotDio = Dio(BaseOptions(
    baseUrl: EndPoints.chatBotBaseUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    responseType: ResponseType.json,
  ));
  chatBotDio.interceptors.add(RetryInterceptor(dio: chatBotDio));
  sl.registerLazySingleton<Dio>(instanceName: 'chatbot', () => chatBotDio);

  sl.registerLazySingleton<AuthRepo>(
      () => AuthRepoImpl(apiConsumer: sl<ApiConsumer>()));
  sl.registerLazySingleton<PostLoginSessionUseCase>(
    () => PostLoginSessionUseCase(
      authSessionService: sl<AuthSessionService>(),
      userRepo: sl<UserRepo>(),
    ),
  );
  sl.registerFactory<LoginCubit>(
    () => LoginCubit(
      authRepo: sl<AuthRepo>(),
      postLoginSessionUseCase: sl<PostLoginSessionUseCase>(),
    ),
  );
  sl.registerFactory<RegisterCubit>(
      () => RegisterCubit(authRepo: sl<AuthRepo>()));
  sl.registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(authRepo: sl<AuthRepo>()));
  sl.registerFactory<VerifyOtpCubit>(
      () => VerifyOtpCubit(authRepo: sl<AuthRepo>()));
  sl.registerFactory<ResetPasswordCubit>(
      () => ResetPasswordCubit(authRepo: sl<AuthRepo>()));

  sl.registerLazySingleton<UserRepo>(
      () => UserRepoImpl(api: sl<ApiConsumer>()));
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(repo: sl<UserRepo>()));
  sl.registerLazySingleton<ProfilePhotoUploadUseCase>(
    () => ProfilePhotoUploadUseCase(
      repo: sl<UserRepo>(),
      authSessionService: sl<AuthSessionService>(),
    ),
  );
  sl.registerFactory<EditProfileCubit>(
    () => EditProfileCubit(
      repo: sl<UserRepo>(),
      profilePhotoUploadUseCase: sl<ProfilePhotoUploadUseCase>(),
      imagePickerService: sl<ImagePickerService>(),
      authSessionService: sl<AuthSessionService>(),
    ),
  );

  sl.registerLazySingleton<GeminiRepository>(
      () => GeminiRepositoryImpl(apiConsumer: sl<ApiConsumer>()));
  sl.registerLazySingleton<LocalTripOptionsRepository>(
    () => const LocalTripOptionsRepository(),
  );
  sl.registerLazySingleton<TripOptionsRepository>(
    () => RemoteTripOptionsRepository(
      api: sl<ApiConsumer>(),
      fallback: sl<LocalTripOptionsRepository>(),
    ),
  );
  sl.registerFactory<AiTripCubit>(
    () => AiTripCubit(
      geminiRepository: sl<GeminiRepository>(),
      tripOptionsRepository: sl<TripOptionsRepository>(),
    ),
  );
  sl.registerLazySingleton<NavigationVoiceCubit>(() => NavigationVoiceCubit());
  sl.registerFactory<TripLocationTrackingService>(
    () => TripLocationTrackingService(),
  );
  sl.registerFactory<TripNavigationVoiceService>(
    () => TripNavigationVoiceService(),
  );
  sl.registerFactory<NavigationService>(
    () => NavigationServiceImpl(
      api: sl<ApiConsumer>(),
      locationService: sl<TripLocationTrackingService>(),
      voiceService: sl<TripNavigationVoiceService>(),
    ),
  );
  sl.registerFactory<RoutePollingService>(() => RoutePollingServiceImpl());
  sl.registerFactory<TripNavigationCubit>(
    () => TripNavigationCubit(
      navigationService: sl<NavigationService>(),
      routePollingService: sl<RoutePollingService>(),
    ),
  );

  // Custom Trip registration
  sl.registerLazySingleton<TripApiService>(
      () => TripApiService(dio: sl<Dio>()));
  sl.registerLazySingleton<TripRepositoryInterface>(
      () => TripRepository(apiService: sl<TripApiService>()));
  sl.registerLazySingleton<GenerateTripPlanUsecase>(
      () => GenerateTripPlanUsecase(sl<TripRepositoryInterface>()));
  sl.registerFactory<CustomTripCubit>(() =>
      CustomTripCubit(generateTripPlanUsecase: sl<GenerateTripPlanUsecase>()));

  sl.registerLazySingleton<ImageSearchRepository>(
    () => ImageSearchRepositoryImpl(dio: sl<Dio>()),
  );
  // sl.registerLazySingleton<ImageSearchRepository>(
  //   () => ImageSearchRepositoryImpl(dio: sl<Dio>()),
  // );
  sl.registerLazySingleton<ImageAcquisitionService>(
    () => ImageAcquisitionServiceImpl(
      imagePickerService: sl<ImagePickerService>(),
    ),
  );
  sl.registerFactory<ImageSearchCubit>(
    () => ImageSearchCubit(
      repository: sl<ImageSearchRepository>(),
      imageAcquisitionService: sl<ImageAcquisitionService>(),
    ),
  );

  // ChatBot registration
  sl.registerLazySingleton<ChatBotApiService>(
    () => ChatBotApiService(dio: sl<Dio>(instanceName: 'chatbot')),
  );
  sl.registerLazySingleton<ChatBotRepository>(
    () => ChatBotRepositoryImpl(
      apiService: sl<ChatBotApiService>(),
    ),
  );

  // ChatBot Use Cases
  sl.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(sl<ChatBotRepository>()),
  );
  sl.registerLazySingleton<StreamMessageUseCase>(
    () => StreamMessageUseCase(sl<ChatBotRepository>()),
  );
  sl.registerLazySingleton<CreateContextUseCase>(
    () => CreateContextUseCase(sl<ChatBotRepository>()),
  );
  sl.registerLazySingleton<UpdateContextItemsUseCase>(
    () => UpdateContextItemsUseCase(sl<ChatBotRepository>()),
  );
  sl.registerLazySingleton<GetContextUseCase>(
    () => GetContextUseCase(sl<ChatBotRepository>()),
  );
  sl.registerLazySingleton<DiscardContextUseCase>(
    () => DiscardContextUseCase(sl<ChatBotRepository>()),
  );
  sl.registerLazySingleton<TripHistoryRepository>(
    () => TripHistoryRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerFactory<TripHistoryCubit>(
    () => TripHistoryCubit(repository: sl<TripHistoryRepository>()),
  );

  // ChatBot Cubit
  sl.registerLazySingleton<ChatBotCubit>(
    () => ChatBotCubit(
      sendMessageUseCase: sl<SendMessageUseCase>(),
      streamMessageUseCase: sl<StreamMessageUseCase>(),
      createContextUseCase: sl<CreateContextUseCase>(),
      updateContextItemsUseCase: sl<UpdateContextItemsUseCase>(),
      getContextUseCase: sl<GetContextUseCase>(),
      discardContextUseCase: sl<DiscardContextUseCase>(),
    ),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      api: sl(),
    ),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl<HomeRemoteDataSource>()),
  );

//details
  sl.registerFactory<PlaceDetailsCubit>(
    () => PlaceDetailsCubit(sl<HomeRepository>()),
  );

  sl.registerFactory<ReviewCubit>(
    () => ReviewCubit(sl<HomeRepository>()),
  );

  // App theme controller
  sl.registerSingleton<AppThemeController>(AppThemeController());

  sl.registerFactory<FavouritesCubit>(
    () => FavouritesCubit(sl<HomeRepository>()),
  );

  sl.registerLazySingleton<NearbyRemoteDataSource>(
    () => NearbyRemoteDataSourceImpl(api: sl<ApiConsumer>()),
  );
  sl.registerLazySingleton<NearbyRepository>(
    () => NearbyRepositoryImpl(remoteDataSource: sl<NearbyRemoteDataSource>()),
  );
  sl.registerLazySingleton<LocationService>(() => GeolocatorLocationService());
  sl.registerFactory<NearbyCubit>(
    () => NearbyCubit(
      repository: sl<NearbyRepository>(),
      locationService: sl<LocationService>(),
    ),
  );
}

Future<bool> _initializeFirebaseObservability() async {
  if (!AppConstants.enableAnalytics && !AppConstants.enableCrashReporting) {
    return false;
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    return true;
  } catch (e, stackTrace) {
    AppLogger.instance.w(
      'Firebase observability disabled because initialization failed',
      error: e,
      stackTrace: stackTrace,
    );
    return false;
  }
}
