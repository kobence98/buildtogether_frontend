import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/auth/auth_sqflite_handler.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/language_code.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/languages/languages_sqflite_handler.dart';
import 'package:flutter_frontend/widgets/liked_posts_widget.dart';
import 'package:flutter_frontend/widgets/my_account_widget.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'companies_widget.dart';

class SettingsWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;
  final Function hideNavBar;
  final Function navBarStatusChangeableAgain;

  const SettingsWidget(
      {required this.session,
      required this.user,
      required this.languages,
      required this.navBarStatusChangeableAgain,
      required this.hideNavBar});

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
            Row(
              children: [
                _menuPoint(languages.myAccountLabel, Icons.perm_identity,
                    _onMyAccountTap),
                _menuPoint(
                    languages.companiesLabel, Icons.factory, _onCompaniesTap),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                _menuPoint(languages.likedPostsLabel, Icons.lightbulb,
                    _onLikedPostsTap),
                _menuPoint(languages.changeLanguageLabel, Icons.language,
                    _onChangeLanguageTap),
              ],
            ),
            SizedBox(height: 5),
            company
                ? Row(children: [
                    _menuPoint(languages.subscriptionHandlingLabel,
                        Icons.subscriptions, _onSubscriptionHandlingTap),
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(5),
                        height: (MediaQuery.of(context).size.width - 15) / 2,
                        width: (MediaQuery.of(context).size.width - 15) / 2,
                      ),
                    ),
                  ])
                : Container()
          ],
        ),
      ),
    );
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
                  color: CupertinoColors.systemYellow),
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
                            languagesSqfLiteHandler
                                .insertLanguageCode(
                                    LanguageCode(code: 'en', id: 0))
                                .whenComplete(() => Phoenix.rebirth(context));
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
                            languagesSqfLiteHandler
                                .insertLanguageCode(
                                    LanguageCode(code: 'hu', id: 0))
                                .whenComplete(() => Phoenix.rebirth(context));
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
                  style: TextStyle(color: CupertinoColors.systemYellow),
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
                      child: Image(
                          image: new AssetImage(
                              "assets/images/loading_breath.gif")),
                    ),
                  )
                : AlertDialog(
                    backgroundColor: Colors.grey[900],
                    title: Text(
                      '${languages.subscriptionHandlingLabel}.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: CupertinoColors.systemYellow),
                    ),
                    content: Container(
                      child: Text(
                        widget.user.isCompanyActive
                            ? languages.unsubscribeTipLabel
                            : languages.subscribeTipLabel,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: CupertinoColors.systemYellow),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          languages.cancelLabel,
                          style: TextStyle(color: CupertinoColors.systemYellow),
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
                          style: TextStyle(color: CupertinoColors.systemYellow),
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
        if (widget.user.isCompanyActive) {
          Fluttertoast.showToast(
              msg: languages.successfulSubscriptionMessage,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 4,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
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

  void _onLikedPostsTap() async {
    await widget.hideNavBar();
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => LikedPostsWidget(
                  user: widget.user,
                  session: widget.session,
                  languages: languages,
                )))
        .whenComplete(() => widget.navBarStatusChangeableAgain());
  }

  void _onCompaniesTap() async {
    await widget.hideNavBar();
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => CompaniesWidget(
                  session: widget.session,
                  languages: languages,
                )))
        .whenComplete(() => widget.navBarStatusChangeableAgain());
  }

  void _onMyAccountTap() async {
    await widget.hideNavBar();
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => MyAccountWidget(
                  session: widget.session,
                  user: widget.user,
                  languages: languages,
                  hideNavBar: widget.hideNavBar,
                  navBarStatusChangeableAgain:
                      widget.navBarStatusChangeableAgain,
                )))
        .whenComplete(() => widget.navBarStatusChangeableAgain());
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
