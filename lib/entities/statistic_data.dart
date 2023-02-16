import 'package:flutter_frontend/entities/age_bracket.dart';
import 'package:flutter_frontend/entities/salary_type.dart';

import 'gender.dart';
import 'living_place_type.dart';

class StatisticData {
  Map<Gender, int> genderStatistics;
  Map<LivingPlaceType, int> livingPlaceTypeStatistics;
  Map<SalaryType, int> salaryTypeStatistics;
  Map<int, int> numberOfHouseholdMembersStatistics;
  Map<AgeBracket, int> ageStatistics;

  StatisticData(
      {required this.genderStatistics,
      required this.livingPlaceTypeStatistics,
      required this.salaryTypeStatistics,
      required this.numberOfHouseholdMembersStatistics,
      required this.ageStatistics});

  factory StatisticData.fromJson(Map<String, dynamic> json) {
    Map<Gender, int> genderMapHelper = {};
    Gender.values.forEach((element) => genderMapHelper.addAll({element: 0}));
    genderMapHelper.addAll(json['genderStatistics']!.map<Gender, int>(
        (key, value) => (MapEntry(
            Gender.values.firstWhere((element) => element.stringValue == key),
            int.parse(value.toString())))));

    Map<LivingPlaceType, int> livingPlaceTypeMapHelper = {};
    LivingPlaceType.values
        .forEach((element) => livingPlaceTypeMapHelper.addAll({element: 0}));
    livingPlaceTypeMapHelper.addAll(json['livingPlaceTypeStatistics']!
        .map<LivingPlaceType, int>((key, value) => (MapEntry(
            LivingPlaceType.values
                .firstWhere((element) => element.stringValue == key),
            int.parse(value.toString())))));

    Map<SalaryType, int> salaryTypeMapHelper = {};
    SalaryType.values.forEach((element) => salaryTypeMapHelper.addAll({element: 0}));
    salaryTypeMapHelper.addAll(json['salaryTypeStatistics']!
        .map<SalaryType, int>((key, value) => (MapEntry(
        SalaryType.values
            .firstWhere((element) => element.stringValue == key),
        int.parse(value.toString())))));

    Map<AgeBracket, int> ageMapHelper = {};
    AgeBracket.values.forEach((element) => ageMapHelper.addAll({element: 0}));
    ageMapHelper.addAll(json['ageStatistics']!
        .map<AgeBracket, int>((key, value) => (MapEntry(
        AgeBracket.values
            .firstWhere((element) => element.stringValue == key),
        int.parse(value.toString())))));

    Map<int, int> numberOfHouseHoldMembersMapHelper = {1 : 0, 2 : 0, 3 : 0, 4 : 0, 5 : 0, 6 : 0, 7 : 0, 8 : 0, 9 : 0, 10 : 0, };
    numberOfHouseHoldMembersMapHelper.addAll(json['numberOfHouseholdMembersStatistics']!.map<int, int>(
            (key, value) =>
        (MapEntry(int.parse(key), int.parse(value.toString())))));

    return StatisticData(
      genderStatistics: genderMapHelper,
      livingPlaceTypeStatistics: livingPlaceTypeMapHelper,
      salaryTypeStatistics: salaryTypeMapHelper,
      numberOfHouseholdMembersStatistics: numberOfHouseHoldMembersMapHelper,
      ageStatistics: ageMapHelper,
    );
  }
}
