import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/company.dart';
import 'package:flutter_frontend/entities/post.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/static/date_formatter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';
import 'package:polls/polls.dart';

import 'comments_widget.dart';

class SinglePostWidget extends StatefulWidget {
  final Post post;
  final Session session;
  final User user;
  final Languages languages;

  const SinglePostWidget(
      {required this.post,
      required this.session,
      required this.user,
      required this.languages});

  @override
  _SinglePostWidgetState createState() => _SinglePostWidgetState();
}

class _SinglePostWidgetState extends State<SinglePostWidget> {
  late Languages languages;

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(bottom: 10),
        color: Colors.black,
        child: SingleChildScrollView(
          child: Container(
            color: Colors.black,
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      widget.session.domainName +
                          "/api/images/" +
                          widget.post.companyId.toString(),
                      headers: widget.session.headers,
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Text(
                            widget.post.companyName,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        onTap: () {
                          _onCompanyTap(widget.post.companyId);
                        },
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.post.implemented
                          ? InkWell(
                              child: Icon(
                                Icons.lightbulb_outline_sharp,
                                color: Colors.yellow,
                              ),
                              onTap: () {
                                Fluttertoast.showToast(
                                    msg: languages.ideaIsImplementedMessage,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              },
                            )
                          : Container(),
                      Text(
                        DateFormatter.formatDate(
                            widget.post.createdDate, languages),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text(
                    widget.post.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.topLeft,
                  child: widget.post.postType == 'SIMPLE_POST'
                      ? Text(
                          widget.post.description,
                          style: TextStyle(color: Colors.white),
                        )
                      : _pollWidget(widget.post),
                ),
                Container(
                  height: 40,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LikeButton(
                        size: 20.0,
                        circleColor: CircleColor(
                            start: Colors.yellow.shade200, end: Colors.yellow),
                        bubblesColor: BubblesColor(
                          dotPrimaryColor: Colors.yellow.shade200,
                          dotSecondaryColor: Colors.yellow,
                        ),
                        isLiked: widget.post.liked,
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            Icons.lightbulb,
                            color: isLiked ? Colors.yellow : Colors.white,
                          );
                        },
                        onTap: (isLiked) {
                          return _onLikeButton(isLiked);
                        },
                        likeCount: widget.post.likeNumber,
                      ),
                      Row(
                        children: [
                          Text(
                            widget.post.commentNumber.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            icon: Icon(Icons.comment),
                            color: Colors.white,
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CommentsWidget(
                                        session: widget.session,
                                        postId: widget.post.postId,
                                        user: widget.user,
                                        languages: languages,
                                      )));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCompanyTap(int companyId) {
    widget.session
        .get('/api/companies/' + companyId.toString())
        .then((response) {
      if (response.statusCode == 200) {
        setState(() {
          Company company =
              Company.fromJson(json.decode(utf8.decode(response.bodyBytes)));
          showDialog(
              context: context,
              useRootNavigator: false,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.black,
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          widget.session.domainName +
                              "/api/images/" +
                              company.imageId.toString(),
                          headers: widget.session.headers,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        company.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  ),
                  content: Container(
                    height: 100,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      child: Text(
                        company.description,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(languages.closeLabel)),
                  ],
                );
              });
        });
      }
    });
  }

  Future<bool> _onLikeButton(bool isLiked) async {
    dynamic response = await widget.session.post(
        "/api/posts/" + widget.post.postId.toString() + "/like",
        new Map<String, dynamic>());
    if (response.statusCode == 200) {
      widget.post.liked = !widget.post.liked;
      if (widget.post.liked) {
        widget.post.likeNumber++;
      } else {
        widget.post.likeNumber--;
      }
      return !isLiked;
    } else {
      return isLiked;
    }
  }

  Widget _pollWidget(Post post) {
    List<dynamic> polls = [];
    Map<dynamic, dynamic> voteData = {};
    post.pollOptions.forEach((option) {
      polls.add(
        Polls.options(
            title: option.title!,
            value: double.parse(option.likeNumber.toString())),
      );
      for (int i = 0; i < option.likeNumber; i++) {
        voteData.addAll({i.toString(): post.pollOptions.indexOf(option) + 1});
      }
      if (option.liked) {
        voteData.remove(voteData.values.last);
        voteData.addAll({
          widget.user.userId.toString(): post.pollOptions.indexOf(option) + 1
        });
      }
    });
    return Polls(
      children: polls,
      question: Text(''),
      currentUser: widget.user.userId.toString(),
      creatorID: widget.post.companyUserId.toString(),
      voteData: voteData,
      userChoice: voteData[widget.user.userId.toString()],
      onVoteBackgroundColor: Colors.yellow,
      leadingBackgroundColor: Colors.yellow.shade800,
      backgroundColor: Colors.white,
      onVote: (choice) {
        widget.session
            .post(
                '/api/posts/' +
                    post.postId.toString() +
                    '/pollVote/' +
                    post.pollOptions.elementAt(choice - 1).pollId.toString(),
                Map())
            .then((response) {
          if (response.statusCode == 200) {
            setState(() {
              post.pollOptions.forEach((option) {
                option.liked = false;
              });
              post.pollOptions.elementAt(choice - 1).liked = true;
              post.pollOptions.elementAt(choice - 1).likeNumber++;
            });
          } else {
            Fluttertoast.showToast(
                msg: languages.globalErrorMessage,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        });
      },
    );
  }
}
