import 'dart:convert';

import 'package:autologin_plugin/autologin_plugin_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/auth/login_widget.dart';
import 'package:flutter_frontend/languages/hungarian_language.dart';
import 'package:flutter_frontend/widgets/home_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import 'entities/session.dart';
import 'entities/user.dart';

class RouterLoadingWidget extends StatefulWidget {
  final String path;

  const RouterLoadingWidget({Key? key, required this.path}) : super(key: key);

  @override
  State<RouterLoadingWidget> createState() => _RouterLoadingWidgetState();
}

class _RouterLoadingWidgetState extends State<RouterLoadingWidget> {
  late Widget _routerLoadingWidget;
  bool _loading = true;
  Session session = new Session();

  @override
  void initState() {
    super.initState();
    _onAutomaticLogin().then((widget) {
      setState(() {
        _routerLoadingWidget = widget;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Scaffold(
            body: Container(
              color: Colors.black,
              child: Center(
                child: Image(
                    image: new AssetImage("assets/images/loading_breath.gif")),
              ),
            ),
          )
        : _routerLoadingWidget;
  }

  Future<Widget> _onAutomaticLogin() async {
    try {
      List<dynamic> credentials = await AutologinPlugin.getLoginData();
      if (credentials.isNotEmpty &&
          credentials.first != null &&
          credentials.last != null) {
        var body = new Map<String, dynamic>();
        body['username'] = credentials.first;
        body['password'] = credentials.last;
        if (credentials.last != 'null') {
          Response res = await session.postLogin(
            '/api/login',
            body,
          );
          if (res.statusCode == 200) {
            Response innerRes =
                await session.get('/api/users/getAuthenticatedUser');
            if (innerRes.statusCode == 200) {
              User user =
                  User.fromJson(jsonDecode(utf8.decode(innerRes.bodyBytes)));
              if (user.active) {
                if (user.roles.contains('ROLE_COMPANY') &&
                    !user.isCompanyActive) {
                  Fluttertoast.showToast(
                      msg: LanguageHu().subscribeWarningMessage,
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 4,
                      backgroundColor: Colors.yellow,
                      textColor: Colors.black,
                      fontSize: 16.0);
                }
                return _selectWidgetByPath(user);
              } else {
                Fluttertoast.showToast(
                    msg: LanguageHu().errorInAutomaticLogin,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 4,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
                return LoginPage(languages: LanguageHu());
              }
            }
          } else if (res.statusCode == 401) {
            Fluttertoast.showToast(
                msg: LanguageHu().errorInAutomaticLogin,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 4,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            return LoginPage(languages: LanguageHu());
          } else {
            Fluttertoast.showToast(
                msg: res.toString(),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 4,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            return LoginPage(languages: LanguageHu());
          }
        } else {
          Fluttertoast.showToast(
              msg: LanguageHu().loggedOutLastTime,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 4,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          return LoginPage(languages: LanguageHu());
        }
      } else {
        return LoginPage(languages: LanguageHu());
      }
    } catch (error) {
      return LoginPage(languages: LanguageHu());
    }
    return LoginPage(languages: LanguageHu());
  }

  Widget _selectWidgetByPath(User user) {
    switch (widget.path) {
      case '/createPost':
        return HomeWidget(
            session: session,
            user: user,
            initPage: 1,
            initTab: 1,
            languages: LanguageHu(),
            navBarStatusChangeableAgain: () {},
            hideNavBar: () {});
      case '/myAccount':
        return HomeWidget(
            session: session,
            user: user,
            initPage: 2,
            initTab: 1,
            languages: LanguageHu(),
            navBarStatusChangeableAgain: () {},
            hideNavBar: () {});
      case '/registeredCompanies':
        return HomeWidget(
            session: session,
            user: user,
            initPage: 3,
            initTab: 1,
            languages: LanguageHu(),
            navBarStatusChangeableAgain: () {},
            hideNavBar: () {});
      case '/likedPosts':
        return HomeWidget(
            session: session,
            user: user,
            initPage: 4,
            initTab: 1,
            languages: LanguageHu(),
            navBarStatusChangeableAgain: () {},
            hideNavBar: () {});
      case '/subscription':
        return HomeWidget(
            session: session,
            user: user,
            initPage: 5,
            initTab: 1,
            languages: LanguageHu(),
            navBarStatusChangeableAgain: () {},
            hideNavBar: () {});
      case '/home':
      default:
        return HomeWidget(
            session: session,
            user: user,
            initPage: 0,
            initTab: 1,
            languages: LanguageHu(),
            navBarStatusChangeableAgain: () {},
            hideNavBar: () {});
    }
  }
}
