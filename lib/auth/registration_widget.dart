import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../entities/session.dart';
import '../languages/languages.dart';
import '../languages/languages_sqflite_handler.dart';
import '../static/profanity_checker.dart';
import 'auth_sqflite_handler.dart';

class RegistrationWidget extends StatefulWidget {
  final Languages languages;

  const RegistrationWidget({required this.languages});

  @override
  _RegistrationWidgetState createState() => _RegistrationWidgetState();
}

class _RegistrationWidgetState extends State<RegistrationWidget> {
  late Languages languages;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regPassAgainController = TextEditingController();
  final _regNameController = TextEditingController();
  final _regCompanyNameController = TextEditingController();
  final _regCompanyDescriptionController = TextEditingController();
  Session session = Session();
  AuthSqfLiteHandler authSqfLiteHandler = AuthSqfLiteHandler();
  LanguagesSqfLiteHandler languagesSqfLiteHandler = LanguagesSqfLiteHandler();
  bool company = false;
  XFile? image;
  bool loading = false;
  List<String> countryCodes = [];
  String? _chosenCountryCode;
  bool isPolicyAccepted = false;

  @override
  void initState() {
    super.initState();
    countryCodes.add("Global");
    languages = widget.languages;
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: loading
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.yellow,
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.all(10),
                color: Colors.black,
                child: ListView(
                  children: [
                    Center(
                      child: Text(
                        languages.registrationLabel,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 25),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.black,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
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
                                  controller: _regEmailController,
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
                                  color: Colors.yellow.withOpacity(0.7),
                                ),
                                child: TextField(
                                  style: TextStyle(color: Colors.black),
                                  controller: _regPasswordController,
                                  cursorColor: Colors.black,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none),
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
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none),
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
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none),
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
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: Colors.yellow,
                              ),
                              padding: EdgeInsets.all(1),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: Colors.black,
                                ),
                                child: ListTile(
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
                              ),
                            ),
                            SizedBox(height: company ? 5 : 0),
                            company
                                ? Center(
                                    child: Container(
                                      height: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        color: Colors.yellow.withOpacity(0.7),
                                      ),
                                      padding: EdgeInsets.all(4),
                                      child: TextField(
                                          maxLines: 3000,
                                          cursorColor: Colors.black,
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
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      color: Colors.yellow,
                                    ),
                                    padding: EdgeInsets.all(1),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        color: Colors.black,
                                      ),
                                      child: ListTile(
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
                                                    backgroundColor:
                                                        Colors.yellow,
                                                    radius: 20,
                                                    backgroundImage: AssetImage(
                                                        "assets/images/add_image.png"),
                                                  ),
                                                ),
                                                onTap: () {
                                                  _addPicture(setState);
                                                },
                                              ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: company ? 5 : 0),
                            company
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      color: Colors.yellow,
                                    ),
                                    padding: EdgeInsets.all(1),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        color: Colors.black,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          focusColor: Colors.white,
                                          value: _chosenCountryCode,
                                          style:
                                              TextStyle(color: Colors.yellow),
                                          iconEnabledColor: Colors.yellow,
                                          dropdownColor: Colors.black,
                                          items: countryCodes
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                    color: Colors.yellow),
                                              ),
                                            );
                                          }).toList(),
                                          hint: Text(
                                            languages
                                                .locationWithGlobalHintLabel,
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
                                      ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: 5),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: Colors.yellow,
                              ),
                              padding: EdgeInsets.all(1),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: Colors.black,
                                ),
                                child: ListTile(
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
                                                text:
                                                    languages.acceptPolicyLabel,
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            languages.closeLabel,
                            style: TextStyle(color: Colors.yellow),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            onRegistrationActivatePressed(setState);
                          },
                          child: Text(
                            languages.registrationLabel,
                            style: TextStyle(color: Colors.yellow),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    color: Colors.yellow,
                    child: SingleChildScrollView(
                      child: Text(languages.userPolicyText),
                    ),
                  ),
                )
              ],
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
}
