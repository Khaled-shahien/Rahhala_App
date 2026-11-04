# دليل الدفاع عن مشروع Rahhala App

هذا الملف يلخص مشروع **Rahhala** من منظور الفكرة، المعمارية، الميزات، التقنيات، تدفق البيانات، وأسئلة لجنة التخرج المتوقعة. الشرح مبني على الكود الموجود في المشروع، خصوصا الملفات داخل `lib/core` و `lib/features` و `pubspec.yaml`.

---

## 1. الفكرة العامة للمشروع

### ما المشكلة التي يحلها التطبيق؟

تطبيق **Rahhala** يحل مشكلة التخطيط للسفر والرحلات، وهي مشكلة شائعة لأن المستخدم يحتاج عادة إلى البحث في أكثر من مصدر: أماكن سياحية، ميزانية، عدد أيام، مطاعم، فنادق، أنشطة، أماكن قريبة، ومسارات تنقل. التطبيق يجمع هذه الخطوات في تجربة واحدة:

- يقترح أماكن ووجهات.
- يولد خطة رحلة بالذكاء الاصطناعي حسب الدولة، عدد الأيام، الموسم، الميزانية، والاهتمامات.
- يدعم خطة مخصصة داخل محافظات ومناطق مصر.
- يعرض تفاصيل الرحلة اليومية والأنشطة والتكلفة والتنقلات.
- يحفظ الرحلات ويعرض سجل الرحلات.
- يساعد المستخدم في اكتشاف الأماكن القريبة من موقعه.
- يوفر بحثا بالصورة للتعرف على أماكن مشابهة.
- يحتوي على مساعد دردشة سياحي باسم Anis.

### من هو المستخدم المستهدف؟

المستخدم المستهدف هو:

- المسافر الذي يريد تخطيط رحلة بسرعة دون بحث طويل.
- السائح أو المقيم الذي يريد اكتشاف أماكن جديدة.
- المستخدم محدود الميزانية الذي يحتاج خطة تناسب ميزانيته.
- العائلات أو الأصدقاء الذين يحتاجون برنامجا واضحا بعدد أيام محدد.
- المستخدم داخل مصر الذي يريد اقتراحات قريبة أو رحلات مخصصة لمحافظات مصر.

### ما القيمة التي يضيفها للمستخدم؟

القيمة الأساسية هي **تحويل التخطيط من عملية مشتتة إلى تجربة ذكية وموجهة**. بدلا من أن يفتح المستخدم خرائط ومواقع تقييمات ومحركات بحث، التطبيق يعطيه:

- خطة يومية جاهزة.
- تكلفة تقديرية.
- أنشطة مرتبة زمنيا.
- مسارات على الخريطة.
- اقتراحات قريبة حسب الموقع.
- إمكانية حفظ ومراجعة الرحلات.
- واجهة عربية/إنجليزية ووضع فاتح/داكن.

---

## 2. المعمارية والهيكل التقني

### ما المعمارية المستخدمة؟

المشروع يستخدم **Clean Architecture بأسلوب Feature-First** مع **BLoC/Cubit** لإدارة الحالة.

يمكن وصفها أمام اللجنة بهذا الشكل:

> المشروع مبني على Clean Architecture؛ كل ميزة مقسمة إلى طبقات `presentation`, `domain`, و `data`. طبقة العرض تتعامل مع الواجهات و Cubits، طبقة الدومين تحتوي الكيانات والـ use cases والعقود، وطبقة البيانات تحتوي models و repositories و API services. أما `core` ففيها الأشياء المشتركة مثل الشبكة، التوجيه، الثيم، اللغة، التخزين، وحقن الاعتمادات.

المشروع ليس MVC تقليديا. الأقرب هو:

- **Clean Architecture** كمعمارية أساسية.
- **BLoC/Cubit** كـ State Management.
- Cubit يؤدي دورا شبيها بـ ViewModel في MVVM، لكنه ليس MVVM صريحا.

### تنظيم المجلدات والملفات

الهيكل الرئيسي:

```text
lib/
  main.dart
  core/
    analytics/
    auth/
    components/
    constants/
    crash/
    di/
    errors/
    localization/
    logging/
    network/
    routing/
    services/
    startup/
    theme/
    utils/
    widgets/
  features/
    ai_recommendation/
    auth/
    chatbot/
    custom_trip/
    home/
    image_search/
    nearby/
    onboarding/
    profile/
    splash/
    trip_history/
    trip_type_selection/
```

شرح أهم المجلدات:

- `core`: كود مشترك بين كل الميزات، مثل `DioConsumer`, `EndPoints`, `AppRouter`, `TokenStorage`, `AppTheme`, `AppLocaleController`, و `service_locator`.
- `features`: كل ميزة مستقلة نسبيا. مثلا `auth`, `home`, `ai_recommendation`, `nearby`.
- `presentation`: الشاشات والـ Widgets والـ Cubits الخاصة بالواجهة.
- `domain`: منطق العمل، الكيانات، العقود، use cases.
- `data`: الاتصال بالـ API، تحويل JSON إلى Models، وتنفيذ الـ repositories.

### الطبقات التقنية

#### Presentation Layer

تحتوي على:

- `pages`: الشاشات مثل `LoginPage`, `HomeScreen`, `TripDetailsScreen`.
- `widgets`: مكونات واجهة قابلة لإعادة الاستخدام داخل الميزة.
- `cubit`: إدارة حالة الواجهة واستقبال أحداث المستخدم.

مثال: `HomeScreen` يستدعي `HomeCubit`، والـ Cubit يعيد حالات مثل `HomeLoading`, `HomeSuccess`, `HomeError`.

#### Domain Layer

تحتوي على:

- Entities: نماذج منطقية تمثل بيانات التطبيق.
- Repository contracts: عقود مجردة.
- Use cases: عمليات business logic مستقلة.

مثال: `GenerateTripPlanUsecase` في الرحلة المخصصة، و `PostLoginSessionUseCase` بعد تسجيل الدخول.

#### Data Layer

تحتوي على:

- API Services/Data Sources.
- Repository implementations.
- Models و JSON parsing.

