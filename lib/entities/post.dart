import 'package:flutter_frontend/entities/poll_option.dart';

class Post{
  int postId;
  String title;
  String description;
  String companyName;
  String userName;
  String creatorEmail;
  int companyId;
  int likeNumber;
  bool liked;
  DateTime createdDate;
  int commentNumber;
  bool implemented;
  String postType;
  List<PollOption> pollOptions;
  int companyUserId;
  int companyImageId;
  int creatorId;

  Post({required this.postId, required this.title, required this.description, required this.companyName, required this.userName, required this.creatorEmail, required this.likeNumber, required this.liked, required this.companyId, required this.createdDate, required this.commentNumber, required this.implemented, required this.postType, required this.pollOptions, required this.companyUserId, required this.companyImageId, required this.creatorId});

  factory Post.fromJson(Map<String, dynamic> json) {
    String stringDate = json['createdDate'];
    DateTime createdDate = DateTime(int.parse(stringDate.substring(0,4)), int.parse(stringDate.substring(5,7)), int.parse(stringDate.substring(8,10)), int.parse(stringDate.substring(11,13)), int.parse(stringDate.substring(14,16)));
    return Post(
      postId: json['postId'],
      title: json['title'],
      description: json['description'],
      companyName: json['companyName'],
      userName: json['userName'],
      creatorEmail: json['creatorEmail'],
      companyId: json['companyId'],
      likeNumber: json['likeNumber'],
      liked: json['liked'],
      commentNumber: json['commentNumber'],
      createdDate: createdDate,
      implemented: json['implemented'],
      postType: json['postType'],
      pollOptions: List<PollOption>.from(
          json['pollOptions'].map((po) => PollOption.fromJson(po))),
      companyUserId: json['companyUserId'],
      companyImageId: json['companyImageId'],
      creatorId: json['creatorId'],
    );
  }
}
