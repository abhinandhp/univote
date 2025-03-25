import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:univote/pages/homepage.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  List<Widget> screens() {
    return [
      const HomePage(),
      const HomePage(),
      const HomePage(),
      const HomePage(),
    ];
  }

  List<PersistentBottomNavBarItem> navbaritems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(LineIcons.home),
        title: 'Home',
        textStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 15,
          letterSpacing: 1,
        ),
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.yellow,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(LineIcons.voteYea),
        title: 'Vote',
        textStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 15,
          letterSpacing: 1,
        ),
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.yellow,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(LineIcons.fireExtinguisher),
        title: 'Results',
        textStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 15,
          letterSpacing: 1,
        ),
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.yellow,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(LineIcons.userAlt),
        title: 'Account',
        textStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 15,
          letterSpacing: 1,
        ),
        activeColorPrimary: Colors.white,
        activeColorSecondary: Colors.yellow,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PersistentTabView(
        onWillPop: (context) async {
          return false;
        },
        handleAndroidBackButtonPress: false,
        context,
        screens: screens(),

        items: navbaritems(),
        navBarStyle: NavBarStyle.style12,
        resizeToAvoidBottomInset: true,
        navBarHeight: 75,
        padding: const EdgeInsets.all(10),
        margin: EdgeInsets.only(right: 15, left: 15, bottom: 10),

        decoration: NavBarDecoration(
          colorBehindNavBar: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        //handleAndroidBackButtonPress: true,
        backgroundColor: Colors.black,
        stateManagement: true,
      ),
    );
  }
}
