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
//   final rollController = TextEditingController();
//   final emailTextController = TextEditingController();
//   final passwordTextController = TextEditingController();
//   final confirmPasswordTextController = TextEditingController();

//   // register button pressed
//   void register() async {
//     // prepare data
//     String name = nameController.text;
//     String rollno = rollController.text;
//     String email = emailTextController.text;
//     String password = passwordTextController.text;
//     String confirmPassword = confirmPasswordTextController.text;

//     if (password != confirmPassword) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
//       return;
//     }

//     // attempt sign up..
//     try {
//       await _auth.signUp(email, password, name, rollno);
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
//       body: SingleChildScrollView(
//         // <-- Fix overflow
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 30, vertical: 60),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min, // <-- Important
//                 children: [
//                   // ** Title: UNIVOTE **
//                   const Text(
//                     'Create Account',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // ** Username Input **
//                   TextField(
//                     controller: nameController,
//                     decoration: InputDecoration(
//                       hintText: 'Username',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 10),
//                   TextField(
//                     controller: rollController,
//                     decoration: InputDecoration(
//                       hintText: 'Roll Number',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   // ** Student ID/Email Input **
//                   TextField(
//                     controller: emailTextController,
//                     decoration: InputDecoration(
//                       hintText: 'Student ID / Email',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   // ** Password Input **
//                   TextField(
//                     controller: passwordTextController,
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       hintText: 'Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   // ** Confirm Password Input **
//                   TextField(
//                     controller: confirmPasswordTextController,
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       hintText: 'Confirm Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // ** Sign up Button **
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       onPressed: register,
//                       child: const Text(
//                         'SIGN UP',
//                         style: TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:univote/auth/authservice.dart';

// // class RegisterPage extends StatefulWidget {
// //   const RegisterPage({super.key});

// //   @override
// //   State<RegisterPage> createState() => _RegisterPageState();
// // }

// // class _RegisterPageState extends State<RegisterPage> {
// //   // get auth service
// //   final _auth = AuthService();

// //   // text controllers
// //   final nameController = TextEditingController();
// //   final emailTextController = TextEditingController();
// //   final passwordTextController = TextEditingController();
// //   final confirmPasswordTextController = TextEditingController();

// //   // register button pressed
// //   void register() async {
// //     // prepare data
// //     String name=nameController.text;
// //     String email = emailTextController.text;
// //     String password = passwordTextController.text;
// //     String confirmPassword = confirmPasswordTextController.text;

// //     if (password != confirmPassword) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
// //     }

// //     // attempt sign up..
// //     try {
// //       await _auth.signUp(email, password,name);
// //       if (mounted) Navigator.pop(context);
// //     } catch (e) {
// //       if (mounted) {
// //         ScaffoldMessenger.of(
// //           context,
// //         ).showSnackBar(SnackBar(content: Text("Error: $e")));
// //       }
// //     }
// //   }

// //   // BUILD UI
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.blueAccent,
// //       appBar: AppBar(backgroundColor: Colors.blueAccent),
// //       body: Center(
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(15),
// //           ),
// //           margin: EdgeInsets.symmetric(horizontal: 30, vertical: 90),

// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 20.0),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 // ** Title: UNIVOTE **
// //                 const Text(
// //                   'Create Account',
// //                   style: TextStyle(
// //                     fontSize: 22,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black,
// //                   ),
// //                 ),

// //                 const SizedBox(height: 20),

// //                 // ** Student username **
// //                 SizedBox(
// //                   width: 300,
// //                   height: 50,
// //                   child: TextField(
// //                     controller: nameController,
// //                     decoration: InputDecoration(
// //                       hintText: 'Username',
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       contentPadding: const EdgeInsets.symmetric(
// //                         horizontal: 10,
// //                       ),
// //                     ),
// //                   ),
// //                 ),

// //                 const SizedBox(height: 10),

// //                 // ** Student ID/Email Input **
// //                 SizedBox(
// //                   width: 300,
// //                   height: 50,
// //                   child: TextField(
// //                     controller: emailTextController,
// //                     decoration: InputDecoration(
// //                       hintText: 'Student ID / Email',
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       contentPadding: const EdgeInsets.symmetric(
// //                         horizontal: 10,
// //                       ),
// //                     ),
// //                   ),
// //                 ),

// //                 const SizedBox(height: 10),

// //                 // ** Password Input **
// //                 SizedBox(
// //                   width: 300,
// //                   height: 50,
// //                   child: TextField(
// //                     controller: passwordTextController,
// //                     obscureText: true,
// //                     decoration: InputDecoration(
// //                       hintText: 'Password',
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       contentPadding: const EdgeInsets.symmetric(
// //                         horizontal: 10,
// //                       ),
// //                     ),
// //                   ),
// //                 ),

// //                 const SizedBox(height: 10),

// //                 // ** confirm Password Input **
// //                 SizedBox(
// //                   width: 300,
// //                   height: 50,
// //                   child: TextField(
// //                     controller: confirmPasswordTextController,
// //                     obscureText: true,
// //                     decoration: InputDecoration(
// //                       hintText: 'Confirm Password',
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       contentPadding: const EdgeInsets.symmetric(
// //                         horizontal: 10,
// //                       ),
// //                     ),
// //                   ),
// //                 ),

// //                 const SizedBox(height: 20),

// //                 // ** Sign up Button **
// //                 SizedBox(
// //                   width: 300,
// //                   height: 50,
// //                   child: ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.blue, // Dark blue button
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                     ),
// //                     onPressed: register,
// //                     child: const Text(
// //                       'SIGN UP',
// //                       style: TextStyle(fontSize: 16, color: Colors.white),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 10),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

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
  final rollController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // register button pressed
  void register() async {
    // prepare data
    String name = nameController.text;
    String rollno = rollController.text;
    String email = emailTextController.text;
    String password = passwordTextController.text;
    String confirmPassword = confirmPasswordTextController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Text("Passwords do not match!"),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // attempt sign up..
    try {
      await _auth.signUp(email, password, name, rollno);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text("Error: $e")),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                        letterSpacing: 1.0,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Fill in your details to register',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    const SizedBox(height: 30),

                    // Username Input
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Full Name',
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Roll Number Input
                    TextField(
                      controller: rollController,
                      decoration: InputDecoration(
                        hintText: 'Roll Number',
                        prefixIcon: const Icon(
                          Icons.numbers,
                          color: Colors.blue,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email Input
                    TextField(
                      controller: emailTextController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Student ID / Email',
                        prefixIcon: const Icon(Icons.email, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password Input
                    TextField(
                      controller: passwordTextController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password Input
                    TextField(
                      controller: confirmPasswordTextController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.blue,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: Colors.blue.withOpacity(0.5),
                        ),
                        onPressed: register,
                        child: const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1565C0),
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
