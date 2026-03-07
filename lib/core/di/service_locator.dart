import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:rahhala_app/features/image_search/data/repositories/image_search_repository_impl.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_cubit.dart';
import 'package:rahhala_app/features/image_search/domain/image_search_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/dio_consumer.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rahhala_app/features/auth/domain/forgot_password/forgot_password_cubit.dart';
import 'package:rahhala_app/features/auth/domain/login/login_cubit.dart';
import 'package:rahhala_app/features/auth/domain/register/register_cubit.dart';
import 'package:rahhala_app/features/auth/domain/reset_password/reset_password_cubit.dart';
import 'package:rahhala_app/features/auth/domain/verify_otp/verify_otp_cubit.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/core/utils/user_session.dart';
import 'package:rahhala_app/core/network/api_interceptors.dart';

import 'package:rahhala_app/features/profile/data/repositories/user_repository.dart';
import 'package:rahhala_app/features/profile/data/repositories/user_repository_impl.dart';
import 'package:rahhala_app/features/profile/domain/profile/profile_cubit.dart';
import 'package:rahhala_app/features/profile/domain/edit_profile/edit_profile_cubit.dart';

import 'package:rahhala_app/features/ai_recommendation/data/repositories/gemini_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/data/repositories/gemini_repository_impl.dart';
import 'package:rahhala_app/features/ai_recommendation/domain/ai_trip_cubit.dart';

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
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<TokenStorage>(TokenStorage(prefs));
  sl.registerLazySingleton<UserSession>(() => UserSession());

  final dio = Dio();
  dio.interceptors.add(ApiInterceptors());
  sl.registerLazySingleton<Dio>(() => dio);
  sl.registerLazySingleton<ApiConsumer>(() => DioConsumer(dio: sl<Dio>()));

  sl.registerLazySingleton<AuthRepo>(
      () => AuthRepoImpl(apiConsumer: sl<ApiConsumer>()));
  sl.registerFactory<LoginCubit>(() => LoginCubit(authRepo: sl<AuthRepo>()));
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
  sl.registerFactory<EditProfileCubit>(
      () => EditProfileCubit(repo: sl<UserRepo>()));

  sl.registerLazySingleton<GeminiRepository>(
      () => GeminiRepositoryImpl(apiConsumer: sl<ApiConsumer>()));
  sl.registerFactory<AiTripCubit>(
      () => AiTripCubit(geminiRepository: sl<GeminiRepository>()));

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
  sl.registerFactory<ImageSearchCubit>(
    () => ImageSearchCubit(repository: sl<ImageSearchRepository>()),
  );

  // ChatBot registration
  sl.registerLazySingleton<ChatBotApiService>(
    () => ChatBotApiService(dio: sl<Dio>()),
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

  // ChatBot Cubit
  sl.registerFactory<ChatBotCubit>(
    () => ChatBotCubit(
      sendMessageUseCase: sl<SendMessageUseCase>(),
      streamMessageUseCase: sl<StreamMessageUseCase>(),
      createContextUseCase: sl<CreateContextUseCase>(),
      updateContextItemsUseCase: sl<UpdateContextItemsUseCase>(),
      getContextUseCase: sl<GetContextUseCase>(),
      discardContextUseCase: sl<DiscardContextUseCase>(),
    ),
  );
}
