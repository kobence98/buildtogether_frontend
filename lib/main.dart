import 'dart:convert';
import 'dart:html';

import 'package:autologin_plugin/autologin_plugin_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/router.dart';
import 'package:flutter_frontend/widgets/home_widget.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_strategy/url_strategy.dart';

import 'auth/automatic_login_page.dart';
import 'auth/login_widget.dart';
import 'auth/registration_widget.dart';
import 'entities/session.dart';
import 'entities/user.dart';
import 'languages/hungarian_language.dart';

void main() async {
  setPathUrlStrategy();
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      home: AutomaticLoginPage(),
    );
  }
}
