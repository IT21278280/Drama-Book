import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders, // From providers.dart
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'DramaBook',
            theme: themeProvider.currentTheme, // Use dynamic theme
            initialRoute: AppRouter.login,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
