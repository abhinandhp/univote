// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(child: Text("Profile Page",style: GoogleFonts.outfit(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800,
//                   color: Color.fromARGB(255, 66, 65, 82),
//                 ),),),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:univote/pages/loginpage.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue.shade900),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile',
              style: GoogleFonts.ultra(
                fontSize: 28,
                letterSpacing: 1.5,
                color: const Color.fromARGB(255, 22, 59, 133),
              ),
            ),
            TextButton(
              onPressed: () {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
},
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20), 
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
            ),
            SizedBox(height: 15),
            ProfileDetail(title: "Name", value: "Abhinand"),
            SizedBox(height: 10),
            ProfileDetail(title: "Roll No", value: "B20011CS"),
            SizedBox(height: 10),
            ProfileDetail(title: "Email", value: "abhinand@nitc.ac.in"),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                
              ),
    
              child: Text(
                "Edit Profile",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileDetail extends StatelessWidget {
  final String title;
  final String value;

  ProfileDetail({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
