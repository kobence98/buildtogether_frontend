import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangeLocationWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;

  const ChangeLocationWidget(
      {required this.session, required this.user, required this.languages});

  @override
  _ChangeLocationWidgetState createState() => _ChangeLocationWidgetState();
}

class _ChangeLocationWidgetState extends State<ChangeLocationWidget> {
  late bool _useLocation;
  List<String> countryCodes = [];
  String? _chosenCountryCode;
  bool _countryCodesLoaded = false;
  late Languages languages;

  @override
  void initState() {
    super.initState();
    _useLocation = widget.user.setByLocale;
    languages = widget.languages;

    countryCodes.add("Global");
    widget.session.get('/api/companies/countryCodes').then((response) {
      if (response.statusCode == 200) {
        Iterable l = json.decode(utf8.decode(response.bodyBytes));
        countryCodes.addAll(l.map((data) => data.toString()).toList());
        countryCodes.remove("Undefined");
        countryCodes = countryCodes.toSet().toList();
        countryCodes.sort((String a, String b){
          if(a == 'Global'){
            return -1;
          }
          else if(b == 'Global'){
            return 1;
          }
          else{
            if(a == 'Hungary'){
              return -1;
            }
            else if(b == 'Hungary'){
              return 1;
            }
            else{
              if(a == 'United Kingdom'){
                return -1;
              }
              else if(b == 'United Kingdom'){
                return 1;
              }
            }
          }
          return a.compareTo(b);
        });
        _chosenCountryCode =
            widget.user.locale == null ? 'Global' : widget.user.locale;
        setState(() {
          _countryCodesLoaded = true;
        });
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
                    width: 600,
                    height: 1000,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            _useLocation
                                ? languages.switchOffLocationUseLabel
                                : languages.switchOnLocationUseLabel,
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
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.yellow),
                              ),
                              onPressed: _onChangePressed,
                              child: Text(
                                languages.changeLocationLabel,
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
      ),
    );
  }

  void _onChangePressed() {
    if (!_useLocation && _chosenCountryCode == null) {
      Fluttertoast.showToast(
          msg: languages.chooseLocationWarningLabel,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
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
        body,
      )
          .then((response) {
        if (response.statusCode == 200) {
          Navigator.of(context).pop();
          widget.user.locale = _chosenCountryCode;
          widget.user.setByLocale = _useLocation;
          Fluttertoast.showToast(
              msg: languages.successfulLocationChangeMessage,
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
  }
}
