import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/comment.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/static/profanity_checker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';

class CommentsWidget extends StatefulWidget {
  final Session session;
  final int postId;
  final User user;

  const CommentsWidget(
      {required this.session, required this.postId, required this.user});

  @override
  _CommentsWidgetState createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  List<Comment> comments = [];
  final TextEditingController _commentController = TextEditingController();
  late bool loading;

  @override
  void initState() {
    super.initState();
    loading = true;
    widget.session
        .get('/api/posts/' + widget.postId.toString() + '/comments')
        .then((response) {
      if (response.statusCode == 200) {
        setState(() {
          Iterable l = json.decode(utf8.decode(response.bodyBytes));
          comments =
              List<Comment>.from(l.map((model) => Comment.fromJson(model)));
          loading = false;
        });
      }
      else{
        Fluttertoast.showToast(
            msg: "Something went wrong pls check your network connection!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: loading ? Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Colors.yellow,),
        ),
      ) : Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(bottom: 10),
        color: Colors.black,
        child: Column(
          children: [
            Flexible(
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: 10),
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.white,
                ),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  Comment comment = comments.elementAt(index);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black,
                              ),
                              borderRadius:
                              BorderRadius.all(Radius.circular(20))),
                          child: Text(
                            comment.userName,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          comment.text,
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: comment.userId == widget.user.userId
                            ? Container(
                          child: PopupMenuButton(
                              child: Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ),
                              itemBuilder: (context) {
                                return List.generate(1, (index) {
                                  return PopupMenuItem(
                                    child: Text('Delete'),
                                    value: 0,
                                  );
                                });
                              },
                              onSelected: (index) {
                                widget.session
                                    .delete('/api/comments/' +
                                    comment.commentId.toString())
                                    .then((response) {
                                  if (response.statusCode == 200) {
                                    Fluttertoast.showToast(
                                        msg: "Successful delete!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    setState(() {
                                      comments.remove(comment);
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Something went wrong!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
                                });
                              }),
                        )
                            : Container(
                          width: 1,
                        ),
                      ),
                      Container(
                        height: 40,
                        margin: EdgeInsets.only(left: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            LikeButton(
                              size: 20.0,
                              circleColor: CircleColor(
                                  start: Colors.yellow.shade200,
                                  end: Colors.yellow),
                              bubblesColor: BubblesColor(
                                dotPrimaryColor: Colors.yellow.shade200,
                                dotSecondaryColor: Colors.yellow,
                              ),
                              isLiked: comment.liked,
                              likeBuilder: (bool isLiked) {
                                return Icon(
                                  Icons.lightbulb,
                                  color: isLiked ? Colors.yellow : Colors.white,
                                );
                              },
                              onTap: (isLiked) {
                                return _onLikeButton(isLiked, comment);
                              },
                              likeCount: comment.likeNumber,
                            ),
                            Text(
                              _formatDate(comment.createdDate),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              flex: 8,
            ),
            Flexible(
              child: ElevatedButton(
                onPressed: () {
                  _addComment();
                },
                style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.yellowAccent)),
                child: Center(
                  child: Text(
                    "Add comment",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }

  void _addComment() {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setInnerState) {
            return loading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.yellow,),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: Colors.black,
                    title: Center(
                      child: Text(
                        "Add comment",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    content: Container(
                      height: MediaQuery.of(context).size.height - 350,
                      margin: EdgeInsets.only(left: 10, right: 10),
                      color: Colors.white,
                      padding: EdgeInsets.all(4),
                      child: TextField(
                          maxLines: 3000,
                          maxLength: 256,
                          controller: _commentController,
                          style: TextStyle(fontSize: 20),
                          decoration: new InputDecoration.collapsed(
                              hintText:
                                  'This is where you should write your comment. Maximum of 256 characters.'),
                          onChanged: (text) => setState(() {})),
                    ),
                    actions: <Widget>[
                      Container(
                        color: Colors.yellow,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Close',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.yellow,
                        child: TextButton(
                          onPressed: () {
                            _addCommentToList(setInnerState);
                          },
                          child: Text(
                            'Add comment',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  );
          });
        });
  }

  void _addCommentToList(setInnerState) {
    setInnerState(() {
      loading = true;
    });
    if(ProfanityChecker.alert(_commentController.text)){
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(
          msg: "Please dont use bad language!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    else{
      if (_commentController.text != '') {
        dynamic body = <String, String>{'text': _commentController.text};
        widget.session
            .postJson(
          '/api/posts/' + widget.postId.toString() + '/comments',
          jsonEncode(body),
        )
            .then((response) {
          if (response.statusCode == 200) {
            Comment comment =
            Comment.fromJson(json.decode(utf8.decode(response.bodyBytes)));
            Navigator.of(context).pop();
            setState(() {
              comments.add(comment);
              loading = false;
              Fluttertoast.showToast(
                  msg: "Your comment is added!",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0);
            });
          } else {
            setInnerState(() {
              loading = false;
            });
            Fluttertoast.showToast(
                msg: "There is some problem! Check your network connection!",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        });
      } else {
        setInnerState(() {
          loading = false;
        });
        Fluttertoast.showToast(
            msg: "Dont let the comment empty!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  String _formatDate(DateTime createdDate) {
    if (createdDate.isAfter(DateTime.now().subtract(Duration(hours: 1)))) {
      return (DateTime.now().hour == createdDate.hour
                  ? DateTime.now().minute - createdDate.minute
                  : DateTime.now().minute + (60 - createdDate.minute))
              .toString() +
          'm';
    }
    for (int i = 2; i < 24; i++) {
      if (createdDate.isAfter(DateTime.now().subtract(Duration(hours: i)))) {
        return (i - 1).toString() + 'h';
      }
    }
    for (int i = 2; i < 21; i++) {
      if (createdDate.isAfter(DateTime.now().subtract(Duration(days: i)))) {
        return (i - 1).toString() + "d";
      }
    }
    return createdDate.year.toString() +
        '.' +
        createdDate.month.toString() +
        '.' +
        createdDate.day.toString() +
        '.' +
        createdDate.hour.toString() +
        ':' +
        createdDate.minute.toString();
  }

  Future<bool> _onLikeButton(bool isLiked, Comment comment) async {
    dynamic response = await widget.session.post(
        "/api/comments/" + comment.commentId.toString() + "/like",
        new Map<String, dynamic>());
    if (response.statusCode == 200) {
      comment.liked = !comment.liked;
      if (comment.liked) {
        comment.likeNumber++;
      } else {
        comment.likeNumber--;
      }
      return !isLiked;
    } else {
      return isLiked;
    }
  }
}
