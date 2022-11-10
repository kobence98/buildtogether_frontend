class CompanyForListing{
  int id;
  String name;
  int imageId;
  bool active;

  CompanyForListing({required this.id, required this.name, required this.imageId, required this.active});

  factory CompanyForListing.fromJson(Map<String, dynamic> json) {
    return CompanyForListing(
      id: json['id'],
      name: json['name'],
      imageId: json['imageId'],
      active: json['active'],
    );
  }
}
