import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:univote/pages/homepage.dart';

class Navpage extends StatelessWidget {
  const Navpage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      backgroundColor: Colors.transparent,
      // navBarHeight: 10,
      
      tabs: [
        PersistentTabConfig(
          screen: HomePage(),
          item: ItemConfig(icon: Icon(Icons.home), title: "Home"),
        ),
        PersistentTabConfig(
          screen: HomePage(),
          item: ItemConfig(icon: Icon(Icons.message), title: "Messages"),
        ),
        PersistentTabConfig(
          screen: HomePage(),
          item: ItemConfig(icon: Icon(Icons.settings), title: "Settings"),
        ),
      ],
      navBarBuilder:
          (navBarConfig) => Style10BottomNavBar(navBarConfig: navBarConfig),
    );
  }
}
