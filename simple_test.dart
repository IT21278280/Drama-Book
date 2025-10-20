// Simple test to verify authentication logic works
import 'lib/services/auth_service.dart';

void main() async {
  print('Testing authentication service...');
  
  final authService = AuthService();
  
  // Test admin login
  print('\n--- Testing Admin Login ---');
  final adminUser = await authService.signIn('admin@dramabook.com', 'admin123');
  if (adminUser != null) {
    print('✅ Admin login successful!');
    print('Email: ${adminUser.email}');
    print('Role: ${adminUser.role}');
    print('Is Admin: ${authService.isAdmin}');
  } else {
    print('❌ Admin login failed!');
  }
  
  // Test sign out
  await authService.signOut();
  print('✅ Sign out successful!');
  
  // Test regular user login
  print('\n--- Testing Regular User Login ---');
  final regularUser = await authService.signIn('user@dramabook.com', 'user123');
  if (regularUser != null) {
    print('✅ Regular user login successful!');
    print('Email: ${regularUser.email}');
    print('Role: ${regularUser.role}');
    print('Is Admin: ${authService.isAdmin}');
  } else {
    print('❌ Regular user login failed!');
  }
  
  // Test invalid credentials
  print('\n--- Testing Invalid Credentials ---');
  final invalidUser = await authService.signIn('invalid@email.com', 'wrongpassword');
  if (invalidUser == null) {
    print('✅ Invalid credentials correctly rejected!');
  } else {
    print('❌ Invalid credentials were accepted!');
  }
  
  print('\n--- Test Complete ---');
}
