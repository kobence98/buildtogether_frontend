import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_frontend/auth/auth_sqflite_handler.dart';
import 'package:flutter_frontend/auth/auth_user.dart';
import 'package:flutter_frontend/auth/registration_widget.dart';
import 'package:flutter_frontend/design/main_background.dart';
import 'package:flutter_frontend/languages/english_language.dart';
import 'package:flutter_frontend/languages/hungarian_language.dart';
import 'package:flutter_frontend/languages/language_code.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/languages/languages_sqflite_handler.dart';
import 'package:flutter_frontend/widgets/main_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../entities/session.dart';
import '../../entities/user.dart';
import '../static/safe_area.dart';

class LoginPage extends StatefulWidget {
  final Languages languages;

  const LoginPage({required this.languages});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _forgottenPasswordEmailController = TextEditingController();
  Session session = Session();
  AuthSqfLiteHandler authSqfLiteHandler = AuthSqfLiteHandler();
  LanguagesSqfLiteHandler languagesSqfLiteHandler = LanguagesSqfLiteHandler();
  bool loading = false;
  late Languages languages;
  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    languages = widget.languages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: MainBackground(),
        child: Container(
          child: InnoSafeArea(
            child: loading
                ? Container(
              child: Center(
                child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
              ),
            )
                : Center(
              child: Container(
                padding: EdgeInsets.all(
                    MediaQuery.of(context).size.height * 0.02),
                width: 600,
                height: 1000,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30,
                              foregroundImage: AssetImage(
                                  'icons/flags/png/gb.png',
                                  package: 'country_icons'),
                            ),
                            onTap: () {
                              setState(() {
                                languages = LanguageEn();
                                languagesSqfLiteHandler.insertLanguageCode(
                                    LanguageCode(code: 'en', id: 0));
                              });
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30,
                              foregroundImage: AssetImage(
                                  'icons/flags/png/hu.png',
                                  package: 'country_icons'),
                            ),
                            onTap: () {
                              setState(() {
                                languages = LanguageHu();
                                languagesSqfLiteHandler.insertLanguageCode(
                                    LanguageCode(code: 'hu', id: 0));
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Container(
                        padding: EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: CupertinoColors.systemYellow.withOpacity(0.7),
                        ),
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          controller: _emailController,
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none),
                            hintText: languages.emailLabel,
                            hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: Container(
                        padding: EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: CupertinoColors.systemYellow.withOpacity(0.7),
                        ),
                        child: TextField(
                          enableSuggestions: false,
                          autocorrect: false,
                          obscureText: !_passwordVisible,
                          style: TextStyle(color: Colors.black),
                          controller: _passwordController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                // Based on passwordVisible state choose the icon
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                // Update the state i.e. toogle the state of passwordVisible variable
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none),
                            hintText: languages.passwordLabel,
                            hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: ButtonTheme(
                        height: 50,
                        minWidth: 300,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(
                                CupertinoColors.systemYellow),
                          ),
                          onPressed: onLoginPressed,
                          child: Text(
                            languages.loginLabel,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: ButtonTheme(
                        height: 50,
                        minWidth: 300,
                        child: ElevatedButton(
                          onPressed: onRegistrationPressed,
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(
                                CupertinoColors.systemYellow),
                          ),
                          child: Text(
                            languages.registrationLabel,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: Container(
                        child: InkWell(
                          child: Text(
                            languages.forgottenPasswordLabel,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 15,
                                color: CupertinoColors.systemYellow),
                          ),
                          onTap: _onForgottenPasswordTap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //GOMBOK KATTINTÁSAI
  void onLoginPressed() {
    setState(() {
      loading = true;
    });
    var body = new Map<String, dynamic>();
    body['username'] = _emailController.text.split(' ').first;
    body['password'] = _passwordController.text;
    session
        .postLogin(
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
            if (user.active) {
              setState(() {
                loading = false;
              });
              authSqfLiteHandler.insertUser(AuthUser(
                  id: 0,
                  email: _emailController.text.split(' ').first,
                  password: _passwordController.text));
              if (user.roles.contains('ROLE_COMPANY') &&
                  !user.isCompanyActive) {
                Fluttertoast.showToast(
                    msg: languages.subscribeWarningMessage,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 4,
                    backgroundColor: CupertinoColors.systemYellow,
                    textColor: Colors.black,
                    fontSize: 16.0);
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MainWidget(
                        session: session, user: user, languages: languages)),
              );
            } else {
              setState(() {
                loading = false;
              });
              showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setInnerState) {
                      return loading
                          ? Container(
                              child: Center(
                                child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
                              ),
                            )
                          : AlertDialog(
                              backgroundColor: Colors.grey[900],
                              title: Text(
                                languages.confirmationWarningMessage,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: CupertinoColors.systemYellow),
                              ),
                              content: Container(
                                height: 100,
                                child: Center(
                                  child: Text(
                                    languages.spamFolderTipMessage,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: CupertinoColors.systemYellow),
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    languages.cancelLabel,
                                    style: TextStyle(color: CupertinoColors.systemYellow),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _onVerificationEmailResent(setInnerState);
                                  },
                                  child: Text(
                                    languages.requestNewVerificationEmailLabel,
                                    style: TextStyle(color: CupertinoColors.systemYellow),
                                  ),
                                )
                              ],
                            );
                    });
                  });
            }
          }
        });
      } else if (res.statusCode == 401) {
        setState(() {
          loading = false;
        });
        Fluttertoast.showToast(
            msg: languages.wrongCredentialsErrorMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        setState(() {
          loading = false;
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

  void onRegistrationPressed() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return RegistrationWidget(
        languages: languages,
      );
    }));
  }

