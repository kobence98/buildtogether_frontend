import 'package:flutter_frontend/languages/languages.dart';

enum AgeBracket{
  BELOW_18,
  FROM_18_TO_24,
  FROM_25_TO_34,
  FROM_35_TO_44,
  FROM_45_TO_54,
  FROM_55_TO_64,
  ABOVE_64
}


extension AgeBracketName on AgeBracket {
  String get getName {
    switch (this) {
      case AgeBracket.BELOW_18:
        return '< 18';
      case AgeBracket.FROM_18_TO_24:
        return '18 - 24';
      case AgeBracket.FROM_25_TO_34:
        return '25 - 34';
      case AgeBracket.FROM_35_TO_44:
        return '35 - 44';
      case AgeBracket.FROM_45_TO_54:
        return '45 - 54';
      case AgeBracket.FROM_55_TO_64:
        return '55 - 64';
      default:
        return '64+';
    }
  }

  String get stringValue {
    switch (this) {
      case AgeBracket.BELOW_18:
        return 'BELOW_18';
      case AgeBracket.FROM_18_TO_24:
        return 'FROM_18_TO_24';
      case AgeBracket.FROM_25_TO_34:
        return 'FROM_25_TO_34';
      case AgeBracket.FROM_35_TO_44:
        return 'FROM_35_TO_44';
      case AgeBracket.FROM_45_TO_54:
        return 'FROM_45_TO_54';
      case AgeBracket.FROM_55_TO_64:
        return 'FROM_55_TO_64';
      default:
        return 'ABOVE_64';
    }
  }
}