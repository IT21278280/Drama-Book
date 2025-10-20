import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/local_database_service.dart';
import '../services/fake_api_service.dart';
import 'theme_provider.dart';

final List<ChangeNotifierProvider> appProviders = [
  ChangeNotifierProvider<LocalDatabaseService>(
    create: (_) {
      final dbService = LocalDatabaseService();
      dbService.initDatabase(); // Initialize database with sample data
      return dbService;
    },
  ),
  ChangeNotifierProvider<AuthService>(
    create: (context) => AuthService(
      Provider.of<LocalDatabaseService>(context, listen: false),
    ),
  ),
  ChangeNotifierProvider<FakeApiService>(
    create: (context) => FakeApiService(
      Provider.of<LocalDatabaseService>(context, listen: false),
    ),
  ),
  ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
];