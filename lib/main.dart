  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:overlay_support/overlay_support.dart';
  import 'core/theme/app_theme.dart';
  import 'providers/theme_provider.dart';
  import 'routes/app_router.dart';
  import 'firebase_options.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
      Firebase.app();
    }
    runApp(const ProviderScope(child: FreshCartApp()));
  }

  class FreshCartApp extends ConsumerWidget {
    const FreshCartApp({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final themeMode = ref.watch(themeModeProvider);
      final router = ref.watch(appRouterProvider);

      // OverlaySupport must wrap MaterialApp so toasts render correctly
      return OverlaySupport.global(
        child: MaterialApp.router(
          title: 'FreshCart',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: router,
        ),
      );
    }
  }
