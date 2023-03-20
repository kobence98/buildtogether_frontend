import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../entities/banned_user.dart';
import '../entities/session.dart';
import '../entities/user.dart';
import '../languages/languages.dart';

class HandleBansWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;
  final Function closeActualWidget;

  const HandleBansWidget(
      {required this.session, required this.user, required this.languages, required this.closeActualWidget});

  @override
  _HandleBansWidgetState createState() => _HandleBansWidgetState();
}

class _HandleBansWidgetState extends State<HandleBansWidget> {
  late bool _dataLoaded;
  late Languages languages;
  late List<BannedUser> bannedUsers;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    bannedUsers = [];
    languages = widget.languages;
    super.initState();
    _dataLoaded = false;

    widget.session.get('/api/users/findBannedUsers').then((response) {
      if (response.statusCode == 200) {
        setState(() {
          Iterable l = json.decode(utf8.decode(response.bodyBytes));
          bannedUsers = List<BannedUser>.from(
              l.map((model) => BannedUser.fromJson(model)));
          _dataLoaded = true;
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
          _dataLoaded = true;
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
          leading: InkWell(
            onTap: () => widget.closeActualWidget(),
            child: Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
            ),
          ),
          title: Center(
            child: Text(
              languages.handleBansLabel,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: _dataLoaded
            ? _bannedListWidget()
            : Center(
                child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
              ),
      ),
    );
  }

  Widget _bannedListWidget() {
    return bannedUsers.isEmpty
        ? Container(
            child: Center(
              child: Text(
                languages.noBannedUsers,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        : Container(
      padding: EdgeInsets.all(20),
          child: RawScrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            thumbColor: Colors.grey,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Container(
                    width: 700,
                    child: ListView.builder(
                      shrinkWrap: true,
                        itemCount: bannedUsers.length,
                        itemBuilder: (BuildContext context, int index) {
                          BannedUser bannedUser = bannedUsers.elementAt(index);
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: Colors.yellow,
                                ),
                                padding: EdgeInsets.all(1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    color: Colors.black,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(left: 5, top: 3, bottom: 3),
                                                child: Text(
                                                  '${languages.idLabel}: ${bannedUser.id}',
                                                  style: TextStyle(color: Colors.yellow),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(left: 5, top: 3, bottom: 3),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  '${languages.nameLabel}: ${bannedUser.name}',
                                                  style: TextStyle(color: Colors.yellow),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(left: 5, top: 3, bottom: 3),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  '${languages.emailLabel}: ${bannedUser.email}',
                                                  style: TextStyle(color: Colors.yellow),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(right: 15),
                                        child: InkWell(
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.yellow,
                                          ),
                                          onTap: (){_deleteBanTap(bannedUsers.elementAt(index).id);},
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: bannedUsers.length - 1 <= index ? 0 : 10,)
                            ],
                          );
                        }),
                  ),
                ),
              ),
            ),
          ),
        );
  }

  void _deleteBanTap(userId) {
    widget.session.postJson('/api/users/removeBanFromUser/$userId', Map()).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          bannedUsers.removeWhere((user) => user.id == userId);
        });
        Fluttertoast.showToast(
            msg: languages.successfulBanDeleteMessage,
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
  }
}
