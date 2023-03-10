import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/entities/age_bracket.dart';
import 'package:flutter_frontend/entities/gender.dart';
import 'package:flutter_frontend/entities/salary_type.dart';
import 'package:flutter_frontend/widgets/posts_widget.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:url_strategy/url_strategy.dart';

import 'auth/login_widget.dart';
import 'entities/living_place_type.dart';
import 'entities/session.dart';
import 'entities/user.dart';
import 'languages/hungarian_language.dart';

void main() async{
  // HttpOverrides.global = MyHttpOverrides();
  setPathUrlStrategy();
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // String valami = '';

  @override
  void initState() {
    super.initState();
  //   //TODO kivenni csak teszt
  //   Session session = Session();
  //   session.get('/api/verificationToken/fdsafs').then((response) {
  //     setState(() {
  //       valami = utf8.decode(response.bodyBytes);
  //     });
  //   });
  }
  //TODO WEB MIATT EGYBŐL LOGIN PAGE MEHET, MAJD LEHET OKOSKODNI KÉSŐBB A LEMENTETT ADATOKKAL STB, DE EGYELŐRE JÓ ÍGY
  // Session session = Session();
  // AuthSqfLiteHandler authSqfLiteHandler = AuthSqfLiteHandler();
  // LanguagesSqfLiteHandler languagesSqfLiteHandler = LanguagesSqfLiteHandler();
  // late Languages languages;
  // Widget mainWidget = Container(
  //   color: Colors.black,
  //   child: Center(
  //     child: Image(image: new AssetImage("assets/images/loading_breath.gif")),
  //   ),
  // );

  // @override
  // void initState() {
  //   super.initState();
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  //   languagesSqfLiteHandler.retrieveLanguageCode().then((languageCode) {
  //     if (languageCode == null) {
  //       languages = LanguageEn();
  //     } else {
  //       switch (languageCode.code) {
  //         case 'en':
  //           languages = LanguageEn();
  //           break;
  //         case 'hu':
  //           languages = LanguageHu();
  //           break;
  //         default:
  //           languages = LanguageEn();
  //           break;
  //       }
  //     }
  //     authSqfLiteHandler.retrieveUser().then((authUser) {
  //       if (authUser != null) {
  //         var body = new Map<String, dynamic>();
  //         body['username'] = authUser.email;
  //         body['password'] = authUser.password;
  //         session
  //             .post(
  //           '/api/login',
  //           body,
  //         )
  //             .then((res) {
  //           if (res.statusCode == 200) {
  //             session.updateCookie(res);
  //             session.get('/api/users/getAuthenticatedUser').then((innerRes) {
  //               if (innerRes.statusCode == 200) {
  //                 session.updateCookie(innerRes);
  //                 User user = User.fromJson(
  //                     jsonDecode(utf8.decode(innerRes.bodyBytes)));
  //                 if (user.roles.contains('ROLE_COMPANY') &&
  //                     !user.isCompanyActive) {
  //                   Fluttertoast.showToast(
  //                       msg: languages.subscribeWarningMessage,
  //                       toastLength: Toast.LENGTH_LONG,
  //                       gravity: ToastGravity.CENTER,
  //                       timeInSecForIosWeb: 4,
  //                       backgroundColor: Colors.yellow,
  //                       textColor: Colors.black,
  //                       fontSize: 16.0);
  //                 }
  //                 setState(() {
  //                   mainWidget = MainWidget(
  //                     session: session,
  //                     user: user,
  //                     languages: languages,
  //                   );
  //                 });
  //               }
  //             });
  //           } else {
  //             authSqfLiteHandler.deleteUsers();
  //             Fluttertoast.showToast(
  //                 msg: languages.automaticLoginErrorMessage,
  //                 toastLength: Toast.LENGTH_LONG,
  //                 gravity: ToastGravity.CENTER,
  //                 timeInSecForIosWeb: 4,
  //                 backgroundColor: Colors.red,
  //                 textColor: Colors.white,
  //                 fontSize: 16.0);
  //             setState(() {
  //               mainWidget = LoginPage(languages: languages);
  //             });
  //           }
  //         });
  //       } else {
  //         setState(() {
  //           mainWidget = LoginPage(languages: languages);
  //         });
  //       }
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Text(valami),
    // );
    return LoginPage(languages: LanguageHu());
    return PostsWidget(
        session: Session(),
        user: User(
          userId: 1,
          email: 'kobence98@gmail.com',
          name: 'Kovács Bence',
          roles: ['ROLE_ONLINE_USER', 'ROLE_COMPANY'],
          active: true,
          emailNotificationForCompanyNumber: 0,
          locale: 'HU',
          setByLocale: false,
          companyCountryCode: 'HU',
          isCompanyActive: true,
          companyId: null,
          gender: Gender.OTHER,
          livingPlaceType: LivingPlaceType.TOWN,
          salaryType: SalaryType.FROM1M_TO_1_5M, numberOfHouseholdMembers: 10, age: AgeBracket.FROM_25_TO_34,
        ),
        initPage: 1,
        languages: LanguageHu(),
        navBarStatusChangeableAgain: () {},
        hideNavBar: () {});
  }
}
//
// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     HttpClient httpClient = super.createHttpClient(context);
//     File file = File('myCertificate.crt');
//     String myCert = file.readAsStringSync();
//     httpClient.badCertificateCallback =
//     ((X509Certificate cert, String host, int port) => cert.pem == myCert);
//     return httpClient;
//   }
// }

