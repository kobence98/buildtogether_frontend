import 'dart:convert';

import 'package:country_codes/country_codes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_frontend/entities/company.dart';
import 'package:flutter_frontend/entities/post.dart';
import 'package:flutter_frontend/entities/search_field_names.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/widgets/single_post_widget.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'comments_widget.dart';
import 'filtered_posts_widget.dart';

class PostsWidget extends StatefulWidget {
  final Session session;
  final User user;
  final int initPage;

  const PostsWidget(
      {required this.session, required this.user, required this.initPage});

  @override
  _PostsWidgetState createState() => _PostsWidgetState();
}

class _PostsWidgetState extends State<PostsWidget> {
  late List<Post> actualNewPosts = [];
  late List<Post> actualBestPosts = [];
  late List<Post> actualOwnPosts = [];
  late List<Post> newPosts = [];
  late List<Post> bestPosts = [];
  late List<Post> ownPosts = [];
  final ScrollController _newScrollController = ScrollController();
  final ScrollController _bestScrollController = ScrollController();
  final ScrollController _ownScrollController = ScrollController();
  final TextEditingController _searchFieldController = TextEditingController();
  bool loading = false;
  RefreshController _refreshNewController =
      RefreshController(initialRefresh: false);
  RefreshController _refreshBestController =
      RefreshController(initialRefresh: false);
  RefreshController _refreshOwnController =
      RefreshController(initialRefresh: false);
  List<SearchFieldNames> names = [];
  String? country;
  bool loadedPosts = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _newScrollController.dispose();
    _bestScrollController.dispose();
    _ownScrollController.dispose();
    _refreshNewController.dispose();
    _refreshBestController.dispose();
    _refreshOwnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initPage,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: Container(
            height: 40,
            padding: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Flexible(
                  child: TypeAheadField(
                    noItemsFoundBuilder: (context) {
                      return Container(
                        padding: EdgeInsets.all(1),
                        color: Colors.yellow,
                        child: Container(
                          color: Colors.black,
                          child: ListTile(
                            leading: Icon(
                              Icons.not_interested_rounded,
                              color: Colors.yellow,
                            ),
                            title: Text(
                              'No items found!',
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration:
                          new InputDecoration.collapsed(hintText: 'Search'),
                      controller: _searchFieldController,
                      cursorColor: Colors.black,
                      autofocus: false,
                      style: TextStyle(fontSize: 20),
                      onEditingComplete: _onSearchButtonPressed,
                    ),
                    suggestionsCallback: (pattern) async {
                      dynamic response = await widget.session
                          .get("/api/searchField/" + pattern);
                      if (response.statusCode == 200) {
                        widget.session.updateCookie(response);
                        Iterable l =
                            json.decode(utf8.decode(response.bodyBytes));
                        names = List<SearchFieldNames>.from(
                            l.map((name) => SearchFieldNames.fromJson(name)));
                        List<String> resultList = [];
                        names.forEach((name) {
                          if (name.id != null) {
                            resultList.add(name.id.toString());
                          } else {
                            resultList.add(name.name);
                          }
                        });
                        return resultList;
                      }
                      return [];
                    },
                    itemBuilder: (context, n) {
                      SearchFieldNames? name;
                      if (names
                          .where((nm) => nm.id.toString() == n)
                          .isNotEmpty) {
                        name = names.where((nm) => nm.id.toString() == n).first;
                      }
                      return Container(
                        padding: EdgeInsets.all(1),
                        color: Colors.yellow,
                        child: Container(
                          color: Colors.black,
                          child: ListTile(
                            leading: name != null
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(
                                      widget.session.domainName +
                                          "/api/images/" +
                                          name.imageId.toString(),
                                      headers: widget.session.headers,
                                    ),
                                  )
                                : Icon(
                                    Icons.lightbulb_outline_sharp,
                                    color: Colors.yellow,
                                  ),
                            title: Text(
                              name == null ? n.toString() : name.name,
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    },
                    onSuggestionSelected: (n) {
                      String name;
                      if (names
                          .where((nm) => nm.id.toString() == n)
                          .isNotEmpty) {
                        name = names
                            .where((nm) => nm.id.toString() == n)
                            .first
                            .name;
                      } else {
                        name = n.toString();
                      }
                      _searchFieldController.text = name.toString();
                      _onSearchButtonPressed();
                    },
                  ),
                  flex: 8,
                ),
                Flexible(
                  child: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    onPressed: _onSearchButtonPressed,
                  ),
                  flex: 1,
                ),
              ],
            ),
          ),
          bottom: TabBar(
              labelColor: Colors.yellow,
              indicatorColor: Colors.yellow,
              tabs: [
                Tab(
                  child: Text(
                    'New',
                    style: TextStyle(color: Colors.yellow),
                  ),
                ),
                Tab(
                  child: Text(
                    'Best',
                    style: TextStyle(color: Colors.yellow),
                  ),
                ),
                Tab(
                  child: Text(
                    'Own',
                    style: TextStyle(color: Colors.yellow),
                  ),
                ),
              ]),
        ),
        body: TabBarView(children: [
          _postsWidget(1),
          _postsWidget(2),
          _postsWidget(3),
        ]),
      ),
    );
  }

