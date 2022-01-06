import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/company.dart';
import 'package:flutter_frontend/entities/post.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/widgets/single_post_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';

import 'comments_widget.dart';

class FilteredPostsWidget extends StatefulWidget {
  final Session session;
  final String pattern;
  final User user;

  const FilteredPostsWidget({required this.session, required this.pattern, required this.user});

  @override
  _FilteredPostsWidgetState createState() => _FilteredPostsWidgetState();
}

class _FilteredPostsWidgetState extends State<FilteredPostsWidget> {
  late List<Post> posts = [];
  late List<Post> actualPosts = [];
  final ScrollController _scrollController = ScrollController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !loading) {
        _loadNew();
      }
    });
    widget.session
        .get('/api/posts/filtered/' + widget.pattern)
        .then((response) {
      if (response.statusCode == 200) {
        setState(() {
          widget.session.updateCookie(response);
          Iterable l = json.decode(utf8.decode(response.bodyBytes));
          posts = List<Post>.from(l.map((model) => Post.fromJson(model)));
          actualPosts = posts.sublist(0, posts.length < 10 ? posts.length : 10);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: true,
        title: Center(
          child: Text(
            widget.pattern,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: actualPosts.isNotEmpty
            ? Stack(
                children: [
                  ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.only(bottom: 10),
                      separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey.shade900,
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
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage( widget.session.domainName +
                                      "/api/images/" +
                                          post.companyId.toString(),
                                      headers: widget.session.headers,
                                    ),
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
                                                    msg:
                                                        "This idea is implemented!",
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
                                        _formatDate(post.createdDate),
                                        style: TextStyle(color: Colors.white),
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
                                    post.postType == 'SIMPLE_POST' ? post.description : 'Click here to open the poll!',
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
                                          return _onLikeButton(isLiked, index);
                                        },
                                        likeCount: post.likeNumber,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            post.commentNumber.toString(),
                                            style:
                                                TextStyle(color: Colors.white),
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
                                                              postId: post
                                                                  .postId,
                                                          user: widget.user,)));
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
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              )
            : Container(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.yellow,),
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
                  backgroundColor: Colors.black,
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage( widget.session.domainName +
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
                        child: Text('Close')),
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
              post: actualPosts.elementAt(index), session: widget.session, user: widget.user)),
    ).whenComplete(() => {
          widget.session
              .get('/api/posts/' +
                  actualPosts[index].postId.toString())
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
}
