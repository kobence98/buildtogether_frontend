import 'package:flutter_frontend/entities/age_bracket.dart';
import 'package:flutter_frontend/entities/living_place_type.dart';
import 'package:flutter_frontend/entities/salary_type.dart';
import 'package:collection/collection.dart';

import 'gender.dart';

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

  Gender? gender;
  LivingPlaceType? livingPlaceType;
  SalaryType? salaryType;
  int? numberOfHouseholdMembers;
  AgeBracket? age;

  User({required this.userId, required this.email, required this.name, required this.roles, required this.active, required this.emailNotificationForCompanyNumber, required this.locale, required this.setByLocale, required this.companyCountryCode, required this.isCompanyActive,
      required this.companyId, required this.gender, required this.livingPlaceType, required this.salaryType, required this.numberOfHouseholdMembers, required this.age});

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
      gender: Gender.values.firstWhereOrNull((element) => element.stringValue == json['gender']),
      livingPlaceType: LivingPlaceType.values.firstWhereOrNull((element) => element.stringValue == json['livingPlaceType']),
      salaryType: SalaryType.values.firstWhereOrNull((element) => element.stringValue == json['salaryType']),
      numberOfHouseholdMembers: json['numberOfHouseholdMembers'],
      age: AgeBracket.values.firstWhereOrNull((element) => element.stringValue == json['age']),
    );
  }
}
