# Strayz — Flutter Project Reference Guide

A platform for helping stray animals find homes. This document serves as an architectural reference for building future Flutter projects following the same conventions.

---

## Table of Contents

1. [Tech Stack](#tech-stack)
2. [Folder Structure](#folder-structure)
3. [Architecture Overview](#architecture-overview)
4. [Dependency Injection](#dependency-injection)
5. [State Management (BLoC/Cubit)](#state-management-bloccubit)
6. [Navigation & Routing](#navigation--routing)
7. [Theming & Styling](#theming--styling)
8. [Reusable Core Components](#reusable-core-components)
9. [Localization (i18n)](#localization-i18n)
10. [Backend Integration](#backend-integration)
11. [Features Inventory](#features-inventory)
12. [Naming Conventions](#naming-conventions)
13. [Adding a New Feature — Checklist](#adding-a-new-feature--checklist)

---

## Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc` ^8.1.6 |
| Dependency injection | Custom singleton `DependencyInjector` |
| Navigation | Named routes + `get` (GetMaterialApp) |
| Backend (auth & DB) | `supabase_flutter` ^2.8.3 |
| Secondary backend | `firebase_core` + `cloud_firestore` + `firebase_auth` |
| Responsive sizing | `flutter_screenutil` ^5.9.3 |
| Local storage | `shared_preferences` via `core_dependencies_global` |
| Networking | `core_dependencies_global` `NetworkService` (Dio wrapper) |
| Maps | `google_maps_flutter` + `flutter_map` + `geolocator` |
| Image picking | `image_picker` ^1.1.2 |
| Caching images | `cached_network_image` ^3.3.1 |
| SVG rendering | `flutter_svg` ^2.0.16 |
| Sharing | `share_plus` ^10.1.4 |
| Bottom nav bar | `salomon_bottom_bar` ^3.3.2 |
| Carousel | `carousel_slider` ^5.0.0 |
| Google fonts | `google_fonts` ^6.2.1 |
| Localization | `flutter_localizations` + `intl` 0.20.2 |
| Connectivity | `internet_connection_checker_plus` ^2.7.2 |
| Equality | `equatable` ^2.0.5 |
| Time formatting | `timeago` ^3.7.0 |
| Shimmer loading | `shimmer` ^3.0.0 |

**Private shared package:** `core_dependencies_global` (git: `alyeldin97/core_dependencies_global`) — provides `NetworkService`, `LocalStorageService`, `ImagePickerService`, `SnackBarService`, `NavigationService`, and shared widgets like `AppSVGImage`.

---

## Folder Structure

```
lib/
├── main.dart                        # App entry point, MultiBlocProvider setup
├── routes.dart                      # Centralized RouteGenerator + bottom nav wrapper
│
├── core/                            # Shared code used across all features
│   ├── di/
│   │   └── dependency_injection.dart  # Singleton DI container
│   ├── data/
│   │   ├── model/                   # Shared models (Animal, User, Comment, Conversation)
│   │   ├── remote/                  # Shared RDS (likes, share count)
│   │   └── repos/                   # Shared repos (likes, share count)
│   ├── extensions/
│   │   └── extensions.dart          # BuildContext extensions (locale, appCubit)
│   ├── helpers/
│   │   ├── app_avatar.dart
│   │   ├── app_border.dart
│   │   ├── app_buttons.dart
│   │   ├── app_formfield.dart       # AppFormField widget
│   │   ├── app_theming.dart         # AppThemes (light/dark)
│   │   └── app_validator.dart       # AppValidator static methods
│   ├── navigation/
│   │   └── presentation/cubits/
│   │       └── navigation_cubit.dart # Bottom nav state
│   ├── presentation/
│   │   ├── cubits/
│   │   │   ├── app/                 # AppCubit (language, first-launch flags)
│   │   │   ├── comments/            # CommentsCubit
│   │   │   ├── likes_count/         # LikesCountCubit
│   │   │   └── share_count/         # ShareCountCubit
│   │   ├── screens/
│   │   │   └── server_error_screen.dart
│   │   └── widgets/                 # Shared widgets (AppPost, NavBar, Map, etc.)
│   ├── services/
│   │   ├── internet_connectivity_wrapper.dart
│   │   ├── navigation_service.dart
│   │   └── share_plus/
│   ├── styling/
│   │   ├── colors.dart              # AppColors
│   │   ├── images.dart              # AppImages (asset paths)
│   │   ├── padding.dart             # AppPadding
│   │   └── text_styles.dart         # AppTextStyles
│   └── utils/
│       ├── configurations.dart      # AppConfigurations (base URL, Supabase keys)
│       └── end_points.dart          # EndPoints constants
│
├── features/                        # One folder per product feature
│   └── <feature_name>/
│       ├── data/
│       │   ├── model/               # Data models with fromJson/toJson
│       │   ├── remote/              # Abstract RDS + implementation
│       │   └── repo/                # Abstract repo + implementation
│       └── presentation/
│           ├── cubits/ (or cubit/)  # XxxCubit + XxxState
│           ├── screens/             # Full-screen widgets
│           └── widgets/             # Screen-scoped reusable widgets
│
└── l10n/                            # Localization
    ├── app_en.arb
    ├── app_ar.arb
    └── app_localizations.dart       # Generated delegates
```

---

## Architecture Overview

The project follows **Feature-First Clean Architecture**:

```
UI (Screen/Widget)
      ↓ dispatches events via context.read<XxxCubit>()
   Cubit  ←→  State (Equatable, copyWith)
      ↓
  Repository (abstract interface)
      ↓
Remote Data Source (abstract interface)
      ↓
  NetworkService / Supabase / Firebase
```

- **Cubit** holds business logic and emits immutable states.
- **Repository** abstracts data sources from the presentation layer.
- **Remote Data Source (RDS)** talks directly to the network/backend.
- Each layer depends only on the abstraction (interface) of the layer below it.

---

## Dependency Injection

`DependencyInjector` is a hand-rolled singleton that uses a `Map<Type, dynamic>` to cache instances:

```dart
class DependencyInjector {
  static final DependencyInjector _singleton = DependencyInjector._internal();
  static final Map<Type, dynamic> _dependencies = {};

  factory DependencyInjector() => _singleton;
  DependencyInjector._internal();

  // Lazy singleton pattern
  SomeService get someService =>
      _dependencies[SomeService] ??= SomeServiceImpl();
}
```

**Key rule:** use `??=` to create the instance only once (lazy singleton). If a dependency must be recreated on each access (e.g. a Cubit that should not be shared), omit `_dependencies[...]` and just `return XxxCubit(repo)`.

All cubits are provided globally in `main.dart` via `MultiBlocProvider`:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => DependencyInjector().authCubit),
    BlocProvider(create: (_) => DependencyInjector().feedCubit..getAllFeeds()),
    // ...
  ],
  child: ...,
)
```

---

## State Management (BLoC/Cubit)

### State class pattern

```dart
// xxx_state.dart
part of 'xxx_cubit.dart';

enum XxxStatus { initial, loading, success, failure }

class XxxState extends Equatable {
  final XxxStatus status;
  final List<XxxModel> items;
  final String? errorMessage;

  const XxxState({
    this.status = XxxStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  XxxState copyWith({
    XxxStatus? status,
    List<XxxModel>? items,
    String? errorMessage,
  }) => XxxState(
    status: status ?? this.status,
    items: items ?? this.items,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, items, errorMessage];
}
```

### Cubit class pattern

```dart
// xxx_cubit.dart
part 'xxx_state.dart';

class XxxCubit extends Cubit<XxxState> {
  final XxxRepository repository;

  XxxCubit(this.repository) : super(const XxxState());

  Future<void> fetchItems() async {
    emit(state.copyWith(status: XxxStatus.loading));
    try {
      final items = await repository.getItems();
      emit(state.copyWith(status: XxxStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(status: XxxStatus.failure, errorMessage: e.toString()));
    }
  }
}
```

### Consuming state in UI

```dart
BlocBuilder<XxxCubit, XxxState>(
  builder: (context, state) {
    if (state.status == XxxStatus.loading) return const CircularProgressIndicator();
    if (state.status == XxxStatus.failure) return Text(state.errorMessage ?? 'Error');
    return ListView(children: state.items.map((i) => Text(i.name)).toList());
  },
)
```

---

## Navigation & Routing

### Named routes

Every screen declares its own route name constant:

```dart
class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';
  // ...
}
```

`RouteGenerator.getRoute()` in [routes.dart](lib/routes.dart) handles all routes via a `switch` statement and returns a `MaterialPageRoute`.

### Navigating

```dart
// Push
Navigator.of(context).pushNamed(LoginScreen.routeName);

// Push and clear stack
Navigator.of(context).pushNamedAndRemoveUntil(
  LayoutScreen.routeName,
  (route) => false,
);

// Pop
Navigator.of(context).pop();
```

### Bottom navigation

`NavigationCubit` owns the current tab index. `tabRoutes` maps each index to a route name. The `_BottomNavWrapper` in `routes.dart` wraps non-auth screens and renders `SalomonBottomBar` (5 tabs: Home, Feed, Map, Services, Profile).

Tab routes bypass the normal push flow — `RouteGenerator` redirects them to `LayoutScreen` after calling `navigationCubit.changeTab(index)`.

---

## Theming & Styling

### Colors — `AppColors` ([lib/core/styling/colors.dart](lib/core/styling/colors.dart))

```dart
AppColors.myBGColor        // #FBFBFF — scaffold background
AppColors.myBlackText      // #010119 — primary text
AppColors.myBodyColor      // #747474 — secondary text
AppColors.myPink           // #DC7399
AppColors.myYellow         // #FFC107
AppColors.myDarkYellow     // #CB9932
AppColors.mypurple         // #853FA7
AppColors.mycyan           // #A2E8E1 — focus border
AppColors.loginTitle       // #3E8881
AppColors.borderColor      // #E1E1E1
```

### Text styles — `AppTextStyles` ([lib/core/styling/text_styles.dart](lib/core/styling/text_styles.dart))

```dart
AppTextStyles.title      // 20sp, bold
AppTextStyles.subtitle   // 16sp, w500
AppTextStyles.label      // 14sp, w400
AppTextStyles.body       // 12sp, w400
AppTextStyles.splashTitle // Google Fonts LilyScriptOne, 40sp
```

All sizes use `flutter_screenutil` (`.sp`, `.w`, `.h`). The design canvas is **375 × 812** (iPhone 14):

```dart
ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) { ... },
)
```

### Asset paths — `AppImages` ([lib/core/styling/images.dart](lib/core/styling/images.dart))

Centralizes all `assets/icons/` and `assets/images/` paths as string constants. Always use `AppImages.xxx` rather than raw strings.

---

## Reusable Core Components

| Widget | Location | Purpose |
|---|---|---|
| `AppFormField` | [lib/core/helpers/app_formfield.dart](lib/core/helpers/app_formfield.dart) | Styled `TextFormField` with SVG prefix/suffix icons and password toggle |
| `AppValidator` | [lib/core/helpers/app_validator.dart](lib/core/helpers/app_validator.dart) | Static validators: `validateEmail`, `validatePassword`, `validateNotEmpty` |
| `AppBorderRadius` | [lib/core/helpers/app_border.dart](lib/core/helpers/app_border.dart) | Shared `BorderRadius` constants (e.g. `AppBorderRadius.r16`) |
| `AppPadding` | [lib/core/styling/padding.dart](lib/core/styling/padding.dart) | Shared `EdgeInsets` helpers |
| `InternetConnectivityWrapper` | [lib/core/services/internet_connectivity_wrapper.dart](lib/core/services/internet_connectivity_wrapper.dart) | Root widget that shows a no-internet dialog automatically |
| `AppPost` | [lib/core/presentation/widgets/app_post.dart](lib/core/presentation/widgets/app_post.dart) | Shared feed post card widget |
| `AppSVGImage` | from `core_dependencies_global` | Renders SVG assets with optional color tint |

### `AppFormField` usage

```dart
AppFormField(
  labelText: 'Email',
  controller: _emailController,
  validator: AppValidator.validateEmail,
  prefixIconPath: AppImages.email,   // SVG path
  obscureText: false,
)
```

---

## Localization (i18n)

The app supports **English** and **Arabic** using Flutter's built-in `flutter_localizations`.

ARB files live in [lib/l10n/](lib/l10n/). Run `flutter gen-l10n` (or `flutter pub get` with `generate: true` in `pubspec.yaml`) to regenerate `app_localizations.dart`.

### Access translations

```dart
// Via context extension (lib/core/extensions/extensions.dart)
context.locale.someKey

// Or directly
AppLocalizations.of(context)!.someKey
```

### Change language at runtime

```dart
context.appCubit.changeLanguage('ar');
```

`AppCubit` persists the selected language to `SharedPreferences` and rebuilds the entire app through `BlocBuilder<AppCubit, AppState>` in `main.dart`.

---

## Backend Integration

### Supabase

Initialized in `main.dart` before `runApp`:

```dart
await Supabase.initialize(
  url: AppConfigurations.supabaseUrl,
  anonKey: AppConfigurations.anonKey,
);
```

Access the client anywhere:

```dart
final supabase = Supabase.instance.client;
```

Auth methods (email/password, Google) are implemented in [lib/features/auth/data/remote/supabase_auth_rds_impl.dart](lib/features/auth/data/remote/supabase_auth_rds_impl.dart).

### API / REST (via `core_dependencies_global`)

The `NetworkService` abstraction wraps Dio. Usage in an RDS:

```dart
class XxxRemoteDataSourceImpl implements XxxRemoteDataSource {
  final NetworkService networkService;
  XxxRemoteDataSourceImpl({required this.networkService});

  @override
  Future<List<XxxModel>> getAll() => networkService.getList<XxxModel>(
    EndPoints.getAll,
    fromMap: XxxModel.fromJson,
  );
}
```

All endpoint strings are defined in [lib/core/utils/end_points.dart](lib/core/utils/end_points.dart).

### Firebase

Used for Firestore real-time data (chat). `Firebase.initializeApp()` must be called before any Firebase usage.

---

## Features Inventory

| Feature | Screens | Key cubit |
|---|---|---|
| `splash` | `SplashScreen` | `SplashCubit` |
| `onboarding` | `LanguageScreen`, `OnboardingScreen` | — |
| `auth` | `LoginScreen`, `SignupScreen`, `ForgotPasswordScreen`, `ResetPasswordScreen` | `AuthCubit` |
| `layout` | `LayoutScreen` (tab container) | `NavigationCubit` |
| `home` | `HomeScreen` | — |
| `feed` | `FeedsScreen` | `FeedCubit` |
| `feed_details` | `FeedDetailsScreen`, `FilterBottomSheet` | `LostFoundCubit` |
| `add_feed` | `AddFeedLayoutScreen`, `AddFeed1/2/3` | `AddFeedCubit` |
| `map` | `MapScreen` | — |
| `services` | `ServicesMainList`, `ServicesByCategoryScreen`, `ServiceDetailsScreen`, `ShopScreen` | `ServicesCubit` |
| `event` | `EventsScreen`, `EventDetailsScreen` | `EventCubit` |
| `news` | `NewsScreen`, `NewsDetailsScreen` | `NewsCubit` |
| `notification` | `NotificationScreen` | `NotificationsCubit` |
| `profile` | `ProfileScreen`, `ProfileInfoScreen`, `ActivityPostsScreen`, `DonationScreen`, `SubscribeScreen`, `TermsAndConditions` | `ProfileCubit` |
| `donation` | `DonationScreen`, `DonationProcessScreen` | `DonationCubit` |
| `chat` | `ConversationsScreen`, `ConversationDetailsScreen` | `ChatCubit` |
| `settings` | `SettingsScreen`, `TermsAndConditionsScreen` | `TermsAndConditionsCubit` |
| `faq` | `FAQScreen` | `FAQCubit` |

---

## Naming Conventions

| Artifact | Convention | Example |
|---|---|---|
| Feature folder | `snake_case` | `add_feed/`, `feed_details/` |
| Screen class | `PascalCase` + `Screen` suffix | `FeedDetailsScreen` |
| Route constant | `static const String routeName = '/...'` | `'/feed-details'` |
| Cubit class | `PascalCase` + `Cubit` suffix | `FeedCubit` |
| State class | `PascalCase` + `State` suffix | `FeedState` |
| Status enum | `PascalCase` + `Status` suffix | `FeedStatus` |
| RDS abstract | `PascalCase` + `RemoteDataSource` | `FeedRemoteDataSource` |
| RDS impl | abstract name + `Impl` | `FeedRemoteDataSourceImpl` |
| Repository abstract | `PascalCase` + `Repository` | `FeedRepository` |
| Repository impl | abstract name + `Implementation` | `FeedRepositoryImplementation` |
| Model file | `snake_case.dart` matching class | `feed.dart` → `class Feed` |
| Asset constants | `AppImages.camelCase` | `AppImages.navHome` |
| Color constants | `AppColors.camelCase` | `AppColors.myPink` |

---

## Adding a New Feature — Checklist

1. **Create the folder tree:**
   ```
   lib/features/<feature>/
   ├── data/
   │   ├── model/<feature>.dart
   │   ├── remote/<feature>_rds.dart       # abstract + impl
   │   └── repo/<feature>_repo.dart        # abstract + impl
   └── presentation/
       ├── cubits/<feature>_cubit.dart
       ├── cubits/<feature>_state.dart
       ├── screens/<feature>_screen.dart
       └── widgets/
   ```

2. **Define the model** with `fromJson` / `toJson` and extend `Equatable` if used in state.

3. **Define the RDS** — abstract interface first, then implementation using `NetworkService` or Supabase.

4. **Define the Repository** — abstract interface, then implementation that delegates to the RDS.

5. **Add a static route name** to the screen class.

6. **Register in `DependencyInjector`** ([lib/core/di/dependency_injection.dart](lib/core/di/dependency_injection.dart)):
   ```dart
   XxxRemoteDataSource get xxxRDS => _dependencies[XxxRemoteDataSource] ??= XxxRDSImpl(networkService: netWorkService);
   XxxRepository get xxxRepo => _dependencies[XxxRepository] ??= XxxRepoImpl(rds: xxxRDS);
   XxxCubit get xxxCubit => XxxCubit(xxxRepo); // no caching if one-per-use
   ```

7. **Add endpoint** to [lib/core/utils/end_points.dart](lib/core/utils/end_points.dart).

8. **Register the route** in the `switch` block in [lib/routes.dart](lib/routes.dart).

9. **Provide the cubit** in `main.dart` `MultiBlocProvider` if it needs to be globally accessible.

10. **Add translations** to both `app_en.arb` and `app_ar.arb`, then run `flutter gen-l10n`.
