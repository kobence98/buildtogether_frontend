import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/company.dart';
import 'package:flutter_frontend/entities/poll_option.dart';
import 'package:flutter_frontend/entities/post.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/static/date_formatter.dart';
import 'package:flutter_frontend/widgets/statistic_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';

import '../static/profanity_checker.dart';
import 'comments_widget.dart';
import 'flutter_polls_inno.dart';
import 'open_image_widget.dart';

class SinglePostWidget extends StatefulWidget {
  final Post post;
  final Session session;
  final User user;
  final Languages languages;
  final bool commentTapped;
  final Function hideNavBar;
  final Function navBarStatusChangeableAgain;
  final Function backToPostsPage;
  final Function jumpToPage;

  const SinglePostWidget(
      {required this.post,
      required this.session,
      required this.user,
      required this.languages,
      required this.commentTapped,
      required this.hideNavBar,
      required this.navBarStatusChangeableAgain,
      required this.backToPostsPage,
      required this.jumpToPage});

  @override
  _SinglePostWidgetState createState() => _SinglePostWidgetState();
}

class _SinglePostWidgetState extends State<SinglePostWidget> {
  late Languages languages;

  late Post post;
  bool innerLoading = false;
  final TextEditingController _reportReasonTextFieldController =
      TextEditingController();
  final TextEditingController _couponCodeController = TextEditingController();
  late bool voted;
  final commentsKey = GlobalKey();
  late bool isCreator;

  final TextEditingController _editTitleTextController =
      TextEditingController();
  FocusNode _editTitleTextFocusNode = FocusNode();
  bool _editTitleIsActive = false;

