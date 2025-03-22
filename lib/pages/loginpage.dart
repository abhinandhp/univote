// import 'package:flutter/material.dart';
// import 'package:flutter_login/flutter_login.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:univote/auth/authservice.dart';
// import 'package:univote/pages/admin/adminhome.dart';
// import 'package:univote/pages/homepage.dart';

// class Loginpage extends StatefulWidget {
//   const Loginpage({super.key});

//   @override
//   State<Loginpage> createState() => _LoginpageState();
// }

// class _LoginpageState extends State<Loginpage> {
//   final AuthService authService = AuthService();
//   final SupabaseClient supabase = Supabase.instance.client;
//   bool isAdmin = false;
//   Future<String?> onLogin(LoginData data) async {
//     try {
//       final response = await authService.signIn(data.name, data.password);
//       if (response.user == null) throw Exception("Login failed");

//       // Check Admin Status
//       final adminCheck =
//           await supabase
//               .from('profiles')
//               .select('is_admin')
//               .eq('id', response.user!.id)
//               .single();

//       isAdmin = adminCheck['is_admin'] ?? false;
//       return null;
//     } catch (e) {
//       print(e);
//     }
//     return 'User not exists';
//   }

//   Future<String?> onRecoverPassword(String name) async {
//     await Future.delayed(Durations.medium1);
//     return null;
//   }

//   Future<String?> onSignUp(SignupData data) async {
//     await authService.signUp(data.name!, data.password!);
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FlutterLogin(
//         onLogin: onLogin,
//         onRecoverPassword: onRecoverPassword,
//         onSignup: onSignUp,
//         onSubmitAnimationCompleted: () {
//           print("ahahahahahhahahha------------------------##########################a@");
//           if (context.mounted) {
//             print(isAdmin);
//             if (isAdmin) {
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(builder: (context) => AdminHome()),
//               );
//             } else {
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(builder: (context) => Homepage()),
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:univote/auth/authservice.dart';
import 'package:univote/pages/regpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // get auth service
  final _auth = AuthService();

  // text controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  // login button pressed
  void login() async {
    // prepare data
    String email = emailTextController.text;
    String password = passwordTextController.text;

    // attempt login..
    try {
      await _auth.signIn(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            const Icon(
              Icons.lock_open,
              size: 120,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: Text("T E X T   B A S E D   S O C I A L   A P P"),
            ),

            // email textfield
            TextField(
              controller: emailTextController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            // password textfield
            TextField(
              controller: passwordTextController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            const SizedBox(height: 50),

            // login button
            MaterialButton(
              onPressed: login,
              child: const Text("LOGIN"),
            ),

            // go to register page
            TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterPage())),
              child: const Text("SIGN UP"),
            ),
          ],
        ),
      ),
    );
  }
}