class LanguageCode {
  int id;
  String code;

  LanguageCode({required this.id, required this.code});

  LanguageCode.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        code = res["code"];

  Map<String, Object?> toMap() {
    return {'id': id, 'code': code};
  }
}
