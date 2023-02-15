import 'package:flutter_frontend/languages/languages.dart';

enum LivingPlaceType{
  CAPITAL_CITY,
  TOWN,
  VILLAGE
}

extension LivingPlaceTypeName on LivingPlaceType {
  String getName(Languages language) {
    switch (this) {
      case LivingPlaceType.CAPITAL_CITY:
        return language.capitalCity;
      case LivingPlaceType.TOWN:
        return language.town;
      default:
        return language.village;
    }
  }
  String get stringValue {
    switch (this) {
      case LivingPlaceType.CAPITAL_CITY:
        return 'CAPITAL_CITY';
      case LivingPlaceType.TOWN:
        return 'TOWN';
      default:
        return 'VILLAGE';
}
  }
}