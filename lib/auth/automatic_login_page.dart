import 'dart:convert';
import 'dart:html';

import 'package:autologin_plugin/autologin_plugin_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../entities/session.dart';
import '../entities/user.dart';
import '../languages/hungarian_language.dart';
import '../widgets/home_widget.dart';
import 'login_widget.dart';

class AutomaticLoginPage extends StatefulWidget {
  @override
  _AutomaticLoginPageState createState() => _AutomaticLoginPageState();
}

class _AutomaticLoginPageState extends State<AutomaticLoginPage> {
  bool loading = true;
  bool isMobile = false;

  late Widget currentWidget;

  @override
  void initState() {
    super.initState();
    try {
      if (kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android)) {
        isMobile = true;
      } else {
        isMobile = false;
      }
    } catch (e) {
      isMobile = false;
    }
    _initPage();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Image(
              image: new AssetImage("assets/images/loading_breath.gif")),
        ),
      ),
    )
        : Scaffold(
      body: currentWidget,
    );
  }

  void _initPage() async {
    try {
      List<dynamic> credentials = await AutologinPlugin.getLoginData();
      if(credentials.last == 'null'){
        setState(() {
          loading = false;
          currentWidget = LoginPage(languages: LanguageHu());
          Fluttertoast.showToast(
              msg: LanguageHu().loggedOutLastTime,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 4,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      }
      else if (credentials.isNotEmpty &&
          credentials.first != null &&
          credentials.last != null) {
        _onAutomaticLogin(credentials);
      } else {
        setState(() {
          loading = false;
          currentWidget = LoginPage(languages: LanguageHu());
        });
      }
    } catch (error) {
      setState(() {
        loading = false;
        currentWidget = LoginPage(languages: LanguageHu());
      });
    }
  }

  void _onAutomaticLogin(List<dynamic> credentials) {
    var body = new Map<String, dynamic>();
    body['username'] = credentials.first;
    body['password'] = credentials.last;
    Session session = new Session();
    if (credentials.last != null) {
      session
          .postLogin(
        '/api/login',
        body,
      )
          .then((res) {
        if (res.statusCode == 200) {
          session.get('/api/users/getAuthenticatedUser').then((innerRes) {
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
                setState(() {
                  loading = false;
                  currentWidget = HomeWidget(
                      session: session,
                      user: user,
                      initPage: 0,
                      initTab: 1,
                      languages: LanguageHu(),
                      navBarStatusChangeableAgain: () {},
                      hideNavBar: () {});
                });
              } else {
                Fluttertoast.showToast(
                    msg: LanguageHu().errorInAutomaticLogin,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 4,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            }
          });
        } else if (res.statusCode == 401) {
          setState(() {
            loading = false;
            currentWidget = LoginPage(languages: LanguageHu());
          });
          Fluttertoast.showToast(
              msg: LanguageHu().errorInAutomaticLogin,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 4,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          setState(() {
            loading = false;
            currentWidget = LoginPage(languages: LanguageHu());
          });
          Fluttertoast.showToast(
              msg: res.toString(),
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


}