class User {
  final String email;
  final String username;
  final int userId;
  //final String rol;
  final String? refresh;
  final String? access;

  User({
    required this.email,
    required this.username,
    required this.userId,
    //required this.rol,
    this.refresh,
    this.access
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }

}