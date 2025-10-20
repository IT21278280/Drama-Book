import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/drama.dart';
import '../models/booking.dart';
import '../models/user.dart';

class LocalDatabaseService extends ChangeNotifier {
  List<Drama> _dramas = [];
  List<Booking> _bookings = [];
  List<User> _users = [];
  Map<String, List<String>> _userLikes = {}; // userId -> list of dramaIds
  final _uuid = const Uuid();
  bool _isInitialized = false;

  List<Drama> get dramas => _dramas;
  List<Booking> get bookings => _bookings;
  List<User> get users => _users;
  Map<String, List<String>> get userLikes => _userLikes;

  LocalDatabaseService();

  Future<void> initDatabase() async {
    if (_isInitialized) return;
    await _initializeData();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _initializeData() async {
    // Initialize sample dramas
    _dramas = [
      Drama(
        id: _uuid.v4(),
        title: 'Romeo and Juliet',
        description:
            'A timeless tale of star-crossed lovers in fair Verona. Experience Shakespeare\'s masterpiece with stunning performances and beautiful set design.',
        poster: 'assets/images/romeo_juliet.jpg',
        price: 30.0,
        duration: '2h 45min',
        genre: 'Romance, Tragedy',
        showTimes: ['7:00 PM', '9:30 PM'],
      ),
      Drama(
        id: _uuid.v4(),
        title: 'Hamlet',
        description:
            'The Prince of Denmark seeks revenge in this psychological masterpiece. A gripping tale of madness, betrayal, and moral complexity.',
        poster: 'assets/images/hamlet.jpeg',
        price: 35.0,
        duration: '3h 15min',
        genre: 'Tragedy, Drama',
        showTimes: ['6:00 PM', '8:45 PM'],
      ),
      Drama(
        id: _uuid.v4(),
        title: 'A Midsummer Night\'s Dream',
        description:
            'A magical comedy filled with fairies, lovers, and mischievous sprites. Perfect for audiences of all ages.',
        poster: 'assets/images/midsummer_night.jpeg',
        price: 25.0,
        duration: '2h 30min',
        genre: 'Comedy, Fantasy',
        showTimes: ['7:30 PM', '9:45 PM'],
      ),
      Drama(
        id: _uuid.v4(),
        title: 'Macbeth',
        description:
            'Ambition and guilt consume the Scottish general in this dark tale of power and corruption.',
        poster: 'assets/images/macbeth.jpeg',
        price: 40.0,
        duration: '2h 50min',
        genre: 'Tragedy, Thriller',
        showTimes: ['6:30 PM', '9:00 PM'],
      ),
      Drama(
        id: _uuid.v4(),
        title: 'The Tempest',
        description:
            'Prospero\'s magical island becomes the stage for forgiveness and redemption in Shakespeare\'s final masterpiece.',
        poster: 'assets/images/tempest.jpg',
        price: 28.0,
        duration: '2h 20min',
        genre: 'Fantasy, Drama',
        showTimes: ['7:15 PM', '9:30 PM'],
      ),
    ];

    // Initialize sample users
    _users = [
      User(
        id: _uuid.v4(),
        name: 'Admin User',
        email: 'admin@dramabook.com',
        password: 'admin123',
        role: 'admin',
      ),
      User(
        id: _uuid.v4(),
        name: 'John Doe',
        email: 'user@example.com',
        password: 'user123',
        role: 'user',
      ),
    ];

    _bookings = [];
  }

  // User management methods
  Future<User?> getUserByEmail(String email) async {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<void> addUser(User user) async {
    _users.add(user);
    notifyListeners();
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    return _bookings.where((booking) => booking.userId == userId).toList();
  }

  // Drama management methods
  Future<void> addDrama(Drama drama) async {
    _dramas.add(drama);
    notifyListeners();
  }

  Future<void> updateDrama(Drama drama) async {
    int index = _dramas.indexWhere((d) => d.id == drama.id);
    if (index != -1) {
      _dramas[index] = drama;
      notifyListeners();
    }
  }

  Future<void> deleteDrama(String dramaId) async {
    _dramas.removeWhere((drama) => drama.id == dramaId);
    notifyListeners();
  }

  Future<List<Drama>> getDramas() async {
    return _dramas;
  }

  Stream<List<Drama>> getDramasStream() {
    return Stream.periodic(Duration(seconds: 1), (_) => _dramas);
  }

  // Booking management methods
  Future<void> createBooking(Booking booking) async {
    _bookings.add(booking);
    notifyListeners();
  }

  Future<void> deleteBooking(String bookingId) async {
    _bookings.removeWhere((booking) => booking.id == bookingId);
    notifyListeners();
  }

  Future<void> addBooking(Booking booking) async {
    _bookings.add(booking);
    notifyListeners();
  }

  Drama? getDramaById(String id) {
    try {
      return _dramas.firstWhere((drama) => drama.id == id);
    } catch (e) {
      return null;
    }
  }

  // Like management methods
  Future<void> likeDrama(String userId, String dramaId) async {
    if (!_userLikes.containsKey(userId)) {
      _userLikes[userId] = [];
    }
    if (!_userLikes[userId]!.contains(dramaId)) {
      _userLikes[userId]!.add(dramaId);
      notifyListeners();
    }
  }

  Future<void> unlikeDrama(String userId, String dramaId) async {
    if (_userLikes.containsKey(userId)) {
      _userLikes[userId]!.remove(dramaId);
      notifyListeners();
    }
  }

  bool isDramaLiked(String userId, String dramaId) {
    return _userLikes.containsKey(userId) && _userLikes[userId]!.contains(dramaId);
  }

  Future<List<Drama>> getUserLikedDramas(String userId) async {
    if (!_userLikes.containsKey(userId)) {
      return [];
    }
    List<Drama> likedDramas = [];
    for (String dramaId in _userLikes[userId]!) {
      Drama? drama = getDramaById(dramaId);
      if (drama != null) {
        likedDramas.add(drama);
      }
    }
    return likedDramas;
  }

  // Enhanced search with genre filtering
  Future<List<Drama>> searchDramas(String query, {String? genreFilter}) async {
    List<Drama> filteredDramas = _dramas;
    
    // Apply genre filter if provided
    if (genreFilter != null && genreFilter.isNotEmpty && genreFilter != 'All') {
      filteredDramas = filteredDramas.where((drama) => 
        drama.genre.toLowerCase().contains(genreFilter.toLowerCase())
      ).toList();
    }
    
    // Apply search query
    if (query.isNotEmpty) {
      filteredDramas = filteredDramas.where((drama) => 
        drama.title.toLowerCase().contains(query.toLowerCase()) ||
        drama.description.toLowerCase().contains(query.toLowerCase()) ||
        drama.genre.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    
    return filteredDramas;
  }
}
