class Company{
  String name;
  String description;
  int imageId;
  String countryCode;

  Company({required this.name, required this.description, required this.imageId, required this.countryCode});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
      description: json['description'],
      imageId: json['imageId'],
      countryCode: json['countryCode'],
    );
  }
}
