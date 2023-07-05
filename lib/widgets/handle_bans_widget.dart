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

  const HandleBansWidget(
      {required this.session, required this.user, required this.languages});

  @override
  _HandleBansWidgetState createState() => _HandleBansWidgetState();
}

class _HandleBansWidgetState extends State<HandleBansWidget> {
  late bool _dataLoaded;
  late Languages languages;
  late List<BannedUser> bannedUsers;

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
                    color: CupertinoColors.systemYellow,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        : ListView.builder(
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
                      color: CupertinoColors.systemYellow,
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
                                      style: TextStyle(color: CupertinoColors.systemYellow),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 5, top: 3, bottom: 3),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${languages.nameLabel}: ${bannedUser.name}',
                                      style: TextStyle(color: CupertinoColors.systemYellow),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 5, top: 3, bottom: 3),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${languages.emailLabel}: ${bannedUser.email}',
                                      style: TextStyle(color: CupertinoColors.systemYellow),
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
                                color: CupertinoColors.systemYellow,
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
            });
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
