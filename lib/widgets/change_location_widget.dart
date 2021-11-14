import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangeLocationWidget extends StatefulWidget {
  final Session session;
  final User user;

  const ChangeLocationWidget({required this.session, required this.user});

  @override
  _ChangeLocationWidgetState createState() => _ChangeLocationWidgetState();
}

class _ChangeLocationWidgetState extends State<ChangeLocationWidget> {
  late bool _useLocation;
  List<String> countryCodes = [];
  String? _chosenCountryCode;
  bool _countryCodesLoaded = false;

  @override
  void initState() {
    super.initState();
    _useLocation = widget.user.setByLocale;

    countryCodes.add("Global");
    widget.session
        .get('/api/companies/countryCodes')
        .then((response) {
      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        countryCodes.addAll(l.map((data) => data.toString()).toList());
        countryCodes.remove("Undefined");
        _chosenCountryCode = widget.user.locale == null ? 'Global' : widget.user.locale;
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
                      Container(
                        child: Text(
                          _useLocation
                              ? 'Switch off if you don\'t want to use your location'
                              : 'Switch on if you want to use your location',
                          style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                      SizedBox(height: 5),
                      Center(
                        child: Container(
                          child: Switch(
                            value: _useLocation,
                            onChanged: (value) {
                              setState(() {
                                _useLocation = value;
                              });
                            },
                            activeTrackColor: Colors.yellow.shade200,
                            activeColor: Colors.yellow.shade600,
                            inactiveTrackColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: _useLocation ? 0 : 5),
                      _useLocation
                          ? Container()
                          : Container(
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
                                  "Location (if you want to see only global company posts)",
                                  style: TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                disabledHint: Text(
                                  "DDD (if you want to see only global company posts)",
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
                      SizedBox(
                        height: 20,
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
                              "Change location",
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
    if (!_useLocation && _chosenCountryCode == null) {
      Fluttertoast.showToast(
          msg: "Choose a location!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      dynamic body = <String, dynamic>{
        'setByLocale': _useLocation,
        'countryCode':
            _chosenCountryCode == 'Global' ? null : _chosenCountryCode,
      };
      widget.session
          .postJson(
        '/api/users/setCountryCode',
        jsonEncode(body),
      )
          .then((response) {
        if (response.statusCode == 200) {
          Navigator.of(context).pop();
          widget.user.locale = _chosenCountryCode;
          widget.user.setByLocale = _useLocation;
          Fluttertoast.showToast(
              msg: "Successful location change!",
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
    }
  }
}
