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
    String email = emailTextController.text;
    String password = passwordTextController.text;

    try {
      await _auth.signIn(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid username or password")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SingleChildScrollView(
        child: SizedBox(
          height:
              MediaQuery.of(
                context,
              ).size.height, // Ensures it takes full height
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Keeps the column compact
                children: [
                  // ** Logo (Circular UV) **
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: const Center(
                      child: Text(
                        'UV',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ** Title: UNIVOTE **
                  const Text(
                    'UNIVOTE',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  // ** Subtitle: NIT Calicut Election System **
                  const Text(
                    'NIT Calicut Election System',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

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

                  const SizedBox(height: 20),

                  // ** Login Button **
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
                      onPressed: login,
                      child: const Text(
                        'LOG IN',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ** Register Link **
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ** Footer Text **
                  const Text(
                    '© 2025 NIT Calicut',
                    style: TextStyle(color: Colors.grey),
                  ),
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
// import 'package:univote/pages/regpage.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   // get auth service
//   final _auth = AuthService();

//   // text controllers
//   final emailTextController = TextEditingController();
//   final passwordTextController = TextEditingController();

//   // login button pressed
//   void login() async {
//     // prepare data
//     String email = emailTextController.text;
//     String password = passwordTextController.text;
//     // attempt login..
//     try {
//       await _auth.signIn(email, password);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Invalid username or password")));
//       }
//     }
//   }

//   // BUILD UI
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blueAccent,
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
//                 // ** Logo (Circular UV) **
//                 Container(
//                   width: 100,
//                   height: 100,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.blue, // Circle background color
//                   ),
//                   child: const Center(
//                     child: Text(
//                       'UV',
//                       style: TextStyle(
//                         fontSize: 30,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),

//                 // ** Title: UNIVOTE **
//                 const Text(
//                   'UNIVOTE',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),

//                 // ** Subtitle: NIT Calicut Election System **
//                 const Text(
//                   'NIT Calicut Election System',
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 20),

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

//                 const SizedBox(height: 20),

//                 // ** Login Button **
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
//                     onPressed: login,
//                     child: const Text(
//                       'LOG IN',
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),

//                 // // ** Forgot Password & Register Links **
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => RegisterPage(),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         'Register',
//                         style: TextStyle(color: Colors.blue),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),

//                 // ** Footer Text **
//                 const Text(
//                   '© 2025 NIT Calicut',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
