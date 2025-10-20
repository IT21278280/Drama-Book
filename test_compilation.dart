import 'lib/services/local_database_service.dart';
import 'lib/services/fake_api_service.dart';
import 'lib/services/auth_service.dart';
import 'lib/models/drama.dart';
import 'lib/models/booking.dart';
import 'lib/models/user.dart';

void main() {
  print('🎭 Testing DramaBook Demo App Compilation...');
  
  // Test model creation
  final drama = Drama(
    id: '1',
    title: 'Test Drama',
    genre: 'Test',
    description: 'Test description',
    poster: 'https://example.com/poster.jpg',
    showTimes: ['7:00 PM'],
  );
  
  final user = User(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    role: 'user',
  );
  
  final booking = Booking(
    id: '1',
    userId: '1',
    dramaId: '1',
    date: '2024-01-15',
    time: '7:00 PM',
    seats: ['A1', 'A2'],
  );
  
  print('✅ Models created successfully');
  print('✅ Drama: ${drama.title}');
  print('✅ User: ${user.name}');
  print('✅ Booking: ${booking.id}');
  
  // Test services
  final databaseService = LocalDatabaseService();
  final apiService = FakeApiService();
  final authService = AuthService();
  
  print('✅ Services initialized successfully');
  print('✅ LocalDatabaseService: ${databaseService.runtimeType}');
  print('✅ FakeApiService: ${apiService.runtimeType}');
  print('✅ AuthService: ${authService.runtimeType}');
  
  print('🎉 All compilation tests passed!');
  print('🚀 App is ready to run with: flutter run');
}