مثال: `GeminiRepositoryImpl` يتصل بـ `/api/gemini/Ask_Gemini` ثم يحول الرد إلى `TripPlanResponse`.

### Design Patterns المستخدمة

1. **Repository Pattern**
   - موجود في `AuthRepo`, `HomeRepository`, `GeminiRepository`, `NearbyRepository`, `TripHistoryRepository`, `ChatBotRepository`.
   - فائدته فصل مصدر البيانات عن الواجهة.

2. **Use Case Pattern**
   - مثل `PostLoginSessionUseCase`, `GenerateTripPlanUsecase`, و use cases الخاصة بالـ ChatBot.
   - فائدته عزل منطق العملية عن الشاشة والـ Cubit.

3. **Dependency Injection**
   - باستخدام `get_it` في `lib/core/di/service_locator.dart`.
   - كل Repositories و Cubits و Services تسجل في مكان واحد ثم يتم حقنها وقت الحاجة.

4. **BLoC/Cubit State Pattern**
   - كل ميزة لها Cubit يصدر States.
   - الواجهة تستمع للحالات باستخدام `BlocBuilder`, `BlocConsumer`, `BlocListener`.

5. **Adapter/Wrapper Pattern**
   - `DioConsumer` يغلف Dio خلف عقد `ApiConsumer`.
   - `ImagePickerServiceImpl` يغلف `image_picker`.
   - `GeolocatorLocationService` يغلف `geolocator`.

6. **Interceptor Pattern**
   - `ApiInterceptors` يضيف headers والتوكن.
   - `RetryInterceptor` يعيد محاولة GET/HEAD/OPTIONS عند أخطاء مؤقتة.

7. **Fallback Strategy**
   - `RemoteTripOptionsRepository` يحاول تحميل خيارات الرحلة من API، وإذا فشل يستخدم `LocalTripOptionsRepository` من `assets/config/trip_options.json`.

8. **Mapper Pattern**
   - `TripMapper` يحول نتيجة الرحلة المخصصة إلى نفس شكل `TripPlanResponse` المستخدم في شاشة تفاصيل الرحلة.

9. **Singleton/Factory Registration**
   - `GetIt` يستخدم `registerSingleton`, `registerLazySingleton`, و `registerFactory`.
   - الخدمات العامة غالبا Lazy Singleton، أما Cubits التي تحتاج lifecycle خاص غالبا Factory.

---

## 3. شرح كل Features بالتفصيل

### 3.1 تشغيل التطبيق والـ Splash

**الوظيفة:**
تحديد أول شاشة يراها المستخدم عند فتح التطبيق: onboarding، home، أو welcome.

**كيف تعمل تقنيا:**

- `main.dart` يستدعي `setupServiceLocator`.
- يتم تهيئة اللغة والثيم.
- `MaterialApp.router` يستخدم `AppRouter.router`.
- `SplashScreen` يستخدم `AppBootstrapCubit`.
- `AppBootstrapService` يفحص:
  - هل المستخدم أنهى onboarding؟
  - هل لديه token مخزن؟
- بناء على النتيجة يوجه إلى:
  - `/onboarding`
  - `/home`
  - `/welcome`

**Screens/Widgets:**

- `lib/main.dart`
- `lib/features/splash/presentation/pages/splash_screen.dart`
- `lib/core/startup/app_bootstrap_cubit.dart`
- `lib/core/startup/app_bootstrap_service.dart`

---

### 3.2 Onboarding

**الوظيفة:**
تعريف المستخدم الجديد بفكرة التطبيق قبل الدخول.

**كيف تعمل تقنيا:**

- `OnboardingScreen` يستخدم `PageView`.
- `smooth_page_indicator` يعرض مؤشر الصفحات.
- `OnboardingCubit` يحتفظ برقم الصفحة الحالي.
- عند الضغط على Start أو Skip يتم استدعاء `completeOnboarding`.
- `SharedPreferencesOnboardingRepository` يحفظ أن onboarding انتهى في `SharedPreferences`.

**Screens/Widgets:**

- `OnboardingScreen`
- `OnboardingPageWidget`
- `OnboardingCubit`
- `SharedPreferencesOnboardingRepository`

---

### 3.3 Authentication: تسجيل الدخول، التسجيل، OTP، واسترجاع كلمة المرور

**الوظيفة:**
تمكين المستخدم من إنشاء حساب، تسجيل الدخول، تأكيد البريد بالـ OTP، واسترجاع كلمة المرور.

**كيف تعمل تقنيا:**

- `LoginCubit` يستدعي `AuthRepo.loginUser`.
- `AuthRepoImpl` يرسل الطلب إلى `/api/Auth/Login`.
- الرد يحول إلى `Login`، ثم `PostLoginSessionUseCase` يحفظ التوكن وبيانات المستخدم.
- `TokenStorage` يخزن البيانات الحساسة في `flutter_secure_storage`.
- `ApiInterceptors` يضيف `Authorization: Bearer <token>` تلقائيا لكل طلب إذا كان التوكن موجودا.
- التسجيل يستخدم `/api/Auth/register`.
- نسيان كلمة المرور يستخدم `/api/Auth/forgot-password`.
- التحقق من OTP يستخدم `/api/Auth/verify-otp`.
- reset password يستخدم `/api/Auth/reset-password`.

**Screens/Widgets:**

- `WelcomePage`
- `LoginPage`
- `SignUpPage`
- `ForgotPasswordPage`
- `OtpVerificationPage`
- `ResetPasswordPage`
- `ResetPasswordLoggedInPage`
- `CustomFormTextField`
- `CustomButton`
- `SocialLoginSection`

**ملاحظة دفاع مهمة:**
يوجد UI لأزرار social login، لكن لا توجد SDKs فعلية مثل Google Sign-In أو Facebook Auth في `pubspec.yaml`. لذلك قل إن هذه واجهة قابلة للتوسعة وليست تكاملا مكتمل التنفيذ حاليا.

---

### 3.4 Guest Mode

**الوظيفة:**
السماح للمستخدم بالدخول للصفحة الرئيسية دون حساب لتجربة التطبيق.

**كيف تعمل تقنيا:**