  final TextEditingController _editDescriptionTextController =
      TextEditingController();
  FocusNode _editDescriptionTextFocusNode = FocusNode();
  bool _editDescriptionIsActive = false;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    window.history.pushState(null, 'singlePost', '/singlePost');
    super.initState();
    languages = widget.languages;
    post = widget.post;
    isCreator = post.creatorId == widget.user.userId;
    _editTitleTextController.text = post.title;
    _editDescriptionTextController.text = post.description;
  }

  @override
  Widget build(BuildContext context) {
    voted = post.pollOptions.any((element) => element.liked);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 24,
            onPressed: () {
              widget.backToPostsPage();
            },
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          title: Center(
            child: Text(
              post.title,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(bottom: 10),
          color: Colors.black,
          child: Center(
            child: Container(
              child: RawScrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thumbColor: Colors.grey,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Center(
                    child: Container(
                      color: Colors.black,
                      width: 700,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.yellow.withOpacity(0.1),
                                border: Border.all(color: Colors.yellow)),
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.symmetric(vertical: 10),
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
                                                    timeInSecForIosWeb: 4,
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
                                                              post.companyId ||
                                                          widget.user.userId ==
                                                              post.creatorId
                                                      ? languages.deleteLabel
                                                      : languages.reportLabel),
                                                  value: 0,
                                                );
                                              } else if (index == 1) {
                                                return PopupMenuItem(
                                                  child: Text(
                                                      languages.banUserLabel),
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
                                                        post.postId.toString())
                                                    .then((response) {
                                                  if (response.statusCode ==
                                                      200) {
                                                    Fluttertoast.showToast(
                                                        msg: languages
                                                            .successfulDeleteMessage,
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 4,
                                                        backgroundColor:
                                                            Colors.green,
                                                        textColor: Colors.white,
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
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 4,
                                                        backgroundColor:
                                                            Colors.red,
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
                                                      timeInSecForIosWeb: 4,
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
                                                      timeInSecForIosWeb: 4,
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
                                  title: isCreator && _editTitleIsActive
                                      ? EditableText(
                                          controller: _editTitleTextController,
                                          focusNode: _editTitleTextFocusNode,
                                          onChanged: (newText) {
                                            setState(() {});
                                          },
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                          cursorColor: Colors.white,
                                          backgroundCursorColor: Colors.black)
                                      : Text(
                                          post.title,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                  trailing: isCreator
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              child: Icon(
                                                _editTitleIsActive
                                                    ? Icons.save_alt
                                                    : Icons.edit,
                                                color: post.title ==
                                                            _editTitleTextController
                                                                .text &&
                                                        _editTitleIsActive
                                                    ? Colors.grey
                                                    : Colors.white,
                                              ),
                                              onTap: _editTitleIsActive
                                                  ? _onSaveTitleEditTap
                                                  : () {
                                                      setState(() {
                                                        _editTitleTextFocusNode
                                                            .requestFocus();
                                                        _editTitleIsActive =
                                                            true;
                                                      });
                                                    },
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            _editTitleIsActive
                                                ? InkWell(
                                                    child: Icon(
                                                      Icons.cancel,
                                                      color: Colors.white,
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        _editTitleIsActive =
                                                            false;
                                                        _editTitleTextController
                                                            .text = post.title;
                                                      });
                                                    },
                                                  )
                                                : Container(),
                                          ],
                                        )
                                      : Container(
                                          width: 0,
                                          height: 0,
                                        ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 5, right: 5, top: 5, bottom: 15),
                                  alignment: Alignment.topLeft,
                                  child: post.postType == 'SIMPLE_POST'
                                      ? (isCreator
                                          ? Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(left: 10),
                                                  width:
                                                      _editDescriptionIsActive
                                                          ? MediaQuery.of(context).size.width < 758 ? MediaQuery.of(context).size.width - 150 : 608
                                                          : MediaQuery.of(context).size.width < 758 ? MediaQuery.of(context).size.width - 130 : 628,
                                                  child: (isCreator &&
                                                          _editDescriptionIsActive
                                                      ? EditableText(
                                                          textInputAction:
                                                              TextInputAction
                                                                  .newline,
                                                          maxLines: null,
                                                          controller:
                                                              _editDescriptionTextController,
                                                          focusNode:
                                                              _editDescriptionTextFocusNode,
                                                          onChanged: (newText) {
                                                            setState(() {});
                                                          },
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                          cursorColor:
                                                              Colors.white,
                                                          backgroundCursorColor:
                                                              Colors.black)
                                                      : Text(
                                                          post.description,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                ),
                                                Container(
                                                  width:
                                                      _editDescriptionIsActive
                                                          ? 60
                                                          : 30,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InkWell(
                                                        child: Icon(
                                                          _editDescriptionIsActive
                                                              ? Icons.save_alt
                                                              : Icons.edit,
                                                          color: post.description ==
                                                                      _editDescriptionTextController
                                                                          .text &&
                                                                  _editDescriptionIsActive
                                                              ? Colors.grey
                                                              : Colors.white,
                                                        ),
                                                        onTap: () {
                                                          if (_editDescriptionIsActive) {
                                                            _onSaveDescriptionTap();
                                                          } else {
                                                            setState(() {
                                                              _editDescriptionTextFocusNode
                                                                  .requestFocus();
                                                              _editDescriptionIsActive =
                                                                  true;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            _editDescriptionIsActive
                                                                ? 10
                                                                : 0,
                                                      ),
                                                      _editDescriptionIsActive
                                                          ? InkWell(
                                                              child: Icon(
                                                                Icons.cancel,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onTap: () {
                                                                setState(() {
                                                                  _editDescriptionIsActive =
                                                                      false;
                                                                  _editDescriptionTextController
                                                                          .text =
                                                                      post.description;
                                                                });
                                                              },
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              post.description,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ))
                                      : _pollWidget(post),
                                ),
                                SizedBox(
                                  height: post.postImageId == null ? 0 : 10,
                                ),
                                post.postImageId == null
                                    ? Container()
                                    : Container(
                                        margin: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            border: Border.all(
                                                color: Colors.yellow),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  '${languages.thisPostHasPicture}:',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                flex: 5,
                                              ),
                                              Flexible(
                                                child: InkWell(
                                                  child: Center(
                                                    child: Container(
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .yellow),
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                              widget.session
                                                                      .domainName +
                                                                  "/api/postImages/" +
                                                                  post.postImageId
                                                                      .toString(),
                                                              headers: widget
                                                                  .session
                                                                  .headers,
                                                            ),
                                                            fit: BoxFit.contain,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    Navigator.of(context).push(PageRouteBuilder(
                                                        opaque: false,
                                                        pageBuilder: (_, __, ___) =>
                                                            OpenImageWidget(
                                                                imageId: post
                                                                    .postImageId
                                                                    .toString(),
                                                                session: widget
                                                                    .session)));
                                                  },
                                                ),
                                                flex: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                Container(
                                  height: 40,
                                  margin: EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: LikeButton(
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
                                                : _onLikeButton(isLiked);
                                          },
                                          likeCount: post.likeNumber,
                                        ),
                                      ),
                                      widget.user.companyId != null &&
                                              widget.user.companyId ==
                                                  post.companyId
                                          ? InkWell(
                                              child: Icon(
                                                Icons.bar_chart,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                              onTap: () {
                                                _openStatisticPage(post.postId);
                                              })
                                          : (voted
                                              ? InkWell(
                                                  child: Text(
                                                    languages.removeMyVoteLabel,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontStyle:
                                                            FontStyle.italic),
                                                  ),
                                                  onTap: _onRemovePollVote,
                                                )
                                              : Container()),
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
                                              Scrollable.ensureVisible(
                                                  commentsKey.currentContext!,
                                                  duration: Duration(
                                                      milliseconds: 500));
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CommentsWidget(
                            key: commentsKey,
                            session: widget.session,
                            postId: post.postId,
                            post: post,
                            user: widget.user,
                            languages: languages,
                            commentTapped: widget.commentTapped,
                            setMainState: setState,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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

  Future<bool> _onLikeButton(bool isLiked) async {
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

  Widget _pollWidget(Post post) {
    List<PollOption> polls = [];
    List<PollOptionInno> likedPollOptions =
        post.pollOptions.where((po) => po.liked).toList();

    for (PollOptionInno option in post.pollOptions) {
      polls.add(PollOption(
          id: option.pollId,
          title: Container(
            padding: likedPollOptions.isEmpty
                ? EdgeInsets.symmetric(horizontal: 5)
                : EdgeInsets.zero,
            child: Text(
              option.title == null ? '' : option.title!,
            ),
            width:
                likedPollOptions.isEmpty && widget.user.userId != post.creatorId
                    ? 650
                    : 470,
          ),
          votes: option.likeNumber));
    }

    return FlutterPollsInno(
      isOwn: post.creatorId == widget.user.userId,
      votesText: languages.votesText,
      pollOptionsFillColor: Colors.yellow,
      votedBackgroundColor: Colors.yellow.shade600,
      leadingVotedByUserProgessColor: Colors.red,
      votedProgressColor: Colors.yellow.shade900,
      leadingVotedProgessColor: Colors.yellow.shade900,
      pollOptionsSplashColor: Colors.red,
      hasVoted: voted || post.creatorId == widget.user.userId,
      pollId: 'POLLID',
      onVoted: (PollOption pollOption, int newTotalVotes) {
        return _onPollVoted(pollOption.id!);
      },
      pollTitle: Text(
        '${languages.numberOfVotesLabel}: ${post.pollOptions.map((e) => e.likeNumber).reduce((a, b) => a + b)}',
        style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
      ),
      onPollOptionRemove: () {
        _onRemovePollVote();
      },
      pollOptions: polls,
      userVotedOptionId:
          likedPollOptions.isEmpty ? null : likedPollOptions.first.pollId,
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
        timeInSecForIosWeb: 4,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    return Future.value(false);
  }

  void _onRemovePollVote() {
    widget.session
        .delete('/api/posts/' + post.postId.toString() + '/pollVote')
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
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
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

  Future<bool> _onPollVoted(int pollId) async {
    dynamic response = await widget.session.post(
        '/api/posts/' +
            post.postId.toString() +
            '/pollVote/' +
            pollId.toString(),
        Map());
    if (response.statusCode == 200) {
      setState(() {
        post.pollOptions.forEach((option) {
          if (option.liked) {
            option.likeNumber--;
          }
          option.liked = false;
        });
        post.pollOptions.where((po) => po.pollId == pollId).first.likeNumber++;
        post.pollOptions.where((po) => po.pollId == pollId).first.liked = true;
      });
      return Future.value(true);
    } else {
      Fluttertoast.showToast(
          msg: languages.globalErrorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return Future.value(false);
    }
  }

  void _onSaveTitleEditTap() {
    _editTitleTextFocusNode.unfocus();
    if (ProfanityChecker.alert(_editTitleTextController.text)) {
      Fluttertoast.showToast(
          msg: languages.profanityWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (_editTitleTextController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: languages.fillAllFieldsWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (post.title == _editTitleTextController.text) {
      Fluttertoast.showToast(
          msg: languages.titleNotEditedMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (_editTitleTextController.text.length > 256) {
      Fluttertoast.showToast(
          msg: languages.titleTooLongWarningMessage,
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
                        languages.editTitleConfirmLabel,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      content: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black),
                        height: MediaQuery.of(context).size.height / 5,
                        width: MediaQuery.of(context).size.width,
                        child: ListView(
                          children: [
                            Center(
                              child: Text(
                                post.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.yellow),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Icon(
                                Icons.keyboard_double_arrow_down,
                                color: Colors.yellow,
                                size: 40,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Text(
                                _editTitleTextController.text,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.yellow),
                              ),
                            ),
                          ],
                        ),
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
                            dynamic body = <String, String?>{
                              'postId': post.postId.toString(),
                              'title': _editTitleTextController.text,
                            };
                            widget.session
                                .postJson('/api/posts/editTitle', body)
                                .then((response) {
                              setInnerState(() {
                                innerLoading = false;
                              });
                              if (response.statusCode == 200) {
                                setState(() {
                                  post.title = _editTitleTextController.text;
                                  _editTitleIsActive = false;
                                });
                                Navigator.of(context).pop();
                                Fluttertoast.showToast(
                                    msg: languages.successfulDataChangeLabel,
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
                            languages.OKLabel,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    );
            });
          });
    }
  }

  void _onSaveDescriptionTap() {
    _editDescriptionTextFocusNode.unfocus();
    if (ProfanityChecker.alert(_editDescriptionTextController.text)) {
      Fluttertoast.showToast(
          msg: languages.profanityWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (_editDescriptionTextController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: languages.fillAllFieldsWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (post.description == _editDescriptionTextController.text) {
      Fluttertoast.showToast(
          msg: languages.descriptionNotEditedMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (_editDescriptionTextController.text.length > 2048) {
      Fluttertoast.showToast(
          msg: languages.descriptionTooLongWarningMessage,
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
                        languages.editDescriptionConfirmLabel,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      content: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black),
                        height: MediaQuery.of(context).size.height / 5,
                        width: MediaQuery.of(context).size.width,
                        child: ListView(
                          children: [
                            Center(
                              child: Text(
                                post.description,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.yellow),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Icon(
                                Icons.keyboard_double_arrow_down,
                                color: Colors.yellow,
                                size: 40,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Text(
                                _editDescriptionTextController.text,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.yellow),
                              ),
                            ),
                          ],
                        ),
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
                            dynamic body = <String, String?>{
                              'postId': post.postId.toString(),
                              'description':
                                  _editDescriptionTextController.text,
                            };
                            widget.session
                                .postJson('/api/posts/editDescription', body)
                                .then((response) {
                              setInnerState(() {
                                innerLoading = false;
                              });
                              if (response.statusCode == 200) {
                                setState(() {
                                  post.description =
                                      _editDescriptionTextController.text;
                                  _editDescriptionIsActive = false;
                                });
                                Navigator.of(context).pop();
                                Fluttertoast.showToast(
                                    msg: languages.successfulDataChangeLabel,
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
                            languages.OKLabel,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    );
            });
          });
    }
  }

  void _openStatisticPage(int postId) async {
    await widget.hideNavBar();
    widget.jumpToPage(
      StatisticPage(
        backToPostsPage: () {
          widget.jumpToPage(SinglePostWidget(
              post: widget.post,
              session: widget.session,
              user: widget.user,
              languages: widget.languages,
              commentTapped: widget.commentTapped,
              hideNavBar: widget.hideNavBar,
              navBarStatusChangeableAgain: widget.navBarStatusChangeableAgain,
              backToPostsPage: widget.backToPostsPage,
              jumpToPage: widget.jumpToPage));
          widget.navBarStatusChangeableAgain();
        },
        postId: postId,
        session: widget.session,
        languages: languages,
      ),
    );
  }
}
