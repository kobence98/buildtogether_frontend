import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:numberpicker/numberpicker.dart';

class ChangeUserDataWidget extends StatefulWidget {
  final Session session;
  final User user;

  const ChangeUserDataWidget({required this.session, required this.user});

  @override
  _ChangeUserDataWidgetState createState() => _ChangeUserDataWidgetState();
}

class _ChangeUserDataWidgetState extends State<ChangeUserDataWidget> {
  TextEditingController _nameController = TextEditingController();
  late bool _emailNotificationForCompany;
  late int _emailNotificationNumber;
  late bool company;
  List<String> countryCodes = [];
  String? _chosenCountryCode;
  bool _countryCodesLoaded = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailNotificationForCompany =
        !(widget.user.emailNotificationForCompanyNumber == 0);
    _emailNotificationNumber = (!_emailNotificationForCompany ||
            widget.user.emailNotificationForCompanyNumber == 0)
        ? 100
        : widget.user.emailNotificationForCompanyNumber;
    company = widget.user.roles.contains('ROLE_COMPANY');
    countryCodes.add("Global");
    widget.session
        .get('/api/companies/countryCodes')
        .then((response) {
      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        countryCodes.addAll(l.map((data) => data.toString()).toList());
        countryCodes.remove("Undefined");
        _chosenCountryCode = widget.user.companyCountryCode == null ? 'Global' : widget.user.companyCountryCode;
        setState(() {
          _countryCodesLoaded = true;
        });
      } else {
        Fluttertoast.showToast(
            msg:
                "Something went wrong with the countries! Check your network connection",
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
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: _countryCodesLoaded
          ? Container(
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
                        child: Row(
                          children: [
                            Flexible(
                              child: Container(
                                child: Text(
                                  "Name: ",
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
                                color: Colors.yellow.withOpacity(0.7),
                                child: TextField(
                                  style: TextStyle(color: Colors.black),
                                  controller: _nameController,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
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
                      SizedBox(height: 20),
                      company
                          ? Container(
                              child: Text(
                                'Switch on if your company want to get an email notification after a specified number of likes on a post:',
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
                                                value: _emailNotificationNumber,
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
                                hint: Text(
                                  "Location (if you are a global company choose global)",
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
                      SizedBox(
                        height: company ? 20 : 0,
                      ),
                      Center(
                        child: ButtonTheme(
                          height: 50,
                          minWidth: 300,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.yellow),
                            ),
                            onPressed: _onChangePressed,
                            child: Text(
                              "Change data",
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
          : Container(),
    );
  }

  void _onChangePressed() {
    if ((!company || _chosenCountryCode != null) &&
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
      };
      widget.session
          .postJson(
        '/api/users/updateUser',
        jsonEncode(body),
      )
          .then((response) {
        if (response.statusCode == 200) {
          Navigator.of(context).pop();
          widget.user.name = _nameController.text;
          widget.user.emailNotificationForCompanyNumber =
              _emailNotificationForCompany ? _emailNotificationNumber : 0;
          widget.user.companyCountryCode = _chosenCountryCode;
          Fluttertoast.showToast(
              msg: "Successful data change!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: "Something went wrong!",
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
          msg: company
              ? "Fill all fields properly, choose a location as well!"
              : "Fill all fields properly!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
