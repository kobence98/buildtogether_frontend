import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/company.dart';
import 'package:flutter_frontend/entities/post.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/static/date_formatter.dart';
import 'package:flutter_frontend/widgets/single_post_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';

import 'comments_widget.dart';

class LikedPostsWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;

  const LikedPostsWidget(
      {required this.session,
        required this.user,
        required this.languages});

  @override
  _LikedPostsWidgetState createState() => _LikedPostsWidgetState();
}

class _LikedPostsWidgetState extends State<LikedPostsWidget> {
  late List<Post> posts = [];
  late List<Post> actualPosts = [];
  final ScrollController _scrollController = ScrollController();
  bool loading = false;
  late bool dataLoading;
  late Languages languages;

  bool innerLoading = false;
  final TextEditingController _reportReasonTextFieldController =
  TextEditingController();
  final TextEditingController _couponCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent &&
          !loading) {
        _loadNew();
      }
    });
    dataLoading = true;
    widget.session
        .get('/api/posts/liked')
        .then((response) {
      if (response.statusCode == 200) {
        setState(() {
          widget.session.updateCookie(response);
          Iterable l = json.decode(utf8.decode(response.bodyBytes));
          posts = List<Post>.from(l.map((model) => Post.fromJson(model)));
          actualPosts = posts.sublist(0, posts.length < 10 ? posts.length : 10);
          dataLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: true,
          title: Center(
            child: Text(
              languages.likedPostsLabel,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ),
        body: Container(
          color: Colors.black,
          child: dataLoading
              ? Container(
            child: Center(
              child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
            ),
          )
              : actualPosts.isEmpty ? Container(
            child: Center(
              child: Text(
                languages.noPostWithFilters,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ) : Stack(
            children: [
              ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.only(bottom: 10),
                  separatorBuilder: (context, index) => Divider(
                    height: 5,
                    color: Colors.grey.shade700,
                  ),
                  itemCount: actualPosts.length,
                  itemBuilder: (context, index) {
                    Post post = actualPosts.elementAt(index);
                    return InkWell(
                      child: Container(
                        color: Colors.black,
                        child: Column(
                          children: [
                            ListTile(
                              leading: InkWell(
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                    widget.session.domainName +
                                        "/api/images/" +
                                        post.companyImageId.toString(),
                                    headers: widget.session.headers,
                                  ),
                                ),
                                onTap: () => _onCompanyTap(post.companyId),
                              ),
                              title: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.userName,
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Text(
                                        post.companyName,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    onTap: () {
                                      _onCompanyTap(post.companyId);
                                    },
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  post.implemented
                                      ? InkWell(
                                    child: Icon(
                                      Icons.lightbulb_outline_sharp,
                                      color: Colors.yellow,
                                    ),
                                    onTap: () {
                                      Fluttertoast.showToast(
                                          msg: languages
                                              .ideaIsImplementedMessage,
                                          toastLength:
                                          Toast.LENGTH_SHORT,
                                          gravity:
                                          ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor:
                                          Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    },
                                  )
                                      : Container(),
                                  Text(
                                    DateFormatter.formatDate(
                                        post.createdDate, languages),
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
                                            widget.user.companyId ==
                                                post.companyId
                                                ? 4
                                                : 2, (index) {
                                          if (index == 0) {
                                            return PopupMenuItem(
                                              child: Text(widget.user
                                                  .companyId ==
                                                  post
                                                      .companyId ||
                                                  widget.user
                                                      .userId ==
                                                      post.creatorId
                                                  ? languages.deleteLabel
                                                  : languages
                                                  .reportLabel),
                                              value: 0,
                                            );
                                          } else if (index == 1) {
                                            return PopupMenuItem(
                                              child: Text(languages
                                                  .banUserLabel),
                                              value: 1,
                                            );
                                          } else if (index == 2) {
                                            return PopupMenuItem(
                                              child: Text(languages
                                                  .contactCreatorLabel),
                                              value: 2,
                                            );
                                          } else {
                                            return PopupMenuItem(
                                              child: Text(post.implemented
                                                  ? languages
                                                  .notImplementedLabel
                                                  : languages
                                                  .implementedLabel),
                                              value: 3,
                                            );
                                          }
                                        });
                                      },
                                      onSelected: (index) {
                                        if (index == 0) {
                                          if (widget.user.companyId ==
                                              post.companyId ||
                                              widget.user.userId ==
                                                  post.creatorId) {
                                            widget.session
                                                .delete('/api/posts/' +
                                                post.postId
                                                    .toString())
                                                .then((response) {
                                              if (response.statusCode ==
                                                  200) {
                                                Fluttertoast.showToast(
                                                    msg: languages
                                                        .successfulDeleteMessage,
                                                    toastLength:
                                                    Toast.LENGTH_LONG,
                                                    gravity: ToastGravity
                                                        .CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                    Colors.green,
                                                    textColor:
                                                    Colors.white,
                                                    fontSize: 16.0);
                                                setState(() {
                                                  Navigator.of(context)
                                                      .pop();
                                                });
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg: languages
                                                        .globalServerErrorMessage,
                                                    toastLength:
                                                    Toast.LENGTH_LONG,
                                                    gravity: ToastGravity
                                                        .CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                    Colors.red,
                                                    textColor:
                                                    Colors.white,
                                                    fontSize: 16.0);
                                              }
                                            });
                                          } else {
                                            onReportTap(post);
                                          }
                                        } else if (index == 1) {
                                          _onBanUserTap(post.creatorId);
                                        } else if (index == 2) {
                                          _onContactCreatorTap(post);
                                        } else {
                                          widget.session
                                              .post(
                                              '/api/posts/' +
                                                  post.postId
                                                      .toString() +
                                                  '/implemented',
                                              Map<String, dynamic>())
                                              .then((response) {
                                            if (response.statusCode ==
                                                200) {
                                              Fluttertoast.showToast(
                                                  msg:
                                                  "${languages.successLabel}!",
                                                  toastLength:
                                                  Toast.LENGTH_LONG,
                                                  gravity:
                                                  ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                  Colors.green,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0);
                                              setState(() {
                                                post.implemented =
                                                !post.implemented;
                                              });
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: languages
                                                      .globalServerErrorMessage,
                                                  toastLength:
                                                  Toast.LENGTH_LONG,
                                                  gravity:
                                                  ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor:
                                                  Colors.red,
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
                                post.title,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                            Container(
                              height: 60,
                              padding: EdgeInsets.all(5),
                              alignment: Alignment.topLeft,
                              child: Text(
                                post.postType == 'SIMPLE_POST'
                                    ? post.description
                                    : languages
                                    .clickHereToOpenThePollLabel,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Container(
                              height: 40,
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  LikeButton(
                                    size: 20.0,
                                    circleColor: CircleColor(
                                        start: Colors.yellow.shade200,
                                        end: Colors.yellow),
                                    bubblesColor: BubblesColor(
                                      dotPrimaryColor:
                                      Colors.yellow.shade200,
                                      dotSecondaryColor: Colors.yellow,
                                    ),
                                    isLiked: post.liked,
                                    likeBuilder: (bool isLiked) {
                                      return Icon(
                                        Icons.lightbulb,
                                        color: isLiked
                                            ? Colors.yellow
                                            : Colors.white,
                                      );
                                    },
                                    onTap: (isLiked) {
                                      return post.creatorId ==
                                          widget.user.userId
                                          ? _onLikeOwnButtonPressed()
                                          : _onLikeButton(isLiked, index);
                                    },
                                    likeCount: post.likeNumber,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        post.commentNumber.toString(),
                                        style: TextStyle(
                                            color: Colors.white),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.comment),
                                        color: Colors.white,
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CommentsWidget(
                                                        session: widget
                                                            .session,
                                                        postId:
                                                        post.postId,
                                                        user: widget.user,
                                                        languages:
                                                        languages,
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
                      onTap: () {
                        _onPostTap(index);
                      },
                    );
                  }),
              loading
                  ? Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 80,
                  height: 80,
                  child: Center(
                    child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
                  ),
                ),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void _loadNew() async {
    if (posts.length == actualPosts.length) {
      return;
    }
    setState(() {
      loading = true;
    });
    await Future.delayed(Duration(milliseconds: 500));
    actualPosts.addAll(posts.getRange(
        actualPosts.length,
        actualPosts.length + 10 >= posts.length
            ? posts.length
            : actualPosts.length + 10));
    setState(() {
      loading = false;
    });
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
                        child: Text(
                          languages.closeLabel,
                          style: TextStyle(color: Colors.yellow),
                        )),
                  ],
                );
              });
        });
      }
    });
  }

  Future<bool> _onLikeButton(bool isLiked, int index) async {
    dynamic response = await widget.session.post(
        "/api/posts/" +
            actualPosts.elementAt(index).postId.toString() +
            "/like",
        new Map<String, dynamic>());
    if (response.statusCode == 200) {
      actualPosts[index].liked = !actualPosts[index].liked;
      if (actualPosts[index].liked) {
        actualPosts[index].likeNumber++;
      } else {
        actualPosts[index].likeNumber--;
      }
      return !isLiked;
    } else {
      return isLiked;
    }
  }

  void _onPostTap(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SinglePostWidget(
            post: actualPosts.elementAt(index),
            session: widget.session,
            user: widget.user,
            languages: languages,
          )),
    ).whenComplete(() => {
      widget.session
          .get('/api/posts/' + actualPosts[index].postId.toString())
          .then((response) {
        if (response.statusCode == 200) {
          setState(() {
            actualPosts[index] =
                Post.fromJson(json.decode(utf8.decode(response.bodyBytes)));
          });
        }
      })
    });
  }

  void onReportTap(Post post) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return innerLoading
                ? Container(
              child: Center(
                child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
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
                child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
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
                                borderSide: BorderSide.none),
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

  void _onBanUserTap(int creatorId) {
    if(creatorId == widget.user.userId){
      Fluttertoast.showToast(
          msg: languages.banOwnAccountWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    else{
      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setInnerState) {
              return innerLoading
                  ? Container(
                child: Center(
                  child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
                ),
              )
                  : AlertDialog(
                backgroundColor: Colors.yellow,
                title: Text(
                  languages.banCreatorConfirmQuestionLabel,
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
                      widget.session.postJson('/api/users/banUser/$creatorId', Map()).then((response) {
                        setInnerState((){
                          innerLoading = false;
                        });
                        if (response.statusCode == 200) {
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                              msg: languages.successfulBanMessage,
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
}
