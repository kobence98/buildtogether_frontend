import 'dart:convert';
import 'dart:html';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/age_bracket.dart';
import 'package:flutter_frontend/entities/company.dart';
import 'package:flutter_frontend/entities/living_place_type.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/static/profanity_checker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';

import '../entities/gender.dart';
import '../entities/salary_type.dart';

class ChangeUserDataWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;
  final Function refreshApp;
  final Function closeActualWidget;

  const ChangeUserDataWidget(
      {required this.session,
      required this.user,
      required this.languages,
      required this.refreshApp,
      required this.closeActualWidget});

  @override
  _ChangeUserDataWidgetState createState() => _ChangeUserDataWidgetState();
}

class _ChangeUserDataWidgetState extends State<ChangeUserDataWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late bool _emailNotificationForCompany;
  late int _emailNotificationNumber;
  late int _numberOfHouseholdMembersValue;
  late bool company;
  List<String> countryCodes = [];
  String? _chosenCountryCode;
  bool _countryCodesLoaded = false;
  XFile? image;
  Company? companyData;
  late Languages languages;
  List<Widget> widgetList = [];
  AgeBracket? _chosenAgeBracket;
  Gender? _chosenGender;
  LivingPlaceType? _chosenLivingPlaceType;
  SalaryType? _chosenSalaryType;
  List<int> houseHoldMembersHelperList = [];
  bool _imageLoading = false;

  @override
  void initState() {
    super.initState();
    window.history.pushState(null, 'changeUserData', '/changeUserData');
    languages = widget.languages;
    _nameController.text = widget.user.name;
    _emailNotificationForCompany =
        !(widget.user.emailNotificationForCompanyNumber == 0);
    _emailNotificationNumber = (!_emailNotificationForCompany ||
            widget.user.emailNotificationForCompanyNumber == 0)
        ? 100
        : widget.user.emailNotificationForCompanyNumber;
    _numberOfHouseholdMembersValue =
        widget.user.numberOfHouseholdMembers == null
            ? 1
            : widget.user.numberOfHouseholdMembers!;

    company = widget.user.roles.contains('ROLE_COMPANY');
    // company = false;
    //ADATOK BETÖLTÉSE AZ ÁTADOTT USER DATA-BÓL
    _chosenAgeBracket = widget.user.age;
    _chosenGender = widget.user.gender;
    _chosenLivingPlaceType = widget.user.livingPlaceType;
    _chosenSalaryType = widget.user.salaryType;

    widget.session.get('/api/companies/countryCodes').then((response) {
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
        _chosenCountryCode = widget.user.companyCountryCode == null
            ? 'Global'
            : widget.user.companyCountryCode;
        if (company) {
          widget.session
              .get('/api/companies/' + widget.user.companyId.toString())
              .then((response) {
            if (response.statusCode == 200) {
              setState(() {
                companyData = Company.fromJson(
                    json.decode(utf8.decode(response.bodyBytes)));
                _descriptionController.text = companyData!.description;
                _countryCodesLoaded = true;
              });
            }
          });
        } else {
          setState(() {
            _countryCodesLoaded = true;
          });
        }
      } else {
        Fluttertoast.showToast(
            msg: languages.countryCodesErrorMessage,
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
    if (company && companyData != null) {
      _addCompanyItems();
    } else if (!company) {
      _addNonCompanyItems();
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: InkWell(
            onTap: () => widget.closeActualWidget(),
            child: Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
            ),
          ),
          title: Center(
            child: Text(
              languages.changeUserDataLabel,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ),
        body: _countryCodesLoaded
            ? Container(
                color: Colors.black,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.height * 0.02),
                    child: ListView(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.yellow)),
                          padding: EdgeInsets.all(5),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      "${languages.nameLabel}: ",
                                      style: TextStyle(
                                          color: Colors.yellow,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.only(left: 20.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      color: Colors.yellow.withOpacity(0.7),
                                    ),
                                    child: TextField(
                                      style: TextStyle(color: Colors.black),
                                      controller: _nameController,
                                      maxLength: 30,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide.none),
                                        hintText: widget.user.name,
                                        hintStyle: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.5)),
                                      ),
                                    ),
                                  ),
                                  flex: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...widgetList,
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
                              onPressed: _onChangePressed,
                              child: Text(
                                languages.changeDataLabel,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                color: Colors.black,
                child: Center(
                  child: Image(
                      image:
                          new AssetImage("assets/images/loading_breath.gif")),
                ),
              ));
  }

  void _onChangePressed() {
    if (ProfanityChecker.alert(
        _descriptionController.text + ' ' + _nameController.text)) {
      Fluttertoast.showToast(
          msg: languages.profanityWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      if ((!company ||
              (_chosenCountryCode != null &&
                  _descriptionController.text.isNotEmpty)) &&
          _nameController.text.isNotEmpty) {
        dynamic body = <String, String?>{
          'name': _nameController.text,
          'emailNotificationForCompanyNumber': company
              ? (_emailNotificationForCompany ? _emailNotificationNumber : 0)
                  .toString()
              : null,
          'countryCode': !company ||
                  _chosenCountryCode == null ||
                  _chosenCountryCode == 'Global'
              ? null
              : _chosenCountryCode,
          'description': company ? _descriptionController.text : null,
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
        widget.session
            .postJson(
          '/api/users/updateUser',
          body,
        )
            .then((response) {
          if (response.statusCode == 200) {
            widget.user.name = _nameController.text;
            widget.user.emailNotificationForCompanyNumber =
                _emailNotificationForCompany ? _emailNotificationNumber : 0;
            widget.user.companyCountryCode = _chosenCountryCode;
            if (company && image != null) {
              image!.readAsBytes().then((multipartImage) {
                dynamic imageBody = <String, String>{
                  'companyId': widget.user.companyId.toString()
                };
                widget.session
                    .sendMultipart(
                        '/api/images/update', imageBody, multipartImage)
                    .then((response) {
                  if (response.statusCode == 200) {
                    Fluttertoast.showToast(
                        msg: languages.successfulCompanyDataChangeLabel,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 4,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    widget.refreshApp();
                  } else {
                    Fluttertoast.showToast(
                        msg: languages.pictureUpdateErrorMessage,
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
              Fluttertoast.showToast(
                  msg: languages.successfulDataChangeLabel,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 4,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0);
              widget.refreshApp();
            }
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
      } else {
        Fluttertoast.showToast(
            msg: company
                ? languages.fillAllFieldsWithLocationWarningMessage
                : languages.fillAllFieldsWarningMessage,
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
    setState(() {
      _imageLoading = true;
    });
    final ImagePicker _picker = ImagePicker();
    image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
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
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.all(2),
                  child: DropdownButton2<int>(
                    isExpanded: true,
                    underline: Container(),
                    focusColor: Colors.white,
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.yellow,
                    ),
                    value: _numberOfHouseholdMembersValue,
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
                            width: 220,
                            child: Center(
                              child: Text(
                                _numberOfHouseholdMembersValue.toString(),
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
                    items: houseHoldMembersHelperList
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: value ==
                                      houseHoldMembersHelperList.first
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    )
                                  : (value == houseHoldMembersHelperList.last
                                      ? BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        )
                                      : BorderRadius.zero)),
                          child: Center(
                            child: Text(
                              value.toString(),
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
                    onChanged: (int? value) {
                      setState(() {
                        _numberOfHouseholdMembersValue = value!;
                      });
                    },
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
                          width: 220,
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
                          width: 220,
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
                          width: 220,
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
                          width: 220,
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
    widgetList.add(
      SizedBox(
        height: 20,
      ),
    );
  }

  void _addCompanyItems() {
    widgetList.clear();
    widgetList.add(SizedBox(height: 10));
    widgetList.add(
      Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.yellow)),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Text(
                  "${languages.descriptionLabel}:",
                  style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.yellow,
              ),
              padding: EdgeInsets.all(4),
              child: TextField(
                  maxLines: 3000,
                  maxLength: 2048,
                  cursorColor: Colors.black,
                  controller: _descriptionController,
                  style: TextStyle(fontSize: 20),
                  decoration: new InputDecoration.collapsed(
                      hintText: languages.descriptionLabel),
                  onChanged: (text) => setState(() {})),
            ),
          ],
        ),
      ),
    );
    widgetList.add(SizedBox(height: 20));
    widgetList.add(
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.yellow)),
        child: ListTile(
          leading: Text(
            '${languages.logoLabel}:',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          title: _imageLoading
              ? InkWell(
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.black,
                radius: 20,
                backgroundImage:
                AssetImage("assets/images/loading_spin.gif"),
              ),
            ),
            onTap: () {
              _addPicture(setState);
            },
          )
              : (image != null
              ? InkWell(
            child: Center(
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(image!.path),
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
          )),
        ),
      ),
    );
    widgetList.add(SizedBox(height: 10));
    widgetList.add(
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.yellow)),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              child: Text(
                languages.likesNotificationEmailTipLabel,
                style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.yellow)),
              child: Row(
                children: [
                  Flexible(
                    child: Center(
                      child: Container(
                        child: Switch(
                          value: _emailNotificationForCompany,
                          onChanged: (value) {
                            setState(() {
                              _emailNotificationForCompany = value;
                            });
                          },
                          activeTrackColor: Colors.yellow.shade200,
                          activeColor: Colors.yellow.shade600,
                          inactiveTrackColor: Colors.white,
                        ),
                      ),
                    ),
                    flex: 1,
                  ),
                  Flexible(
                    child: _emailNotificationForCompany
                        ? Center(
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.yellow),
                                  color: Colors.yellow),
                              child: NumberPicker(
                                axis: Axis.horizontal,
                                itemWidth: 70,
                                itemHeight: 40,
                                value: _emailNotificationNumber,
                                minValue: 100,
                                textStyle: TextStyle(color: Colors.black),
                                selectedTextStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                                step: 100,
                                maxValue: 10000000,
                                onChanged: (value) => setState(() {
                                  _emailNotificationNumber = value;
                                }),
                              ),
                            ),
                          )
                        : Container(),
                    flex: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    widgetList.add(SizedBox(height: 10));
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
                "${languages.nationalityLabel}",
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
                          width: 220,
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
                      _chosenCountryCode = value;
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
    widgetList.add(SizedBox(height: 20));
  }
}
