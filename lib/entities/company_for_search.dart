class CompanyForSearch{
  int id;
  String name;
  int imageId;

  CompanyForSearch({required this.id, required this.name, required this.imageId});

  factory CompanyForSearch.fromJson(Map<String, dynamic> json) {
    return CompanyForSearch(
      id: json['id'],
      name: json['name'],
      imageId: json['imageId'],
    );
  }
}
