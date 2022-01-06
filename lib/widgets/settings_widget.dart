import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/auth/auth_sqflite_handler.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'change_location_widget.dart';
import 'change_password_widget.dart';
import 'change_user_data_widget.dart';

class SettingsWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;

  const SettingsWidget(
      {required this.session, required this.user, required this.languages});

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  AuthSqfLiteHandler authSqfLiteHandler = AuthSqfLiteHandler();
  late bool loading;
  late Languages languages;

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    bool company = widget.user.roles.contains('ROLE_COMPANY');

    return Container(
      color: Colors.black,
      child: ListView(
        children: [
          SizedBox(
            height: 50,
          ),
          Container(
            color: Colors.yellowAccent,
            child: ListTile(
              leading: Icon(
                Icons.security,
                color: Colors.black,
              ),
              title: Text(
                'Change password',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              onTap: _onChangePasswordTap,
            ),
          ),
          SizedBox(height: 5),
          Container(
            color: Colors.yellowAccent,
            child: ListTile(
              leading: Icon(
                Icons.perm_identity,
                color: Colors.black,
              ),
              title: Text(
                'Change user data',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              onTap: _onChangeUserDataTap,
            ),
          ),
          SizedBox(height: 5),
          Container(
            color: Colors.yellowAccent,
            child: ListTile(
              leading: Icon(
                Icons.location_on,
                color: Colors.black,
              ),
              title: Text(
                'Change location',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              onTap: _onChangeLocationTap,
            ),
          ),
          SizedBox(height: 5),
          company
              ? Container(
                  color: Colors.yellowAccent,
                  child: ListTile(
                    leading: Icon(
                      Icons.subscriptions,
                      color: Colors.black,
                    ),
                    title: Text(
                      'Subscription handling',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    onTap: _onSubscriptionHandlingTap,
                  ),
                )
              : Container(),
          SizedBox(height: company ? 5 : 0),
          Container(
            color: Colors.yellowAccent,
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.black,
              ),
              title: Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              onTap: _onLogoutTap,
            ),
          ),
        ],
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

  void _onChangePasswordTap() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChangePasswordWidget(
              user: widget.user,
              session: widget.session,
              languages: languages,
            )));
  }

  void _onChangeUserDataTap() {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => ChangeUserDataWidget(
                  user: widget.user,
                  session: widget.session,
                  languages: languages,
                )))
        .whenComplete(() => Phoenix.rebirth(context));
  }

  void _onChangeLocationTap() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChangeLocationWidget(
              user: widget.user,
              session: widget.session,
              languages: languages,
            )));
  }

  void _onSubscriptionHandlingTap() {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return loading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.yellow,
                      ),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: Colors.black,
                    title: Text(
                      'Subscription handling.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.yellow),
                    ),
                    content: Container(
                      child: Text(
                        widget.user.isCompanyActive
                            ? 'Tap the button below to unsubscribe!'
                            : 'Until 5000 users the app ensure free subscription for companies. After that it will cost about 30 euros monthly. Its necessary to subscribe if you want to get ideas from users.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.yellow),
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
                          _onSubscriptionTap(setState);
                        },
                        child: Text(
                          widget.user.isCompanyActive
                              ? 'Unsubscribe'
                              : 'Subscribe',
                          style: TextStyle(color: Colors.yellow),
                        ),
                      )
                    ],
                  );
          });
        });
  }

  _onSubscriptionTap(setState) {
    setState(() {
      loading = true;
    });
    widget.session
        .postDomainJson(
            '/api/companies/' +
                widget.user.companyId.toString() +
                '/subscription',
            Map<String, String?>())
        .then((response) {
      if (response.statusCode == 200) {
        loading = false;
        Navigator.of(context).pop();
        widget.user.isCompanyActive = !widget.user.isCompanyActive;
        Fluttertoast.showToast(
            msg: "Successful subscription!",
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
