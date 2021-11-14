class Company{
  String name;
  String description;
  int imageId;

  Company({required this.name, required this.description, required this.imageId});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
      description: json['description'],
      imageId: json['imageId'],
    );
  }
}
