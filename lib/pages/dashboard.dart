import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("UNIVOTE", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text("AB", style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Hello, Abhinandh",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Welcome to UNIVOTE election portal",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            _sectionTitle("Active Elections"),
            _electionCard(
              "Class Representative - B22 CS",
              "Ends in: 2 days 5 hours",
              "5 candidates",
              true,
            ),
            _electionCard(
              "Department Secretary - CSE",
              "Ends in: 5 days 12 hours",
              "3 candidates",
              true,
            ),
            _sectionTitle("Upcoming Elections"),
            _electionCard(
              "Student Council - General Secretary",
              "Starts in: 1 week 2 days",
              "Registration open",
              false,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote),
            label: "Elections",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Results",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _electionCard(
    String title,
    String time,
    String info,
    bool showButton,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(time, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 4),
            Text(info, style: TextStyle(color: Colors.grey)),
            if (showButton) ...[
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("Vote Now"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
