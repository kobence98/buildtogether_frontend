import 'package:flutter_frontend/languages/languages.dart';

enum Gender{
  MAN,
  WOMAN,
  OTHER
}

extension GenderName on Gender {
  String getName(Languages language) {
    switch (this) {
      case Gender.MAN:
        return language.manLabel;
      case Gender.WOMAN:
        return language.womanLabel;
      case Gender.OTHER:
        return language.otherLabel;
    }
  }

  String get stringValue {
    switch (this) {
      case Gender.MAN:
        return 'MAN';
      case Gender.WOMAN:
        return 'WOMAN';
      case Gender.OTHER:
        return 'OTHER';
    }
  }
}