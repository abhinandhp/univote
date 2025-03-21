import 'package:flutter/material.dart';
import 'package:univote/auth/authservice.dart';
import 'package:univote/pages/dashboard.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});
  final AuthService authService = AuthService();
  void logout() async {
    try {
      await authService.signOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Home Page'),
            SizedBox(height: 20),
            Column(
              children: [
                TextButton(onPressed: logout, child: Text("Logout")),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => DashboardPage()),
                    );
                  },
                  child: Text("Go to Dashboard"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