  Widget _postsWidget(int pageNumber) {
    List<Post> actualPosts = [];
    ScrollController _scrollController;
    RefreshController _refreshController;

    if (pageNumber == 1) {
      actualPosts = actualNewPosts;
      _scrollController = _newScrollController;
      _refreshController = _refreshNewController;
    } else if (pageNumber == 2) {
      actualPosts = actualBestPosts;
      _scrollController = _bestScrollController;
      _refreshController = _refreshBestController;
    } else {
      actualPosts = actualOwnPosts;
      _scrollController = _ownScrollController;
      _refreshController = _refreshOwnController;
    }
    return Container(
      color: Colors.black,
      child: loadedPosts
          ? Stack(
              children: [
                SmartRefresher(
                  controller: _refreshController,
                  onRefresh: () {
                    _loadData();
                  },
                  header: WaterDropHeader(),
                  child: actualPosts.isNotEmpty
                      ? ListView.separated(
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
                                        backgroundImage: NetworkImage(
                                          widget.session.domainName +
                                              "/api/images/" +
                                              post.companyImageId.toString(),
                                          headers: widget.session.headers,
                                        ),
                                      ),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post.userName,
                                            style:
                                                TextStyle(color: Colors.white),
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
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                              child: Text(
                                                post.companyName,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                    Icons
                                                        .lightbulb_outline_sharp,
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
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          pageNumber == 3
                                              ? Container(
                                                  margin:
                                                      EdgeInsets.only(left: 5),
                                                  child: PopupMenuButton(
                                                    child: Icon(
                                                      Icons.more_horiz,
                                                      color: Colors.white,
                                                    ),
                                                    itemBuilder: (context) {
                                                      return List.generate(
                                                          widget.user.roles
                                                                  .contains(
                                                                      'ROLE_COMPANY')
                                                              ? 2
                                                              : 1, (index) {
                                                        if (index == 0) {
                                                          return PopupMenuItem(
                                                            child:
                                                                Text('Delete'),
                                                            value: 0,
                                                          );
                                                        } else {
                                                          return PopupMenuItem(
                                                            child: Text(post
                                                                    .implemented
                                                                ? 'Not implemented'
                                                                : 'Implemented'),
                                                            value: 1,
                                                          );
                                                        }
                                                      });
                                                    },
                                                    onSelected: (index) {
                                                      if (index == 0) {
                                                        widget.session
                                                            .delete('/api/posts/' +
                                                                post.postId
                                                                    .toString())
                                                            .then((response) {
                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Successful delete!",
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                            setState(() {
                                                              actualNewPosts
                                                                  .remove(post);
                                                              actualBestPosts
                                                                  .remove(post);
                                                              actualOwnPosts
                                                                  .remove(post);
                                                            });
                                                          } else {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Something went wrong!",
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                          }
                                                        });
                                                      } else {
                                                        widget.session
                                                            .post(
                                                                '/api/posts/' +
                                                                    post.postId
                                                                        .toString() +
                                                                    '/implemented',
                                                                Map<String,
                                                                    dynamic>())
                                                            .then((response) {
                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                            Fluttertoast.showToast(
                                                                msg: "Success!",
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                            setState(() {
                                                              bool imp = !post
                                                                  .implemented;
                                                              if (actualNewPosts
                                                                  .where((p) {
                                                                return p.postId ==
                                                                    post.postId;
                                                              }).isNotEmpty) {
                                                                actualNewPosts
                                                                    .where((p) {
                                                                      return p.postId ==
                                                                          post.postId;
                                                                    })
                                                                    .first
                                                                    .implemented = imp;
                                                              }
                                                              if (actualBestPosts
                                                                  .where((p) {
                                                                return p.postId ==
                                                                    post.postId;
                                                              }).isNotEmpty) {
                                                                actualBestPosts
                                                                    .where((p) {
                                                                      return p.postId ==
                                                                          post.postId;
                                                                    })
                                                                    .first
                                                                    .implemented = imp;
                                                              }
                                                              if (actualOwnPosts
                                                                  .where((p) {
                                                                return p.postId ==
                                                                    post.postId;
                                                              }).isNotEmpty) {
                                                                actualOwnPosts
                                                                    .where((p) {
                                                                      return p.postId ==
                                                                          post.postId;
                                                                    })
                                                                    .first
                                                                    .implemented = imp;
                                                              }
                                                            });
                                                          } else {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Something went wrong!",
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                          }
                                                        });
                                                      }
                                                    },
                                                  ),
                                                )
                                              : Container(),
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
                                            : 'Click here to open the poll!',
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
                                              return _onLikeButton(
                                                  isLiked, index, pageNumber);
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
                                                                  postId: post
                                                                      .postId,
                                                                  user: widget
                                                                      .user)));
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
                                _onPostTap(index, pageNumber);
                              },
                            );
                          })
                      : Container(
                          child: Center(
                            child: Text(
                              'There is no post in your area, please check your location settings or pull down to refresh!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                ),
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
    );
  }

  void _loadNew(int i) async {
    late List<Post> actualPosts = [];
    late List<Post> posts = [];
    if (i == 1) {
      actualPosts = actualNewPosts;
      posts = newPosts;
    } else if (i == 2) {
      actualPosts = actualBestPosts;
      posts = bestPosts;
    } else if (i == 3) {
      actualPosts = actualOwnPosts;
      posts = ownPosts;
    }
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
                        child: Text('Close')),
                  ],
                );
              });
        });
      }
    });
  }

  Future<bool> _onLikeButton(bool isLiked, int index, int i) async {
    late List<Post> actualPosts = [];
    if (i == 1) {
      actualPosts = actualNewPosts;
    } else if (i == 2) {
      actualPosts = actualBestPosts;
    } else if (i == 3) {
      actualPosts = actualOwnPosts;
    }
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

  void _onPostTap(int index, int i) {
    late List<Post> actualPosts = [];
    if (i == 1) {
      actualPosts = actualNewPosts;
    } else if (i == 2) {
      actualPosts = actualBestPosts;
    } else if (i == 3) {
      actualPosts = actualOwnPosts;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SinglePostWidget(
              post: actualPosts.elementAt(index),
              session: widget.session,
              user: widget.user)),
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

  String _formatDate(DateTime createdDate) {
    if (createdDate.isAfter(DateTime.now().subtract(Duration(hours: 1)))) {
      String minString = (DateTime.now().hour == createdDate.hour
                  ? DateTime.now().minute - createdDate.minute
                  : DateTime.now().minute + (60 - createdDate.minute))
              .toString() +
          'm';
      return minString == '0m' ? 'now' : minString;
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

  void refresh() {
    initState();
  }

  void _loadData() {
    _newScrollController.addListener(() {
      if (_newScrollController.position.pixels >=
              _newScrollController.position.maxScrollExtent &&
          !loading) {
        _loadNew(1);
      }
    });
    _bestScrollController.addListener(() {
      if (_bestScrollController.position.pixels >=
              _bestScrollController.position.maxScrollExtent &&
          !loading) {
        _loadNew(2);
      }
    });
    _ownScrollController.addListener(() {
      if (_ownScrollController.position.pixels >=
              _ownScrollController.position.maxScrollExtent &&
          !loading) {
        _loadNew(3);
      }
    });
    CountryCodes.init().then((success) {
      if (success) {
        Locale? deviceLocale = CountryCodes.getDeviceLocale();
        country = CountryCodes.detailsForLocale(deviceLocale).name;
      }
      Map<String, dynamic> body = {
        'countryCode': widget.user.setByLocale
            ? country
            : (widget.user.locale == null ? 'Global' : widget.user.locale),
      };
      widget.session.post('/api/posts/getPosts', body).then((response) {
        if (response.statusCode == 200) {
          setState(() {
            Map<String, dynamic> body =
                json.decode(utf8.decode(response.bodyBytes));

            bestPosts = List<Post>.from(
                body['bestPosts'].map((model) => Post.fromJson(model)));
            newPosts = List<Post>.from(
                body['newPosts'].map((model) => Post.fromJson(model)));
            ownPosts = List<Post>.from(
                body['ownPosts'].map((model) => Post.fromJson(model)));

            actualNewPosts = newPosts.sublist(
                0, newPosts.length < 10 ? newPosts.length : 10);
            actualBestPosts = bestPosts.sublist(
                0, bestPosts.length < 10 ? bestPosts.length : 10);
            actualOwnPosts = ownPosts.sublist(
                0, ownPosts.length < 10 ? ownPosts.length : 10);
          });
          loadedPosts = true;
        }
      });
    });
    _refreshNewController.refreshCompleted();
    _refreshBestController.refreshCompleted();
    _refreshOwnController.refreshCompleted();
  }

  void _evictImage(String url) {
    final NetworkImage provider = NetworkImage(url);
    provider.evict().then<void>((bool success) {
      if (success) debugPrint('removed image!');
    });
  }

  void _onSearchButtonPressed() {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => FilteredPostsWidget(
                session: widget.session,
                pattern: _searchFieldController.text,
                user: widget.user)))
        .whenComplete(
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => PostsWidget(
                      session: widget.session,
                      user: widget.user,
                      initPage: 1,
                    ))));
  }
}
