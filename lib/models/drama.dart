class Drama {
  final String id;
  final String title;
  final String genre;
  final String description;
  final String poster;
  final List<String> showTimes;
  final double price;
  final String duration;

  Drama({
    required this.id,
    required this.title,
    required this.genre,
    required this.description,
    required this.poster,
    required this.showTimes,
    this.price = 25.0,
    this.duration = '2h 30min',
  });

  factory Drama.fromMap(Map<String, dynamic> data) {
    return Drama(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      genre: data['genre'] ?? '',
      description: data['description'] ?? '',
      poster: data['poster'] ?? '',
      showTimes: List<String>.from(data['showTimes'] ?? []),
      price: (data['price'] ?? 25.0).toDouble(),
      duration: data['duration'] ?? '2h 30min',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'description': description,
      'poster': poster,
      'showTimes': showTimes,
      'price': price,
      'duration': duration,
    };
  }
}