- `WelcomePage` يحتوي على خيار Guest.
- يتم مسح أي session قديمة عبر `AuthSessionService.clearSession`.
- يفتح `HomePage(isGuest: true)`.
- بعض الميزات الحساسة مثل Nearby تطلب تسجيل الدخول إذا كان المستخدم Guest.

**Screens/Widgets:**

- `WelcomePage`
- `HomePage`
- `NearbyScreen`

---

### 3.5 Home واكتشاف الأماكن

**الوظيفة:**
عرض قائمة أماكن مقترحة للمستخدم مع pagination وسحب للتحديث.

**كيف تعمل تقنيا:**

- `HomeScreen` ينشئ `HomeCubit`.
- `HomeCubit.getHomeData` يطلب `/api/Home/GetHome?page=...&pagesize=...`.
- البيانات تتحول إلى `HomeResponse` و `PlaceModel`.
- عند الاقتراب من نهاية القائمة يتم استدعاء `loadMore`.
- يتم عرض loading shimmer أثناء التحميل.
- عند الضغط على مكان يفتح `PlaceDetailsScreen`.

**Screens/Widgets:**

- `HomePage`
- `HomeScreen`
- `PlaceCard`
- `HomeCubit`
- `HomeRepository`
- `HomeRemoteDataSource`

---

### 3.6 تفاصيل المكان والمراجعات

**الوظيفة:**
عرض تفاصيل المكان: وصف، فنادق، مطاعم، أنشطة، تقييمات، وإضافة/تعديل/حذف مراجعة.

**كيف تعمل تقنيا:**

- `PlaceDetailsCubit` يستدعي `HomeRepository.getPlaceDetails`.
- endpoint المستخدم: `/api/Home/Places/{id}`.
- `ReviewCubit` يدير عمليات:
  - إضافة مراجعة: POST `/api/Home/Reviews/{placeId}`
  - تعديل مراجعة: PUT `/api/Home/Reviews/{reviewId}`
  - حذف مراجعة: DELETE `/api/Home/Reviews/{reviewId}`
- بعد نجاح عملية review يتم إعادة تحميل تفاصيل المكان.

**Screens/Widgets:**

- `PlaceDetailsScreen`
- `HorizontalSection`
- `ReviewCard`
- `SubmitReview`
- `RatingSummaryCard`
- `PlaceDetailsCubit`
- `ReviewCubit`

---

### 3.7 المفضلة Favourites

**الوظيفة:**
حفظ الأماكن المفضلة وإزالتها وعرض قائمة بها.

**كيف تعمل تقنيا:**

- في `HomeCubit.toggleFavourite` يتم تحديث الواجهة تفاؤليا Optimistic Update ثم إرسال الطلب.
- إذا فشل الطلب يتم الرجوع للحالة السابقة.
- عرض المفضلة يتم من خلال `FavouritesCubit.getFavourites`.
- endpoints:
  - GET `/api/Home/Favourites`
  - POST `/api/Home/Favourites/{placeId}`
  - DELETE `/api/Home/Favourites/{placeId}`

**Screens/Widgets:**

- `FavouritesScreen`
- `FavouritesCubit`
- `PlaceCard`

---

### 3.8 اختيار نوع الرحلة

**الوظيفة:**
إعطاء المستخدم خيارين:

- رحلة مخصصة داخل مصر.
- رحلة عامة مولدة بالذكاء الاصطناعي.

**كيف تعمل تقنيا:**

- `TripTypeSelectionScreen` يعرض بطاقتين.
- الضغط على Custom يفتح `CustomTripFlowScreen`.
- الضغط على General يفتح `AIRecommendationFlowScreen`.

**Screens/Widgets:**

- `TripTypeSelectionScreen`
- `CustomTripFlowScreen`
- `AIRecommendationFlowScreen`

---

### 3.9 AI Recommendation: الرحلة العامة بالذكاء الاصطناعي

**الوظيفة:**
توليد خطة رحلة كاملة بناء على الدولة، عدد الأيام، الموسم، الميزانية، والاهتمامات.

**كيف تعمل تقنيا:**

- `AIRecommendationFlowScreen` يستخدم `PageView` بثلاث خطوات:
  1. `TripInfoScreen`: الدولة، عدد الأيام، الموسم.
  2. `TripBudgetRangeScreen`: الميزانية.
  3. `TripInterestsScreen`: الاهتمامات.
- `AiTripCubit` يخزن اختيارات المستخدم.
- خيارات الميزانية والاهتمامات تأتي من:
  - API: `/api/trip-options`
  - fallback محلي: `assets/config/trip_options.json`
- عند الضغط النهائي يتم استدعاء `generateTripPlan`.
- `GeminiRepositoryImpl` يرسل الطلب إلى `/api/gemini/Ask_Gemini`.
- الطلب يحتوي على:
  - `country`
  - `NumberOfDays`
  - `Budget`
  - `InterestTypes`
  - `Season`
- الرد يتحول إلى `TripPlanResponse`.
- `TripSplashScreen` يعرض loading animation ثم يفتح `TripDetailsScreen`.

**Screens/Widgets:**

- `AIRecommendationFlowScreen`
- `TripInfoScreen`
- `TripBudgetRangeScreen`
- `TripInterestsScreen`
- `TripSplashScreen`
- `TripDetailsScreen`
- `AiTripCubit`
- `GeminiRepositoryImpl`
- `RemoteTripOptionsRepository`
- `LocalTripOptionsRepository`

---

### 3.10 الرحلة المخصصة Custom Trip

**الوظيفة:**
توليد خطة رحلة مخصصة داخل منطقة/محافظة يختارها المستخدم في مصر.

**كيف تعمل تقنيا:**

- `CustomTripInputStep` يسمح باختيار محافظة من `egyptGovernorates` وعدد الأيام.
- `CustomTripCubit` يخزن `selectedRegion` و `numberOfDays`.
- `GenerateTripPlanUsecase` يستدعي `TripRepository`.
- `TripApiService` يرسل الطلب إلى `/api/gemini/Generate_Specific_Plan`.
- توجد retry logic داخل `TripRepository` لأخطاء 503 مع exponential backoff.
- `TripMapper` يحول `TripDataEntity` إلى `TripPlanResponse` حتى يعاد استخدام نفس شاشة تفاصيل الرحلة.
- في الرحلة المخصصة `showActions: false`، لذلك لا تظهر أزرار الحفظ وإعادة التوليد الخاصة بخطة Gemini العامة.

