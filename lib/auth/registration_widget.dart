import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../entities/age_bracket.dart';
import '../entities/gender.dart';
import '../entities/living_place_type.dart';
import '../entities/salary_type.dart';
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
  late String _chosenCountryCode;
  bool isPolicyAccepted = false;
  late bool _regPasswordVisible;
  late bool _regPassAgainVisible;

  List<Widget> widgetList = [];
  AgeBracket? _chosenAgeBracket;
  Gender? _chosenGender;
  LivingPlaceType? _chosenLivingPlaceType;
  SalaryType? _chosenSalaryType;
  late int _numberOfHouseholdMembersValue;

  @override
  void initState() {
    super.initState();
    _numberOfHouseholdMembersValue = 1;
    _chosenAgeBracket = AgeBracket.values.first;
    _chosenGender = Gender.values.first;
    _chosenLivingPlaceType = LivingPlaceType.values.first;
    _chosenSalaryType = SalaryType.values.first;
    _regPasswordVisible = false;
    _regPassAgainVisible = false;
    countryCodes.add("Global");
    languages = widget.languages;
    session.get('/api/companies/countryCodes').then((response) {
      if (response.statusCode == 200) {
        Iterable l = json.decode(utf8.decode(response.bodyBytes));
        countryCodes.addAll(l.map((data) => data.toString()).toList());
        countryCodes.remove("Undefined");
        countryCodes = countryCodes.toSet().toList();
        countryCodes.sort((String a, String b) {
          if (a == 'Global') {
            return -1;
          } else if (b == 'Global') {
            return 1;
          } else {
            if (a == 'Hungary') {
              return -1;
            } else if (b == 'Hungary') {
              return 1;
            } else {
              if (a == 'United Kingdom') {
                return -1;
              } else if (b == 'United Kingdom') {
                return 1;
              }
            }
          }
          return a.compareTo(b);
        });
        _chosenCountryCode = countryCodes.first;
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

  @override
  Widget build(BuildContext context) {
    if (company) {
      _addCompanyItems();
    } else {
      _addNonCompanyItems();
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: loading
            ? Container(
                child: Center(
                  child: Image(
                      image:
                          new AssetImage("assets/images/loading_breath.gif")),
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
                            color: Colors.yellow,
                            fontSize: 25),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.black,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 10),
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
                            SizedBox(height: 10),
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
                                  obscureText: !_regPasswordVisible,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        // Based on passwordVisible state choose the icon
                                        _regPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        // Update the state i.e. toogle the state of passwordVisible variable
                                        setState(() {
                                          _regPasswordVisible =
                                              !_regPasswordVisible;
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
                                  obscureText: !_regPassAgainVisible,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        // Based on passwordVisible state choose the icon
                                        _regPassAgainVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        // Update the state i.e. toogle the state of passwordVisible variable
                                        setState(() {
                                          _regPassAgainVisible =
                                              !_regPassAgainVisible;
                                        });
                                      },
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none),
                                    hintText: languages.passAgainLabel,
                                    hintStyle: TextStyle(
                                        color: Colors.black.withOpacity(0.5)),
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
                                  color: Colors.yellow.withOpacity(0.7),
                                ),
                                child: TextField(
                                  style: TextStyle(color: Colors.black),
                                  maxLength: company ? 100 : 30,
                                  controller: company
                                      ? _regCompanyNameController
                                      : _regNameController,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none),
                                    counterText: '',
                                    hintText: company
                                        ? languages.companyNameLabel
                                        : languages.nameLabel +
                                            languages.maxThirtyLengthLabel,
                                    hintStyle: TextStyle(
                                        color: Colors.black.withOpacity(0.5)),
                                  ),
                                ),
                              ),
                            ),
                            ...widgetList,
                            SizedBox(height: 10),
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
                            SizedBox(height: 10),
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
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (!isPolicyAccepted) {
      Fluttertoast.showToast(
          msg: languages.acceptPolicyWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
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
            'language': languages.countryCode,
            'numberOfHouseholdMembers':
                company ? null : _numberOfHouseholdMembersValue.toString(),
            'age': company || _chosenAgeBracket == null
                ? null
                : _chosenAgeBracket!.stringValue,
            'salaryType': company || _chosenSalaryType == null
                ? null
                : _chosenSalaryType!.stringValue,
            'livingPlaceType': company || _chosenLivingPlaceType == null
                ? null
                : _chosenLivingPlaceType!.stringValue,
            'gender': company || _chosenGender == null
                ? null
                : _chosenGender!.stringValue,
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
                          timeInSecForIosWeb: 4,
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
                          timeInSecForIosWeb: 4,
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
                    timeInSecForIosWeb: 4,
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
                  timeInSecForIosWeb: 4,
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
                    timeInSecForIosWeb: 4,
                    backgroundColor: Colors.red,
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
            } else {
              setInnerState(() {
                loading = false;
              });
              Fluttertoast.showToast(
                  msg: response.toString(),
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 4,
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
              timeInSecForIosWeb: 4,
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
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  void _addPicture(setState) async {
    await Permission.photos.request();
    final ImagePicker _picker = ImagePicker();
    image = await _picker
        .pickImage(source: ImageSource.gallery)
        .onError((error, stackTrace) {
      Fluttertoast.showToast(
          msg: languages.goToSettingsForPermission,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return null;
    });
    if (image != null &&
        (await image!.readAsBytes()).lengthInBytes >= 1048576) {
      image = null;
      Fluttertoast.showToast(
          msg: languages.imageFileSizeIsTooBigExceptionMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
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

  void _addNonCompanyItems() {
    widgetList.clear();
    widgetList.add(
      SizedBox(
        height: 10,
      ),
    );
    //NUMBER OF HOUSEHOLD MEMBERS
    widgetList.add(
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.yellow)),
        padding: EdgeInsets.all(5),
        child: Row(
          children: [
            Flexible(
              child: Container(
                child: Text(
                  "${languages.numberOfHouseholdMembersLabel}",
                  style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              flex: 1,
            ),
            Flexible(
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.yellow),
                      color: Colors.yellow),
                  child: NumberPicker(
                    axis: Axis.horizontal,
                    itemWidth: 50,
                    itemHeight: 40,
                    value: _numberOfHouseholdMembersValue,
                    minValue: 1,
                    textStyle: TextStyle(color: Colors.black),
                    selectedTextStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    step: 1,
                    maxValue: 99,
                    onChanged: (value) => setState(() {
                      _numberOfHouseholdMembersValue = value;
                    }),
                  ),
                ),
              ),
              flex: 1,
            ),
          ],
        ),
      ),
    );
    widgetList.add(
      SizedBox(
        height: 10,
      ),
    );
    //AGE BRACKET
    widgetList.add(Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellow),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              child: Text(
                "${languages.ageLabel}",
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            flex: 1,
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.all(2),
                child: DropdownButton2<AgeBracket>(
                  isExpanded: true,
                  underline: Container(),
                  focusColor: Colors.white,
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.yellow,
                  ),
                  value: _chosenAgeBracket,
                  style: TextStyle(color: Colors.yellow),
                  iconEnabledColor: Colors.yellow,
                  itemPadding: const EdgeInsets.all(1),
                  dropdownPadding: EdgeInsets.all(2),
                  scrollbarRadius: const Radius.circular(40),
                  itemSplashColor: Colors.yellow.shade100,
                  scrollbarThickness: 6,
                  dropdownMaxHeight: 200,
                  customButton: Container(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
                          ),
                          width: MediaQuery.of(context).size.width - 256,
                          child: Center(
                            child: Text(
                              _chosenAgeBracket!.getName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        IconTheme(
                          data: IconThemeData(
                            color: Colors.yellow,
                            size: 24,
                          ),
                          child: Icon(Icons.arrow_drop_down_outlined),
                        ),
                      ],
                    ),
                  ),
                  items: AgeBracket.values
                      .map<DropdownMenuItem<AgeBracket>>((AgeBracket value) {
                    return DropdownMenuItem<AgeBracket>(
                      value: value,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: value == AgeBracket.values.first
                                ? BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  )
                                : (value == AgeBracket.values.last
                                    ? BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      )
                                    : BorderRadius.zero)),
                        child: Center(
                          child: Text(
                            value.getName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (AgeBracket? value) {
                    setState(() {
                      _chosenAgeBracket = value;
                    });
                  },
                ),
              ),
            ),
            flex: 1,
          ),
        ],
      ),
    ));
    widgetList.add(
      SizedBox(
        height: 10,
      ),
    );
    //GENDER
    widgetList.add(Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellow),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              child: Text(
                "${languages.genderLabel}",
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            flex: 1,
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.all(2),
                child: DropdownButton2<Gender>(
                  isExpanded: true,
                  underline: Container(),
                  focusColor: Colors.white,
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.yellow,
                  ),
                  value: _chosenGender,
                  style: TextStyle(color: Colors.yellow),
                  iconEnabledColor: Colors.yellow,
                  itemPadding: const EdgeInsets.all(1),
                  dropdownPadding: EdgeInsets.all(2),
                  scrollbarRadius: const Radius.circular(40),
                  itemSplashColor: Colors.yellow.shade100,
                  scrollbarThickness: 6,
                  dropdownMaxHeight: 200,
                  customButton: Container(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
                          ),
                          width: MediaQuery.of(context).size.width - 256,
                          child: Center(
                            child: Text(
                              _chosenGender!.getName(languages),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        IconTheme(
                          data: IconThemeData(
                            color: Colors.yellow,
                            size: 24,
                          ),
                          child: Icon(Icons.arrow_drop_down_outlined),
                        ),
                      ],
                    ),
                  ),
                  items: Gender.values
                      .map<DropdownMenuItem<Gender>>((Gender value) {
                    return DropdownMenuItem<Gender>(
                      value: value,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: value == Gender.values.first
                                ? BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  )
                                : (value == Gender.values.last
                                    ? BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      )
                                    : BorderRadius.zero)),
                        child: Center(
                          child: Text(
                            value.getName(languages),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (Gender? value) {
                    setState(() {
                      _chosenGender = value;
                    });
                  },
                ),
              ),
            ),
            flex: 1,
          ),
        ],
      ),
    ));
    widgetList.add(
      SizedBox(
        height: 10,
      ),
    );
    //LIVING PLACE TYPE
    widgetList.add(Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellow),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              child: Text(
                "${languages.livingPlaceTypeLabel}",
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            flex: 1,
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.all(2),
                child: DropdownButton2<LivingPlaceType>(
                  isExpanded: true,
                  underline: Container(),
                  focusColor: Colors.white,
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.yellow,
                  ),
                  value: _chosenLivingPlaceType,
                  style: TextStyle(color: Colors.yellow),
                  iconEnabledColor: Colors.yellow,
                  itemPadding: const EdgeInsets.all(1),
                  dropdownPadding: EdgeInsets.all(2),
                  scrollbarRadius: const Radius.circular(40),
                  itemSplashColor: Colors.yellow.shade100,
                  scrollbarThickness: 6,
                  dropdownMaxHeight: 200,
                  customButton: Container(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
                          ),
                          width: MediaQuery.of(context).size.width - 256,
                          child: Center(
                            child: Text(
                              _chosenLivingPlaceType!.getName(languages),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        IconTheme(
                          data: IconThemeData(
                            color: Colors.yellow,
                            size: 24,
                          ),
                          child: Icon(Icons.arrow_drop_down_outlined),
                        ),
                      ],
                    ),
                  ),
                  items: LivingPlaceType.values
                      .map<DropdownMenuItem<LivingPlaceType>>(
                          (LivingPlaceType value) {
                    return DropdownMenuItem<LivingPlaceType>(
                      value: value,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: value == LivingPlaceType.values.first
                                ? BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  )
                                : (value == LivingPlaceType.values.last
                                    ? BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      )
                                    : BorderRadius.zero)),
                        child: Center(
                          child: Text(
                            value.getName(languages),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (LivingPlaceType? value) {
                    setState(() {
                      _chosenLivingPlaceType = value;
                    });
                  },
                ),
              ),
            ),
            flex: 1,
          ),
        ],
      ),
    ));
    widgetList.add(
      SizedBox(
        height: 10,
      ),
    );
    //SALARY TYPE
    widgetList.add(Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellow),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              child: Text(
                "${languages.salaryTypeLabel}",
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            flex: 1,
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.all(2),
                child: DropdownButton2<SalaryType>(
                  isExpanded: true,
                  underline: Container(),
                  focusColor: Colors.white,
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.yellow,
                  ),
                  value: _chosenSalaryType,
                  style: TextStyle(color: Colors.yellow),
                  iconEnabledColor: Colors.yellow,
                  itemPadding: const EdgeInsets.all(1),
                  dropdownPadding: EdgeInsets.all(2),
                  scrollbarRadius: const Radius.circular(40),
                  itemSplashColor: Colors.yellow.shade100,
                  scrollbarThickness: 6,
                  dropdownMaxHeight: 150,
                  customButton: Container(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
                          ),
                          width: MediaQuery.of(context).size.width - 256,
                          child: Center(
                            child: Text(
                              _chosenSalaryType!.getName(languages),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        IconTheme(
                          data: IconThemeData(
                            color: Colors.yellow,
                            size: 24,
                          ),
                          child: Icon(Icons.arrow_drop_down_outlined),
                        ),
                      ],
                    ),
                  ),
                  items: SalaryType.values
                      .map<DropdownMenuItem<SalaryType>>((SalaryType value) {
                    return DropdownMenuItem<SalaryType>(
                      value: value,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: value == SalaryType.values.first
                                ? BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  )
                                : (value == SalaryType.values.last
                                    ? BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      )
                                    : BorderRadius.zero)),
                        child: Center(
                          child: Text(
                            value.getName(languages),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (SalaryType? value) {
                    setState(() {
                      _chosenSalaryType = value;
                    });
                  },
                ),
              ),
            ),
            flex: 1,
          ),
        ],
      ),
    ));
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

  void _addCompanyItems() {
    widgetList.clear();
    widgetList.add(SizedBox(height: 10));
    widgetList.add(Center(
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
            controller: _regCompanyDescriptionController,
            style: TextStyle(fontSize: 20),
            decoration: new InputDecoration.collapsed(
                hintText: languages.companyDescriptionTipLabel),
            onChanged: (text) => setState(() {})),
      ),
    ));
    widgetList.add(SizedBox(height: 10));
    widgetList.add(Container(
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
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          title: image != null
              ? InkWell(
                  child: Center(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: FileImage(File(image!.path)),
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
                      backgroundImage:
                          AssetImage("assets/images/add_image.png"),
                    ),
                  ),
                  onTap: () {
                    _addPicture(setState);
                  },
                ),
        ),
      ),
    ));
    widgetList.add(SizedBox(height: 10));
    widgetList.add(Container(
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
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  child: Text(
                    "${languages.nationalityLabel}",
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                flex: 4,
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.all(2),
                    child: DropdownButton2<String>(
                      dropdownScrollPadding: EdgeInsets.only(bottom: 5),
                      isExpanded: true,
                      underline: Container(),
                      focusColor: Colors.white,
                      dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.yellow,
                      ),
                      value: _chosenCountryCode,
                      style: TextStyle(color: Colors.yellow),
                      iconEnabledColor: Colors.yellow,
                      itemPadding: const EdgeInsets.all(1),
                      dropdownPadding: EdgeInsets.all(2),
                      scrollbarRadius: const Radius.circular(40),
                      itemSplashColor: Colors.yellow.shade100,
                      scrollbarThickness: 6,
                      dropdownOverButton: true,
                      dropdownFullScreen: true,
                      customButton: Container(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                              ),
                              width: MediaQuery.of(context).size.width - 252,
                              child: Center(
                                child: Text(
                                  _chosenCountryCode!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconTheme(
                              data: IconThemeData(
                                color: Colors.yellow,
                                size: 24,
                              ),
                              child: Icon(Icons.arrow_drop_down_outlined),
                            ),
                          ],
                        ),
                      ),
                      items: countryCodes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: value == countryCodes.first
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      )
                                    : (value == countryCodes.last
                                        ? BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          )
                                        : BorderRadius.zero)),
                            child: Center(
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _chosenCountryCode = value!;
                        });
                      },
                    ),
                  ),
                ),
                flex: 5,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
