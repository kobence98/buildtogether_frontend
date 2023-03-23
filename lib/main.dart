import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/auth/login_widget.dart';
import 'package:flutter_frontend/auth/registration_widget.dart';
import 'package:flutter_frontend/languages/english_language.dart';
import 'package:flutter_frontend/languages/hungarian_language.dart';
import 'package:flutter_frontend/router_loading_widget.dart';
import 'package:flutter_frontend/static/inno_web_scroll_behavior.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  setPathUrlStrategy();
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: InnoWebScrollBehavior(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginPage(languages: window.navigator.language == 'hu' ? LanguageHu() : LanguageEn()),
        '/registration': (context) =>
            RegistrationWidget(languages:  window.navigator.language == 'hu' ? LanguageHu() : LanguageEn()),
        '/home': (context) => RouterLoadingWidget(
              path: '/home',
            ),
        '/createPost': (context) => RouterLoadingWidget(
              path: '/createPost',
            ),
        '/myAccount': (context) => RouterLoadingWidget(
              path: '/myAccount',
            ),
        '/registeredCompanies': (context) => RouterLoadingWidget(
              path: '/registeredCompanies',
            ),
        '/likedPosts': (context) => RouterLoadingWidget(
              path: '/likedPosts',
            ),
        '/subscription': (context) => RouterLoadingWidget(
              path: '/subscription',
            ),
        '/filteredPosts': (context) => RouterLoadingWidget(
              path: '/home',
            ),
        '/singlePost': (context) => RouterLoadingWidget(
              path: '/home',
            ),
        '/statistics': (context) => RouterLoadingWidget(
              path: '/home',
            ),
        '/changePassword': (context) => RouterLoadingWidget(
              path: '/myAccount',
            ),
        '/changeUserData': (context) => RouterLoadingWidget(
              path: '/myAccount',
            ),
        '/changeLocation': (context) => RouterLoadingWidget(
              path: '/myAccount',
            ),
        '/userBans': (context) => RouterLoadingWidget(
              path: '/myAccount',
            ),
      },
      // home: AutomaticLoginPage(),
    );
  }
}