**Screens/Widgets:**

- `CustomTripFlowScreen`
- `CustomTripInputStep`
- `CustomTripSplashScreen`
- `TripDetailsScreen`
- `CustomTripCubit`
- `GenerateTripPlanUsecase`
- `TripApiService`
- `TripMapper`

---

### 3.11 تفاصيل الرحلة Trip Details

**الوظيفة:**
عرض الخطة اليومية بتفاصيل كل يوم: الأنشطة، الصور، الوصف، التكلفة، التنقلات، النصائح، وأرقام الطوارئ.

**كيف تعمل تقنيا:**

- `TripDetailsScreen` يستقبل `TripPlanResponse`.
- يعرض Header للوجهة.
- كل يوم يعرض من خلال `TripDaySection`.
- كل نشاط يحتوي على وقت، مكان، وصف، تكلفة، صورة، ووسائل نقل.
- يمكن حفظ الخطة عبر `/api/gemini/Save_Trip`.
- يمكن إعادة توليد الخطة عبر `/api/gemini/Regenerate_Trip`.
- الصور تعرض باستخدام `cached_network_image`.

**Screens/Widgets:**

- `TripDetailsScreen`
- `TripDetailsHeader`
- `TripDaySection`
- `TripInfoSections`
- `TripSaveButton`

---

### 3.12 الخرائط والمسارات والتنقل الصوتي

**الوظيفة:**
عرض مسار اليوم على الخريطة، وفتح خريطة كاملة، وتتبع موقع المستخدم، وإعطاء تعليمات صوتية أثناء التنقل.

**كيف تعمل تقنيا:**

- `flutter_map` يعرض خريطة OpenStreetMap.
- `latlong2` يمثل نقاط الإحداثيات.
- endpoint `/api/activityroute/get-route` يرجع polyline ومسافة ومدة وخطوات.
- `decodeTripPolylinePoints` يفك ترميز polyline إلى نقاط.
- `TripLocationTrackingService` يستخدم `geolocator` لموقع المستخدم.
- `TripNavigationVoiceService` يستخدم `flutter_tts` للتعليمات الصوتية.
- `RoutePollingServiceImpl` يستمع لتغيرات الموقع.
- `TripNavigationCubit` يدير حالات التنقل: idle, loading, navigating, error.

**Screens/Widgets:**

- `TripDaySection`
- `_FullScreenDayRouteMap`
- `TripNavigationCubit`
- `NavigationServiceImpl`
- `RoutePollingServiceImpl`
- `TripLocationTrackingService`
- `TripNavigationVoiceService`

---

### 3.13 سجل الرحلات Trip History

**الوظيفة:**
عرض الرحلات المحفوظة سابقا وتفاصيل كل رحلة.

**كيف تعمل تقنيا:**

- `TripHistoryCubit.loadTrips` يستدعي `/api/gemini/My_Trips`.
- `loadTripDetail` يستدعي `/api/gemini/My_Trips/{tripId}`.
- تعرض القائمة `TripHistoryScreen`.
- التفاصيل تعرض `TripHistoryDetailScreen`.
- التفاصيل تشمل الأيام والأنشطة والتكلفة والنصائح وخريطة المسار.

**Screens/Widgets:**

- `TripHistoryScreen`
- `TripHistoryDetailScreen`
- `TripHistoryCubit`
- `TripHistoryRepositoryImpl`

---

### 3.14 الأماكن القريبة Nearby

**الوظيفة:**
عرض أماكن قريبة من موقع المستخدم مثل مطاعم، كافيهات، تسوق، طوارئ، سوبر ماركت.

**كيف تعمل تقنيا:**

- `NearbyScreen` يمنع Guest من استخدام الميزة ويطلب تسجيل الدخول.
- `NearbyCubit.requestLocationAndLoad` يطلب الموقع من `LocationService`.
- `GeolocatorLocationService` يتعامل مع permissions وحالات الرفض.
- بعد الحصول على الموقع يتم طلب `/api/places/nearby?lat=...&lng=...`.
- `NearbyPlacesPage` يعرض الخريطة والأماكن.
- يمكن فلترة النتائج حسب category.
- عند الضغط على Go يتم فتح Google Maps external link باستخدام `url_launcher`.

**Screens/Widgets:**

- `NearbyScreen`
- `NearbyPermissionPage`
- `NearbyPlacesPage`
- `NearbyPlaceCard`
- `NearbyCubit`
- `GeolocatorLocationService`

---

### 3.15 البحث بالصورة Image Search

**الوظيفة:**
التقاط صورة أو اختيار صورة من المعرض ثم البحث عن أماكن مشابهة.

**كيف تعمل تقنيا:**

- `ImageSearchBar` يفتح شاشة الكاميرا.
- `PinterestCameraScreen` يستخدم:
  - `camera` للمعاينة والتقاط الصورة.
  - `photo_manager` لعرض صور المعرض.
- بعد اختيار الصورة يستدعي `ImageSearchCubit.pickAndSearch`.
- `ImageSearchRepositoryImpl` يرسل `MultipartFile` باسم `photo` إلى `/api/PhotoApi/upload`.
- النتيجة تتحول إلى `ImageSearchResponse` تحتوي labels و places.
- `ImageSearchResultsScreen` يعرض النتائج أو loading shimmer أو رسالة خطأ.

**Screens/Widgets:**

- `ImageSearchBar`
- `PinterestCameraScreen`
- `ImageSearchResultsScreen`
- `ImageSearchCubit`
- `ImageSearchRepositoryImpl`
- `ImageAcquisitionServiceImpl`

---

### 3.16 ChatBot / Anis

**الوظيفة:**
مساعد دردشة سياحي يجيب عن أسئلة المستخدم ويقترح خططا ونصائح سفر.

**كيف تعمل تقنيا:**

