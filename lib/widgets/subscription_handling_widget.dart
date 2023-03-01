import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../entities/session.dart';
import '../entities/user.dart';
import '../languages/languages.dart';

class SubscriptionHandlingWidget extends StatefulWidget {
  final Languages languages;
  final User user;
  final Session session;

  const SubscriptionHandlingWidget(
      {Key? key,
      required this.languages,
      required this.user,
      required this.session})
      : super(key: key);

  @override
  State<SubscriptionHandlingWidget> createState() =>
      _SubscriptionHandlingWidgetState();
}

class _SubscriptionHandlingWidgetState
    extends State<SubscriptionHandlingWidget> {
  bool loading = false;
  late Languages languages;

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          height: 400,
          width: 400,
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.yellow,
              )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${languages.subscriptionHandlingLabel}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.yellow),
              ),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    widget.user.isCompanyActive
                        ? languages.unsubscribeTipLabel
                        : languages.subscribeTipLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.yellow),
                  ),
                ),
              ),
              Container(
                height: 30,
                child: TextButton(
                  onPressed: () {
                    _onSubscriptionTap();
                  },
                  child: Text(
                    widget.user.isCompanyActive
                        ? languages.unsubscribeLabel
                        : languages.subscribeLabel,
                    style: TextStyle(color: Colors.yellow),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _onSubscriptionTap() {
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
}
