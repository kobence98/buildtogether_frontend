import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../auth/auth_sqflite_handler.dart';
import '../entities/session.dart';
import '../entities/user.dart';
import '../languages/languages.dart';
import '../languages/languages_sqflite_handler.dart';
import '../static/safe_area.dart';
import 'change_location_widget.dart';
import 'change_password_widget.dart';
import 'change_user_data_widget.dart';
import 'handle_bans_widget.dart';

class MyAccountWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;
  final Function hideNavBar;
  final Function navBarStatusChangeableAgain;

  const MyAccountWidget(
      {Key? key,
      required this.languages,
      required this.session,
      required this.user,
      required this.hideNavBar,
      required this.navBarStatusChangeableAgain})
      : super(key: key);

  @override
  State<MyAccountWidget> createState() => _MyAccountWidgetState();
}

class _MyAccountWidgetState extends State<MyAccountWidget> {
  late Languages languages;
  AuthSqfLiteHandler authSqfLiteHandler = AuthSqfLiteHandler();
  late bool loading;
  LanguagesSqfLiteHandler languagesSqfLiteHandler = LanguagesSqfLiteHandler();

  @override
  void initState() {
    super.initState();
    loading = false;
    languages = widget.languages;
  }

  @override
  Widget build(BuildContext context) {
    return InnoSafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        body: Container(
          color: Colors.black,
          child: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  _menuPoint(languages.changePasswordLabel, Icons.password,
                      _onChangePasswordTap),
                  _menuPoint(languages.changeUserDataLabel, Icons.security,
                      _onChangeUserDataTap),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  _menuPoint(languages.changeLocationLabel, Icons.location_on,
                      _onChangeLocationTap),
                  _menuPoint(languages.handleBansLabel, Icons.not_interested,
                      _onHandleBansTap),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  _menuPoint(languages.logoutLabel, Icons.logout, _onLogoutTap),
                  _menuPoint(languages.deleteAccountLabel, Icons.delete_forever,
                      _onDeleteAccountTap),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onLogoutTap() {
    widget.session
        .post(
      '/api/logout',
      new Map<String, dynamic>(),
    )
        .then((res) {
      if (res.statusCode == 200) {
        widget.session.updateCookie(res);
        authSqfLiteHandler.deleteUsers();
        Phoenix.rebirth(context);
      }
    });
  }

  void _onChangePasswordTap() async {
    await widget.hideNavBar();
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => ChangePasswordWidget(
                  user: widget.user,
                  session: widget.session,
                  languages: languages,
                )))
        .whenComplete(() {
          widget.navBarStatusChangeableAgain();
          widget.hideNavBar();
    });
  }

  void _onChangeUserDataTap() async {
    await widget.hideNavBar();
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => ChangeUserDataWidget(
                  user: widget.user,
                  session: widget.session,
                  languages: languages,
                )))
        .then((message) {
      if (message != null && message == 'DATA_CHANGED') {
        Phoenix.rebirth(context);
      } else {
        widget.navBarStatusChangeableAgain();
        widget.hideNavBar();
      }
    });
  }

  void _onChangeLocationTap() async {
    await widget.hideNavBar();
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => ChangeLocationWidget(
                  user: widget.user,
                  session: widget.session,
                  languages: languages,
                )))
        .whenComplete(() {
          widget.navBarStatusChangeableAgain();
          widget.hideNavBar();
    });
  }

  void _onHandleBansTap() async {
    await widget.hideNavBar();
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => HandleBansWidget(
                  user: widget.user,
                  session: widget.session,
                  languages: languages,
                )))
        .whenComplete(() {
          widget.navBarStatusChangeableAgain();
          widget.hideNavBar();
    });
  }

  void _onDeleteAccountTap() {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setInnerState) {
            return loading
                ? Container(
                    child: Center(
                      child: Image(
                          image: new AssetImage(
                              "assets/images/loading_breath.gif")),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: Colors.red,
                    title: Text(
                      languages.deleteAccountWarningTitle,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                    content: Container(
                      child: Text(
                        languages.deleteAccountWarningMessage,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          languages.cancelLabel,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _onDeleteAccountDeleteButtonTap(setInnerState);
                        },
                        child: Text(
                          languages.deleteLabel,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  );
          });
        });
  }

  _onDeleteAccountDeleteButtonTap(setState) {
    setState(() {
      loading = true;
    });
    widget.session.delete('/api/users').then((response) {
      if (response.statusCode == 200) {
        loading = false;
        widget.session.updateCookie(response);
        authSqfLiteHandler.deleteUsers();
        Phoenix.rebirth(context);
        Fluttertoast.showToast(
            msg: languages.successfulAccountDeleteMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
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
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  Widget _menuPoint(String label, IconData icon, Function onTap) {
    return Flexible(
      flex: 1,
      child: InkWell(
        child: Container(
          margin: EdgeInsets.all(5),
          height: (MediaQuery.of(context).size.width - 15) / 2,
          width: (MediaQuery.of(context).size.width - 15) / 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: CupertinoColors.systemYellow,
          ),
          child: Stack(children: [
            Center(
              child: AutoSizeText(
                label,
                textAlign: TextAlign.center,
                maxFontSize: 30,
                minFontSize: 24,
                maxLines: 3,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              top: (MediaQuery.of(context).size.width - 15) / 16,
              left: (MediaQuery.of(context).size.width - 15) / 16,
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.black.withOpacity(0.05),
                  size: 150,
                ),
              ),
            )
          ]),
        ),
        onTap: () => onTap(),
      ),
    );
  }
}
