import 'package:flutter/material.dart';
import 'package:univote/auth/authservice.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});
  final AuthService authService=AuthService();
  void logout() async{
    try {
    await authService.signOut();

    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Home Page'),
            SizedBox(height: 20,),
            TextButton(onPressed: logout, child: Text("Logout"))
          ],
        ),
      ),
    );
  }
}
