import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  try {
    await MobileAds.instance.initialize();
    print("Google Mobile Ads SDK successfully initialized on startup.");
  } catch (e) {
    print("Failed to initialize Google Mobile Ads SDK: $e");
  }
  
  runApp(
    const ProviderScope(
      child: FlipLessApp(),
    ),
  );
}

class FlipLessApp extends StatelessWidget {
  const FlipLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FlipLess',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Defaulting to Dark Theme
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
