import 'package:flutter_frontend/languages/languages.dart';

enum SalaryType{
  BELOW_300K,
  FROM300K_TO_500K,
  FROM500K_TO_700K,
  FROM700K_TO_1M,
  FROM1M_TO_1_5M,
  FROM1_5M_TO_2M,
  ABOVE_2M
}

//TODO ezt még eurosítani valahogyan, vagy valamit kitalálni majd ha akarjuk külföldre is vinni
extension SalaryTypeName on SalaryType {
  String getName(Languages languages) {
    switch (this) {
      case SalaryType.BELOW_300K:
        return languages.BELOW_300K;
      case SalaryType.FROM300K_TO_500K:
        return languages.FROM300K_TO_500K;
      case SalaryType.FROM500K_TO_700K:
        return languages.FROM500K_TO_700K;
      case SalaryType.FROM700K_TO_1M:
        return languages.FROM700K_TO_1M;
      case SalaryType.FROM1M_TO_1_5M:
        return languages.FROM1M_TO_1_5M;
      case SalaryType.FROM1_5M_TO_2M:
        return languages.FROM1_5M_TO_2M;
      default:
        return languages.ABOVE_2M;
    }
  }

  String get stringValue {
    switch (this) {
      case SalaryType.BELOW_300K:
        return 'BELOW_300K';
      case SalaryType.FROM300K_TO_500K:
        return 'FROM300K_TO_500K';
      case SalaryType.FROM500K_TO_700K:
        return 'FROM500K_TO_700K';
      case SalaryType.FROM700K_TO_1M:
        return 'FROM700K_TO_1M';
      case SalaryType.FROM1M_TO_1_5M:
        return 'FROM1M_TO_1_5M';
      case SalaryType.FROM1_5M_TO_2M:
        return 'FROM1_5M_TO_2M';
      default:
        return 'ABOVE_2M';
    }
  }
}