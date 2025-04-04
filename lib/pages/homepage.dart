import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/auth/authservice.dart';
import 'package:univote/pages/userelctiondetails.dart';
import 'package:univote/supabase/electionbase.dart';
import 'package:intl/intl.dart';

final supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  final PersistentTabController tabController;
  const HomePage({super.key, required this.tabController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final electionbase = ElectionBase();

  final AuthService authService = AuthService();

  final _stream = supabase
      .from('elections')
      .stream(primaryKey: ['id'])
      .order('end', ascending: true);

  late Map<String, dynamic> profile;

  Future<void> getUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print("No user is logged in.");
      return;
    }

    profile =
        await supabase.from('profiles').select().eq('id', user.id).single();

    // print("Is Admin: ${profile['is_admin']}");
  }

  @override
  void initState() {
    getUserProfile();
    super.initState();
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
              'Univote',
              style: GoogleFonts.ultra(
                //fontWeight: FontWeight.bold,
                fontSize: 28,
                letterSpacing: 1.5,
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                widget.tabController.jumpToTab(3);
              },
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: Text('AB'),
              ),
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
        padding: EdgeInsets.symmetric(horizontal: 9),
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
                    color: const Color.fromARGB(255, 34, 32, 52),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () {
                  widget.tabController.jumpToTab(2);
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.19,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23),
                    ),

                    //color: const Color.fromARGB(255, 34, 32, 52),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23),
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A237E), Color(0xFF303F9F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  ' Results',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    letterSpacing: 2,
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
                              color: const Color.fromARGB(255, 236, 208, 83),
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
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Results',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade900,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 350,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // Apply border radius
                  image: DecorationImage(
                    image: AssetImage('assets/result.jpg'),
                    fit: BoxFit.cover, // Ensures the image fills the container
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                            color: const Color.fromARGB(255, 229, 243, 241),
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
                                          color: Color.fromARGB(
                                            255,
                                            34,
                                            32,
                                            52,
                                          ),
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
                                                      UserElectionDetails(
                                                        elec: elec,
                                                        profile: profile,
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

                  final elections = snapshot.data;
                  if (elections == null || elections.isEmpty) {
                    return Card(
                      color: const Color.fromARGB(255, 168, 185, 223),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No upcoming elections',
                            style: GoogleFonts.outfit(fontSize: 18),
                          ),
                        ),
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
                    return Card(
                      color: const Color.fromARGB(255, 168, 185, 223),

                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No upcoming elections',
                            style: GoogleFonts.outfit(fontSize: 18),
                          ),
                        ),
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
                            color: const Color.fromARGB(255, 244, 229, 217),
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
                                          color: Color.fromARGB(
                                            255,
                                            34,
                                            32,
                                            52,
                                          ),
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
                                                      UserElectionDetails(
                                                        elec: elec,
                                                        profile: profile,
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
                  color: Color.fromARGB(255, 66, 65, 82),
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
                            (context, index) => buildShimmerElectionCard(2),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 175,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder:
                            (context, index) => buildShimmerElectionCard(2),
                      ),
                    );
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
                              side: BorderSide(
                                color: Color.fromARGB(255, 70, 69, 86),
                                width: 2,
                              ),
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
                                          color: Color.fromARGB(
                                            255,
                                            34,
                                            32,
                                            52,
                                          ),
                                        ),
                                      ),
                                      Chip(
                                        label: Text('Ended'),
                                        backgroundColor: Color.fromARGB(
                                          255,
                                          165,
                                          164,
                                          181,
                                        ),
                                        labelStyle: GoogleFonts.outfit(
                                          color: Color.fromARGB(
                                            255,
                                            49,
                                            48,
                                            61,
                                          ),
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
                                                      UserElectionDetails(
                                                        elec: elec,
                                                        profile: profile,
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
              SizedBox(height: 150),
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
              : type == 1
              ? Color.fromARGB(223, 249, 229, 196)
              : Color.fromARGB(223, 190, 189, 189),

      highlightColor:
          type == 0
              ? const Color.fromARGB(246, 237, 248, 248)
              : type == 1
              ? const Color.fromARGB(246, 248, 243, 237)
              : Color.fromARGB(246, 216, 216, 216),
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






// Container(
//                 height: 200,
//                 width: 350,
//                 padding: EdgeInsets.all(8),
//                 margin: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   color: const Color.fromARGB(196, 127, 135, 230),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       height: 200,
//                       width: 135,
//                       padding: EdgeInsets.all(8),
//                       margin: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: const Color.fromARGB(196, 32, 43, 161),
//                       ),
//                     ),
//                     Column(
//                       children: [
//                         Container(
//                           height: 78,
//                           width: 135,

//                           padding: EdgeInsets.all(8),
//                           margin: EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20),
//                             color: const Color.fromARGB(196, 32, 43, 161),
//                           ),
//                         ),
//                         Container(
//                           height: 78,
//                           width: 135,

//                           padding: EdgeInsets.all(8),
//                           margin: EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20),
//                             color: const Color.fromARGB(196, 32, 43, 161),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),