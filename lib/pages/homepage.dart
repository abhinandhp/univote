import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/auth/authservice.dart';
import 'package:univote/models/model.dart';
import 'package:univote/pages/resultdetails.dart';
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

  // Color scheme
  final Color primaryColor = const Color(0xFF6C63FF);
  final Color secondaryColor = const Color(0xFF8A84FF);
  final Color accentColor = const Color(0xFFFF6584);
  final Color neutralDark = const Color(0xFF2D3142);
  final Color neutralLight = const Color(0xFFF8F7FF);
  final Color activeColor = const Color(0xFF42E2B8);
  final Color upcomingColor = const Color(0xFFFFC857);
  final Color pastColor = const Color(0xFF9297C4);

  Future<Map<String, dynamic>> getUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print("No user is logged in.");
      return {'username': "Invalid User"};
    }

    profile =
        await supabase.from('profiles').select().eq('id', user.id).single();
    return profile;
  }

  Future<int> resultcount() async {
    final data = await supabase.from('elections').select().eq('publish', true);
    return data.length;
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

  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} days ${duration.inHours % 24} hours';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
    } else {
      return '${duration.inMinutes} minutes';
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
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: primaryColor,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                widget.tabController.jumpToTab(3);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  child: Text('AB'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: accentColor),
            onPressed: logout,
            tooltip: 'Logout',
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: neutralLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: RefreshIndicator(
            color: primaryColor,
            onRefresh: () async {
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting section
                  const SizedBox(height: 12),
                  FutureBuilder(
                    future: getUserProfile(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SpinKitThreeBounce(
                            size: 18,
                            color: accentColor,
                          ),
                        );
                      }

                      var data = snapshot.data;
                      String name = data!['username'];
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Hello ",
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  color: neutralDark,
                                ),
                              ),
                              TextSpan(
                                text: name,
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Results Card
                  _buildResultsCard(context),

                  const SizedBox(height: 32),

                  // Active Elections
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSectionHeader('Active Elections', activeColor),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          widget.tabController.jumpToTab(1);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: activeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "See all",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: activeColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildElectionsList(0),

                  const SizedBox(height: 32),

                  // Upcoming Elections
                  _buildSectionHeader('Upcoming Elections', upcomingColor),
                  const SizedBox(height: 16),
                  _buildElectionsList(1),

                  const SizedBox(height: 32),

                  // Past Elections
                  _buildSectionHeader('Past Elections', pastColor),
                  const SizedBox(height: 16),
                  _buildElectionsList(2),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: neutralDark,
          ),
        ),
      ],
    );
  }

  Widget _buildResultsCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.tabController.jumpToTab(2);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.19,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              right: -30,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            color: Colors.white.withOpacity(0.9),
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Results',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      FutureBuilder(
                        future: resultcount(),

                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SpinKitThreeBounce(
                              size: 16,
                              color: accentColor,
                            );
                          }

                          var data = snapshot.data;
                          String count = data!.toString();
                          return Text(
                            count,
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElectionsList(int type) {
    return StreamBuilder(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => buildShimmerElectionCard(type),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorCard(type);
        }

        final elections = snapshot.data;
        if (elections == null || elections.isEmpty) {
          return _buildEmptyCard(type);
        }

        final now = DateTime.now();
        List filteredElections;

        // Filter elections based on type
        if (type == 0) {
          // Active
          filteredElections =
              elections
                  .where(
                    (elec) =>
                        DateTime.parse(elec['start']).isBefore(now) &&
                        DateTime.parse(elec['end']).isAfter(now),
                  )
                  .toList();
        } else if (type == 1) {
          // Upcoming
          filteredElections =
              elections
                  .where((elec) => DateTime.parse(elec['start']).isAfter(now))
                  .toList();
        } else {
          // Past
          filteredElections =
              elections
                  .where((elec) => DateTime.parse(elec['end']).isBefore(now))
                  .toList();
        }

        if (filteredElections.isEmpty) {
          return _buildEmptyCard(type);
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredElections.length,
            itemBuilder: (context, index) {
              return _buildElectionCard(filteredElections[index], type, now);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyCard(int type) {
    String message;
    Color cardColor;
    Color iconColor;
    IconData iconData;

    if (type == 0) {
      message = 'No active elections';
      cardColor = activeColor.withOpacity(0.15);
      iconColor = activeColor;
      iconData = Icons.hourglass_empty_rounded;
    } else if (type == 1) {
      message = 'No upcoming elections';
      cardColor = upcomingColor.withOpacity(0.15);
      iconColor = upcomingColor;
      iconData = Icons.event_repeat_sharp;
    } else {
      message = 'No past elections';
      cardColor = pastColor.withOpacity(0.15);
      iconColor = pastColor;
      iconData = Icons.history;
    }

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width - 32,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 48, color: iconColor),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: neutralDark.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(int type) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => buildShimmerElectionCard(type),
      ),
    );
  }

  Widget _buildElectionCard(Map<String, dynamic> elec, int type, DateTime now) {
    String statusLabel;
    Color statusColor;
    IconData statusIcon;
    Color cardBgColor;
    Color borderColor;
    String timeText;
    IconData timeIcon;

    if (type == 0) {
      // Active
      statusLabel = 'Active';
      statusColor = activeColor;
      statusIcon = Icons.play_circle_filled;
      cardBgColor = neutralLight;
      borderColor = activeColor;
      timeIcon = Icons.timer;

      final timeLeft = DateTime.parse(elec['end']).difference(now);
      timeText = 'Ends in: ${formatDuration(timeLeft)}';
    } else if (type == 1) {
      // Upcoming
      statusLabel = 'Upcoming';
      statusColor = upcomingColor;
      statusIcon = Icons.upcoming;
      cardBgColor = neutralLight;
      borderColor = upcomingColor;
      timeIcon = Icons.event;

      final timeLeft = DateTime.parse(elec['start']).difference(now);
      timeText = 'Starts in: ${formatDuration(timeLeft)}';
    } else {
      // Past
      statusLabel = 'Ended';
      statusColor = pastColor;
      statusIcon = Icons.check_circle;
      cardBgColor = neutralLight;
      borderColor = pastColor;
      timeIcon = Icons.event_available;

      timeText =
          'Ended on: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(elec['end']))}';
    }

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 10),
      child: Card(
        elevation: 2,
        shadowColor: borderColor.withOpacity(0.4),
        color: cardBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor.withOpacity(0.5), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      elec['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: neutralDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: GoogleFonts.poppins(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(timeIcon, size: 16, color: statusColor.withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Text(
                    timeText,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: neutralDark.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (type != 2) // Not past
                    OutlinedButton.icon(
                      onPressed: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: UserElectionDetails(
                            elec: elec,
                            profile: profile,
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('View'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: statusColor,
                        side: BorderSide(color: statusColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  if (type == 2) // Past
                    ElevatedButton.icon(
                      onPressed: () {
                        elec['publish']
                            ? PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: ResultDetailsPage(
                                election: Election.fromMap(elec),
                              ),
                              withNavBar: false,
                            )
                            : ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text("Results not published"),
                                  ],
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                        ;
                      },
                      icon: const Icon(Icons.bar_chart_rounded),
                      label: const Text('Results'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pastColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildShimmerElectionCard(int type) {
  Color baseColor;
  Color highlightColor;

  if (type == 0) {
    baseColor = const Color(0xFFE0F2F1);
    highlightColor = const Color(0xFFF5F5F5);
  } else if (type == 1) {
    baseColor = const Color(0xFFFFF8E1);
    highlightColor = const Color(0xFFF5F5F5);
  } else {
    baseColor = const Color(0xFFE8EAF6);
    highlightColor = const Color(0xFFF5F5F5);
  }

  return Container(
    width: 300,
    margin: const EdgeInsets.only(right: 16),
    child: Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    width: 180,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time Remaining Placeholder
              Container(
                width: 200,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 30),

              // Buttons Placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 90,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 90,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
