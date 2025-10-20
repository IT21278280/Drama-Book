// Simple test to verify authentication logic
import 'lib/services/auth_service.dart';

void main() async {
  // Test the authentication service
  final authService = AuthService();
  
  print('Testing authentication...');
  
  // Test admin login
  final adminUser = await authService.signIn('admin@dramabook.com', 'admin123');
  if (adminUser != null) {
    print('✅ Admin login successful!');
    print('User: ${adminUser.email}');
    print('Role: ${adminUser.role}');
    print('Is Admin: ${authService.isAdmin}');
  } else {
    print('❌ Admin login failed!');
  }
  
  // Test regular user login
  final regularUser = await authService.signIn('user@dramabook.com', 'user123');
  if (regularUser != null) {
    print('✅ Regular user login successful!');
    print('User: ${regularUser.email}');
    print('Role: ${regularUser.role}');
    print('Is Admin: ${authService.isAdmin}');
  } else {
    print('❌ Regular user login failed!');
  }
  
  // Test sign out
  await authService.signOut();
  print('✅ Sign out successful!');
  print('Is Authenticated: ${authService.isAuthenticated}');
}
