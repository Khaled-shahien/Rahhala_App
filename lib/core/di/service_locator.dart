import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rahhala_app/core/network/api_consumer.dart';
import 'package:rahhala_app/core/network/dio_consumer.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository.dart';
import 'package:rahhala_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rahhala_app/features/auth/logic/forgot_password/forgot_password_cubit.dart';
import 'package:rahhala_app/features/auth/logic/login/login_cubit.dart';
import 'package:rahhala_app/features/auth/logic/register/register_cubit.dart';
import 'package:rahhala_app/features/auth/logic/reset_password/reset_password_cubit.dart';
import 'package:rahhala_app/features/auth/logic/verify_otp/verify_otp_cubit.dart';
import 'package:rahhala_app/core/utils/token_storage.dart';
import 'package:rahhala_app/core/utils/user_session.dart';
import 'package:rahhala_app/core/network/api_interceptors.dart';

import 'package:rahhala_app/features/profile/data/repositories/user_repository.dart';
import 'package:rahhala_app/features/profile/data/repositories/user_repository_impl.dart';
import 'package:rahhala_app/features/profile/logic/profile/profile_cubit.dart';
import 'package:rahhala_app/features/profile/logic/edit_profile/edit_profile_cubit.dart';

import 'package:rahhala_app/features/ai_recommendation/data/repositories/gemini_repository.dart';
import 'package:rahhala_app/features/ai_recommendation/data/repositories/gemini_repository_impl.dart';
import 'package:rahhala_app/features/ai_recommendation/logic/ai_trip_cubit.dart';

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
}
