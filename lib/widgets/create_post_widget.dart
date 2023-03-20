import 'dart:convert';
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/entities/company_for_search.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/static/profanity_checker.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

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
  final FocusNode _companyNameFocus = FocusNode();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pollTitleController = TextEditingController();
  final FocusNode _pollTitleNameFocus = FocusNode();
  XFile? image;
  List<CompanyForSearch> companies = [];
  CompanyForSearch? _selectedCompany;
  late bool company;

  List<TextEditingController> pollControllers = [];
  List<Widget> pollOptions = [];
  List<FocusNode> pollFocusNodes = [];
  late bool isButtonEnabled;
  int nameLength = 0;

  late Languages languages;

  ScrollController _simplePostScrollController = ScrollController();
  ScrollController _pollPostScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
    isButtonEnabled = true;
    company = widget.user.roles.contains('ROLE_COMPANY');
    TextEditingController first = TextEditingController();
    TextEditingController second = TextEditingController();
    pollControllers.add(first);
    pollControllers.add(second);
    _addInitPollOption(first);
    _addInitPollOption(second);
    _companyNameFocus.requestFocus();
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
                        onTap: (int index) {
                          if (index == 0) {
                            _companyNameFocus.requestFocus();
                          } else if (index == 1) {
                            _pollTitleNameFocus.requestFocus();
                          }
                        },
                        labelColor: CupertinoColors.systemYellow,
                        indicatorColor: CupertinoColors.systemYellow,
                        tabs: [
                          Tab(
                            child: Text(
                              languages.simplePostLabel,
                              style: TextStyle(
                                  color: CupertinoColors.systemYellow),
                            ),
                          ),
                          Tab(
                            child: Text(
                              languages.pollPostLabel,
                              style: TextStyle(
                                  color: CupertinoColors.systemYellow),
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
    setState(() {
      isButtonEnabled = false;
    });
    if (ProfanityChecker.alert(
        _descriptionController.text + ' ' + _titleController.text)) {
      setState(() {
        isButtonEnabled = true;
      });
      Fluttertoast.showToast(
          msg: languages.profanityWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
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
            timeInSecForIosWeb: 4,
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
            timeInSecForIosWeb: 4,
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
            if (image != null) {
              image!.readAsBytes().then((multipartImage) {
                dynamic imageBody = <String, String>{
                  'postId': response.body.toString()
                };
                widget.session
                    .sendMultipart('/api/postImages', imageBody, multipartImage)
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
                        timeInSecForIosWeb: 4,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    Phoenix.rebirth(context);
                  } else {
                    setState(() {
                      isButtonEnabled = true;
                    });
                    Fluttertoast.showToast(
                        msg: languages.globalServerErrorMessage,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 4,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                });
              });
            } else {
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
                  timeInSecForIosWeb: 4,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0);
              Phoenix.rebirth(context);
            }
          }
        });
      }
    }
  }

  Widget _simplePostWidget() {
    return RawScrollbar(
      controller: _simplePostScrollController,
      thumbVisibility: true,
      thumbColor: Colors.grey,
      child: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Container(
            color: Colors.black,
            width: 700,
            child: ListView(
              controller: _simplePostScrollController,
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
                        height: 45,
                        margin: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(4),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width - 70,
                            child: TypeAheadField(
                              noItemsFoundBuilder: (context) {
                                return Container(
                                  padding: EdgeInsets.all(1),
                                  color: CupertinoColors.systemYellow,
                                  child: Container(
                                    color: Colors.black,
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.not_interested_rounded,
                                        color: CupertinoColors.systemYellow,
                                      ),
                                      title: Text(
                                        languages.noItemsFoundLabel,
                                        style: TextStyle(
                                            color: CupertinoColors.systemYellow,
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
                                onEditingComplete: () {
                                  if (_titleController.text.isEmpty) {
                                    _titleFocus.requestFocus();
                                  } else if (_descriptionController
                                      .text.isEmpty) {
                                    _descriptionFocus.requestFocus();
                                  } else {
                                    _companyNameFocus.unfocus();
                                  }
                                },
                                cursorColor: Colors.black,
                                focusNode: _companyNameFocus,
                                autofocus: true,
                                style: TextStyle(fontSize: 20),
                              ),
                              suggestionsCallback: (pattern) async {
                                dynamic response = await widget.session
                                    .get("/api/companies/getByName/" + pattern);
                                if (response.statusCode == 200) {
                                  Iterable l = json
                                      .decode(utf8.decode(response.bodyBytes));
                                  companies = List<CompanyForSearch>.from(l.map(
                                      (company) =>
                                          CompanyForSearch.fromJson(company)));
                                  List<String> resultList = [];
                                  companies.forEach((company) {
                                    resultList.add(company.id.toString());
                                  });
                                  return resultList;
                                }
                                return [];
                              },
                              itemBuilder: (context, suggestion) {
                                CompanyForSearch company = companies
                                    .where((cp) => cp.id.toString() == suggestion)
                                    .first;
                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onPanDown: (_) {
                                      setState(() {
                                        CompanyForSearch company = companies
                                            .where((cp) => cp.id.toString() == suggestion)
                                            .first;
                                        _companyNameController.text = company.name;
                                        _selectedCompany = company;
                                        if (_titleController.text.isEmpty) {
                                          _titleFocus.requestFocus();
                                        } else if (_descriptionController.text.isEmpty) {
                                          _descriptionFocus.requestFocus();
                                        } else {
                                          _companyNameFocus.unfocus();
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 700,
                                      padding: EdgeInsets.all(1),
                                      color: CupertinoColors.systemYellow,
                                      child: Container(
                                        color: Colors.black,
                                        child: ListTile(
                                          onTap: (){},
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
                                                color: CupertinoColors.systemYellow,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              onSuggestionSelected: (suggestion) {},
                            ),
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        padding: EdgeInsets.all(1),
                        color: CupertinoColors.systemYellow,
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
                                  color: CupertinoColors.systemYellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            trailing: InkWell(
                              child: Icon(
                                Icons.clear,
                                color: CupertinoColors.systemYellow,
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
                  child: Container(
                    width: MediaQuery.of(context).size.width - 70,
                    height: 35,
                    child: Center(
                      child: TextField(
                        cursorColor: Colors.black,
                        focusNode: _titleFocus,
                        onEditingComplete: () {
                          if (_descriptionController.text.isEmpty) {
                            _descriptionFocus.requestFocus();
                          } else {
                            _titleFocus.unfocus();
                          }
                        },
                        controller: _titleController,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        decoration: new InputDecoration.collapsed(
                            hintText: languages.titleOfIdeaLabel),
                      ),
                    ),
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
                  child: Container(
                    width: MediaQuery.of(context).size.width - 70,
                    child: TextField(
                        maxLines: null,
                        maxLength: 2048,
                        controller: _descriptionController,
                        focusNode: _descriptionFocus,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration.collapsed(
                          hintText: languages.writeHereYourIdeaLabel,
                        ),
                        onChanged: (text) => setState(() {})),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.systemYellow),
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Text(
                      '${languages.addPictureLabel}:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    title: image != null
                        ? InkWell(
                            child: Center(
                                child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: CupertinoColors.systemYellow),
                                  image: DecorationImage(
                                      image: NetworkImage(image!.path),
                                      fit: BoxFit.contain),
                                  borderRadius: BorderRadius.circular(10)),
                            )),
                            onTap: () {
                              _addPicture(setState);
                            },
                          )
                        : InkWell(
                            child: Center(
                                child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: CupertinoColors.systemYellow,
                                  image: DecorationImage(
                                      image: AssetImage(
                                        "assets/images/add_image.png",
                                      ),
                                      fit: BoxFit.fill),
                                  borderRadius: BorderRadius.circular(10)),
                            )),
                            onTap: () {
                              _addPicture(setState);
                            },
                          ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          isButtonEnabled
                              ? CupertinoColors.systemYellow
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
          ),
        ),
      ),
    );
  }

  Widget _pollPostWidget() {
    return RawScrollbar(
      controller: _pollPostScrollController,
      thumbVisibility: true,
      thumbColor: Colors.grey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Center(
          child: Container(
            width: 700,
            child: ListView.builder(
                controller: _pollPostScrollController,
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
                      height: 40,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(5),
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width - 20,
                          child: TextField(
                            cursorColor: Colors.black,
                            controller: _pollTitleController,
                            focusNode: _pollTitleNameFocus,
                            onEditingComplete: () {
                              int nextEmptyIndex = pollControllers.indexWhere(
                                  (element) => element.text.isEmpty);
                              if (nextEmptyIndex != -1) {
                                pollFocusNodes
                                    .elementAt(nextEmptyIndex)
                                    .requestFocus();
                              } else {
                                _pollTitleNameFocus.unfocus();
                              }
                            },
                            maxLength: 256,
                            style: TextStyle(fontSize: 20),
                            decoration: new InputDecoration(
                              isCollapsed: true,
                              counterText: '',
                              border: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
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
                                  CupertinoColors.systemYellow),
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
                                  ? CupertinoColors.systemYellow
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
          ),
        ),
      ),
    );
  }

  void _onAddOptionPressed() {
    setState(() {
      FocusNode focusNode = new FocusNode();
      pollFocusNodes.add(focusNode);
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
                  focusNode: focusNode,
                  onEditingComplete: () {
                    int nextEmptyIndex = pollControllers.indexWhere((element) =>
                        element.text.isEmpty &&
                        pollControllers.indexOf(element) >
                            pollFocusNodes.indexOf(focusNode) &&
                        element != textEditingController);
                    if (nextEmptyIndex != -1) {
                      pollFocusNodes.elementAt(nextEmptyIndex).requestFocus();
                    } else {
                      focusNode.unfocus();
                    }
                  },
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
                    focusedBorder:
                        OutlineInputBorder(borderSide: BorderSide.none),
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
      focusNode.requestFocus();
    });
  }

  void _onPostPollPressed() {
    setState(() {
      isButtonEnabled = false;
    });
    bool pollsAreEmpty = false;
    String pollsConcat = '';
    pollControllers.forEach((poll) {
      if (poll.text.isEmpty) {
        pollsAreEmpty = true;
      } else {
        pollsConcat = pollsConcat + ' ' + poll.text;
      }
    });
    if (ProfanityChecker.alert(_pollTitleController.text + ' ' + pollsConcat)) {
      setState(() {
        isButtonEnabled = true;
      });
      Fluttertoast.showToast(
          msg: languages.profanityWarningMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      if (_pollTitleController.text.isEmpty || pollsAreEmpty) {
        setState(() {
          isButtonEnabled = true;
        });
        Fluttertoast.showToast(
            msg: languages.fillAllFieldsWithPollOptionWarningMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 4,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        List<String> options = [];
        pollControllers.forEach((poll) {
          options.add(poll.text);
        });
        dynamic body = <String, dynamic>{
          'title': _pollTitleController.text,
          'options': options
        };
        widget.session
            .postJson(
          '/api/posts/poll',
          body,
        )
            .then((response) {
          if (response.statusCode == 200) {
            _pollTitleController.clear();
            _companyNameController.clear();
            _descriptionController.clear();
            setState(() {
              isButtonEnabled = true;
            });
            Fluttertoast.showToast(
                msg: languages.yourPostIsOutMessage,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 4,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
            Phoenix.rebirth(context);
          }
        });
      }
    }
  }

  void _addInitPollOption(TextEditingController textEditingController) {
    FocusNode focusNode = new FocusNode();
    pollFocusNodes.add(focusNode);
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
          controller: textEditingController,
          focusNode: focusNode,
          onEditingComplete: () {
            int nextEmptyIndex = pollControllers.indexWhere((element) =>
                element.text.isEmpty &&
                pollControllers.indexOf(element) >
                    pollFocusNodes.indexOf(focusNode) &&
                element != textEditingController);
            if (nextEmptyIndex != -1) {
              pollFocusNodes.elementAt(nextEmptyIndex).requestFocus();
            } else {
              focusNode.unfocus();
            }
          },
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

  void _addPicture(setState) async {
    final ImagePicker _picker = ImagePicker();
    image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null &&
        (await image!.readAsBytes()).lengthInBytes >= 1048576) {
      image = null;
      Fluttertoast.showToast(
          msg: languages.imageFileSizeIsTooBigExceptionMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    setState(() {});
  }

  @override
  void dispose() {
    image = null;
    super.dispose();
  }
}
