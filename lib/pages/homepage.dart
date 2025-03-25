import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/auth/authservice.dart';
import 'package:univote/models/model.dart';
import 'package:univote/pages/admin/electiondetails.dart';
import 'package:univote/supabase/electionbase.dart';
import 'package:intl/intl.dart';

final supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
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
            : DateFormat('yyyy-MM-dd HH:mm').format(dateTime),
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
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(9),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Hello Abhinandh...",
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.19,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Active Elections',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder(
                              future: supabase.from('elections').count(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SpinKitThreeBounce(
                                    size: 18,
                                    color: Colors.amber,
                                  );
                                }

                                var data = snapshot.data;
                                String count = data!.toString();
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    count,
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Spacer(),
                        Icon(
                          Icons.navigate_next_rounded,
                          color: Colors.white,
                          size: 60,
                          shadows: const [
                            BoxShadow(
                              color: Color.fromARGB(170, 255, 243, 6),
                              blurRadius: 18,
                              offset: Offset(-2, 2),
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Active Elections',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 15),

              StreamBuilder(
                stream: _stream, // Backend stream for fetching elections
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 175,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder:
                            (context, index) => buildShimmerElectionCard(0),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: \${snapshot.error}"));
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

                  final now = DateTime.now();
                  final activeElections =
                      elections
                          .where(
                            (elec) =>
                                DateTime.parse(elec['start']).isBefore(now) &&
                                DateTime.parse(elec['end']).isAfter(now),
                          )
                          .toList();

                  if (activeElections.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No active elections')),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 175,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: activeElections.length,
                      itemBuilder: (context, index) {
                        final elec = activeElections[index];
                        final timeLeft = DateTime.parse(
                          elec['end'],
                        ).difference(now);

                        String formatDuration(Duration duration) {
                          if (duration.inDays > 0) {
                            return '${duration.inDays} days ${duration.inHours % 24} hours';
                          } else if (duration.inHours > 0) {
                            return '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
                          } else {
                            return '${duration.inMinutes} minutes';
                          }
                        }

                        return SizedBox(
                          width: 300,
                          child: Card(
                            margin: const EdgeInsets.only(right: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.blue, width: 2),
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
                                        elec['name'],
                                        style: GoogleFonts.outfit(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Chip(
                                        label: Text('Active'),
                                        backgroundColor: Colors.blue.shade100,
                                        labelStyle: GoogleFonts.outfit(
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Ends in: ${formatDuration(timeLeft)}',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),

                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      AdminElectionDetails(
                                                        elec: elec,
                                                      ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.visibility),
                                        label: const Text('View'),
                                      ),
                                      // const SizedBox(width: 8),
                                      // OutlinedButton.icon(
                                      //   onPressed: () {
                                      //     // Edit election
                                      //   },
                                      //   icon: const Icon(Icons.edit),
                                      //   label: const Text('Edit'),
                                      // ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          // View live results
                                        },
                                        icon: const Icon(Icons.poll),
                                        label: const Text('Results'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Upcoming Elections',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 10),
              StreamBuilder(
                stream: _stream, // Backend stream for fetching elections
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 175,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder:
                            (context, index) => buildShimmerElectionCard(1),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: \${snapshot.error}"));
                  }

                  final elections = snapshot.data;
                  if (elections == null || elections.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No upcoming elections')),
                      ),
                    );
                  }

                  final now = DateTime.now();
                  final upcomingElections =
                      elections
                          .where(
                            (elec) =>
                                DateTime.parse(elec['start']).isAfter(now),
                          )
                          .toList();

                  if (upcomingElections.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No upcoming elections')),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 175,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: upcomingElections.length,
                      itemBuilder: (context, index) {
                        final elec = upcomingElections[index];
                        final timeLeft = DateTime.parse(
                          elec['start'],
                        ).difference(now);

                        String formatDuration(Duration duration) {
                          if (duration.inDays > 0) {
                            return '${duration.inDays} days ${duration.inHours % 24} hours';
                          } else if (duration.inHours > 0) {
                            return '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
                          } else {
                            return '${duration.inMinutes} minutes';
                          }
                        }

                        return SizedBox(
                          width: 300,
                          child: Card(
                            margin: const EdgeInsets.only(right: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.orange, width: 2),
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
                                        elec['name'],
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Chip(
                                        label: Text('Upcoming'),
                                        backgroundColor: Colors.orange.shade100,
                                        labelStyle: GoogleFonts.outfit(
                                          color: Colors.orange.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Starts in: ${formatDuration(timeLeft)}',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Colors.orange,
                                    ),
                                  ),

                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      AdminElectionDetails(
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              SizedBox(height: 20),
              Text(
                'Past Elections',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 10),

              StreamBuilder(
                stream: _stream, // Backend stream for fetching elections
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 175,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder:
                            (context, index) => buildShimmerElectionCard(1),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: \${snapshot.error}"));
                  }

                  final elections = snapshot.data;
                  if (elections == null || elections.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No past elections')),
                      ),
                    );
                  }

                  final now = DateTime.now();
                  final pastElections =
                      elections
                          .where(
                            (elec) => DateTime.parse(elec['end']).isBefore(now),
                          )
                          .toList();

                  if (pastElections.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No past elections')),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 175,

                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      //physics: const NeverScrollableScrollPhysics(),
                      itemCount: pastElections.length,
                      itemBuilder: (context, index) {
                        final elec = pastElections[index];

                        return SizedBox(
                          width: 300,

                          child: Card(
                            margin: const EdgeInsets.only(right: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey, width: 2),
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
                                        elec['name'],
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Chip(
                                        label: Text('Ended'),
                                        backgroundColor: Colors.grey.shade100,
                                        labelStyle: GoogleFonts.outfit(
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Ended on: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(elec['end']))}',
                                    style: GoogleFonts.outfit(
                                      color: Colors.grey.shade700,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      AdminElectionDetails(
                                                        elec: elec,
                                                      ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.visibility),
                                        label: const Text('View'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          // View final results
                                        },
                                        icon: const Icon(Icons.bar_chart),
                                        label: const Text('Results'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.green.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildShimmerElectionCard(int type) {
  return SizedBox(
    width: 300,
    child: Shimmer.fromColors(
      baseColor:
          type == 0
              ? Color.fromARGB(223, 196, 230, 249)
              : Color.fromARGB(223, 249, 229, 196),

      highlightColor:
          type == 0
              ? const Color.fromARGB(246, 237, 248, 248)
              : const Color.fromARGB(246, 248, 243, 237),
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: const Color.fromARGB(255, 233, 250, 171),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Status Chip Placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Time Remaining Placeholder
              Container(
                width: 180,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),

              // Buttons Placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 80,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 100,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
