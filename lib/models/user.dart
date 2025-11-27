class User {
  final String username;
  final String name;
  final String? email;
  final String? phone;
  final String? photoPath;

  User({
    required this.username,
    required this.name,
    this.email,
    this.phone,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'name': name,
        'email': email,
        'phone': phone,
        'photoPath': photoPath,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        username: json['username'] ?? '',
        name: json['name'] ?? '',
        email: json['email'],
        phone: json['phone'],
        photoPath: json['photoPath'],
      );
}
