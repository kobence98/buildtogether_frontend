import 'dart:convert';
import 'dart:io';

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
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:like_button/like_button.dart';
import 'package:location/location.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../entities/feed_type.dart';
import 'filtered_posts_widget.dart';

class PostsWidget extends StatefulWidget {
  final Session session;
  final User user;
  final int initPage;
  final Languages languages;
  final Function hideNavBar;
  final Function navBarStatusChangeableAgain;

  const PostsWidget(
      {required this.session,
      required this.user,
      required this.initPage,
      required this.languages,
      required this.navBarStatusChangeableAgain,
      required this.hideNavBar});

  @override
  _PostsWidgetState createState() => _PostsWidgetState();
}

class _PostsWidgetState extends State<PostsWidget> {
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
  bool loadedNewPosts = false;
  bool loadedBestPosts = false;
  bool loadedOwnPosts = false;
  late Languages languages;
  final TextEditingController _couponCodeController = TextEditingController();
  bool innerLoading = false;
  final TextEditingController _reportReasonTextFieldController =
      TextEditingController();

  static const _pageSize = 20;

  final PagingController<int, Post> _pagingNewController =
      PagingController(firstPageKey: 0);
  final PagingController<int, Post> _pagingBestController =
      PagingController(firstPageKey: 0);
  final PagingController<int, Post> _pagingOwnController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
    _initPageControllers();
  }

  Future<void> _fetchPage(int pageKey, FeedType feedType) async {
    String url;
    PagingController<int, Post> pagingController;
    switch (feedType) {
      case FeedType.NEW:
        url = '/api/posts/new';
        pagingController = _pagingNewController;
        break;
      case FeedType.BEST:
        url = '/api/posts/best';
        pagingController = _pagingBestController;
        break;
      case FeedType.OWN:
        url = '/api/posts/own';
        pagingController = _pagingOwnController;
        break;
    }
    try {
      LocationData? locationData;
      bool useLocation = false;
      if (widget.user.setByLocale) {
        Location location = new Location();
        bool _serviceEnabled = await location.serviceEnabled();
        if (_serviceEnabled) {
          bool _requestedServiceEnabled = await location.requestService();
          if (_requestedServiceEnabled) {
            PermissionStatus _permissionGranted =
                await location.hasPermission();
            if (_permissionGranted == PermissionStatus.denied) {
              if (Platform.isAndroid) {
                await explainPermissionDialog();
              }
              PermissionStatus _permissionGrantedAfterAsk =
                  await location.requestPermission();
              if (_permissionGrantedAfterAsk != PermissionStatus.granted) {
                locationErrorToast();
              } else {
                locationData = await location.getLocation();
                useLocation = true;
              }
            } else if (_permissionGranted == PermissionStatus.granted) {
              locationData = await location.getLocation();
              useLocation = true;
            }
          } else {
            locationErrorToast();
          }
        } else {
          locationErrorToast();
        }
      }
      String countryCode =
          widget.user.locale == null ? 'Global' : widget.user.locale!;
      String? countryCodeByLocation;
      if (useLocation && locationData != null) {
        List<geocoding.Placemark> address =
            await geocoding.placemarkFromCoordinates(
                locationData.latitude!, locationData.longitude!);
        if (address.isEmpty || address.first.isoCountryCode == null) {
          locationErrorToast();
        } else {
          countryCodeByLocation = address.first.isoCountryCode!;
        }
      }

      dynamic data = <String, dynamic>{
        'countryCode': countryCode,
        'countryCodeByLocation': countryCodeByLocation,
        'pageNumber': pageKey / _pageSize,
        'pageSize': _pageSize
      };
      dynamic body = json.decode(
          utf8.decode((await widget.session.postJson(url, data)).bodyBytes));
      List<Post> newItems =
          List<Post>.from(body.map((model) => Post.fromJson(model)));
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        pagingController.appendPage(newItems, nextPageKey);
      }
      switch (feedType) {
        case FeedType.NEW:
          _refreshNewController.refreshCompleted();
          break;
        case FeedType.BEST:
          _refreshBestController.refreshCompleted();
          break;
        case FeedType.OWN:
          _refreshOwnController.refreshCompleted();
          break;
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingNewController.dispose();
    _pagingOwnController.dispose();
    _pagingBestController.dispose();
    _searchFieldController.dispose();
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
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
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
                              loadingBuilder: (context) {
                                return Container(
                                  height: 50,
                                  padding: EdgeInsets.all(1),
                                  color: Colors.yellow,
                                  child: Container(
                                      color: Colors.black,
                                      child: Center(
                                        child: Image(
                                            image: new AssetImage(
                                                "assets/images/loading_breath.gif")),
                                      )),
                                );
                              },
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
                              minCharsForSuggestions: 1,
                              textFieldConfiguration: TextFieldConfiguration(
                                decoration: new InputDecoration.collapsed(
                                    hintText: languages.searchLabel),
                                controller: _searchFieldController,
                                cursorColor: Colors.black,
                                autofocus: false,
                                style: TextStyle(fontSize: 20),
                                onEditingComplete: _onSearchComplete,
                              ),
                              suggestionsCallback: (pattern) async {
                                dynamic response = await widget.session
                                    .get("/api/searchField/" + pattern);
                                if (response.statusCode == 200) {
                                  widget.session.updateCookie(response);
                                  Iterable l = json
                                      .decode(utf8.decode(response.bodyBytes));
                                  names = List<SearchFieldNames>.from(l.map(
                                      (name) =>
                                          SearchFieldNames.fromJson(name)));
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
                    pinned: true,
                    floating: true,
                    snap: true,
                    forceElevated: innerBoxIsScrolled,
                    bottom: TabBar(
                        labelColor: Colors.yellow,
                        indicatorColor: Colors.yellow,
                        tabs: [
                          Tab(
                            child: Text(
                              languages.bestLabel,
                              style: TextStyle(color: Colors.yellow),
                            ),
                          ),
                          Tab(
                            child: Text(
                              languages.newLabel,
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
                ];
              },
              body: TabBarView(children: [
                _postsWidget(_pagingBestController, FeedType.BEST),
                _postsWidget(_pagingNewController, FeedType.NEW),
                _postsWidget(_pagingOwnController, FeedType.OWN),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _postsWidget(
      PagingController<int, Post> pagingController, FeedType feedType) {
    RefreshController _refreshController;
    switch (feedType) {
      case FeedType.NEW:
        _refreshController = _refreshNewController;
        break;
      case FeedType.BEST:
        _refreshController = _refreshBestController;
        break;
      case FeedType.OWN:
        _refreshController = _refreshOwnController;
        break;
    }
    return Container(
      color: Colors.black,
      child: SmartRefresher(
        controller: _refreshController,
        onRefresh: () {
          pagingController.refresh();
        },
        header: WaterDropHeader(
          refresh: SizedBox(
              width: 25.0,
              height: 25.0,
              child: Image(
                  image: new AssetImage("assets/images/loading_spin.gif"))),
        ),
        child: PagedListView<int, Post>(
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            firstPageErrorIndicatorBuilder: (context) => Container(
              child: Center(
                child: Text(
                  languages.errorLoadPostsLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            noMoreItemsIndicatorBuilder: (context) => Container(
              color: Colors.black,
              height: 80,
              alignment: Alignment.topCenter,
              child: Text(
                languages.noMoreItemsLabel,
                style: TextStyle(
                    color: Colors.yellow,
                    fontStyle: FontStyle.italic,
                    fontSize: 15),
              ),
            ),
            newPageProgressIndicatorBuilder: (context) => Container(
              margin: EdgeInsets.only(bottom: 20),
              width: 80,
              height: 80,
              child: Center(
                child: Image(
                    height: 30,
                    width: 30,
                    image: new AssetImage("assets/images/loading_spin.gif")),
              ),
            ),
            firstPageProgressIndicatorBuilder: (context) =>
                _refreshController.isRefresh
                    ? Container()
                    : Container(
                        child: Center(
                          child: Image(
                              image: new AssetImage(
                                  "assets/images/loading_breath.gif")),
                        ),
                      ),
            noItemsFoundIndicatorBuilder: (context) => Container(
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
            itemBuilder: (context, post, postIndex) => InkWell(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
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
                                        msg: languages.ideaIsImplementedMessage,
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 4,
                                        backgroundColor: Colors.green,
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
                                    widget.user.companyId == post.companyId
                                        ? 4
                                        : 2, (index) {
                                  if (index == 0) {
                                    return PopupMenuItem(
                                      child: Text(widget.user.companyId ==
                                                  post.companyId ||
                                              widget.user.userId ==
                                                  post.creatorId
                                          ? languages.deleteLabel
                                          : languages.reportLabel),
                                      value: 0,
                                    );
                                  } else if (index == 1) {
                                    return PopupMenuItem(
                                      child: Text(languages.banUserLabel),
                                      value: 1,
                                    );
                                  } else if (index == 2) {
                                    return PopupMenuItem(
                                      child:
                                          Text(languages.contactCreatorLabel),
                                      value: 2,
                                    );
                                  } else {
                                    return PopupMenuItem(
                                      child: Text(post.implemented
                                          ? languages.notImplementedLabel
                                          : languages.implementedLabel),
                                      value: 3,
                                    );
                                  }
                                });
                              },
                              onSelected: (index) {
                                if (index == 0) {
                                  if (widget.user.companyId == post.companyId ||
                                      widget.user.userId == post.creatorId) {
                                    widget.session
                                        .delete('/api/posts/' +
                                            post.postId.toString())
                                        .then((response) {
                                      if (response.statusCode == 200) {
                                        Fluttertoast.showToast(
                                            msg: languages
                                                .successfulDeleteMessage,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        pagingController.refresh();
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
                                              post.postId.toString() +
                                              '/implemented',
                                          Map<String, dynamic>())
                                      .then((response) {
                                    if (response.statusCode == 200) {
                                      Fluttertoast.showToast(
                                          msg: "${languages.successLabel}!",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 4,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                      setState(() {
                                        post.implemented = !post.implemented;
                                      });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: languages
                                              .globalServerErrorMessage,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 4,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
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
                            : languages.clickHereToOpenThePollLabel,
                        style: TextStyle(color: Colors.white),
                      ),
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
                            isLiked: post.liked,
                            likeBuilder: (bool isLiked) {
                              return Icon(
                                Icons.lightbulb,
                                color: isLiked ? Colors.yellow : Colors.white,
                              );
                            },
                            onTap: (isLiked) {
                              return post.creatorId == widget.user.userId
                                  ? _onLikeOwnButtonPressed()
                                  : _onLikeButton(isLiked, post);
                            },
                            likeCount: post.likeNumber,
                          ),
                          Row(
                            children: [
                              Text(
                                post.commentNumber.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                icon: Icon(Icons.comment),
                                color: Colors.white,
                                onPressed: () {
                                  widget.hideNavBar();
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              SinglePostWidget(
                                                commentTapped: true,
                                                session: widget.session,
                                                post: post,
                                                user: widget.user,
                                                languages: languages,
                                              )))
                                      .whenComplete(() =>
                                          widget.navBarStatusChangeableAgain());
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
                _onPostTap(post);
              },
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
                      Container(
                        width: 210,
                        child: Text(
                          company.name + ' (${company.countryCode})',
                          maxLines: null,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
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

  Future<bool> _onLikeButton(bool isLiked, Post post) async {
    dynamic response = await widget.session.post(
        "/api/posts/" + post.postId.toString() + "/like",
        new Map<String, dynamic>());
    if (response.statusCode == 200) {
      post.liked = !post.liked;
      if (post.liked) {
        post.likeNumber++;
      } else {
        post.likeNumber--;
      }
      return !isLiked;
    } else {
      return isLiked;
    }
  }

  void _onPostTap(Post post) {
    widget.hideNavBar();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SinglePostWidget(
                commentTapped: false,
                post: post,
                session: widget.session,
                user: widget.user,
                languages: languages,
              )),
    ).whenComplete(() {
      widget.navBarStatusChangeableAgain();
      widget.session
          .get('/api/posts/' + post.postId.toString())
          .then((response) {
        if (response.statusCode == 200) {
          setState(() {
            post = Post.fromJson(json.decode(utf8.decode(response.bodyBytes)));
          });
        }
      });
    });
  }

  void _onSearchButtonPressed() {
    if (_searchFieldController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: languages.fillTheSearchFieldWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      widget.hideNavBar();
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (context) => FilteredPostsWidget(
                    session: widget.session,
                    pattern: _searchFieldController.text,
                    user: widget.user,
                    languages: languages,
                  )))
          .whenComplete(() {
        widget.navBarStatusChangeableAgain();
        _searchFieldController.clear();
        FocusManager.instance.primaryFocus?.unfocus();
      });
    }
  }

  void _onSearchComplete() {
    if (_searchFieldController.text.isEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
    } else {
      widget.hideNavBar();
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (context) => FilteredPostsWidget(
                    session: widget.session,
                    pattern: _searchFieldController.text,
                    user: widget.user,
                    languages: languages,
                  )))
          .whenComplete(() {
        widget.navBarStatusChangeableAgain();
        _searchFieldController.clear();
        FocusManager.instance.primaryFocus?.unfocus();
      });
    }
  }

  void _onContactCreatorTap(Post post) {
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
          timeInSecForIosWeb: 4,
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
                      child: Image(
                          image: new AssetImage(
                              "assets/images/loading_breath.gif")),
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
            timeInSecForIosWeb: 4,
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

  void locationErrorToast() {
    Fluttertoast.showToast(
        msg: languages.locationErrorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 4,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _initPageControllers() {
    _pagingNewController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, FeedType.NEW);
    });
    _pagingBestController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, FeedType.BEST);
    });
    _pagingOwnController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, FeedType.OWN);
    });
  }

  explainPermissionDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            content: Text(
              languages.explainPermissionDialogTitle,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.yellow),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  languages.OKLabel,
                  style: TextStyle(color: Colors.yellow),
                ),
              ),
            ],
          );
        });
  }
}
