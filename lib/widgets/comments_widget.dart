import 'dart:async';
import 'dart:convert';

import 'package:comment_tree/comment_tree.dart' as commentTree;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/static/profanity_checker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';

import '../entities/comment.dart';
import '../entities/post.dart';
import '../static/date_formatter.dart';

class CommentsWidget extends StatefulWidget {
  final Session session;
  final int postId;
  final Post post;
  final User user;
  final Languages languages;
  final GlobalKey key;
  final bool commentTapped;
  final dynamic setMainState;

  const CommentsWidget(
      {required this.key,
      required this.session,
      required this.postId,
      required this.user,
      required this.languages,
      required this.commentTapped,
      required this.post,
      this.setMainState});

  @override
  _CommentsWidgetState createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  List<Comment> comments = [];
  final TextEditingController _commentController = TextEditingController();
  late bool loading;
  late Languages languages;

  bool innerLoading = false;
  final TextEditingController _reportReasonTextFieldController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
    loading = true;
    _initCommentData().whenComplete(() {
      if (widget.commentTapped) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.commentTapped) {
            Scrollable.ensureVisible(widget.key.currentContext!,
                duration: Duration(milliseconds: 500));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Container(
            color: Colors.black,
            child: Center(
              child: Image(
                  image: new AssetImage("assets/images/loading_breath.gif")),
            ),
          )
        : Container(
            padding: EdgeInsets.only(bottom: 10),
            color: Colors.black,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _addComment(null);
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          CupertinoColors.systemYellow)),
                  child: Center(
                    child: Text(
                      languages.addCommentLabel,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ...comments
                    .map(
                      (c) => Container(
                        child: _recursiveCommentTreeWidget(c),
                        padding: EdgeInsets.only(bottom: 20),
                      ),
                    )
                    .toList(),
              ],
            ),
          );
  }

  void _addComment(Comment? parentComment) {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setInnerState) {
            return loading
                ? Container(
                    child: Center(
                      child: Image(
                          image: new AssetImage(
                              "assets/images/loading_breath.gif")),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: Colors.grey[900],
                    title: Center(
                      child: Text(
                        languages.addCommentLabel,
                        style: TextStyle(
                            color: CupertinoColors.systemYellow,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    content: Container(
                      height: MediaQuery.of(context).size.height - 350,
                      margin: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(4),
                      child: TextField(
                          maxLines: 3000,
                          maxLength: 256,
                          controller: _commentController,
                          style: TextStyle(fontSize: 20),
                          decoration: new InputDecoration.collapsed(
                              hintText: languages.commentTipLabel),
                          onChanged: (text) => setState(() {})),
                    ),
                    actions: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: CupertinoColors.systemYellow,
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _commentController.clear();
                          },
                          child: Text(
                            languages.closeLabel,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: CupertinoColors.systemYellow,
                        ),
                        child: TextButton(
                          onPressed: () {
                            _addCommentToList(setInnerState, parentComment);
                          },
                          child: Text(
                            languages.addCommentLabel,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  );
          });
        });
  }

  void _addCommentToList(setInnerState, Comment? parentComment) {
    setInnerState(() {
      loading = true;
    });
    if (ProfanityChecker.alert(_commentController.text)) {
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(
          msg: languages.profanityWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      if (_commentController.text != '') {
        dynamic body = <String, String?>{
          'text': _commentController.text,
          'parentCommentId':
              parentComment == null ? null : parentComment.commentId.toString(),
        };
        widget.session
            .postJson(
          '/api/posts/' + widget.postId.toString() + '/comments',
          body,
        )
            .then((response) {
          if (response.statusCode == 200) {
            Comment comment =
            Comment.fromJson(json.decode(utf8.decode(response.bodyBytes)));
            Navigator.of(context).pop();
              if (parentComment == null) {
                comments.insert(0, comment);
              } else if(parentComment.depthInTree == 2){
                parentComment.parentComment!.childComments.insert(0, comment);
              }else {
                parentComment.childComments.insert(0, comment);
              }
              loading = false;
              _commentController.clear();
            widget.setMainState(() {
              widget.post.commentNumber++;
            });
            Fluttertoast.showToast(
                msg: languages.commentAddedMessage,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 4,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
          } else {
            setInnerState(() {
              loading = false;
            });
            Fluttertoast.showToast(
                msg: languages.globalErrorMessage,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 4,
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
            msg: languages.emptyCommentWarningMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
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

  void onReportTap(Comment comment) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return innerLoading
                ? Container(
                    child: Center(
                      child: Image(
                          image: new AssetImage(
                              "assets/images/loading_breath.gif")),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: CupertinoColors.systemYellow,
                    title: Text(
                      languages.reportUserAndCommentTitleLabel,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          color: Colors.black,
                          padding: EdgeInsets.all(2),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.only(left: 20.0),
                              color: CupertinoColors.systemYellow.withOpacity(0.7),
                              child: TextField(
                                style: TextStyle(color: Colors.black),
                                controller: _reportReasonTextFieldController,
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  hintText: languages.reportReasonHintLabel,
                                  hintStyle: TextStyle(
                                      color: Colors.black.withOpacity(0.5)),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _reportReasonTextFieldController.clear();
                        },
                        child: Text(
                          languages.cancelLabel,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _onSendReportTap(
                              comment.commentId, context, setState);
                          setState(() {
                            innerLoading = true;
                          });
                        },
                        child: Text(
                          languages.sendLabel,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  );
          });
        });
  }

  void _onSendReportTap(int commentId, context, setState) {
    dynamic data = <String, dynamic>{
      'reason': _reportReasonTextFieldController.text,
    };
    widget.session
        .postJson('/api/comments/$commentId/report', data)
        .then((response) {
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        _reportReasonTextFieldController.clear();
        innerLoading = false;
        Fluttertoast.showToast(
            msg: languages.successfulReportMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (response.statusCode == 500) {
        if (response.body != null &&
            json.decode(response.body)['message'] != null &&
            json.decode(response.body)['message'] ==
                'Comment is already reported!') {
          Fluttertoast.showToast(
              msg: languages.alreadyReportedCommentMessage,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 4,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: languages.globalErrorMessage,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 4,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
        setState(() {
          innerLoading = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: languages.globalServerErrorMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          innerLoading = false;
        });
      }
    });
  }

  Future<bool> _onLikeOwnButtonPressed() {
    Fluttertoast.showToast(
        msg: languages.likeOwnCommentWarningMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 4,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    return Future.value(false);
  }

  void _onBanUserTap(int creatorId) {
    if (creatorId == widget.user.userId) {
      Fluttertoast.showToast(
          msg: languages.banOwnAccountWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setInnerState) {
              return innerLoading
                  ? Container(
                      child: Center(
                        child: Image(
                            image: new AssetImage(
                                "assets/images/loading_breath.gif")),
                      ),
                    )
                  : AlertDialog(
                      backgroundColor: CupertinoColors.systemYellow,
                      title: Text(
                        languages.banCommenterConfirmQuestionLabel,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            languages.cancelLabel,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            innerLoading = true;
                            widget.session
                                .postJson(
                                    '/api/users/banUser/$creatorId', Map())
                                .then((response) {
                              setInnerState(() {
                                innerLoading = false;
                              });
                              if (response.statusCode == 200) {
                                Navigator.of(context).pop();
                                Fluttertoast.showToast(
                                    msg: languages.successfulBanMessage,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 4,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              } else {
                                Fluttertoast.showToast(
                                    msg: languages.globalServerErrorMessage,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 4,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            });
                          },
                          child: Text(
                            languages.banLabel,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    );
            });
          });
    }
  }

  Widget _recursiveCommentTreeWidget(Comment parentComment) {
    parentComment.childComments.forEach((cc) => cc.parentComment = parentComment);
    return commentTree.CommentTreeWidget<commentTree.Comment, dynamic>(
      commentTree.Comment(
          avatar: 'null',
          userName: parentComment.userName,
          content: parentComment.text),
      parentComment.childComments,
      treeThemeData: commentTree.TreeThemeData(
          lineColor: CupertinoColors.systemYellow, lineWidth: 3),
      avatarRoot: (context, comment) => PreferredSize(
        child: Icon(
          Icons.comment,
          color: CupertinoColors.systemYellow,
        ),
        preferredSize: Size.fromRadius(18),
      ),
      avatarChild: (context, data) =>
          PreferredSize(child: Container(), preferredSize: Size.zero),
      contentChild: (context, comment) {
        return _recursiveCommentTreeWidget(comment);
      },
      contentRoot: (context, comment) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints:
                  BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (comment.userName == null || parentComment.deleted
                              ? languages.removedLabel
                              : comment.userName!) +
                          ' · ' +
                          DateFormatter.formatDate(
                              parentComment.createdDate, languages),
                      style: Theme.of(context).textTheme.caption!.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      comment.content == null || parentComment.deleted
                          ? languages.removedLabel
                          : comment.content!,
                      style: Theme.of(context).textTheme.caption!.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 8,
                ),
                Container(
                  child: PopupMenuButton(
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                      ),
                      itemBuilder: (context) {
                        return List.generate(2, (index) {
                          if (index == 0) {
                            return PopupMenuItem(
                              child: Text(
                                  parentComment.userId == widget.user.userId
                                      ? languages.deleteLabel
                                      : languages.reportLabel),
                              value: 0,
                            );
                          } else {
                            return PopupMenuItem(
                              child: Text(languages.banUserLabel),
                              value: 1,
                            );
                          }
                        });
                      },
                      onSelected: (index) {
                        if (index == 0) {
                          if (parentComment.userId == widget.user.userId) {
                            widget.session
                                .delete('/api/comments/' +
                                    parentComment.commentId.toString())
                                .then((response) {
                              if (response.statusCode == 200) {
                                Fluttertoast.showToast(
                                    msg: languages.successfulDeleteMessage,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 4,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                widget.setMainState(() {
                                  widget.post.commentNumber--;
                                });
                                _initCommentData();
                              } else {
                                Fluttertoast.showToast(
                                    msg: languages.globalServerErrorMessage,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 4,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            });
                          } else {
                            onReportTap(parentComment);
                          }
                        } else {
                          _onBanUserTap(parentComment.userId);
                        }
                      }),
                ),
                SizedBox(
                  width: 24,
                ),
                InkWell(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.reply,
                        color: parentComment.depthInTree == 3
                            ? Colors.grey[700]
                            : Colors.white,
                        size: 17,
                      ),
                      Text(
                        languages.replyLabel +
                            (parentComment.childComments.length == 0
                                ? ''
                                : ' (${parentComment.childComments.length})'),
                        style: TextStyle(
                          color: parentComment.depthInTree == 3
                              ? Colors.grey[700]
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (parentComment.depthInTree == 3) {
                      Fluttertoast.showToast(
                          msg: languages.tooDeepToDisplayMessage,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 4,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else {
                      _addComment(parentComment);
                    }
                  },
                ),
                SizedBox(
                  width: 24,
                ),
                LikeButton(
                  size: 20.0,
                  circleColor: CircleColor(
                      start: Colors.yellow.shade200, end: CupertinoColors.systemYellow),
                  bubblesColor: BubblesColor(
                    dotPrimaryColor: Colors.yellow.shade200,
                    dotSecondaryColor: CupertinoColors.systemYellow,
                  ),
                  isLiked: parentComment.liked,
                  likeBuilder: (bool isLiked) {
                    return Icon(
                      Icons.lightbulb,
                      size: 20,
                      color: isLiked ? CupertinoColors.systemYellow : Colors.white,
                    );
                  },
                  onTap: (isLiked) {
                    return parentComment.userId == widget.user.userId
                        ? _onLikeOwnButtonPressed()
                        : _onLikeButton(isLiked, parentComment);
                  },
                  likeCount: parentComment.likeNumber,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _reportReasonTextFieldController.dispose();
    super.dispose();
  }

  Future<void> _initCommentData() async {
    await widget.session
        .get('/api/posts/' + widget.postId.toString() + '/comments')
        .then((response) {
      if (response.statusCode == 200) {
        setState(() {
          Iterable l = json.decode(utf8.decode(response.bodyBytes));
          comments =
              List<Comment>.from(l.map((model) => Comment.fromJson(model)));
          loading = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: languages.globalErrorMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          loading = false;
        });
      }
    });
  }
}