- `ChatBotScreen` يعرض المحادثة، الاقتراحات، typing indicator، وحقل الإدخال.
- `ChatBotCubit` يحتفظ بـ conversation history و context id.
- عند فتح الشاشة يتم إنشاء context عبر `createContext`.
- `sendMessage` يرسل prompt مع history و context id.
- `streamMessage` موجود لدعم الردود streaming، رغم أن الشاشة الحالية تستخدم غالبا `sendMessage`.
- Backend خاص بالـ ChatBot على:
  - `https://express-js-on-vercel-ten-roan-21.vercel.app`
- endpoint المستخدم داخل الخدمة: `/api/chat` مع actions مثل:
  - `chat`
  - `chat-stream`
  - `create-context`
  - `update-context-items`
  - `get-context`
  - `discard-context`

**Screens/Widgets:**

- `ChatBotScreen`
- `ChatBubble`
- `ChatInputField`
- `TypingIndicator`
- `AnisAvatar`
- `ChatBotCubit`
- `ChatBotApiService`
- `ChatBotRepositoryImpl`

---

### 3.17 Profile والإعدادات

**الوظيفة:**
عرض بيانات المستخدم وتعديلها، تغيير الصورة، تغيير كلمة المرور، تغيير اللغة والثيم، عرض الرحلات المحفوظة، تسجيل الخروج، حذف الحساب.

**كيف تعمل تقنيا:**

- `ProfileCubit.fetch` يستدعي `/api/User/GetDetails`.
- تعديل البيانات يستخدم `/api/User/Edit-Profile`.
- رفع الصورة يستخدم `FormData` مع `/api/User/edit_photo`.
- حذف الحساب يستخدم `/api/User/DeleteProfile`.
- تغيير كلمة المرور أثناء تسجيل الدخول يستخدم `/api/User/change_password`.
- `EditProfileCubit` يدير تحميل البيانات، اختيار الصورة، رفع الصورة، وحفظ التعديلات.
- اللغة تدار عبر `AppLocaleController` و `SharedPreferences`.
- الثيم يدار عبر `AppThemeController` و `SharedPreferences`.

**Screens/Widgets:**

- `ProfilePage`
- `EditProfilePage`
- `ResetPasswordLoggedInPage`
- `LanguagePickerBottomSheet`
- `ProfileListTile`
- `ProfileCubit`
- `EditProfileCubit`
- `ProfilePhotoUploadUseCase`

---

### 3.18 Localization والـ Theme

**الوظيفة:**
دعم العربية والإنجليزية، ودعم الوضع الفاتح والداكن.

**كيف تعمل تقنيا:**

- ملفات اللغة موجودة في:
  - `lib/l10n/app_en.arb`
  - `lib/l10n/app_ar.arb`
  - `lib/l10n/generated`
- `MaterialApp.router` يستخدم `AppLocalizations.delegate`.
- `AppLocaleController` يقرأ اللغة من `SharedPreferences`.
- `AppThemeController` يقرأ الوضع الداكن من `SharedPreferences`.
- `ListenableBuilder` في `main.dart` يعيد بناء التطبيق عند تغيير اللغة أو الثيم.

**Screens/Widgets:**

- `main.dart`
- `AppLocaleController`
- `AppThemeController`
- `AppTheme`
- `LanguagePickerBottomSheet`

---

## 4. التقنيات والـ Packages المستخدمة

### Packages الأساسية

| Package | سبب الاستخدام |
|---|---|
| `flutter_bloc` | إدارة الحالة عبر Cubit/BLoC. |
| `get_it` | Dependency Injection وتسجيل الخدمات والـ repositories والـ cubits. |
| `dio` | تنفيذ REST API requests، رفع ملفات، interceptors، timeouts. |
| `go_router` | إدارة المسارات العامة مثل splash/auth/home وحماية بعض routes. |
| `dartz` | استخدام `Either<Failure, Success>` بدلا من رمي exceptions مباشرة في طبقة الدومين. |
| `equatable` | مقارنة States و Entities بسهولة بدون كتابة equality يدويا. |
| `shared_preferences` | حفظ تفضيلات بسيطة مثل onboarding، اللغة، والثيم. |
| `flutter_secure_storage` | تخزين التوكن وبيانات session الحساسة بأمان. |
| `flutter_screenutil` | جعل التصميم responsive حسب حجم الشاشة. |
| `flutter_svg` | عرض ملفات SVG مثل اللوجو والأيقونات. |
| `lottie` | عرض animation أثناء توليد الرحلات. |
| `cached_network_image` | عرض الصور من الإنترنت مع caching و placeholder/error handling. |
| `shimmer` | loading skeleton أثناء انتظار البيانات. |
| `logger` | تسجيل logs منظمة أثناء التطوير والتشخيص. |
| `intl` | دعم localization والتواريخ في generated localization وبعض widgets. |

### Packages خاصة بالرحلات والموقع والخرائط

| Package | سبب الاستخدام |
|---|---|
| `flutter_map` | عرض خرائط OpenStreetMap داخل التطبيق. |
| `latlong2` | تمثيل الإحداثيات وحساب المسافات. |
| `geolocator` | الحصول على موقع المستخدم وتتبع الحركة. |
| `flutter_tts` | تحويل تعليمات التنقل إلى صوت. |
| `url_launcher` | فتح Google Maps خارج التطبيق. |

### Packages خاصة بالصور والكاميرا

| Package | سبب الاستخدام |
|---|---|
| `camera` | عرض CameraPreview والتقاط صورة داخل واجهة مخصصة. |
| `photo_manager` | قراءة صور المعرض وعرض آخر الصور. |
| `image_picker` | abstraction أبسط لاختيار صورة في بعض أجزاء التطبيق مثل صورة البروفايل. |

### Packages خاصة بالواجهة

| Package | سبب الاستخدام |
|---|---|
| `curved_navigation_bar` | Bottom navigation bar في `HomePage`. |
| `smooth_page_indicator` | مؤشر صفحات الـ onboarding. |
| `country_picker` | اختيار الدولة في رحلة AI واختيار الدولة في بعض شاشات الحساب. |
| `timeago` | عرض وقت المراجعات بصيغة نسبية مثل "منذ يومين". |
| `cupertino_icons` | أيقونات iOS القياسية إذا احتاجها المشروع. |

