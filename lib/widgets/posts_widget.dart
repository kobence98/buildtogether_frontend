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
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/static/date_formatter.dart';
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
  final Languages languages;

  const PostsWidget(
      {required this.session,
      required this.user,
      required this.initPage,
      required this.languages});

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
  late Languages languages;
  final TextEditingController _couponCodeController = TextEditingController();
  bool innerLoading = false;
  final TextEditingController _reportReasonTextFieldController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
    _loadData();
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    _newScrollController.dispose();
    _bestScrollController.dispose();
    _ownScrollController.dispose();
    _refreshNewController.dispose();
    _refreshBestController.dispose();
    _refreshOwnController.dispose();
    _couponCodeController.dispose();
    _reportReasonTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: DefaultTabController(
        initialIndex: widget.initPage,
        length: 3,
        child: SafeArea(
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
                                  languages.noItemsFoundLabel,
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
                          decoration: new InputDecoration.collapsed(
                              hintText: languages.searchLabel),
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
                            names = List<SearchFieldNames>.from(l.map(
                                (name) => SearchFieldNames.fromJson(name)));
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
                            name = names
                                .where((nm) => nm.id.toString() == n)
                                .first;
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
                        languages.newLabel,
                        style: TextStyle(color: Colors.yellow),
                      ),
                    ),
                    Tab(
                      child: Text(
                        languages.bestLabel,
                        style: TextStyle(color: Colors.yellow),
                      ),
                    ),
                    Tab(
                      child: Text(
                        languages.ownLabel,
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
        ),
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
                                            style:
                                                TextStyle(color: Colors.white),
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
                                                        ? 3
                                                        : 1, (index) {
                                                  if (index == 0) {
                                                    return PopupMenuItem(
                                                      child: Text(widget.user
                                                                      .companyId ==
                                                                  post
                                                                      .companyId ||
                                                              widget.user
                                                                      .userId ==
                                                                  post.creatorId
                                                          ? languages
                                                              .deleteLabel
                                                          : languages
                                                              .reportLabel),
                                                      value: 0,
                                                    );
                                                  } else if (index == 1) {
                                                    return PopupMenuItem(
                                                      child: Text(languages
                                                          .contactCreatorLabel),
                                                      value: 1,
                                                    );
                                                  } else {
                                                    return PopupMenuItem(
                                                      child: Text(post
                                                              .implemented
                                                          ? languages
                                                              .notImplementedLabel
                                                          : languages
                                                              .implementedLabel),
                                                      value: 2,
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
                                                            toastLength: Toast
                                                                .LENGTH_LONG,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            timeInSecForIosWeb:
                                                                1,
                                                            backgroundColor:
                                                                Colors.green,
                                                            textColor:
                                                                Colors.white,
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
                                                            msg: languages
                                                                .globalServerErrorMessage,
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
                                                                Colors.white,
                                                            fontSize: 16.0);
                                                      }
                                                    });
                                                  } else {
                                                    onReportTap(post);
                                                  }
                                                } else if (index == 1) {
                                                  _onContactCreatorTap(post);
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
                                                    if (response.statusCode ==
                                                        200) {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "${languages.successLabel}!",
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
                                                        bool imp =
                                                            !post.implemented;
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
                                                                  .implemented =
                                                              imp;
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
                                                                  .implemented =
                                                              imp;
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
                                                                  .implemented =
                                                              imp;
                                                        }
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
                                                }
                                              },
                                            ),
                                          )
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
                                                  : _onLikeButton(isLiked,
                                                      index, pageNumber);
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
                                                                user:
                                                                    widget.user,
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
                                _onPostTap(index, pageNumber);
                              },
                            );
                          })
                      : Container(
                          child: Center(
                            child: Text(
                              languages.noPostInYourAreaLabel,
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
                child: CircularProgressIndicator(
                  color: Colors.yellow,
                ),
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
                        child: Text(languages.closeLabel)),
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

  void _onSearchButtonPressed() {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => FilteredPostsWidget(
                  session: widget.session,
                  pattern: _searchFieldController.text,
                  user: widget.user,
                  languages: languages,
                )))
        .whenComplete(
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => PostsWidget(
                      session: widget.session,
                      user: widget.user,
                      initPage: 1,
                      languages: languages,
                    ))));
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
}
