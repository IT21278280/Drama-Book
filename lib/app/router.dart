import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/admin/admin_profile_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/booking/booking_screen.dart';
import '../features/drama_details/drama_details_screen.dart';
import '../models/drama.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String admin = '/admin';
  static const String adminDashboard = '/admin-dashboard';
  static const String profile = '/profile';
  static const String booking = '/booking';
  static const String dramaDetails = '/drama-details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case admin:
        return MaterialPageRoute(builder: (_) => AdminProfileScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => AdminDashboard());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case booking:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => BookingScreen(
              drama: args['drama'] as Drama,
              selectedTime: args['selectedTime'] as String,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case dramaDetails:
        final drama = settings.arguments as Drama?;
        if (drama != null) {
          return MaterialPageRoute(builder: (_) => DramaDetailsScreen(drama: drama));
        }
        return MaterialPageRoute(builder: (_) => HomeScreen());
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}