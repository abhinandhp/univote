// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:univote/pages/admin/adminhome.dart';
// import 'package:univote/pages/loginpage.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: Supabase.instance.client.auth.onAuthStateChange,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(body: Center(child: CircularProgressIndicator()));
//         }
//         final session = snapshot.hasData ? snapshot.data!.session : null;
//         if (session != null) {
//           return AdminHome();
//         }
//         return LoginPage();
//       },
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/pages/admin/adminhome.dart';
import 'package:univote/pages/loginpage.dart';
import 'package:univote/pages/homepage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> checkAdminStatus() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return false;

    final response = await supabase
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
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        if (session == null) {
          return LoginPage();
        }

        return FutureBuilder<bool>(
          future: checkAdminStatus(),
          builder: (context, adminSnapshot) {
            if (adminSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (adminSnapshot.hasError) {
              return Scaffold(body: Center(child: Text("Error checking admin status")));
            }

            final isAdmin = adminSnapshot.data ?? false;

            return isAdmin ? AdminHome() : HomePage();
          },
        );
      },
    );
  }
}
