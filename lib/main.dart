import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/auth/auth_sqflite_handler.dart';
import 'package:flutter_frontend/languages/english_language.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/languages/languages_sqflite_handler.dart';
import 'package:flutter_frontend/widgets/main_widget.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'auth/login_widget.dart';
import 'entities/session.dart';
import 'entities/user.dart';
import 'languages/hungarian_language.dart';

void main() {
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //TODO WEB MIATT EGYBŐL LOGIN PAGE MEHET, MAJD LEHET OKOSKODNI KÉSŐBB A LEMENTETT ADATOKKAL STB, DE EGYELŐRE JÓ ÍGY
  // Session session = Session();
  // AuthSqfLiteHandler authSqfLiteHandler = AuthSqfLiteHandler();
  // LanguagesSqfLiteHandler languagesSqfLiteHandler = LanguagesSqfLiteHandler();
  // late Languages languages;
  // Widget mainWidget = Container(
  //   color: Colors.black,
  //   child: Center(
  //     child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
  //   ),
  // );


  // @override
  // void initState() {
  //   super.initState();
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  //   languagesSqfLiteHandler.retrieveLanguageCode().then((languageCode) {
  //     if (languageCode == null) {
  //       languages = LanguageEn();
  //     } else {
  //       switch (languageCode.code) {
  //         case 'en':
  //           languages = LanguageEn();
  //           break;
  //         case 'hu':
  //           languages = LanguageHu();
  //           break;
  //         default:
  //           languages = LanguageEn();
  //           break;
  //       }
  //     }
  //     authSqfLiteHandler.retrieveUser().then((authUser) {
  //       if (authUser != null) {
  //         var body = new Map<String, dynamic>();
  //         body['username'] = authUser.email;
  //         body['password'] = authUser.password;
  //         session
  //             .post(
  //           '/api/login',
  //           body,
  //         )
  //             .then((res) {
  //           if (res.statusCode == 200) {
  //             session.updateCookie(res);
  //             session.get('/api/users/getAuthenticatedUser').then((innerRes) {
  //               if (innerRes.statusCode == 200) {
  //                 session.updateCookie(innerRes);
  //                 User user = User.fromJson(
  //                     jsonDecode(utf8.decode(innerRes.bodyBytes)));
  //                 if (user.roles.contains('ROLE_COMPANY') &&
  //                     !user.isCompanyActive) {
  //                   Fluttertoast.showToast(
  //                       msg: languages.subscribeWarningMessage,
  //                       toastLength: Toast.LENGTH_LONG,
  //                       gravity: ToastGravity.CENTER,
  //                       timeInSecForIosWeb: 4,
  //                       backgroundColor: Colors.yellow,
  //                       textColor: Colors.black,
  //                       fontSize: 16.0);
  //                 }
  //                 setState(() {
  //                   mainWidget = MainWidget(
  //                     session: session,
  //                     user: user,
  //                     languages: languages,
  //                   );
  //                 });
  //               }
  //             });
  //           } else {
  //             authSqfLiteHandler.deleteUsers();
  //             Fluttertoast.showToast(
  //                 msg: languages.automaticLoginErrorMessage,
  //                 toastLength: Toast.LENGTH_LONG,
  //                 gravity: ToastGravity.CENTER,
  //                 timeInSecForIosWeb: 4,
  //                 backgroundColor: Colors.red,
  //                 textColor: Colors.white,
  //                 fontSize: 16.0);
  //             setState(() {
  //               mainWidget = LoginPage(languages: languages);
  //             });
  //           }
  //         });
  //       } else {
  //         setState(() {
  //           mainWidget = LoginPage(languages: languages);
  //         });
  //       }
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return LoginPage(languages: LanguageHu());
  }
}
