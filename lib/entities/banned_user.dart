class BannedUser{
  int id;
  String email;
  String name;

  BannedUser({required this.id, required this.email, required this.name});

  factory BannedUser.fromJson(Map<String, dynamic> json) {
    return BannedUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }
}
