import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/pages/admin/adminhome.dart';
import 'package:univote/pages/loginpage.dart';
import 'package:univote/pages/oldnavpage.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  void refresh() {
    setState(() {});
  }

  Future<bool> checkAdminStatus() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return false;

    final response =
        await supabase
            .from('profiles')
            .select('is_admin')
            .eq('id', user.id)
            .single();

    return response['is_admin'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: SpinKitThreeBounce(
                // Running dots animation
                color: Colors.blue, // Change color as needed
                size: 30.0,
              ),
            ),
          );
        }
        final session = snapshot.data?.session;

        if (session == null) {
          return LoginPage();
        }

        return FutureBuilder<bool>(
          future: checkAdminStatus(),
          builder: (context, adminSnapshot) {
            if (adminSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Lottie.asset('assets/loading.json'),
                  ),
                ),
              );
            }

            if (adminSnapshot.hasError) {
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  title: Text(
                    'Univote',
                    style: GoogleFonts.ultra(
                      //fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 1.5,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade900,
                  elevation: 0,
                ),
                body: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Lottie.asset('assets/no_internet.json'),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: refresh,
                          child: Container(
                            height: 50,
                            width: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(255, 23, 23, 23),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  ' Retry',
                                  style: GoogleFonts.ultra(
                                    color: Colors.white,
                                    fontSize: 17,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w100,
                                  ),
                                ),
                                Lottie.asset('assets/retry.json'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final isAdmin = adminSnapshot.data ?? false;

            return isAdmin ? AdminHome() : BottomNav();
          },
        );
      },
    );
  }
}



// stream builder if we want to change later

// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:univote/pages/admin/adminhome.dart';
// import 'package:univote/pages/loginpage.dart';
// import 'package:univote/pages/oldnavpage.dart';

// class AuthGate extends StatefulWidget {
//   const AuthGate({super.key});

//   @override
//   _AuthGateState createState() => _AuthGateState();
// }

// class _AuthGateState extends State<AuthGate> {
//   final supabase = Supabase.instance.client;
//   Stream<bool> get adminStatusStream async* {
//     final user = supabase.auth.currentUser;
//     if (user == null) yield false;

//     yield* supabase
//         .from('profiles')
//         .stream(primaryKey: ['id'])
//         .eq('id', user!.id)
//         .map((data) => data.isNotEmpty ? (data.first['is_admin'] ?? false) : false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<AuthState>(
//       stream: supabase.auth.onAuthStateChange,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Center(
//               child: SpinKitThreeBounce(
//                 color: Colors.blue,
//                 size: 30.0,
//               ),
//             ),
//           );
//         }

//         final session = snapshot.data?.session;

//         if (session == null) {
//           return LoginPage();
//         }

//         return StreamBuilder<bool>(
//           stream: adminStatusStream,
//           builder: (context, adminSnapshot) {
//             if (adminSnapshot.connectionState == ConnectionState.waiting) {
//               return Scaffold(
//                 body: Center(
//                   child: SpinKitThreeBounce(
//                     color: Colors.blue,
//                     size: 30.0,
//                   ),
//                 ),
//               );
//             }

//             if (adminSnapshot.hasError) {
//               return Scaffold(
//                 body: Center(child: Text("Error checking admin status")),
//               );
//             }

//             final isAdmin = adminSnapshot.data ?? false;

//             return isAdmin ? AdminHome() : BottomNav();
//           },
//         );
//       },
//     );
//   }
// }