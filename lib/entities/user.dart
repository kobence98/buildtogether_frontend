class User{
  int userId;
  String email;
  String name;
  List<dynamic> roles;
  bool active;
  int emailNotificationForCompanyNumber;
  String? locale;
  bool setByLocale;
  String? companyCountryCode;
  bool isCompanyActive;
  int? companyId;

  User({required this.userId, required this.email, required this.name, required this.roles, required this.active, required this.emailNotificationForCompanyNumber, required this.locale, required this.setByLocale, required this.companyCountryCode, required this.isCompanyActive, required this.companyId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      roles: json['roles'],
      email: json['email'],
      name: json['name'],
      active: json['active'],
      emailNotificationForCompanyNumber: json['emailNotificationForCompanyNumber'],
      locale: json['locale'],
      setByLocale: json['setByLocale'],
      companyCountryCode: json['companyCountryCode'],
      isCompanyActive: json['companyActive'],
      companyId: json['companyId'],
    );
  }
}
