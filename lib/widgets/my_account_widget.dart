import 'dart:html';

import 'package:autologin_plugin/autologin_plugin_web.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import '../auth/auth_sqflite_handler.dart';
import '../entities/session.dart';
import '../entities/user.dart';
import '../languages/languages.dart';
import '../languages/languages_sqflite_handler.dart';
import 'change_location_widget.dart';
import 'change_password_widget.dart';
import 'change_user_data_widget.dart';
import 'handle_bans_widget.dart';

class MyAccountWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;

  const MyAccountWidget({Key? key,
    required this.languages,
    required this.session,
    required this.user})
      : super(key: key);

  @override
  State<MyAccountWidget> createState() => _MyAccountWidgetState();
}

class _MyAccountWidgetState extends State<MyAccountWidget> {
  late Languages languages;
  AuthSqfLiteHandler authSqfLiteHandler = AuthSqfLiteHandler();
  late bool loading;
  LanguagesSqfLiteHandler languagesSqfLiteHandler = LanguagesSqfLiteHandler();
  Widget? _actualWidget;
  late List<bool> hovers = [false, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    loading = false;
    languages = widget.languages;
  }

  @override
  Widget build(BuildContext context) {
    return _actualWidget != null
        ? _actualWidget!
        : SafeArea(
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
                        _onChangePasswordTap, 0),
                    _menuPoint(languages.changeUserDataLabel, Icons.security,
                        _onChangeUserDataTap, 1),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    _menuPoint(languages.changeLocationLabel,
                        Icons.location_on, _onChangeLocationTap, 2),
                    _menuPoint(languages.handleBansLabel,
                        Icons.not_interested, _onHandleBansTap, 3),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    _menuPoint(
                        languages.logoutLabel, Icons.logout, _onLogoutTap, 4),
                    _menuPoint(languages.deleteAccountLabel,
                        Icons.delete_forever, _onDeleteAccountTap, 5),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  void _onLogoutTap() async {
    Response res = await widget.session.post(
      '/api/logout',
      new Map<String, dynamic>(),
    );
    if (res.statusCode == 200) {
      await AutologinPlugin.saveLoginData(username: widget.user.email, password: null);
      while(Navigator.canPop(context)){
        Navigator.pop(context);
      }
      Navigator.pushNamed(context, '/login');
    }
  }

  void _onChangePasswordTap() async {
    setState(() {
      _actualWidget = ChangePasswordWidget(
          user: widget.user,
          session: widget.session,
          languages: languages,
          closeActualWidget: () => _closeActualWidget());
    });
  }

  void _onChangeUserDataTap() async {
    setState(() {
      _actualWidget = ChangeUserDataWidget(
        user: widget.user,
        session: widget.session,
        languages: languages,
        refreshApp: () {
          Phoenix.rebirth(context);
        },
        closeActualWidget: () => _closeActualWidget(),
      );
    });
  }

  void _onChangeLocationTap() async {
    setState(() {
      _actualWidget = ChangeLocationWidget(
        user: widget.user,
        session: widget.session,
        languages: languages,
        closeActualWidget: () => _closeActualWidget(),
      );
    });
  }

  void _onHandleBansTap() async {
    setState(() {
      _actualWidget = HandleBansWidget(
        user: widget.user,
        session: widget.session,
        languages: languages,
        closeActualWidget: () => _closeActualWidget(),
      );
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

  Widget _menuPoint(String label, IconData icon, Function onTap,
      int hoverIndex) {
    return Flexible(
      flex: 1,
      child: InkWell(
        onHover: (val) {
          setState(() {
            hovers[hoverIndex] = val;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(top: (hovers.elementAt(hoverIndex)) ? 0 : 5,
              bottom: !(hovers.elementAt(hoverIndex)) ? 0 : 5),
          margin: EdgeInsets.all(5),
          height: 200,
          width: (MediaQuery
              .of(context)
              .size
              .width - 15) / 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: CupertinoColors.systemYellow,
          ),
          child: Stack(children: [
            Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            ),
            Center(
              child: Icon(
                icon,
                color: Colors.black.withOpacity(0.05),
                size: 150,
              ),
            )
          ]),
        ),
        onTap: () => onTap(),
      ),
    );
  }

  _closeActualWidget() {
    setState(() {
      window.history.pushState(null, 'myAccount', '/myAccount');
      _actualWidget = null;
    });
  }
}
