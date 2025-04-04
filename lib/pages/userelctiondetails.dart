import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/pages/votingpage.dart';
import 'package:univote/supabase/candidbase.dart';

final supabase = Supabase.instance.client;

class UserElectionDetails extends StatefulWidget {
  final Map<String, dynamic> elec;
  final Map<String, dynamic> profile;
  const UserElectionDetails({
    super.key,
    required this.elec,
    required this.profile,
  });
  @override
  State<UserElectionDetails> createState() => _UserElectionDetailsState();
}

class _UserElectionDetailsState extends State<UserElectionDetails> {
  final candibase = CandidBase();

  final client = Supabase.instance.client;

  void approve(int id) {
    candibase.updateStatus(id, {"approved": true});
  }

  late Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = client
        .from('candidates')
        .stream(primaryKey: ['id'])
        .eq('electionId', widget.elec['id']);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> elec = widget.elec;

    late List<Map<String, dynamic>> nominees;

    DateTime now = DateTime.now();

    Duration remaining = DateTime.parse(elec["end"]).difference(now);

    int days = remaining.inDays;
    int hours = remaining.inHours % 24;
    int minutes = remaining.inMinutes % 60;

    String timeres;
    if (remaining.isNegative || remaining.inSeconds == 0) {
      timeres = "Voting Ended";
    } else {
      timeres = 'Voting ends in $days days $hours hours $minutes minutes';
    }

    void showConfirmationDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Nomination"),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await client.from('candidates').insert({
                      'uid': widget.profile['id'],
                      'name': widget.profile['username'],
                      'rollno': widget.profile['rollno'],
                      'electionId': widget.elec['id'],
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text(
                          "Nomination submitted for approval!",
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 66, 65, 82),
                          ),
                        ),
                      ),
                    );
                  } on PostgrestException catch (e) {
                    if (e.code == '23505') {
                      // 23505 = Unique constraint violation in PostgreSQL
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "You have already applied for this election.",
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Database Error: ${e.message}"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: ${e.toString()}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  Navigator.of(
                    context,
                  ).pop(); // Close the dialog after submission
                },
                child: const Text("Confirm"),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Election Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          elec['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'B22 Computer Science',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 4),
                        Text(timeres, style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Election Timeline',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('• Registration: Feb 20 - Feb 25, 2025'),
                          Text('• Voting: Feb 26 - Mar 2, 2025'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  (DateTime.parse(elec['start']).isAfter(DateTime.now()))
                      ? Center(
                        child: GestureDetector(
                          onTap: () {
                            showConfirmationDialog();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.green,
                            ),
                            child: Text(
                              "Submit Nomination",
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color.fromARGB(255, 17, 12, 80),
                              ),
                            ),
                          ),
                        ),
                      )
                      : SizedBox(height: 8),

                  Text(
                    'Candidates',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(
                    height: 800,
                    child: StreamBuilder(
                      stream: _stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        if (!snapshot.hasData ||
                            (snapshot.data as List).isEmpty) {
                          return const Center(
                            child: Text("Nothing to display"),
                          );
                        }

                        // Filter only approved candidates
                        final approvedCands =
                            (snapshot.data as List<dynamic>)
                                .where(
                                  (candidate) => candidate['approved'] == true,
                                )
                                .toList();
                        nominees = approvedCands.cast<Map<String, dynamic>>();

                        if (approvedCands.isEmpty) {
                          return const Center(
                            child: Text("No approved candidates"),
                          );
                        }

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: approvedCands.length,
                          itemBuilder: (context, index) {
                            final candidate = approvedCands[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey.shade300,
                                  child: Text(
                                    candidate['name'][0]
                                        .toString()
                                        .toUpperCase(),
                                  ),
                                ),
                                title: Text(candidate['name']),
                                subtitle: Text(candidate['rollno']),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
          (DateTime.parse(elec['start']).isBefore(DateTime.now()) &&
                  DateTime.parse(elec['end']).isAfter(DateTime.now()))
              ? Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: VotingPage(elec: elec, nominees: nominees),
                        withNavBar: false, // OPTIONAL VALUE. True by default.
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 23,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 22, 23, 49),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(
                        "Cast Vote",
                        style: GoogleFonts.outfit(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              : SizedBox(),
        ],
      ),
    );
  }
}