### Firebase

| Package | سبب الاستخدام |
|---|---|
| `firebase_core` | تهيئة Firebase. |
| `firebase_analytics` | تسجيل analytics events عند تفعيلها. |
| `firebase_crashlytics` | تسجيل crash reports عند تفعيلها. |

ملاحظة مهمة: في `AppConstants` القيم الافتراضية `enableAnalytics` و `enableCrashReporting` تساوي `false`، ويتم تفعيلها عبر `--dart-define`. لذلك Firebase موجود كـ observability اختياري، وليس مستخدما كقاعدة بيانات أو Authentication.

### Dev Dependencies

| Package | سبب الاستخدام |
|---|---|
| `flutter_test` | اختبارات Flutter. |
| `bloc_test` | اختبار Cubits/BLoCs. |
| `mocktail` | إنشاء mocks في الاختبارات. |
| `flutter_lints` | قواعد جودة وتحليل للكود. |
| `flutter_launcher_icons` | توليد أيقونات التطبيق. |

### APIs وقواعد البيانات

لا توجد قاعدة بيانات محلية مثل SQLite/Hive في المشروع. الموجود هو:

- **REST API رئيسي**: `https://rahhallaweb2026.runasp.net`
- **ChatBot API**: `https://express-js-on-vercel-ten-roan-21.vercel.app`
- **Local storage**:
  - `flutter_secure_storage` للتوكن وبيانات الجلسة.
  - `shared_preferences` للغة، الثيم، onboarding.
  - `assets/config/trip_options.json` كملف إعدادات محلي fallback.
- **خرائط**:
  - OpenStreetMap tiles عبر `flutter_map`.
  - Google Maps external URL فقط لفتح الاتجاهات خارج التطبيق.
- **Firebase**:
  - Analytics و Crashlytics اختياريان.
  - لا يوجد Firebase Auth.
  - لا يوجد Firestore أو Realtime Database.

### أهم Endpoints

| المجال | Endpoints |
|---|---|
| Auth | `/api/Auth/Login`, `/api/Auth/register`, `/api/Auth/forgot-password`, `/api/Auth/verify-otp`, `/api/Auth/reset-password` |
| User | `/api/User/GetDetails`, `/api/User/Edit-Profile`, `/api/User/DeleteProfile`, `/api/User/change_password`, `/api/User/edit_photo` |
| Home | `/api/Home/GetHome`, `/api/Home/Places/{id}`, `/api/Home/Reviews/{id}`, `/api/Home/Favourites` |
| AI Trip | `/api/gemini/Ask_Gemini`, `/api/gemini/Save_Trip`, `/api/gemini/Regenerate_Trip`, `/api/gemini/Generate_Specific_Plan`, `/api/trip-options` |
| Trip History | `/api/gemini/My_Trips`, `/api/gemini/My_Trips/{tripId}` |
| Image Search | `/api/PhotoApi/upload` |
| Nearby | `/api/places/nearby` |
| Routes | `/api/activityroute/get-route` |
| ChatBot | `/api/chat` |

---

## 5. تدفق البيانات Data Flow

### التدفق العام داخل التطبيق

التدفق القياسي في أغلب الميزات:

```text
User Action
  -> Screen/Widget
  -> Cubit method
  -> UseCase أو Repository
  -> DataSource/API Service
  -> REST API
  -> Model.fromJson
  -> Entity/Response
  -> Cubit emits State
  -> UI rebuilds with BlocBuilder/BlocConsumer
```

مثال Home:

```text
فتح HomeScreen
  -> HomeCubit.getHomeData()
  -> HomeRepository.getHomePlaces()
  -> HomeRemoteDataSource.getHomePlaces()
  -> GET /api/Home/GetHome
  -> HomeResponse.fromJson
  -> emit HomeSuccess
  -> عرض PlaceCard list
```

مثال AI Trip:

```text
اختيار الدولة + الأيام + الموسم + الميزانية + الاهتمامات
  -> AiTripCubit.update...
  -> generateTripPlan()
  -> GeminiRepositoryImpl.getTripPlan()
  -> POST /api/gemini/Ask_Gemini
  -> TripPlanResponse.fromJson
  -> emit AiTripSuccess
  -> TripSplashScreen يفتح TripDetailsScreen
```

مثال Authentication:

```text
إدخال email/password
  -> LoginCubit.loginUser()
  -> AuthRepoImpl.loginUser()
  -> POST /api/Auth/Login
  -> Login.fromJson
  -> PostLoginSessionUseCase
  -> TokenStorage + AuthSessionService
  -> emit LoginSuccess
  -> GoRouter يذهب إلى /home
```

### إدارة الحالة State Management

المشروع يستخدم أكثر من أسلوب حسب نوع الحالة:

- **Cubit/BLoC** للحالات المرتبطة بالميزات والـ API:
  - `LoginCubit`
  - `RegisterCubit`
  - `HomeCubit`
  - `AiTripCubit`
  - `CustomTripCubit`
  - `NearbyCubit`
  - `ImageSearchCubit`
  - `ChatBotCubit`
  - `ProfileCubit`
  - `TripHistoryCubit`

- **ChangeNotifier/Listenable** للحالات العامة الخفيفة:
  - `AppLocaleController`
  - `AppThemeController`

- **StatefulWidget local state** للحالات البسيطة داخل الشاشة:
  - TextEditingControllers
  - PageController
  - ScrollController
  - CameraController
  - selected tab/current index

### تدفق التوكن والأمان

```text
Login Success
  -> PostLoginSessionUseCase
  -> AuthSessionService.saveSession
  -> TokenStorage.setToken
  -> flutter_secure_storage
  -> ApiInterceptors يضيف Authorization header في الطلبات التالية
```

الأفضل في الدفاع أن توضح:

- التوكن لا يخزن في `SharedPreferences` بشكل أساسي.
- توجد migration من SharedPreferences القديمة إلى Secure Storage.
- كل request محمي يحصل على Bearer token تلقائيا.

### Navigation Flow

يوجد نوعان من التنقل:

#### 1. GoRouter للمسارات الأساسية

`AppRouter` يدير:

