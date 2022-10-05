class PollOptionInno{
  int pollId;
  String? title;
  int likeNumber;
  bool liked;

  PollOptionInno({required this.title, required this.likeNumber, required this.liked, required this.pollId});

  factory PollOptionInno.fromJson(Map<String, dynamic> json) {
    return PollOptionInno(
      title: json['title'],
      likeNumber: json['likeNumber'],
      liked: json['liked'],
      pollId: json['pollId'],
    );
  }
}
