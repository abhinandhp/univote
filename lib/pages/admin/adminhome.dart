// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:univote/auth/authservice.dart';
// import 'package:univote/models/model.dart';
// import 'package:univote/pages/admin/electiondetails.dart';
// import 'package:univote/supabase/electionbase.dart';
// import 'package:intl/intl.dart';

// final supabase = Supabase.instance.client;

// class AdminHome extends StatefulWidget {
//   const AdminHome({super.key});

//   @override
//   State<AdminHome> createState() => _AdminHomeState();
// }

// class _AdminHomeState extends State<AdminHome> {
//   final electionbase = ElectionBase();
//   final _electionNameController = TextEditingController();
//   DateTime? _startDateTime;
//   DateTime? _endDateTime;

//   void _showElectionDialog() async {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Create Election"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Election Name Input
//               TextField(
//                 controller: _electionNameController,
//                 decoration: InputDecoration(labelText: "Election Name"),
//               ),

//               // Start DateTime Picker
//               ListTile(
//                 title: Text(
//                   _startDateTime == null
//                       ? "Select Start Date & Time"
//                       : "Start: ${DateFormat('yyyy-MM-dd HH:mm').format(_startDateTime!)}",
//                 ),
//                 trailing: Icon(Icons.calendar_today),
//                 onTap: () async {
//                   DateTime? picked = await _pickDateTime();
//                   if (picked != null) {
//                     setState(() {
//                       _startDateTime = picked;
//                     });
//                   }
//                 },
//               ),

//               // End DateTime Picker
//               ListTile(
//                 title: Text(
//                   _endDateTime == null
//                       ? "Select End Date & Time"
//                       : "End: ${DateFormat('yyyy-MM-dd HH:mm').format(_endDateTime!)}",
//                 ),
//                 trailing: Icon(Icons.calendar_today),
//                 onTap: () async {
//                   DateTime? picked = await _pickDateTime();
//                   if (picked != null) {
//                     setState(() {
//                       _endDateTime = picked;
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context), // Close Dialog
//               child: Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 print("debugggg");
//                 if (_electionNameController.text.isEmpty ||
//                     _startDateTime == null ||
//                     _endDateTime == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Please fill all fields")),
//                   );
//                   return;
//                 }
//                 final newElection = Election(
//                   name: _electionNameController.text,
//                   start: _startDateTime,
//                   end: _endDateTime,
//                 );
//                 electionbase.createElection(newElection);
//                 // Handle election submission
//                 print("Election Name: ${_electionNameController.text}");
//                 print("Start DateTime: $_startDateTime");
//                 print("End DateTime: $_endDateTime");

//                 Navigator.pop(context); // Close Dialog
//               },
//               child: Text("Submit"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Function to pick Date and Time
//   Future<DateTime?> _pickDateTime() async {
//     DateTime? date = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (date == null) return null; // User canceled

//     TimeOfDay? time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );

//     if (time == null) return null; // User canceled

//     return DateTime(date.year, date.month, date.day, time.hour, time.minute);
//   }

//   final _stream = supabase.from('elections').stream(primaryKey: ['id']);

//   final AuthService authService=AuthService();
//   void logout() async{
//     try {
//     await authService.signOut();

