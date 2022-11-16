class Comment{
  DateTime now;
  String userName;
  int userId;
  String text;
  int commentId;
  int likeNumber;
  bool liked;
  DateTime createdDate;
  List<Comment> childComments;
  bool deleted;
  int depthInTree;

  Comment({required this.now, required this.userName, required this.userId, required this.text, required this.commentId, required this.likeNumber, required this.liked, required this.createdDate, required this.childComments, required this.deleted, required this.depthInTree});

  factory Comment.fromJson(Map<String, dynamic> json) {
    String stringDate = json['createdDate'];
    DateTime createdDate = DateTime(int.parse(stringDate.substring(0,4)), int.parse(stringDate.substring(5,7)), int.parse(stringDate.substring(8,10)), int.parse(stringDate.substring(11,13)), int.parse(stringDate.substring(14,16)));
    String stringNow = json['now'];
    DateTime now = DateTime(int.parse(stringNow.substring(0,4)), int.parse(stringNow.substring(5,7)), int.parse(stringNow.substring(8,10)), int.parse(stringNow.substring(11,13)), int.parse(stringNow.substring(14,16)));
    int difference = DateTime.now().difference(now).inHours;
    return Comment(
      now: now,
      userName: json['userName'],
      userId: json['userId'],
      text: json['text'],
      commentId: json['commentId'],
      likeNumber: json['likeNumber'],
      liked: json['liked'],
      createdDate: createdDate.add(Duration(hours: difference)),
      childComments: List<Comment>.from(json['childComments'].map((model) => Comment.fromJson(model))),
      deleted: json['deleted'],
      depthInTree: json['depthInTree'],
    );
  }
}
