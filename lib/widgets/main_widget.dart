import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_frontend/entities/session.dart';
import 'package:flutter_frontend/entities/user.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_frontend/widgets/posts_widget.dart';
import 'package:flutter_frontend/widgets/settings_widget.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'create_post_widget.dart';

class MainWidget extends StatefulWidget {
  final Session session;
  final User user;
  final Languages languages;

  const MainWidget(
      {required this.session, required this.user, required this.languages});

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  PersistentTabController _pageController =
      PersistentTabController(initialIndex: 0);
  late Languages languages;
  bool _hideNavBar = false;
  bool _navBarStatusChangeable = true;

  @override
  void initState() {
    super.initState();
    languages = widget.languages;
  }

  @override
  Widget build(BuildContext context) {
    if (_pageController.index != 0 && _hideNavBar == true) {
      _hideNavBar = false;
    }
    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        final ScrollDirection direction = notification.direction;
        if (direction == ScrollDirection.forward &&
            _hideNavBar == true &&
            _pageController.index == 0 &&
            _navBarStatusChangeable) {
          setState(() {
            _hideNavBar = false;
          });
        } else if (direction == ScrollDirection.reverse &&
            _hideNavBar == false &&
            _pageController.index == 0 &&
            _navBarStatusChangeable) {
          setState(() {
            _hideNavBar = true;
          });
        }
        return true;
      },
      child: PersistentTabView(
        context,
        controller: _pageController,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.black,
        handleAndroidBackButtonPress: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        hideNavigationBar: _hideNavBar,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.black,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle: NavBarStyle.style15,
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      PostsWidget(
        session: widget.session,
        user: widget.user,
        initPage: 1,
        languages: languages,
        hideNavBar: hideNavBar,
        navBarStatusChangeableAgain: () {
          setState(() {
            _navBarStatusChangeable = true;
            _hideNavBar = false;
          });
        },
      ),
      CreatePostWidget(
        session: widget.session,
        user: widget.user,
        languages: languages,
      ),
      SettingsWidget(
          session: widget.session, user: widget.user, languages: languages)
    ];
  }

  Future hideNavBar() async {
    setState(() {
      _navBarStatusChangeable = false;
      _hideNavBar = true;
    });
    await Future.delayed(Duration(milliseconds: 250));
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home),
        activeColorPrimary: CupertinoColors.systemYellow,
        inactiveColorPrimary: CupertinoColors.white,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.add),
        activeColorPrimary: CupertinoColors.systemYellow,
        activeColorSecondary: CupertinoColors.black,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.settings),
        activeColorPrimary: CupertinoColors.systemYellow,
        inactiveColorPrimary: CupertinoColors.white,
      ),
    ];
  }
}
