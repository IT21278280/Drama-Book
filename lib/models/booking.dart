class Booking {
  final String id;
  final String userId;
  final String dramaId;
  final String date;
  final String time;
  final List<String> seats;
  final double totalPrice;

  Booking({
    required this.id,
    required this.userId,
    required this.dramaId,
    required this.date,
    required this.time,
    required this.seats,
    required this.totalPrice,
  });

  String get showTime => time;
  List<String> get selectedSeats => seats;

  factory Booking.fromMap(Map<String, dynamic> data) {
    return Booking(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      dramaId: data['dramaId'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      seats: List<String>.from(data['seats'] ?? []),
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'dramaId': dramaId,
      'date': date,
      'time': time,
      'seats': seats,
      'totalPrice': totalPrice,
    };
  }
}