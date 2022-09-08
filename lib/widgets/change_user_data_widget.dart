import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/company.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/static/profanity_checker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';

class ChangeUserDataWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;

  const ChangeUserDataWidget(
      {required this.session, required this.user, required this.languages});

  @override
  _ChangeUserDataWidgetState createState() => _ChangeUserDataWidgetState();
}

class _ChangeUserDataWidgetState extends State<ChangeUserDataWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late bool _emailNotificationForCompany;
  late int _emailNotificationNumber;
  late bool company;
  List<String> countryCodes = [];
  String? _chosenCountryCode;
  bool _countryCodesLoaded = false;
  XFile? image;
  Company? companyData;
  late Languages languages;

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
    _nameController.text = widget.user.name;
    _emailNotificationForCompany =
        !(widget.user.emailNotificationForCompanyNumber == 0);
    _emailNotificationNumber = (!_emailNotificationForCompany ||
            widget.user.emailNotificationForCompanyNumber == 0)
        ? 100
        : widget.user.emailNotificationForCompanyNumber;

    company = widget.user.roles.contains('ROLE_COMPANY');

    countryCodes.add("Global");
    widget.session.get('/api/companies/countryCodes').then((response) {
      if (response.statusCode == 200) {
        Iterable l = json.decode(utf8.decode(response.bodyBytes));
        countryCodes.addAll(l.map((data) => data.toString()).toList());
        countryCodes.remove("Undefined");
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
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
                        Center(
                          child: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  child: Text(
                                    "${languages.nameLabel}: ",
                                    style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Flexible(
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
                                    controller: _nameController,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                      hintText: widget.user.name,
                                      hintStyle: TextStyle(
                                          color: Colors.black.withOpacity(0.5)),
                                    ),
                                  ),
                                ),
                                flex: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: company ? 10 : 0),
                        company
                            ? Container(
                                height: 200,
                                margin: EdgeInsets.only(left: 10, right: 10),
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
                              )
                            : Container(),
                        SizedBox(height: 20),
                        company && companyData != null
                            ? ListTile(
                                leading: Text(
                                  '${languages.logoLabel}:',
                                  style: TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                title: image != null
                                    ? InkWell(
                                        child: Center(
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundImage:
                                                FileImage(File(image!.path)),
                                          ),
                                        ),
                                        onTap: () {
                                          _addPicture(setState);
                                        },
                                      )
                                    : InkWell(
                                        child: Center(
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundImage: NetworkImage(
                                              widget.session.domainName +
                                                  "/api/images/" +
                                                  companyData!.imageId
                                                      .toString(),
                                              headers: widget.session.headers,
                                            ),
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
                                child: Text(
                                  languages.likesNotificationEmailTipLabel,
                                  style: TextStyle(
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              )
                            : Container(),
                        SizedBox(height: company ? 5 : 0),
                        company
                            ? Container(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Center(
                                        child: Container(
                                          child: Switch(
                                            value: _emailNotificationForCompany,
                                            onChanged: (value) {
                                              setState(() {
                                                _emailNotificationForCompany =
                                                    value;
                                              });
                                            },
                                            activeTrackColor:
                                                Colors.yellow.shade200,
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
                                                child: NumberPicker(
                                                  value:
                                                      _emailNotificationNumber,
                                                  minValue: 100,
                                                  textStyle: TextStyle(
                                                      color: Colors.yellow),
                                                  selectedTextStyle: TextStyle(
                                                      color: Colors.yellow,
                                                      fontSize: 30),
                                                  step: 100,
                                                  maxValue: 10000000,
                                                  onChanged: (value) =>
                                                      setState(() {
                                                    _emailNotificationNumber =
                                                        value;
                                                  }),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      flex: 1,
                                    ),
                                  ],
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
                                        style: TextStyle(color: Colors.yellow),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _chosenCountryCode = value;
                                    });
                                  },
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: company ? 20 : 0,
                        ),
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
                      ],
                    ),
                  ),
                ),
              )
            : Container(
          color: Colors.black,
          child: Center(
            child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
          ),
        )
      ),
    );
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
                    Navigator.of(context).pop('DATA_CHANGED');
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
              Navigator.of(context).pop('DATA_CHANGED');
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
    final ImagePicker _picker = ImagePicker();
    image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
