import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:univote/auth/authservice.dart';
import 'package:univote/pages/homepage.dart';

class Loginpage extends StatelessWidget {
  Loginpage({super.key});
  final AuthService authService=AuthService();

  Future<String?> onLogin(LoginData data) async {
      try {
        await authService.signIn(data.name,data.password);
      return null;
      } catch (e) {
        print(e);
      }
      return 'User not exists'; 
    }

    Future<String?> onRecoverPassword(String name) async {
      await Future.delayed(Durations.medium1);
      return null;
    }

    Future<String?> onSignUp(SignupData data) async {
      await authService.signUp(data.name!, data.password!);
      return null;
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        onLogin: onLogin,
        onRecoverPassword: onRecoverPassword,
        onSignup: onSignUp,
        onSubmitAnimationCompleted: () {
          Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) =>  Homepage()),
      );
        },
      ),
    );
  }
}
