import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/auth/auth_sqflite_handler.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/language_code.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/languages/languages_sqflite_handler.dart';
import 'package:flutter_frontend/widgets/liked_posts_widget.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'change_location_widget.dart';
import 'change_password_widget.dart';
import 'change_user_data_widget.dart';
import 'companies_widget.dart';
import 'handle_bans_widget.dart';

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
  LanguagesSqfLiteHandler languagesSqfLiteHandler = LanguagesSqfLiteHandler();

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
      child: SafeArea(
        child: ListView(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.yellowAccent,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.factory,
                  color: Colors.black,
                ),
                title: Text(
                  languages.companiesLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                onTap: _onCompaniesTap,
              ),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.yellowAccent,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.lightbulb,
                  color: Colors.black,
                ),
                title: Text(
                  languages.likedPostsLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                onTap: _onLikedPostsTap,
              ),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.yellowAccent,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.security,
                  color: Colors.black,
                ),
                title: Text(
                  languages.changePasswordLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                onTap: _onChangePasswordTap,
              ),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.yellowAccent,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.perm_identity,
                  color: Colors.black,
                ),
                title: Text(
                  languages.changeUserDataLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                onTap: _onChangeUserDataTap,
              ),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.yellowAccent,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: Colors.black,
                ),
                title: Text(
                  languages.changeLocationLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                onTap: _onChangeLocationTap,
              ),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.yellowAccent,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.not_interested,
                  color: Colors.black,
                ),
                title: Text(
                  languages.handleBansLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                onTap: _onHandleBansTap,
              ),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.yellowAccent,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.language,
                  color: Colors.black,
                ),
                title: Text(
                  languages.changeLanguageLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                onTap: _onChangeLanguageTap,
              ),
            ),
            SizedBox(height: 5),
            company
                ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.yellowAccent,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.subscriptions,
                  color: Colors.black,
                ),
                title: Text(
                  languages.subscriptionHandlingLabel,
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                onTap: _onSubscriptionHandlingTap,
              ),
            )
                : Container(),
            SizedBox(height: company ? 5 : 0),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.yellowAccent,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.black,
                ),
                title: Text(
                  languages.logoutLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                onTap: _onLogoutTap,
              ),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                color: Colors.yellowAccent,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Colors.black,
                ),
                title: Text(
                  languages.deleteAccountLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                onTap: _onDeleteAccountTap,
              ),
            ),
          ],
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
        .then((message) {
          if(message != null && message == 'DATA_CHANGED'){
            Phoenix.rebirth(context);
          }
    });
  }

  void _onChangeLocationTap() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChangeLocationWidget(
              user: widget.user,
              session: widget.session,
              languages: languages,
            )));
  }

  void _onChangeLanguageTap() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: Text(
                    languages.changeLanguageLabel,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.yellow),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 30,
                                  foregroundImage: AssetImage(
                                      'icons/flags/png/gb.png',
                                      package: 'country_icons'),
                                ),
                                onTap: () {
                                  languagesSqfLiteHandler.insertLanguageCode(
                                      LanguageCode(code: 'en', id: 0)).whenComplete(() => Phoenix.rebirth(context));
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 30,
                                  foregroundImage: AssetImage(
                                      'icons/flags/png/hu.png',
                                      package: 'country_icons'),
                                ),
                                onTap: () {
                                  languagesSqfLiteHandler.insertLanguageCode(
                                      LanguageCode(code: 'hu', id: 0)).whenComplete(() => Phoenix.rebirth(context));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        languages.cancelLabel,
                        style: TextStyle(color: Colors.yellow),
                      ),
                    ),
                  ],
                );
        });
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
                      child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
                    ),
                  )
                : AlertDialog(
              backgroundColor: Colors.grey[900],
                    title: Text(
                      '${languages.subscriptionHandlingLabel}.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.yellow),
                    ),
                    content: Container(
                      child: Text(
                        widget.user.isCompanyActive
                            ? languages.unsubscribeTipLabel
                            : languages.subscribeTipLabel,
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
                          languages.cancelLabel,
                          style: TextStyle(color: Colors.yellow),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _onSubscriptionTap(setState);
                        },
                        child: Text(
                          widget.user.isCompanyActive
                              ? languages.unsubscribeLabel
                              : languages.subscribeLabel,
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
        if(widget.user.isCompanyActive){
          Fluttertoast.showToast(
              msg: languages.successfulSubscriptionMessage,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 4,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        }
        else{
          Fluttertoast.showToast(
              msg: languages.successfulSubscriptionCancelMessage,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 4,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        }
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

  void _onHandleBansTap() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HandleBansWidget(
          user: widget.user,
          session: widget.session,
          languages: languages,
        )));
  }

  void _onDeleteAccountTap() {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return loading
                ? Container(
              child: Center(
                child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
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
                child: Text(languages.deleteAccountWarningMessage,
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
                    _onDeleteAccountDeleteButtonTap(setState);
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
    widget.session
        .delete(
        '/api/users')
        .then((response) {
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

  void _onLikedPostsTap() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LikedPostsWidget(
          user: widget.user,
          session: widget.session,
          languages: languages,
        )));
  }

  void _onCompaniesTap() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CompaniesWidget(
          session: widget.session,
          languages: languages,
        )));
  }
}
