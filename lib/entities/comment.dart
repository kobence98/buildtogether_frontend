class Comment{
  String userName;
  int userId;
  String text;
  int commentId;
  int likeNumber;
  bool liked;
  DateTime createdDate;

  Comment({required this.userName, required this.userId, required this.text, required this.commentId, required this.likeNumber, required this.liked, required this.createdDate});

  factory Comment.fromJson(Map<String, dynamic> json) {
    String stringDate = json['createdDate'];
    DateTime createdDate = DateTime(int.parse(stringDate.substring(0,4)), int.parse(stringDate.substring(5,7)), int.parse(stringDate.substring(8,10)), int.parse(stringDate.substring(11,13)), int.parse(stringDate.substring(14,16)));
    return Comment(
      userName: json['userName'],
      userId: json['userId'],
      text: json['text'],
      commentId: json['commentId'],
      likeNumber: json['likeNumber'],
      liked: json['liked'],
      createdDate: createdDate,
    );
  }
}
