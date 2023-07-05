import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/auth/auth_sqflite_handler.dart';
import 'package:flutter_frontend/auth/auth_user.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePasswordWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;

  const ChangePasswordWidget(
      {required this.session, required this.user, required this.languages});

  @override
  _ChangePasswordWidgetState createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  TextEditingController _passController = TextEditingController();
  TextEditingController _passAgainController = TextEditingController();
  AuthSqfLiteHandler authSqfLiteHandler = AuthSqfLiteHandler();
  late Languages languages;
  late bool _passwordVisible;
  late bool _passAgainVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _passAgainVisible = false;
    languages = widget.languages;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        body: Container(
          color: Colors.black,
          child: Center(
            child: Container(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
              width: 600,
              height: 1000,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        controller: _passController,
                        cursorColor: Colors.black,
                        enableSuggestions: false,
                        autocorrect: false,
                        obscureText: !_passwordVisible,
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
                          focusedBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: languages.passwordLabel,
                          hintStyle:
                              TextStyle(color: Colors.black.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
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
                        controller: _passAgainController,
                        cursorColor: Colors.black,
                        enableSuggestions: false,
                        autocorrect: false,
                        obscureText: !_passAgainVisible,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _passAgainVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                _passAgainVisible = !_passAgainVisible;
                              });
                            },
                          ),
                          focusedBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: languages.passAgainLabel,
                          hintStyle:
                              TextStyle(color: Colors.black.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: ButtonTheme(
                      height: 50,
                      minWidth: 300,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(CupertinoColors.systemYellow),
                        ),
                        onPressed: _onChangePressed,
                        child: Text(
                          languages.changePasswordLabel,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onChangePressed() {
    if (_passController.text == _passAgainController.text) {
      if (_passController.text.isEmpty) {
        Fluttertoast.showToast(
            msg: languages.fillAllFieldsWarningMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        dynamic body = <String, String?>{
          'password': _passController.text,
        };
        widget.session
            .postJson(
          '/api/users/changePassword',
          body,
        )
            .then((response) {
          if (response.statusCode == 200) {
            authSqfLiteHandler.deleteUsers();
            authSqfLiteHandler.insertUser(AuthUser(
                id: 0,
                email: widget.user.email,
                password: _passController.text));
            Navigator.of(context).pop();
            Fluttertoast.showToast(
                msg: languages.successfulPasswordChangeMessage,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 4,
                backgroundColor: Colors.green,
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
        });
      }
    } else {
      Fluttertoast.showToast(
          msg: languages.passwordsAreNotIdenticalWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  void dispose() {
    _passController.dispose();
    _passAgainController.dispose();
    super.dispose();
  }
}
