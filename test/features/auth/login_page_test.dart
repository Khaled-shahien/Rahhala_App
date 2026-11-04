import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rahhala_app/core/di/service_locator.dart';
import 'package:rahhala_app/core/localization/app_messages.dart';
import 'package:rahhala_app/features/auth/domain/login/login_cubit.dart';
import 'package:rahhala_app/features/auth/domain/login/login_state.dart';
import 'package:rahhala_app/features/auth/presentation/pages/login_page.dart';
import 'package:rahhala_app/l10n/generated/app_localizations.dart';

class _MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

Widget _app(Locale locale) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoginPage(),
    ),
  );
}

void main() {
  late _MockLoginCubit cubit;

  setUp(() async {
    await sl.reset();
    cubit = _MockLoginCubit();
    when(() => cubit.state).thenReturn(LoginInitial());
    when(() => cubit.loginUser(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {});
    sl.registerFactory<LoginCubit>(() => cubit);
  });

  tearDown(() async => sl.reset());

  Future<void> pump(WidgetTester tester, Locale locale) async {
    AppMessages.localeResolver = () => locale;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(locale));
    await tester.pumpAndSettle();
  }

  Finder loginButton(AppLocalizations l10n) => find.text(l10n.authLogIn);

  testWidgets('shows localized validation errors and does not submit',
      (tester) async {
    final en = lookupAppLocalizations(const Locale('en'));
    await pump(tester, const Locale('en'));

    await tester.ensureVisible(loginButton(en));
    await tester.tap(loginButton(en));
    await tester.pumpAndSettle();

    expect(find.text(en.validationEmailRequired), findsOneWidget);
    expect(find.text(en.authPasswordRequired), findsOneWidget);
    verifyNever(() => cubit.loginUser(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));
  });

  testWidgets('validation messages are Arabic in the Arabic locale',
      (tester) async {
    final ar = lookupAppLocalizations(const Locale('ar'));
    await pump(tester, const Locale('ar'));

    await tester.ensureVisible(loginButton(ar));
    await tester.tap(loginButton(ar));
    await tester.pumpAndSettle();

    expect(find.text(ar.validationEmailRequired), findsOneWidget);
  });

  testWidgets('submits a normalized email when the form is valid',
      (tester) async {
    final en = lookupAppLocalizations(const Locale('en'));
    await pump(tester, const Locale('en'));

    await tester.enterText(find.byType(TextFormField).at(0), ' User@Mail.COM ');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.ensureVisible(loginButton(en));
    await tester.tap(loginButton(en));
    await tester.pump();

    verify(() => cubit.loginUser(email: 'user@mail.com', password: 'secret'))
        .called(1);
  });
}
