import 'package:flutter/material.dart';
import 'package:univote/auth/authservice.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // get auth service
  final _auth = AuthService();

  // text controllers
  final nameController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // register button pressed
  void register() async {
    // prepare data
    String name = nameController.text;
    String email = emailTextController.text;
    String password = passwordTextController.text;
    String confirmPassword = confirmPasswordTextController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    // attempt sign up..
    try {
      await _auth.signUp(email, password, name);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(backgroundColor: Colors.blueAccent),
      body: SingleChildScrollView(  // <-- Fix overflow
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 60),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,  // <-- Important
                children: [
                  // ** Title: UNIVOTE **
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ** Username Input **
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ** Student ID/Email Input **
                  TextField(
                    controller: emailTextController,
                    decoration: InputDecoration(
                      hintText: 'Student ID / Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ** Password Input **
                  TextField(
                    controller: passwordTextController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ** Confirm Password Input **
                  TextField(
                    controller: confirmPasswordTextController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ** Sign up Button **
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: register,
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:univote/auth/authservice.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   // get auth service
//   final _auth = AuthService();

//   // text controllers
//   final nameController = TextEditingController();
//   final emailTextController = TextEditingController();
//   final passwordTextController = TextEditingController();
//   final confirmPasswordTextController = TextEditingController();

//   // register button pressed
//   void register() async {
//     // prepare data
//     String name=nameController.text;
//     String email = emailTextController.text;
//     String password = passwordTextController.text;
//     String confirmPassword = confirmPasswordTextController.text;

//     if (password != confirmPassword) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
//     }

//     // attempt sign up..
//     try {
//       await _auth.signUp(email, password,name);
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Error: $e")));
//       }
//     }
//   }

//   // BUILD UI
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blueAccent,
//       appBar: AppBar(backgroundColor: Colors.blueAccent),
//       body: Center(
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//           ),
//           margin: EdgeInsets.symmetric(horizontal: 30, vertical: 90),

//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // ** Title: UNIVOTE **
//                 const Text(
//                   'Create Account',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // ** Student username **
//                 SizedBox(
//                   width: 300,
//                   height: 50,
//                   child: TextField(
//                     controller: nameController,
//                     decoration: InputDecoration(
//                       hintText: 'Username',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // ** Student ID/Email Input **
//                 SizedBox(
//                   width: 300,
//                   height: 50,
//                   child: TextField(
//                     controller: emailTextController,
//                     decoration: InputDecoration(
//                       hintText: 'Student ID / Email',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // ** Password Input **
//                 SizedBox(
//                   width: 300,
//                   height: 50,
//                   child: TextField(
//                     controller: passwordTextController,
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       hintText: 'Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // ** confirm Password Input **
//                 SizedBox(
//                   width: 300,
//                   height: 50,
//                   child: TextField(
//                     controller: confirmPasswordTextController,
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       hintText: 'Confirm Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // ** Sign up Button **
//                 SizedBox(
//                   width: 300,
//                   height: 50,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue, // Dark blue button
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed: register,
//                     child: const Text(
//                       'SIGN UP',
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
