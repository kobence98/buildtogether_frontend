import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/auth/auth_sqflite_handler.dart';
import 'package:flutter_frontend/auth/auth_user.dart';
import 'package:flutter_frontend/widgets/main_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../entities/session.dart';
import '../../entities/user.dart';

class LoginPage extends StatefulWidget {
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
  bool company = false;
  XFile? image;
  bool loading = false;
  List<String> countryCodes = [];
  String? _chosenCountryCode;

  @override
  void initState() {
    super.initState();
    countryCodes.add("Global");
    session.get('/api/companies/countryCodes').then((response) {
      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        countryCodes.addAll(l.map((data) => data.toString()).toList());
        countryCodes.remove("Undefined");
      } else {
        Fluttertoast.showToast(
            msg: "Something went wrong! Check your network connection",
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
    //FIXME szebb háttér
    /*
    decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/main_cover.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        */

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
            width: 600,
            height: 1000,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0),
                    color: Colors.yellow.withOpacity(0.7),
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: _emailController,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle:
                            TextStyle(color: Colors.black.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0),
                    color: Colors.yellow.withOpacity(0.7),
                    child: TextField(
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: true,
                      style: TextStyle(color: Colors.black),
                      controller: _passwordController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle:
                            TextStyle(color: Colors.black.withOpacity(0.5)),
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
                            MaterialStateProperty.all<Color>(Colors.yellow),
                      ),
                      onPressed: onLoginPressed,
                      child: Text(
                        "Login",
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
                            MaterialStateProperty.all<Color>(Colors.yellow),
                      ),
                      child: Text(
                        "Registration",
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
                        "Forgotten password",
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
    var body = new Map<String, dynamic>();
    body['username'] = _emailController.text;
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
              authSqfLiteHandler.insertUser(AuthUser(
                  id: 0,
                  email: _emailController.text,
                  password: _passwordController.text));
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MainWidget(session: session, user: user)),
              );
            } else {
              showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return loading
                          ? Container(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : AlertDialog(
                              backgroundColor: Colors.black,
                              title: Text(
                                'Confirm your email address!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.yellow),
                              ),
                              content: Container(
                                height: 100,
                                child: Center(
                                  child: Text(
                                    'If you can\'t find it, check it in the spam folder, or request a new below.',
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
                                    'Cancel',
                                    style: TextStyle(color: Colors.yellow),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _onVerificationEmailResent(setState);
                                  },
                                  child: Text(
                                    'Request new verification email',
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
        Fluttertoast.showToast(
            msg: "Wrong credentials!",
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
                      child: CircularProgressIndicator(),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: Colors.black,
                    title: Text(
                      "Registration",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    content: new SingleChildScrollView(
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              padding: EdgeInsets.only(left: 20.0),
                              color: Colors.yellow.withOpacity(0.7),
                              child: TextField(
                                style: TextStyle(color: Colors.black),
                                controller: _regEmailController,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Email',
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
                              color: Colors.yellow.withOpacity(0.7),
                              child: TextField(
                                style: TextStyle(color: Colors.black),
                                controller: _regPasswordController,
                                cursorColor: Colors.black,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Password',
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
                              color: Colors.yellow.withOpacity(0.7),
                              child: TextField(
                                style: TextStyle(color: Colors.black),
                                controller: _regPassAgainController,
                                cursorColor: Colors.black,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Password again',
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
                              color: Colors.yellow.withOpacity(0.7),
                              child: TextField(
                                style: TextStyle(color: Colors.black),
                                controller: company
                                    ? _regCompanyNameController
                                    : _regNameController,
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  hintText: 'Name',
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
                                  "Switch if you are a " +
                                      (company ? "simple user." : "company."),
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
                                    color: Colors.yellow.withOpacity(0.7),
                                    padding: EdgeInsets.all(4),
                                    child: TextField(
                                        maxLines: 3000,
                                        maxLength: 1024,
                                        controller:
                                            _regCompanyDescriptionController,
                                        style: TextStyle(fontSize: 20),
                                        decoration: new InputDecoration
                                                .collapsed(
                                            hintText:
                                                'This is where you should write your company\'s description. Maximum of 256 characters.'),
                                        onChanged: (text) => setState(() {})),
                                  ),
                                )
                              : Container(),
                          SizedBox(height: company ? 5 : 0),
                          company
                              ? ListTile(
                                  leading: Text(
                                    'Add company logo:',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  title: image != null
                                      ? Center(
                                          child: InkWell(
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundImage:
                                                  FileImage(File(image!.path)),
                                            ),
                                          ),
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
                                        ),
                                  onTap: () {
                                    _addPicture(setState);
                                  },
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
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          onRegistrationActivatePressed(setState);
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
          });
        });
  }

  void onRegistrationActivatePressed(setState) {
    if (_regPasswordController.text == _regPassAgainController.text) {
      if (_regEmailController.text.isNotEmpty &&
          _regPasswordController.text.isNotEmpty &&
          ((company && _regCompanyNameController.text.isNotEmpty) ||
              (!company && _regNameController.text.isNotEmpty)) &&
          (!company || _regCompanyDescriptionController.text.isNotEmpty) &&
          (!company || image != null)) {
        dynamic body = <String, String?>{
          'email': _regEmailController.text,
          'password': _regPasswordController.text,
          'name': company
              ? _regCompanyNameController.text
              : _regNameController.text,
          'companyName': company ? _regCompanyNameController.text : null,
          'description': company ? _regCompanyDescriptionController.text : null,
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
                    loading = false;
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
                        msg:
                            "Successful registration, we sent you a confirmation email!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                });
              });
            } else {
              loading = false;
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
                  msg:
                      "Successful registration, we sent you a confirmation email!",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          } else if (response.statusCode == 400) {
            setState(() {
              loading = false;
            });
            Fluttertoast.showToast(
                msg: "Wrong email format!",
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
            msg: "Fill all fields properly!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(
          msg: "Passwords are not identical!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
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
                      child: CircularProgressIndicator(),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: Colors.black,
                    title: Text(
                      'Write your email address and we will send you a new password.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.yellow),
                    ),
                    content: Center(
                      child: Container(
                        padding: EdgeInsets.only(left: 20.0),
                        color: Colors.yellow.withOpacity(0.7),
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          controller: _forgottenPasswordEmailController,
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email address',
                            hintStyle:
                                TextStyle(color: Colors.black.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.yellow),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _onForgottenPasswordSendTap(setState);
                        },
                        child: Text(
                          'Send',
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
            msg: "We sent you an email with the new password!",
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
            msg:
                "Something went wrong, check if you wrote your email address properly!",
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
        .postDomainJson('/api/users/resendVerification/' + _emailController.text,
            Map<String, String?>())
        .then((response) {
      if (response.statusCode == 200) {
        loading = false;
        Navigator.of(context).pop();
        _forgottenPasswordEmailController.clear();
        Fluttertoast.showToast(
            msg: "We sent you a new verification email!",
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
            msg: "Something went wrong, check your network connection!",
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
