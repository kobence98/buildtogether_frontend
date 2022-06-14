import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/entities/company_for_search.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/static/profanity_checker.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreatePostWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;

  const CreatePostWidget(
      {required this.session, required this.user, required this.languages});

  @override
  _CreatePostWidgetState createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  List<CompanyForSearch> companies = [];
  CompanyForSearch? _selectedCompany;
  late bool company;

  List<TextEditingController> pollControllers = [];
  List<Widget> pollOptions = [];
  late bool isButtonEnabled;
  int nameLength = 0;

  late Languages languages;

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
    isButtonEnabled = true;
    company = widget.user.roles.contains('ROLE_COMPANY');
    pollControllers.add(TextEditingController());
    pollOptions.add(
      Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        padding: EdgeInsets.only(left: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          color: Colors.white,
        ),
        child: TextField(
          style: TextStyle(color: Colors.black),
          maxLength: 40,
          controller: pollControllers.first,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            counterText: '',
            focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
            hintText: languages.newPollOptionLabel,
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
          child: company && widget.user.isCompanyActive
              ? DefaultTabController(
                  initialIndex: 0,
                  length: 2,
                  child: Scaffold(
                    backgroundColor: Colors.black,
                    appBar: TabBar(
                        labelColor: Colors.yellow,
                        indicatorColor: Colors.yellow,
                        tabs: [
                          Tab(
                            child: Text(
                              languages.simplePostLabel,
                              style: TextStyle(color: Colors.yellow),
                            ),
                          ),
                          Tab(
                            child: Text(
                              languages.pollPostLabel,
                              style: TextStyle(color: Colors.yellow),
                            ),
                          ),
                        ]),
                    body: TabBarView(
                        children: [_simplePostWidget(), _pollPostWidget()]),
                  ),
                )
              : Scaffold(
                  body: _simplePostWidget(),
                )),
    );
  }

  void _onPostSimplePressed() {
    isButtonEnabled = false;
    if (ProfanityChecker.alert(
        _descriptionController.text + ' ' + _titleController.text)) {
      setState(() {
        isButtonEnabled = true;
      });
      Fluttertoast.showToast(
          msg: languages.profanityWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      if (_selectedCompany == null) {
        setState(() {
          isButtonEnabled = true;
        });
        Fluttertoast.showToast(
            msg: languages.companyChooseHintLabel,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (_titleController.text.isEmpty ||
          _descriptionController.text.isEmpty) {
        setState(() {
          isButtonEnabled = true;
        });
        Fluttertoast.showToast(
            msg: languages.fillAllFieldsWarningMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        dynamic body = <String, String>{
          'title': _titleController.text,
          'companyId': _selectedCompany!.id.toString(),
          'description': _descriptionController.text
        };
        widget.session
            .postJson(
          '/api/posts',
          body,
        )
            .then((response) {
          if (response.statusCode == 200) {
            setState(() {
              isButtonEnabled = true;
            });
            _titleController.clear();
            _companyNameController.clear();
            _descriptionController.clear();
            Fluttertoast.showToast(
                msg: languages.postIsOutMessage,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
            Phoenix.rebirth(context);
          }
        });
      }
    }
  }

  Widget _simplePostWidget() {
    return Container(
      color: Colors.black,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 30,
          ),
          ListTile(
            title: Text(
              languages.whatIsYourIdeaLabel,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          _selectedCompany == null
              ? Container(
                  height: 35,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(4),
                  child: TypeAheadField(
                    noItemsFoundBuilder: (context) {
                      return Container(
                        padding: EdgeInsets.all(1),
                        color: Colors.yellow,
                        child: Container(
                          color: Colors.black,
                          child: ListTile(
                            leading: Icon(
                              Icons.not_interested_rounded,
                              color: Colors.yellow,
                            ),
                            title: Text(
                              languages.noItemsFoundLabel,
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    },
                    minCharsForSuggestions: 1,
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: new InputDecoration.collapsed(
                          hintText: languages.companyNameLabel),
                      controller: _companyNameController,
                      cursorColor: Colors.black,
                      autofocus: true,
                      style: TextStyle(fontSize: 20),
                    ),
                    suggestionsCallback: (pattern) async {
                      dynamic response = await widget.session
                          .get("/api/companies/getByName/" + pattern);
                      if (response.statusCode == 200) {
                        widget.session.updateCookie(response);
                        Iterable l =
                            json.decode(utf8.decode(response.bodyBytes));
                        companies = List<CompanyForSearch>.from(l.map(
                            (company) => CompanyForSearch.fromJson(company)));
                        List<String> resultList = [];
                        companies.forEach((company) {
                          resultList.add(company.id.toString());
                        });
                        return resultList;
                      }
                      return [];
                    },
                    itemBuilder: (context, c) {
                      CompanyForSearch company =
                          companies.where((cp) => cp.id.toString() == c).first;
                      return Container(
                        padding: EdgeInsets.all(1),
                        color: Colors.yellow,
                        child: Container(
                          color: Colors.black,
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
                            title: Text(
                              company.name,
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      setState(() {
                        CompanyForSearch company = companies
                            .where((cp) => cp.id.toString() == suggestion)
                            .first;
                        _companyNameController.text = company.name;
                        _selectedCompany = company;
                      });
                    },
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  padding: EdgeInsets.all(1),
                  color: Colors.yellow,
                  child: Container(
                    color: Colors.black,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          widget.session.domainName +
                              "/api/images/" +
                              _selectedCompany!.imageId.toString(),
                          headers: widget.session.headers,
                        ),
                      ),
                      title: Text(
                        _selectedCompany!.name,
                        style: TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      trailing: InkWell(
                        child: Icon(
                          Icons.clear,
                          color: Colors.yellow,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedCompany = null;
                            _companyNameController.clear();
                          });
                        },
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(4),
            child: TextField(
              controller: _titleController,
              style: TextStyle(fontSize: 20),
              decoration: new InputDecoration.collapsed(
                  hintText: languages.titleOfIdeaLabel),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            // height: MediaQuery.of(context).size.height - (company ? 450 : 350),
            margin: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(4),
            child: TextField(
                maxLines: null,
                maxLength: 2048,
                controller: _descriptionController,
                style: TextStyle(fontSize: 20),
                decoration: new InputDecoration.collapsed(
                    hintText: languages.writeHereYourIdeaLabel),
                onChanged: (text) => setState(() {})),
          ),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    isButtonEnabled
                        ? Colors.yellowAccent
                        : Colors.yellow.shade200),
              ),
              onPressed: isButtonEnabled ? _onPostSimplePressed : null,
              child: ListTile(
                title: Center(
                  child: Text("POST"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pollPostWidget() {
    return Container(
      color: Colors.black,
      child: ListView.builder(
          itemCount: pollOptions.length + 7,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return SizedBox(
                height: 30,
              );
            } else if (index == 1) {
              return ListTile(
                title: Text(
                  languages.whatIsYourIdeaLabel,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              );
            } else if (index == 2) {
              return SizedBox(
                height: 10,
              );
            } else if (index == 3) {
              return Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(10),
                child: TextField(
                  cursorColor: Colors.black,
                  controller: _titleController,
                  maxLength: 256,
                  style: TextStyle(fontSize: 20),
                  decoration: new InputDecoration(
                    isCollapsed: true,
                      counterText: '',
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: languages.pollShortDescriptionLabel),
                ),
              );
            } else if (index == 4) {
              return ListTile(
                title: Text(
                  '${languages.pollOptionsLabel}:',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              );
            }
            if (index < pollOptions.length + 5) {
              return pollOptions.elementAt(index - 5);
            } else if (index == pollOptions.length + 5) {
              return Container(
                margin: EdgeInsets.only(top: 20),
                child: Center(
                  child: ButtonTheme(
                    height: 70,
                    minWidth: MediaQuery.of(context).size.width - 5,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.yellowAccent),
                      ),
                      onPressed: _onAddOptionPressed,
                      child: Text(
                        languages.addOptionLabel,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        isButtonEnabled
                            ? Colors.yellowAccent
                            : Colors.yellow.shade200),
                  ),
                  onPressed: isButtonEnabled ? _onPostPollPressed : null,
                  child: ListTile(
                    title: Center(
                      child: Text(languages.POSTLabel),
                    ),
                  ),
                ),
              );
            }
          }),
    );
  }

  void _onAddOptionPressed() {
    setState(() {
      TextEditingController textEditingController = TextEditingController();
      pollControllers.add(textEditingController);
      pollOptions.add(
        Container(
          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
          padding: EdgeInsets.only(left: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Flexible(
                child: TextField(
                  style: TextStyle(color: Colors.black),
                  controller: textEditingController,
                  cursorColor: Colors.black,
                  maxLength: 40,
                  onChanged: (val) {
                    setState(() {
                      nameLength = val.length;
                    });
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                    hintText: languages.newPollOptionLabel,
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                  ),
                ),
                flex: 7,
              ),
              Flexible(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      int index =
                          pollControllers.indexOf(textEditingController);
                      pollControllers.removeAt(index);
                      pollOptions.removeAt(index);
                    });
                  },
                  icon: Icon(
                    Icons.highlight_remove,
                    color: Colors.black,
                  ),
                ),
                flex: 1,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _onPostPollPressed() {
    isButtonEnabled = false;
    bool pollsAreEmpty = false;
    String pollsConcat = '';
    pollControllers.forEach((poll) {
      if (poll.text.isEmpty) {
        pollsAreEmpty = true;
      } else {
        pollsConcat = pollsConcat + ' ' + poll.text;
      }
    });
    if (ProfanityChecker.alert(_titleController.text + ' ' + pollsConcat)) {
      setState(() {
        isButtonEnabled = true;
      });
      Fluttertoast.showToast(
          msg: languages.profanityWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      if (_titleController.text.isEmpty || pollsAreEmpty) {
        setState(() {
          isButtonEnabled = true;
        });
        Fluttertoast.showToast(
            msg: languages.fillAllFieldsWithPollOptionWarningMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        List<String> options = [];
        pollControllers.forEach((poll) {
          options.add(poll.text);
        });
        dynamic body = <String, dynamic>{
          'title': _titleController.text,
          'options': options
        };
        widget.session
            .postJson(
          '/api/posts/poll',
          body,
        )
            .then((response) {
          if (response.statusCode == 200) {
            _titleController.clear();
            _companyNameController.clear();
            _descriptionController.clear();
            setState(() {
              isButtonEnabled = true;
            });
            Fluttertoast.showToast(
                msg: languages.yourPostIsOutMessage,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
            Phoenix.rebirth(context);
          }
        });
      }
    }
  }
}
