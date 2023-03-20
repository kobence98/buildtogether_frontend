import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangeLocationWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;
  final Function closeActualWidget;

  const ChangeLocationWidget(
      {required this.session, required this.user, required this.languages, required this.closeActualWidget});

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
    //
    // countryCodes.add("Global");
    // countryCodes.add("HU");
    // countryCodes.add("EN");
    // countryCodes.add("RU");
    // countryCodes.add("UK");
    // countryCodes.add("ES");
    // _chosenCountryCode =
    //     widget.user.locale == null ? 'Global' : widget.user.locale;
    // _countryCodesLoaded = true;
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
            languages.changeLocationLabel,
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
                              decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.all(2),
                                child: DropdownButton2<String>(
                                  dropdownScrollPadding:
                                      EdgeInsets.only(bottom: 5),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft:
                                                    Radius.circular(10)),
                                          ),
                                          width: 220,
                                          child: Center(
                                            child: Text(
                                              _chosenCountryCode!,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.yellow,
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        IconTheme(
                                          data: IconThemeData(
                                            color: Colors.yellow,
                                            size: 24,
                                          ),
                                          child: Icon(
                                              Icons.arrow_drop_down_outlined),
                                        ),
                                      ],
                                    ),
                                  ),
                                  items: countryCodes
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: value ==
                                                    countryCodes.first
                                                ? BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                  )
                                                : (value == countryCodes.last
                                                    ? BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                10),
                                                        bottomRight:
                                                            Radius.circular(
                                                                10),
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
