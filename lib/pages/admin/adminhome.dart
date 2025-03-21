import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/models/model.dart';
import 'package:univote/supabase/electionbase.dart';
import 'package:intl/intl.dart';
import 'package:univote/supabase/realdbservice.dart';

final supabase = Supabase.instance.client;

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final electionbase = ElectionBase();
  final _electionNameController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;

  void _showElectionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Create Election"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Election Name Input
              TextField(
                controller: _electionNameController,
                decoration: InputDecoration(labelText: "Election Name"),
              ),

              // Start DateTime Picker
              ListTile(
                title: Text(
                  _startDateTime == null
                      ? "Select Start Date & Time"
                      : "Start: ${DateFormat('yyyy-MM-dd HH:mm').format(_startDateTime!)}",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await _pickDateTime();
                  if (picked != null) {
                    setState(() {
                      _startDateTime = picked;
                    });
                  }
                },
              ),

              // End DateTime Picker
              ListTile(
                title: Text(
                  _endDateTime == null
                      ? "Select End Date & Time"
                      : "End: ${DateFormat('yyyy-MM-dd HH:mm').format(_endDateTime!)}",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await _pickDateTime();
                  if (picked != null) {
                    setState(() {
                      _endDateTime = picked;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close Dialog
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                print("debugggg");
                if (_electionNameController.text.isEmpty ||
                    _startDateTime == null ||
                    _endDateTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all fields")),
                  );
                  return;
                }
                final newElection = Election(
                  name: _electionNameController.text,
                  start: _startDateTime,
                  end: _endDateTime,
                );
                electionbase.createElection(newElection);
                // Handle election submission
                print("Election Name: ${_electionNameController.text}");
                print("Start DateTime: $_startDateTime");
                print("End DateTime: $_endDateTime");

                Navigator.pop(context); // Close Dialog
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // Function to pick Date and Time
  Future<DateTime?> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return null; // User canceled

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null; // User canceled

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  final _stream = supabase.from('elections').stream(primaryKey: ['id']);
  late RealDBService _rdbService;

  @override
  void initState() {
    _rdbService = RealDBService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Admin Dashboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: _showElectionDialog,
                      child: Container(
                        height: 100,
                        width: 150,
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 170, 207, 237),
                              Colors.blueAccent,
                            ],
                          ),
                        ),
                        child: Center(child: Text("Create Election")),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      height: 100,
                      width: 160,
                      margin: EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "All Elections",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            StreamBuilder(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text(snapshot.error.toString());
                }
                final elections = snapshot.data;
                return Expanded(
                  child: ListView.builder(
                    itemCount: elections!.length,
                    itemBuilder: (context, index) {
                      final elec = elections[index];
                      print(elec['name']);
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListTile(
                          title: Text(elec['name']),
                          leading: FloatingActionButton(
                            onPressed: () {},
                            child: Icon(Icons.add),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