- `/` splash
- `/onboarding`
- `/welcome`
- `/login`
- `/signup`
- `/forgot-password`
- `/otp-verification`
- `/reset-password`
- `/home`
- `/profile`
- `/edit-profile`

كما يحتوي على redirect لحماية بعض المسارات إذا لم يكن هناك token.

#### 2. Navigator.push داخل الميزات

يستخدم داخل flow داخلي مثل:

- فتح ChatBot من HomePage.
- فتح PlaceDetails من HomeScreen.
- فتح TripTypeSelection ثم AI أو Custom Trip.
- فتح TripDetails بعد توليد الخطة.
- فتح TripHistoryDetail من TripHistoryScreen.
- فتح ImageSearchResults من Camera screen.

هذا الاختيار مناسب لأن GoRouter يستخدم للمسارات العامة، بينما الرحلات الداخلية المؤقتة تستخدم `MaterialPageRoute`.

### علاقة الشاشات ببعضها

```text
Splash
  -> Onboarding
  -> Welcome
  -> Login / Signup / Guest
  -> HomePage
       Tab 1: HomeScreen
          -> PlaceDetailsScreen
       Tab 2: FavouritesScreen
          -> PlaceDetailsScreen
       Tab 3: NearbyScreen
          -> NearbyPlacesPage
       Tab 4: TripTypeSelectionScreen
          -> CustomTripFlowScreen
          -> AIRecommendationFlowScreen
          -> TripSplashScreen / CustomTripSplashScreen
          -> TripDetailsScreen
       Tab 5: ProfilePage
          -> EditProfilePage
          -> TripHistoryScreen
          -> ResetPasswordLoggedInPage
       Floating Anis Avatar
          -> ChatBotScreen
```

---

## 6. أسئلة اللجنة المتوقعة وإجاباتها

### السؤال 1: لماذا اخترت Flutter لهذا المشروع؟

اخترت Flutter لأنه يسمح ببناء تطبيق cross-platform من codebase واحد يعمل على Android و iOS وربما Web/Desktop. المشروع يحتوي على واجهات كثيرة وتفاعلات متعددة مثل الخرائط، الكاميرا، الصور، الثيم، اللغة، والـ animations؛ Flutter مناسب لذلك لأنه يعطي أداء جيدا و UI غني باستخدام Widgets. كذلك بيئة Flutter لديها packages قوية مثل `flutter_bloc`, `dio`, `geolocator`, `camera`, و `flutter_map`، وهذا اختصر وقت التطوير مع الحفاظ على جودة التطبيق.

### السؤال 2: ما المعمارية المستخدمة ولماذا؟

المشروع يستخدم Clean Architecture بأسلوب Feature-First مع Cubit/BLoC. اخترت ذلك لأن التطبيق كبير وفيه ميزات متعددة: auth، profile، home، AI trips، nearby، image search، chatbot. لو كان كل شيء في screens فقط سيصعب الاختبار والصيانة. Clean Architecture فصلت الواجهة عن منطق العمل وعن البيانات؛ فمثلا الشاشة لا تعرف تفاصيل API، بل تتعامل مع Cubit، والـ Cubit يتعامل مع Repository أو UseCase.

### السؤال 3: لماذا استخدمت Cubit بدلا من setState فقط؟

`setState` مناسب للحالة البسيطة داخل Widget، لكن المشروع يحتاج حالات API مع loading و success و error، ويحتاج اختبار business logic. Cubit يجعل الحالة واضحة ومنفصلة عن الواجهة. مثلا `HomeCubit` يدير pagination والمفضلة، و`AiTripCubit` يدير اختيارات الرحلة وتوليد الخطة، و`LoginCubit` يدير تسجيل الدخول وحفظ الجلسة. هذا يجعل الكود أسهل في الصيانة والاختبار.

### السؤال 4: كيف يتم تأمين بيانات المستخدم؟

التوكن وبيانات الجلسة تخزن في `flutter_secure_storage` وليس في SharedPreferences العادية. على Android يتم استخدام encrypted shared preferences، وعلى iOS يتم استخدام Keychain. كذلك يوجد `ApiInterceptors` يضيف التوكن في Authorization header تلقائيا. أما SharedPreferences فتستخدم لتفضيلات غير حساسة مثل اللغة، الثيم، وحالة onboarding.

### السؤال 5: هل التطبيق يستخدم Firebase؟

نعم، لكن ليس كقاعدة بيانات ولا كنظام تسجيل دخول. Firebase موجود فقط كطبقة observability اختيارية: `firebase_analytics` للأحداث و`firebase_crashlytics` للأخطاء، ويتم تفعيلهما عبر `--dart-define`. القيم الافتراضية في `AppConstants` تجعل analytics و crash reporting غير مفعلين افتراضيا. البيانات الأساسية تأتي من REST API.

### السؤال 6: كيف يعمل جزء الذكاء الاصطناعي؟

المستخدم يدخل بيانات الرحلة مثل الدولة، عدد الأيام، الموسم، الميزانية، والاهتمامات. `AiTripCubit` يجمع هذه البيانات ويحولها إلى request مناسب للـ backend، ثم `GeminiRepositoryImpl` يرسلها إلى endpoint `/api/gemini/Ask_Gemini`. الرد يحتوي على خطة رحلة منظمة: destination، days، activities، costs، tips، emergency contacts. بعدها تعرض الخطة في `TripDetailsScreen`، ويمكن حفظها أو إعادة توليدها.

### السؤال 7: كيف تتعاملون مع ضعف الإنترنت أو فشل API؟

هناك أكثر من مستوى للتعامل مع الأخطاء. `DioConsumer` يحول أخطاء Dio إلى `ServerException` برسائل مفهومة. `RetryInterceptor` يعيد محاولة بعض الطلبات الآمنة مثل GET عند أخطاء مؤقتة مثل timeout أو 503. في الرحلة المخصصة توجد retry logic خاصة عند 503. كما أن بعض الميزات لديها fallback، مثل `RemoteTripOptionsRepository` الذي يستخدم ملف `trip_options.json` إذا فشل تحميل الخيارات من API.

### السؤال 8: كيف تعمل الخرائط والموقع؟

