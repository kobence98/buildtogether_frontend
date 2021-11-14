class PollOption{
  int pollId;
  String? title;
  int likeNumber;
  bool liked;

  PollOption({required this.title, required this.likeNumber, required this.liked, required this.pollId});

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      title: json['title'],
      likeNumber: json['likeNumber'],
      liked: json['liked'],
      pollId: json['pollId'],
    );
  }
}
