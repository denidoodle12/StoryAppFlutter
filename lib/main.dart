import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/localization.dart';
import 'common/styles.dart';
import 'data/api/api_service.dart';
import 'data/preferences/auth_preferences.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/story_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/story_list_provider.dart';
import 'providers/story_upload_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final apiService = ApiService();
  final authPreferences = AuthPreferences(prefs);
  final authRepository = AuthRepository(
    apiService: apiService,
    preferences: authPreferences,
  );
  final storyRepository = StoryRepository(apiService: apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
        Provider.value(value: storyRepository),
      ],
      child: const StoryApp(),
    ),
  );
}

class StoryApp extends StatefulWidget {
  const StoryApp({super.key});

  @override
  State<StoryApp> createState() => _StoryAppState();
}

class _StoryAppState extends State<StoryApp> {
  late final _router = createRouter(context.read<AuthProvider>());

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final authProvider = context.watch<AuthProvider>();

    final materialApp = MaterialApp.router(
      title: 'Story App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );

    if (authProvider.isLoggedIn && authProvider.token != null) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => StoryListProvider(
              repository: context.read<StoryRepository>(),
              token: authProvider.token!,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => StoryUploadProvider(
              repository: context.read<StoryRepository>(),
              token: authProvider.token!,
            ),
          ),
        ],
        child: materialApp,
      );
    }

    return materialApp;
  }
}
