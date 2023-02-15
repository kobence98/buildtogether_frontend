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
  String get getName {
    switch (this) {
      case SalaryType.BELOW_300K:
        return '< 300.000 FT';
      case SalaryType.FROM300K_TO_500K:
        return '300.000 - 500.000 FT';
      case SalaryType.FROM500K_TO_700K:
        return '500.000 - 700.000 FT';
      case SalaryType.FROM700K_TO_1M:
        return '700.000 - 1.000.000 FT';
      case SalaryType.FROM1M_TO_1_5M:
        return '1.000.000 - 1.500.000 FT';
      case SalaryType.FROM1_5M_TO_2M:
        return '1.500.000 - 2.000.000 FT';
      default:
        return '2.000.000+ FT';
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