الخرائط تعرض باستخدام `flutter_map` مع OpenStreetMap tiles، والإحداثيات تمثل باستخدام `latlong2`. عند عرض مسار رحلة، التطبيق يرسل نقاط الأنشطة إلى `/api/activityroute/get-route` ويحصل على polyline ومسافة ومدة. يتم فك polyline إلى نقاط ورسمها على الخريطة. للتنقل الحي يستخدم التطبيق `geolocator` لتتبع الموقع، و`flutter_tts` لقراءة التعليمات صوتيا.

### السؤال 9: ما أهم مشكلة واجهتك وكيف حللتها؟

من المشكلات المهمة توحيد عرض نتائج الرحلات القادمة من أكثر من مصدر. الرحلة العامة ترجع `TripPlanResponse`، بينما الرحلة المخصصة ترجع `TripDataEntity`. بدلا من بناء شاشة جديدة للرحلة المخصصة، استخدمت `TripMapper` لتحويل نتيجة الرحلة المخصصة إلى نفس شكل `TripPlanResponse`. هذا سمح بإعادة استخدام `TripDetailsScreen` وتقليل تكرار الكود.

### السؤال 10: كيف يمكن تطوير المشروع مستقبلا؟

يمكن تطوير المشروع بعدة اتجاهات:

- إضافة قاعدة بيانات محلية مثل Hive أو SQLite لحفظ الرحلات offline.
- تفعيل push notifications للتذكير بالرحلات.
- إضافة social login فعلي باستخدام Google/Apple/Facebook SDKs.
- تحسين analytics tracking لفهم سلوك المستخدم.
- إضافة caching للخرائط بطريقة متوافقة مع شروط مزودي الخرائط.
- إضافة recommendation engine أقوى يعتمد على history و favourites.
- إضافة multi-language أوسع.
- إضافة payment/subscription إذا تحول التطبيق إلى منتج تجاري.

---

## 7. نقاط القوة في المشروع

### ما الذي يجعل المشروع مميزا؟

- يجمع بين التخطيط السياحي، الذكاء الاصطناعي، الخرائط، الموقع، البحث بالصورة، والمحادثة الذكية في تطبيق واحد.
- ليس مجرد CRUD app؛ فيه تدفقات معقدة وAPIs متعددة وميزات عملية.
- يدعم العربية والإنجليزية.
- يدعم الوضع الفاتح والداكن.
- يحتوي على واجهة responsive باستخدام `flutter_screenutil`.
- يستخدم Secure Storage لحماية التوكن.
- يستخدم Clean Architecture وDependency Injection مما يجعل المشروع قابلا للتوسع.
- يحتوي على tests في مجلد `test` لعدة Cubits واستخدامات.

### قرارات تقنية ذكية

1. **Feature-first Clean Architecture**
   - يجعل كل ميزة مستقلة وسهلة الفهم.

2. **GetIt Service Locator**
   - يقلل coupling بين الكلاسات ويسهل استبدال implementations في الاختبار.

3. **Dio Interceptors**
   - إضافة التوكن وإعادة المحاولة تتم مركزيا بدلا من تكرارها في كل request.

4. **Secure Token Storage**
   - قرار أمني مهم عند التعامل مع authentication.

5. **Fallback للـ trip options**
   - التطبيق لا يتوقف تماما إذا فشل endpoint الخاص بالخيارات.

6. **إعادة استخدام TripDetailsScreen**
   - الرحلة العامة والمخصصة تستخدمان نفس شاشة التفاصيل بعد تحويل البيانات.

7. **Optimistic UI في المفضلة**
   - يعطي تجربة أسرع للمستخدم ثم يتراجع إذا فشل الطلب.

8. **تجريد خدمات الجهاز**
   - location، image picker، navigation voice كلها مغلفة في services، وهذا يحسن الاختبار والصيانة.

### كيف تبرز هذه النقاط أمام اللجنة؟

قل مثلا:

> أهم نقطة في المشروع أنه ليس مجرد واجهات، بل هو تطبيق متكامل مبني بطبقات واضحة. الواجهة لا تتعامل مباشرة مع API؛ هناك Cubit ثم Repository ثم DataSource. هذا جعلنا نضيف ميزات كثيرة مثل AI trip planning وNearby وImage Search بدون أن يصبح الكود متشابكا. كما اهتممنا بالأمان من خلال secure storage، وبقابلية التوسع من خلال Dependency Injection وRepository Pattern.

### نقاط يجب قولها بحذر

- لا تقل إن التطبيق يستخدم Firebase كقاعدة بيانات؛ Firebase هنا اختياري للـ analytics/crash reporting.
- لا تقل إن social login مكتمل؛ الموجود واجهة قابلة للتوسعة.
- لا تقل إن التطبيق offline بالكامل؛ الموجود caching للصور فقط وبعض الإعدادات المحلية.
- لا تقل إن كل navigation عبر GoRouter؛ المشروع يستخدم GoRouter للمسارات العامة وNavigator داخليا لبعض flows.

---

## 8. ملخص تنفيذي سريع في 10 أسطر أو أقل

Rahhala هو تطبيق Flutter لتخطيط الرحلات واكتشاف الأماكن بطريقة ذكية.  
يساعد المستخدم على توليد خطة سفر كاملة حسب الدولة، الأيام، الموسم، الميزانية، والاهتمامات.  
يدعم أيضا رحلات مخصصة داخل مصر، وسجل رحلات محفوظة، ومفضلة للأماكن.  
يعرض تفاصيل الرحلة اليومية مع الأنشطة والتكلفة والتنقلات والخرائط.  
يستخدم الموقع لعرض الأماكن القريبة، والكاميرا للبحث بالصورة عن أماكن مشابهة.  
يحتوي على مساعد دردشة سياحي باسم Anis.  
المشروع مبني بـ Clean Architecture و BLoC/Cubit و Dependency Injection.  
يتصل بـ REST APIs باستخدام Dio، ويخزن التوكن بأمان في Secure Storage.  
يدعم العربية والإنجليزية والوضع الفاتح والداكن.  
نقطة قوته أنه يجمع AI والخرائط والموقع والصور في تجربة سفر واحدة قابلة للتوسع.  

