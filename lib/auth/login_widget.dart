import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_frontend/auth/auth_sqflite_handler.dart';
import 'package:flutter_frontend/auth/auth_user.dart';
import 'package:flutter_frontend/languages/english_language.dart';
import 'package:flutter_frontend/languages/hungarian_language.dart';
import 'package:flutter_frontend/languages/language_code.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/languages/languages_sqflite_handler.dart';
import 'package:flutter_frontend/static/profanity_checker.dart';
import 'package:flutter_frontend/widgets/main_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../entities/session.dart';
import '../../entities/user.dart';

class LoginPage extends StatefulWidget {
  final Languages languages;

  const LoginPage({required this.languages});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regPassAgainController = TextEditingController();
  final _regNameController = TextEditingController();
  final _regCompanyNameController = TextEditingController();
  final _regCompanyDescriptionController = TextEditingController();
  final _forgottenPasswordEmailController = TextEditingController();
  Session session = Session();
  AuthSqfLiteHandler authSqfLiteHandler = AuthSqfLiteHandler();
  LanguagesSqfLiteHandler languagesSqfLiteHandler = LanguagesSqfLiteHandler();
  bool company = false;
  XFile? image;
  bool loading = false;
  List<String> countryCodes = [];
  String? _chosenCountryCode;
  late Languages languages;
  bool isPolicyAccepted = false;

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
    countryCodes.add("Global");
    session.get('/api/companies/countryCodes').then((response) {
      if (response.statusCode == 200) {
        Iterable l = json.decode(utf8.decode(response.bodyBytes));
        countryCodes.addAll(l.map((data) => data.toString()).toList());
        countryCodes.remove("Undefined");
      } else {
        Fluttertoast.showToast(
            msg: languages.globalErrorMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: loading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.yellow,
                    ),
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
                              color: Colors.yellow.withOpacity(0.7),
                            ),
                            child: TextField(
                              style: TextStyle(color: Colors.black),
                              controller: _emailController,
                              cursorColor: Colors.black,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
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
                              color: Colors.yellow.withOpacity(0.7),
                            ),
                            child: TextField(
                              enableSuggestions: false,
                              autocorrect: false,
                              obscureText: true,
                              style: TextStyle(color: Colors.black),
                              controller: _passwordController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
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
                                        Colors.yellow),
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
                                        Colors.yellow),
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
                                    color: Colors.yellow),
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regPassAgainController.dispose();
    _regNameController.dispose();
    _regCompanyNameController.dispose();
    _regCompanyDescriptionController.dispose();
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
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.yellow,
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
                    return StatefulBuilder(builder: (context, setState) {
                      return loading
                          ? Container(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.yellow,
                                ),
                              ),
                            )
                          : AlertDialog(
                              backgroundColor: Colors.grey[900],
                              title: Text(
                                languages.confirmationWarningMessage,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.yellow),
                              ),
                              content: Container(
                                height: 100,
                                child: Center(
                                  child: Text(
                                    languages.spamFolderTipMessage,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.yellow),
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
                                    style: TextStyle(color: Colors.yellow),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _onVerificationEmailResent(setState);
                                  },
                                  child: Text(
                                    languages.requestNewVerificationEmailLabel,
                                    style: TextStyle(color: Colors.yellow),
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
            timeInSecForIosWeb: 1,
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
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  void onRegistrationPressed() {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return loading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.yellow,
                      ),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: Colors.grey.shade900,
                    title: Text(
                      languages.registrationLabel,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    content: Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.black,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 5),
                            ListTile(
                              leading: Switch(
                                value: isPolicyAccepted,
                                onChanged: (value) {
                                  setState(() {
                                    isPolicyAccepted = value;
                                  });
                                },
                                activeTrackColor: Colors.yellow.shade200,
                                activeColor: Colors.yellow.shade600,
                                inactiveTrackColor: Colors.white,
                              ),
                              title: Container(
                                child: Center(
                                  child: RichText(
                                    text: new TextSpan(
                                      children: <TextSpan>[
                                        new TextSpan(
                                            text: languages.acceptPolicyLabel,
                                            style: new TextStyle(
                                                color: Colors.white)),
                                        new TextSpan(
                                            text: languages.userPolicyLabel,
                                            style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.yellow),
                                            recognizer:
                                                new TapGestureRecognizer()
                                                  ..onTap = () =>
                                                      _onPrivacyPolicyTap()),
                                        new TextSpan(
                                            text: '!',
                                            style: new TextStyle(
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                padding: EdgeInsets.only(left: 20.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: Colors.yellow.withOpacity(0.7),
                                ),
                                child: TextField(
                                  style: TextStyle(color: Colors.black),
                                  controller: _regEmailController,
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
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
                                  color: Colors.yellow.withOpacity(0.7),
                                ),
                                child: TextField(
                                  style: TextStyle(color: Colors.black),
                                  controller: _regPasswordController,
                                  cursorColor: Colors.black,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: languages.passwordLabel,
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
                                  color: Colors.yellow.withOpacity(0.7),
                                ),
                                child: TextField(
                                  style: TextStyle(color: Colors.black),
                                  controller: _regPassAgainController,
                                  cursorColor: Colors.black,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: languages.passAgainLabel,
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
                                  color: Colors.yellow.withOpacity(0.7),
                                ),
                                child: TextField(
                                  style: TextStyle(color: Colors.black),
                                  controller: company
                                      ? _regCompanyNameController
                                      : _regNameController,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    hintText: company
                                        ? languages.companyNameLabel
                                        : languages.nameLabel,
                                    hintStyle: TextStyle(
                                        color: Colors.black.withOpacity(0.5)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            ListTile(
                              leading: Switch(
                                value: company,
                                onChanged: (value) {
                                  setState(() {
                                    company = value;
                                    if (company == true) {
                                      _regCompanyNameController.text =
                                          _regNameController.text;
                                    } else {
                                      _regNameController.text =
                                          _regCompanyNameController.text;
                                    }
                                  });
                                },
                                activeTrackColor: Colors.yellow.shade200,
                                activeColor: Colors.yellow.shade600,
                                inactiveTrackColor: Colors.white,
                              ),
                              title: Container(
                                child: Center(
                                  child: Text(
                                    languages
                                        .switchBetweenCompanyAndSimpleUserLabel(
                                            company),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: company ? 5 : 0),
                            company
                                ? Center(
                                    child: Container(
                                      height: 300,
                                      margin:
                                          EdgeInsets.only(left: 10, right: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        color: Colors.yellow.withOpacity(0.7),
                                      ),
                                      padding: EdgeInsets.all(4),
                                      child: TextField(
                                          maxLines: 3000,
                                          maxLength: 1024,
                                          controller:
                                              _regCompanyDescriptionController,
                                          style: TextStyle(fontSize: 20),
                                          decoration: new InputDecoration
                                                  .collapsed(
                                              hintText: languages
                                                  .companyDescriptionTipLabel),
                                          onChanged: (text) => setState(() {})),
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: company ? 5 : 0),
                            company
                                ? ListTile(
                                    leading: Text(
                                      languages.addCompanyLogoLabel,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    title: image != null
                                        ? InkWell(
                                            child: Center(
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundImage: FileImage(
                                                    File(image!.path)),
                                              ),
                                            ),
                                            onTap: () {
                                              _addPicture(setState);
                                            },
                                          )
                                        : InkWell(
                                            child: Center(
                                              child: CircleAvatar(
                                                backgroundColor: Colors.yellow,
                                                radius: 20,
                                                backgroundImage: AssetImage(
                                                    "assets/images/add_image.png"),
                                              ),
                                            ),
                                            onTap: () {
                                              _addPicture(setState);
                                            },
                                          ),
                                  )
                                : Container(),
                            SizedBox(height: company ? 5 : 0),
                            company
                                ? Container(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      focusColor: Colors.white,
                                      value: _chosenCountryCode,
                                      style: TextStyle(color: Colors.yellow),
                                      iconEnabledColor: Colors.yellow,
                                      dropdownColor: Colors.black,
                                      items: countryCodes
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style:
                                                TextStyle(color: Colors.yellow),
                                          ),
                                        );
                                      }).toList(),
                                      hint: Text(
                                        languages.locationWithGlobalHintLabel,
                                        style: TextStyle(
                                            color: Colors.yellow,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      onChanged: (String? value) {
                                        setState(() {
                                          _chosenCountryCode = value;
                                        });
                                      },
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          languages.closeLabel,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          onRegistrationActivatePressed(setState);
                        },
                        child: Text(
                          languages.registrationLabel,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
          });
        });
  }

  void onRegistrationActivatePressed(setInnerState) {
    if (ProfanityChecker.alert(_regNameController.text +
        ' ' +
        _regCompanyDescriptionController.text +
        ' ' +
        _regCompanyNameController.text)) {
      Fluttertoast.showToast(
          msg: languages.profanityWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (!isPolicyAccepted) {
      Fluttertoast.showToast(
          msg: languages.acceptPolicyWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      if (_regPasswordController.text == _regPassAgainController.text) {
        if (_regEmailController.text.split(' ').first.isNotEmpty &&
            _regPasswordController.text.isNotEmpty &&
            ((company && _regCompanyNameController.text.isNotEmpty) ||
                (!company && _regNameController.text.isNotEmpty)) &&
            (!company || _regCompanyDescriptionController.text.isNotEmpty) &&
            (!company || image != null)) {
          dynamic body = <String, String?>{
            'email': _regEmailController.text.split(' ').first,
            'password': _regPasswordController.text,
            'name': company
                ? _regCompanyNameController.text
                : _regNameController.text,
            'companyName': company ? _regCompanyNameController.text : null,
            'description':
                company ? _regCompanyDescriptionController.text : null,
            'countryCode': !company ||
                    _chosenCountryCode == null ||
                    _chosenCountryCode == 'Global'
                ? null
                : _chosenCountryCode,
          };
          setState(() {
            loading = true;
          });
          session
              .postDomainJson(
            '/api/users',
            body,
          )
              .then((response) {
            if (response.statusCode == 200) {
              if (company) {
                image!.readAsBytes().then((multipartImage) {
                  dynamic imageBody = <String, String>{
                    'companyId': response.body.toString()
                  };
                  session
                      .sendMultipart('/api/images', imageBody, multipartImage)
                      .then((response) {
                    if (response.statusCode == 200) {
                      Navigator.of(context).pop();
                      setState(() {
                        _emailController.clear();
                        _passwordController.clear();
                        _regEmailController.clear();
                        _regPasswordController.clear();
                        _regPassAgainController.clear();
                        _regNameController.clear();
                        _regCompanyNameController.clear();
                        _regCompanyDescriptionController.clear();
                        loading = false;
                      });
                      Fluttertoast.showToast(
                          msg: languages.successfulRegistrationMessage,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else {
                      setInnerState(() {
                        loading = false;
                      });
                      Fluttertoast.showToast(
                          msg: languages.globalServerErrorMessage,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  });
                });
              } else {
                setState(() {
                  loading = false;
                });
                _emailController.clear();
                _passwordController.clear();
                _regEmailController.clear();
                _regPasswordController.clear();
                _regPassAgainController.clear();
                _regNameController.clear();
                _regCompanyNameController.clear();
                _regCompanyDescriptionController.clear();
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                    msg: languages.successfulRegistrationMessage,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            } else if (response.statusCode == 400) {
              setInnerState(() {
                loading = false;
              });
              Fluttertoast.showToast(
                  msg: languages.wrongEmailFormatWarningMessage,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else if (response.statusCode == 500) {
              setInnerState(() {
                loading = false;
              });
              if (response.body != null &&
                  json.decode(response.body)['message'] != null &&
                  json.decode(response.body)['message'] ==
                      'Email is already in use!') {
                Fluttertoast.showToast(
                    msg: languages.emailIsAlreadyInUseWarningMessage,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              } else {
                Fluttertoast.showToast(
                    msg: languages.globalErrorMessage,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            } else {
              setInnerState(() {
                loading = false;
              });
              Fluttertoast.showToast(
                  msg: response.toString(),
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          });
        } else {
          Fluttertoast.showToast(
              msg: languages.fillAllFieldsProperlyWarningMessage,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        setInnerState(() {
          loading = false;
        });
        Fluttertoast.showToast(
            msg: languages.passwordsAreNotIdenticalWarningMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  void _addPicture(setState) async {
    final ImagePicker _picker = ImagePicker();
    image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  void _onForgottenPasswordTap() {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return loading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.yellow,
                      ),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: Colors.grey[900],
                    title: Text(
                      languages.forgottenPasswordHintLabel,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.yellow),
                    ),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      Center(
                        child: Container(
                          padding: EdgeInsets.only(left: 20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: Colors.yellow.withOpacity(0.7),
                          ),
                          child: TextField(
                            style: TextStyle(color: Colors.black),
                            controller: _forgottenPasswordEmailController,
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
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
                          style: TextStyle(color: Colors.yellow),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _onForgottenPasswordSendTap(setState);
                        },
                        child: Text(
                          languages.sendLabel,
                          style: TextStyle(color: Colors.yellow),
                        ),
                      )
                    ],
                  );
          });
        });
  }

  void _onForgottenPasswordSendTap(setState) {
    setState(() {
      loading = true;
    });
    session
        .post(
            '/api/users/forgotPassword/' +
                _forgottenPasswordEmailController.text,
            Map<String, dynamic>())
        .then((response) {
      if (response.statusCode == 200) {
        loading = false;
        Navigator.of(context).pop();
        _forgottenPasswordEmailController.clear();
        Fluttertoast.showToast(
            msg: languages.forgottenPasswordSentMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        setState(() {
          loading = false;
        });
        Fluttertoast.showToast(
            msg: languages.forgottenPasswordErrorMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  void _onVerificationEmailResent(StateSetter setState) {
    setState(() {
      loading = true;
    });
    session
        .postDomainJson(
            '/api/users/resendVerification/' +
                _emailController.text.split(' ').first,
            Map<String, String?>())
        .then((response) {
      if (response.statusCode == 200) {
        loading = false;
        Navigator.of(context).pop();
        _forgottenPasswordEmailController.clear();
        Fluttertoast.showToast(
            msg: languages.verificationEmailResentMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        setState(() {
          loading = false;
        });
        Fluttertoast.showToast(
            msg: languages.globalErrorMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  //TODO atatvédelmi szabályzatot lecserélni
  void _onPrivacyPolicyTap() {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              languages.userPolicyTitle,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.yellow),
            ),
            content: Center(
              child: Container(
                height: 500,
                padding: EdgeInsets.all(20.0),
                color: Colors.yellow,
                child: SingleChildScrollView(
                  child: Text(languages.userPolicyText),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  languages.backLabel,
                  style: TextStyle(color: Colors.yellow),
                ),
              ),
            ],
          );
        });
  }
}
