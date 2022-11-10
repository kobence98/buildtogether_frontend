import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../entities/company.dart';
import '../entities/company_for_listing.dart';
import '../entities/session.dart';
import '../languages/languages.dart';

class CompaniesWidget extends StatefulWidget {
  final Session session;
  final Languages languages;

  const CompaniesWidget({required this.session, required this.languages});

  @override
  State<CompaniesWidget> createState() => _CompaniesWidgetState();
}

class _CompaniesWidgetState extends State<CompaniesWidget> {
  late bool dataLoading;
  late Languages languages;
  bool innerLoading = false;
  List<CompanyForListing> companies = [];

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
    dataLoading = true;
    widget.session.get('/api/companies').then((response) {
      if (response.statusCode == 200) {
        setState(() {
          widget.session.updateCookie(response);
          Iterable l = json.decode(utf8.decode(response.bodyBytes));
          companies = List<CompanyForListing>.from(
              l.map((model) => CompanyForListing.fromJson(model)));
          dataLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            automaticallyImplyLeading: true,
            title: Center(
              child: Text(
                languages.companiesLabel,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            actions: [
              Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Center(
                    child: InkWell(
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                      onTap: _onInfoButtonTap,
                    ),
                  ))
            ]),
        body: Container(
          color: Colors.black,
          child: dataLoading
              ? Container(
                  child: Center(
                    child: Image(
                        image:
                            new AssetImage("assets/images/loading_breath.gif")),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 10),
                  itemCount: companies.length,
                  itemBuilder: (context, index) {
                    CompanyForListing company = companies.elementAt(index);
                    return Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: company.active
                              ? CupertinoColors.systemYellow
                              : Colors.red),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            widget.session.domainName +
                                "/api/images/" +
                                company.imageId.toString(),
                            headers: widget.session.headers,
                          ),
                        ),
                        title: Container(
                          child: Text(
                            company.name,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        onTap: () => _onCompanyTap(company.id),
                      ),
                    );
                  }),
        ),
      ),
    );
  }

  void _onCompanyTap(int companyId) {
    widget.session
        .get('/api/companies/' + companyId.toString())
        .then((response) {
      if (response.statusCode == 200) {
        setState(() {
          Company company =
              Company.fromJson(json.decode(utf8.decode(response.bodyBytes)));
          showDialog(
              context: context,
              useRootNavigator: false,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          widget.session.domainName +
                              "/api/images/" +
                              company.imageId.toString(),
                          headers: widget.session.headers,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        company.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  ),
                  content: Container(
                    height: 100,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      child: Text(
                        company.description,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          languages.closeLabel,
                          style: TextStyle(color: Colors.yellow),
                        )),
                  ],
                );
              });
        });
      }
    });
  }

  void _onInfoButtonTap() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              languages.companiesInfoWindowDescription,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            content: Container(
              height: 200,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CupertinoColors.systemYellow),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            AssetImage("assets/images/launcher_icon.png"),
                      ),
                      title: Container(
                        child: Text(
                          languages.activeCompany,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage("assets/images/launcher_icon.png"),
                      ),
                      title: Container(
                        child: Text(
                          languages.inactiveCompany,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    languages.closeLabel,
                    style: TextStyle(color: Colors.yellow),
                  )),
            ],
          );
        });
  }
}
