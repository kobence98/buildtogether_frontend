class SearchFieldNames{
  int? id;
  String name;
  int? imageId;

  SearchFieldNames({required this.id, required this.name, required this.imageId});

  factory SearchFieldNames.fromJson(Map<String, dynamic> json) {
    return SearchFieldNames(
      id: json['id'],
      name: json['name'],
      imageId: json['imageId'],
    );
  }
}
