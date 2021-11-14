import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/auth/auth_sqflite_handler.dart';
import 'package:flutter_frontend/widgets/main_widget.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'auth/login_widget.dart';
import 'entities/session.dart';
import 'entities/user.dart';

void main() {
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Session session = Session();
  AuthSqfLiteHandler authSqfLiteHandler = AuthSqfLiteHandler();
  Widget mainWidget = Container();

  @override
  void initState() {
    super.initState();
    authSqfLiteHandler.retrieveUser().then((authUser) {
      if (authUser != null) {
        var body = new Map<String, dynamic>();
        body['username'] = authUser.email;
        body['password'] = authUser.password;
        session
            .post(
          '/api/login',
          body,
        )
            .then((res) {
          if (res.statusCode == 200) {
            session.updateCookie(res);
            session.get('/api/users/getAuthenticatedUser').then((innerRes) {
              if (innerRes.statusCode == 200) {
                session.updateCookie(innerRes);
                User user =
                    User.fromJson(jsonDecode(utf8.decode(innerRes.bodyBytes)));
                setState(() {
                  mainWidget = MainWidget(session: session, user: user);
                });
              }
            });
          }
        });
      } else {
        setState(() {
          mainWidget = LoginPage();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return mainWidget;
  }
}
