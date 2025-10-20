import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/drama.dart';
import '../models/booking.dart';
import '../models/user.dart';
import 'local_database_service.dart';

class FakeApiService extends ChangeNotifier {
  final LocalDatabaseService _dbService;
  final _uuid = const Uuid();
  
  FakeApiService(this._dbService);

  // Simulate network delay
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));
  }

  // Simulate random errors (5% chance)
  void _simulateRandomError() {
    if (Random().nextInt(100) < 5) {
      throw Exception('Network error occurred. Please try again.');
    }
  }

  // Drama API endpoints
  Future<List<Drama>> getDramas() async {
    await _simulateNetworkDelay();
    _simulateRandomError();
    // Ensure database is initialized before returning dramas
    await _dbService.initDatabase();
    return _dbService.dramas;
  }

  Future<Drama?> getDrama(String id) async {
    await _simulateNetworkDelay();
    _simulateRandomError();
    return _dbService.getDramaById(id);
  }

  Future<void> addDrama(Drama drama) async {
    await _simulateNetworkDelay();
    _simulateRandomError();
    await _dbService.addDrama(drama);
  }

  Future<void> updateDrama(Drama drama) async {
    await _simulateNetworkDelay();
    _simulateRandomError();
    await _dbService.updateDrama(drama);
  }

  Future<void> deleteDrama(String id) async {
    await _simulateNetworkDelay();
    _simulateRandomError();
    await _dbService.deleteDrama(id);
  }

  // User API endpoints
  Future<User?> authenticateUser(String email, String password) async {
    // Ensure database is initialized
    await _dbService.initDatabase();
    
    final user = await _dbService.getUserByEmail(email);
    if (user != null && user.password == password) {
      return user;
    }
    
    throw Exception('Invalid credentials');
  }

  Future<User?> registerUser(String email, String password, String name) async {
    // Ensure database is initialized
    await _dbService.initDatabase();
    
    // Check if user already exists
    final existingUser = await _dbService.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('User with this email already exists');
    }
    
    final newUser = User(
      id: _uuid.v4(),
      email: email,
      name: name,
      password: password,
      role: 'user',
    );
    
    await _dbService.addUser(newUser);
    return newUser;
  }

  // Booking API endpoints
  Future<List<Booking>> getUserBookings(String userId) async {
    await _simulateNetworkDelay();
    _simulateRandomError();
    return await _dbService.getUserBookings(userId);
  }

  Future<List<Booking>> getAllBookings() async {
    await _simulateNetworkDelay();
    _simulateRandomError();
    return _dbService.bookings;
  }

  Future<void> createBooking(Booking booking) async {
    await _simulateNetworkDelay();
    _simulateRandomError();
    await _dbService.addBooking(booking);
  }

  Future<void> deleteBooking(String id) async {
    await _simulateNetworkDelay();
    _simulateRandomError();
    // Add delete booking method to database service if needed
  }

  // Get available seats for a drama and showtime
  Future<List<String>> getAvailableSeats(String dramaId, String showTime) async {
    await _simulateNetworkDelay();
    _simulateRandomError();
    
    final bookedSeats = _dbService.bookings
        .where((booking) => booking.dramaId == dramaId && booking.showTime == showTime)
        .expand((booking) => booking.selectedSeats)
        .toList();
    
    final allSeats = <String>[];
    for (String row in ['A', 'B', 'C', 'D', 'E']) {
      for (int seat = 1; seat <= 10; seat++) {
        allSeats.add('$row$seat');
      }
    }
    
    return allSeats.where((seat) => !bookedSeats.contains(seat)).toList();
  }

  // Stream methods for real-time updates
  Stream<List<Drama>> getDramasStream() async* {
    while (true) {
      yield await getDramas();
      await Future.delayed(Duration(seconds: 5));
    }
  }

  Stream<List<Booking>> getUserBookingsStream(String userId) async* {
    while (true) {
      yield await getUserBookings(userId);
      await Future.delayed(Duration(seconds: 5));
    }
  }

  Stream<List<Booking>> getAllBookingsStream() async* {
    while (true) {
      yield await getAllBookings();
      await Future.delayed(Duration(seconds: 5));
    }
  }
}
