class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}