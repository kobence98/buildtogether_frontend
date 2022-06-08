import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/company.dart';
import 'package:flutter_frontend/entities/poll_option.dart';
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

  bool innerLoading = false;
  final TextEditingController _reportReasonTextFieldController =
      TextEditingController();
  final TextEditingController _couponCodeController = TextEditingController();
  late bool voted;

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
  }

  @override
  Widget build(BuildContext context) {
    voted = widget.post.pollOptions.any((element) => element.liked);
    return SafeArea(
      child: Scaffold(
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
                        Container(
                          margin: EdgeInsets.only(left: 5),
                          child: PopupMenuButton(
                            child: Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                            ),
                            itemBuilder: (context) {
                              return List.generate(
                                  widget.user.companyId == widget.post.companyId
                                      ? 3
                                      : 1, (index) {
                                if (index == 0) {
                                  return PopupMenuItem(
                                    child: Text(widget.user.companyId ==
                                                widget.post.companyId ||
                                            widget.user.userId ==
                                                widget.post.creatorId
                                        ? languages.deleteLabel
                                        : languages.reportLabel),
                                    value: 0,
                                  );
                                } else if (index == 1) {
                                  return PopupMenuItem(
                                    child: Text(languages.contactCreatorLabel),
                                    value: 1,
                                  );
                                } else {
                                  return PopupMenuItem(
                                    child: Text(widget.post.implemented
                                        ? languages.notImplementedLabel
                                        : languages.implementedLabel),
                                    value: 2,
                                  );
                                }
                              });
                            },
                            onSelected: (index) {
                              if (index == 0) {
                                if (widget.user.companyId ==
                                        widget.post.companyId ||
                                    widget.user.userId ==
                                        widget.post.creatorId) {
                                  widget.session
                                      .delete('/api/posts/' +
                                          widget.post.postId.toString())
                                      .then((response) {
                                    if (response.statusCode == 200) {
                                      Fluttertoast.showToast(
                                          msg:
                                              languages.successfulDeleteMessage,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                      setState(() {
                                        Navigator.of(context).pop();
                                      });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: languages
                                              .globalServerErrorMessage,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }
                                  });
                                } else {
                                  onReportTap(widget.post);
                                }
                              } else if (index == 1) {
                                _onContactCreatorTap(widget.post);
                              } else {
                                widget.session
                                    .post(
                                        '/api/posts/' +
                                            widget.post.postId.toString() +
                                            '/implemented',
                                        Map<String, dynamic>())
                                    .then((response) {
                                  if (response.statusCode == 200) {
                                    Fluttertoast.showToast(
                                        msg: "${languages.successLabel}!",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    setState(() {
                                      widget.post.implemented =
                                          !widget.post.implemented;
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: languages.globalServerErrorMessage,
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
                                });
                              }
                            },
                          ),
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
                              start: Colors.yellow.shade200,
                              end: Colors.yellow),
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
                            return widget.post.creatorId == widget.user.userId
                                ? _onLikeOwnButtonPressed()
                                : _onLikeButton(isLiked);
                          },
                          likeCount: widget.post.likeNumber,
                        ),
                        voted ? InkWell(
                          child: Text(
                            'Remove my vote',
                            style: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic),
                          ),
                          onTap: _onRemovePollVote,
                        ) : Container(),
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
                  backgroundColor: Colors.grey[900],
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
                        child: Text(languages.closeLabel, style: TextStyle(color: Colors.yellow),)),
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

    for(PollOption option in post.pollOptions){
      polls.add(
        Polls.options(
            title: "${option.title!}",
            // + (voted ? ' (${option.likeNumber})' : '') --> ha valahogyan meg lehetne oldani hogy ezt megjelenítse
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
    }
    return Polls(
      children: polls,
      question: Text(
        '${languages.numberOfVotesLabel}: ${post.pollOptions.map((e) => e.likeNumber).reduce((a, b) => a + b)}',
        style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
      ),
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

  void onReportTap(Post post) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return innerLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.yellow,
                      ),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: Colors.yellow,
                    title: Text(
                      languages.reportUserAndPostTitleLabel,
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
                              color: Colors.yellow.withOpacity(0.7),
                              child: TextField(
                                style: TextStyle(color: Colors.black),
                                maxLength: 256,
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
                          _onSendReportTap(post.postId, context, setState);
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

  void _onSendReportTap(int postId, context, setState) {
    dynamic data = <String, dynamic>{
      'reason': _reportReasonTextFieldController.text,
    };
    widget.session.postJson('/api/posts/$postId/report', data).then((response) {
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        _reportReasonTextFieldController.clear();
        Fluttertoast.showToast(
            msg: languages.successfulReportMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (response.statusCode == 500) {
        if (response.body != null &&
            json.decode(response.body)['message'] != null &&
            json.decode(response.body)['message'] ==
                'Post is already reported!') {
          Fluttertoast.showToast(
              msg: languages.alreadyReportedPostMessage,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
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
      } else {
        Fluttertoast.showToast(
            msg: languages.globalServerErrorMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      setState(() {
        innerLoading = false;
      });
    });
  }

  void _onContactCreatorTap(Post post) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return innerLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.yellow,
                      ),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: Colors.yellow,
                    title: Text(
                      languages.thisIsTheContactEmailLabel,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: Center(
                            child: Text(
                              post.creatorEmail,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: Colors.black,
                          ),
                          padding: EdgeInsets.all(2),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.only(left: 20.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: Colors.yellow.withOpacity(0.7),
                              ),
                              child: TextField(
                                style: TextStyle(color: Colors.black),
                                controller: _couponCodeController,
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none
                                  ),
                                  hintText: languages.couponCodeLabel,
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
                          _couponCodeController.clear();
                        },
                        child: Text(
                          languages.cancelLabel,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _onSendCouponEmailTap(post.postId, context, setState);
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

  void _onSendCouponEmailTap(int postId, context, setOutterState) {
    if (_couponCodeController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: languages.fillAllFieldsWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      dynamic body = <String, dynamic>{
        'couponCode': _couponCodeController.text,
      };
      widget.session
          .postJson(
        '/api/posts/${postId.toString()}/sendCouponToCreator',
        body,
      )
          .then((response) {
        if (response.statusCode == 200) {
          Navigator.of(context).pop();
          _couponCodeController.clear();
          Fluttertoast.showToast(
              msg: languages.successfulCouponSendMessage,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: languages.globalServerErrorMessage,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
        setOutterState(() {
          innerLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _couponCodeController.dispose();
    _reportReasonTextFieldController.dispose();
    super.dispose();
  }

  Future<bool> _onLikeOwnButtonPressed() {
    Fluttertoast.showToast(
        msg: languages.likeOwnPostWarningMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    return Future.value(false);
  }

  _onRemovePollVote() {
    Post post = widget.post;
    widget.session
        .delete(
        '/api/posts/' +
            post.postId.toString() +
            '/pollVote')
        .then((response) {
      if (response.statusCode == 200) {
        setState(() {
          post.pollOptions.where((element) => element.liked).first.likeNumber--;
          post.pollOptions.forEach((option) {
            option.liked = false;
          });
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
  }
}
