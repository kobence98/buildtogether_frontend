class AuthUser {
  int id;
  String email;
  String password;

  AuthUser({required this.id, required this.email, required this.password});

  AuthUser.fromMap(Map<String, dynamic> res)
      : email = res["email"],
        id = res["id"],
        password = res["password"];

  Map<String, Object?> toMap() {
    return {'email': email, 'password': password, 'id': id};
  }
}