//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Admin Dashboard",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             SizedBox(
//               width: MediaQuery.of(context).size.width,
//               child: SingleChildScrollView(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     GestureDetector(
//                       onTap: _showElectionDialog,
//                       child: Container(
//                         height: 100,
//                         width: 150,
//                         margin: EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           gradient: LinearGradient(
//                             colors: [
//                               const Color.fromARGB(255, 170, 207, 237),
//                               Colors.blueAccent,
//                             ],
//                           ),
//                         ),
//                         child: Center(child: Text("C")),
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     Container(
//                       height: 100,
//                       width: 160,
//                       margin: EdgeInsets.all(10),

//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.blueAccent,
//                       ),
//                       child: TextButton(onPressed: logout, child: Text("Logout")),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 30),
//             Text(
//               "All Elections",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             StreamBuilder(
//               stream: _stream,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   print(snapshot.error);
//                   return Text(snapshot.error.toString());
//                 }
//                 final elections = snapshot.data;
//                 return Expanded(
//                   child: ListView.builder(
//                     itemCount: elections!.length,
//                     itemBuilder: (context, index) {
//                       final elec = elections[index];
//                       print(elec['name']);
//                       return Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.push(context, MaterialPageRoute(builder: (context) {
//                               return AdminElectionDetails(elec: elec,);
//                             },));
//                           },
//                           child: ListTile(
//                             title: Text(elec['name']),

//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/auth/authservice.dart';
import 'package:univote/models/model.dart';
import 'package:univote/pages/admin/electiondetails.dart';
import 'package:univote/supabase/electionbase.dart';
import 'package:intl/intl.dart';

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
  final AuthService authService = AuthService();
  final _stream = supabase.from('elections').stream(primaryKey: ['id']);

  void _showElectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Create Election",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _electionNameController,
                decoration: InputDecoration(
                  labelText: "Election Name",
                  hintText: 'e.g., Class Representative',
                ),
              ),
              SizedBox(height: 10),
              _buildDateTimePicker("Select Start Date & Time", _startDateTime, (
                dateTime,
              ) {
                setState(() => _startDateTime = dateTime);
              }),
              _buildDateTimePicker("Select End Date & Time", _endDateTime, (
                dateTime,
              ) {
                if (_startDateTime != null &&
                    dateTime.isBefore(_startDateTime!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("End date cannot be before start date"),
                    ),
                  );
                  return;
                }
                setState(() => _endDateTime = dateTime);
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
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
                _electionNameController.clear();
                _startDateTime = null;
                _endDateTime = null;
                Navigator.pop(context);
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateTimePicker(
    String label,
    DateTime? dateTime,
    Function(DateTime) onDatePicked,
  ) {
    return ListTile(
      title: Text(
        dateTime == null
            ? label
            : "${DateFormat('yyyy-MM-dd HH:mm').format(dateTime)}",
      ),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        DateTime? picked = await _pickDateTime();
        if (picked != null) onDatePicked(picked);
      },
    );
  }

  Future<DateTime?> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void logout() async {
    try {
      await authService.signOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'UNIVOTE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Spacer(),
            CircleAvatar(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: Text('AB'),
            ),
          ],
        ),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: logout)],
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Admin Dashboard",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Elections',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          //  '${activeElections.length}',
                          '0',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Manage Elections",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
          
                  Spacer(),
          
                  ElevatedButton.icon(
                    onPressed: _showElectionDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Election'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              const Text(
                'Active Elections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
          
              StreamBuilder(
                stream: _stream, // Backend stream for fetching elections
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                        
                  final elections = snapshot.data;
                  if (elections == null || elections.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No active elections')),
                      ),
                    );
                  }
                        
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: elections.length,
                    itemBuilder: (context, index) {
                      final elec = elections[index];
                      final now = DateTime.now();
                      final bool isActive =
                          DateTime.parse(elec['start']).isBefore(now) &&
                          DateTime.parse(elec['end']).isAfter(now);
                      final bool isUpcoming = DateTime.parse(
                        elec['start'],
                      ).isAfter(now);
                        
                      Color borderColor = Colors.grey;
                      if (isActive) borderColor = Colors.blue;
                      if (isUpcoming) borderColor = Colors.orange;
                        
                      String status = 'Ended';
                      if (isActive) status = 'Active';
                      if (isUpcoming) status = 'Upcoming';
                        
                      Duration timeLeft = Duration.zero;
                      String timeLeftText = '';
                        
                      if (isActive) {
                        timeLeft = DateTime.parse(elec['end']).difference(now);
                        timeLeftText = 'Ends in: ';
                      } else if (isUpcoming) {
                        timeLeft = DateTime.parse(
                          elec['start'],
                        ).difference(now);
                        timeLeftText = 'Starts in: ';
                      }
                        
                      String formatDuration(Duration duration) {
                        if (duration.inDays > 0) {
                          return '${duration.inDays} days ${duration.inHours % 24} hours';
                        } else if (duration.inHours > 0) {
                          return '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
                        } else {
                          return '${duration.inMinutes} minutes';
                        }
                      }
                        
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: borderColor, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${elec['name']} - ${elec['department'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(status),
                                    backgroundColor:
                                        isActive
                                            ? Colors.blue.shade100
                                            : isUpcoming
                                            ? Colors.orange.shade100
                                            : Colors.grey.shade100,
                                    labelStyle: TextStyle(
                                      color:
                                          isActive
                                              ? Colors.blue.shade900
                                              : isUpcoming
                                              ? Colors.orange.shade900
                                              : Colors.grey.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (isActive || isUpcoming)
                                Text(
                                  '$timeLeftText${formatDuration(timeLeft)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isActive ? Colors.blue : Colors.orange,
                                  ),
                                )
                              else
                                Text(
                                  'Ended on: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(elec['end']))}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                'Candidates: ${elec['candidates'] ?? 'N/A'}',
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // View election details
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => AdminElectionDetails(
                                                elec: elec,
                                              ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.visibility),
                                    label: const Text('View'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // Edit election
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isActive)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // View live results
                                      },
                                      icon: const Icon(Icons.poll),
                                      label: const Text('Results'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade900,
                                      ),
                                    )
                                  else if (!isUpcoming)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // View final results
                                      },
                                      icon: const Icon(Icons.bar_chart),
                                      label: const Text('Results'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade800,
                                      ),
                                    )
                                  else
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Manage candidates
                                      },
                                      icon: const Icon(Icons.person_add),
                                      label: const Text('Candidates'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade800,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
               SizedBox(height: 20),
              const Text(
                'Upcoming Elections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              StreamBuilder(
                stream: _stream, // Backend stream for fetching elections
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                        
                  final elections = snapshot.data;
                  if (elections == null || elections.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No active elections')),
                      ),
                    );
                  }
                        
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: elections.length,
                    itemBuilder: (context, index) {
                      final elec = elections[index];
                      final now = DateTime.now();
                      final bool isActive =
                          DateTime.parse(elec['start']).isBefore(now) &&
                          DateTime.parse(elec['end']).isAfter(now);
                      final bool isUpcoming = DateTime.parse(
                        elec['start'],
                      ).isAfter(now);
                        
                      Color borderColor = Colors.grey;
                      if (isActive) borderColor = Colors.blue;
                      if (isUpcoming) borderColor = Colors.orange;
                        
                      String status = 'Ended';
                      if (isActive) status = 'Active';
                      if (isUpcoming) status = 'Upcoming';
                        
                      Duration timeLeft = Duration.zero;
                      String timeLeftText = '';
                        
                      if (isActive) {
                        timeLeft = DateTime.parse(elec['end']).difference(now);
                        timeLeftText = 'Ends in: ';
                      } else if (isUpcoming) {
                        timeLeft = DateTime.parse(
                          elec['start'],
                        ).difference(now);
                        timeLeftText = 'Starts in: ';
                      }
                        
                      String formatDuration(Duration duration) {
                        if (duration.inDays > 0) {
                          return '${duration.inDays} days ${duration.inHours % 24} hours';
                        } else if (duration.inHours > 0) {
                          return '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
                        } else {
                          return '${duration.inMinutes} minutes';
                        }
                      }
                        
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: borderColor, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${elec['name']} - ${elec['department'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(status),
                                    backgroundColor:
                                        isActive
                                            ? Colors.blue.shade100
                                            : isUpcoming
                                            ? Colors.orange.shade100
                                            : Colors.grey.shade100,
                                    labelStyle: TextStyle(
                                      color:
                                          isActive
                                              ? Colors.blue.shade900
                                              : isUpcoming
                                              ? Colors.orange.shade900
                                              : Colors.grey.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (isActive || isUpcoming)
                                Text(
                                  '$timeLeftText${formatDuration(timeLeft)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isActive ? Colors.blue : Colors.orange,
                                  ),
                                )
                              else
                                Text(
                                  'Ended on: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(elec['end']))}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                'Candidates: ${elec['candidates'] ?? 'N/A'}',
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // View election details
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => AdminElectionDetails(
                                                elec: elec,
                                              ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.visibility),
                                    label: const Text('View'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // Edit election
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isActive)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // View live results
                                      },
                                      icon: const Icon(Icons.poll),
                                      label: const Text('Results'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade900,
                                      ),
                                    )
                                  else if (!isUpcoming)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // View final results
                                      },
                                      icon: const Icon(Icons.bar_chart),
                                      label: const Text('Results'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade800,
                                      ),
                                    )
                                  else
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Manage candidates
                                      },
                                      icon: const Icon(Icons.person_add),
                                      label: const Text('Candidates'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade800,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              
               SizedBox(height: 20),
              const Text(
                'Past Elections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
          
              StreamBuilder(
                stream: _stream, // Backend stream for fetching elections
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                        
                  final elections = snapshot.data;
                  if (elections == null || elections.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No active elections')),
                      ),
                    );
                  }
                        
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: elections.length,
                    itemBuilder: (context, index) {
                      final elec = elections[index];
                      final now = DateTime.now();
                      final bool isActive =
                          DateTime.parse(elec['start']).isBefore(now) &&
                          DateTime.parse(elec['end']).isAfter(now);
                      final bool isUpcoming = DateTime.parse(
                        elec['start'],
                      ).isAfter(now);
                        
                      Color borderColor = Colors.grey;
                      if (isActive) borderColor = Colors.blue;
                      if (isUpcoming) borderColor = Colors.orange;
                        
                      String status = 'Ended';
                      if (isActive) status = 'Active';
                      if (isUpcoming) status = 'Upcoming';
                        
                      Duration timeLeft = Duration.zero;
                      String timeLeftText = '';
                        
                      if (isActive) {
                        timeLeft = DateTime.parse(elec['end']).difference(now);
                        timeLeftText = 'Ends in: ';
                      } else if (isUpcoming) {
                        timeLeft = DateTime.parse(
                          elec['start'],
                        ).difference(now);
                        timeLeftText = 'Starts in: ';
                      }
                        
                      String formatDuration(Duration duration) {
                        if (duration.inDays > 0) {
                          return '${duration.inDays} days ${duration.inHours % 24} hours';
                        } else if (duration.inHours > 0) {
                          return '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
                        } else {
                          return '${duration.inMinutes} minutes';
                        }
                      }
                        
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: borderColor, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${elec['name']} - ${elec['department'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(status),
                                    backgroundColor:
                                        isActive
                                            ? Colors.blue.shade100
                                            : isUpcoming
                                            ? Colors.orange.shade100
                                            : Colors.grey.shade100,
                                    labelStyle: TextStyle(
                                      color:
                                          isActive
                                              ? Colors.blue.shade900
                                              : isUpcoming
                                              ? Colors.orange.shade900
                                              : Colors.grey.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (isActive || isUpcoming)
                                Text(
                                  '$timeLeftText${formatDuration(timeLeft)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isActive ? Colors.blue : Colors.orange,
                                  ),
                                )
                              else
                                Text(
                                  'Ended on: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(elec['end']))}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                'Candidates: ${elec['candidates'] ?? 'N/A'}',
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // View election details
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => AdminElectionDetails(
                                                elec: elec,
                                              ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.visibility),
                                    label: const Text('View'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      // Edit election
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isActive)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // View live results
                                      },
                                      icon: const Icon(Icons.poll),
                                      label: const Text('Results'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade900,
                                      ),
                                    )
                                  else if (!isUpcoming)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // View final results
                                      },
                                      icon: const Icon(Icons.bar_chart),
                                      label: const Text('Results'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade800,
                                      ),
                                    )
                                  else
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Manage candidates
                                      },
                                      icon: const Icon(Icons.person_add),
                                      label: const Text('Candidates'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade800,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