  void _onForgottenPasswordTap() {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setInnerState) {
            return loading
                ? Container(
                    child: Center(
                      child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: Colors.grey[900],
                    title: Text(
                      languages.forgottenPasswordHintLabel,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: CupertinoColors.systemYellow),
                    ),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      Center(
                        child: Container(
                          padding: EdgeInsets.only(left: 20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: CupertinoColors.systemYellow.withOpacity(0.7),
                          ),
                          child: TextField(
                            style: TextStyle(color: Colors.black),
                            controller: _forgottenPasswordEmailController,
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: languages.emailLabel,
                              hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                          ),
                        ),
                      )
                    ]),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          languages.cancelLabel,
                          style: TextStyle(color: CupertinoColors.systemYellow),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _onForgottenPasswordSendTap(setInnerState);
                        },
                        child: Text(
                          languages.sendLabel,
                          style: TextStyle(color: CupertinoColors.systemYellow),
                        ),
                      )
                    ],
                  );
          });
        });
  }

  void _onForgottenPasswordSendTap(setInnerState) {
    setInnerState(() {
      loading = true;
    });
    session
        .post(
            '/api/users/forgotPassword/${_forgottenPasswordEmailController.text}/${languages.countryCode}',
            Map<String, dynamic>())
        .then((response) {

      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        Navigator.of(context).pop();
        _forgottenPasswordEmailController.clear();
        Fluttertoast.showToast(
            msg: languages.forgottenPasswordSentMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        setInnerState(() {
          loading = false;
        });
        Fluttertoast.showToast(
            msg: languages.forgottenPasswordErrorMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  void _onVerificationEmailResent(StateSetter setInnerState) {
    setInnerState(() {
      loading = true;
    });
    session
        .postDomainJson(
            '/api/users/resendVerification/${_emailController.text.split(' ').first}/${languages.countryCode}',
            Map<String, String?>())
        .then((response) {
      if (response.statusCode == 200) {
        setState(() {
          loading = false;
        });
        Navigator.of(context).pop();
        _forgottenPasswordEmailController.clear();
        Fluttertoast.showToast(
            msg: languages.verificationEmailResentMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        setInnerState(() {
          loading = false;
        });
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
}
