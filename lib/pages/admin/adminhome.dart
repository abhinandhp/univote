import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/auth/authservice.dart';
import 'package:univote/models/model.dart';
import 'package:univote/pages/admin/electiondetails.dart';
import 'package:univote/pages/profilepage.dart';
import 'package:univote/pages/resultdetails.dart';
import 'package:univote/supabase/electionbase.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

final supabase = Supabase.instance.client;

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome>
    with SingleTickerProviderStateMixin {
  final electionbase = ElectionBase();
  final _electionNameController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  final AuthService authService = AuthService();
  final _stream = supabase.from('elections').stream(primaryKey: ['id']);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    getUserProfile();

    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _electionNameController.dispose();
    super.dispose();
  }

  late Map<String, dynamic> profile;

  Future<Map<String, dynamic>> getUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print("No user is logged in.");
      return {'username': "Invalid User"};
    }

    profile =
        await supabase.from('profiles').select().eq('id', user.id).single();
    return profile;
    // print("Is Admin: ${profile['is_admin']}");
  }

  void _showElectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? startDateTime = _startDateTime;
        DateTime? endDateTime = _endDateTime;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.blue.shade50],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create Election",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(color: Colors.blue.shade200),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _electionNameController,
                      decoration: InputDecoration(
                        labelStyle: GoogleFonts.outfit(),
                        hintStyle: GoogleFonts.outfit(),
                        labelText: "Election Name",
                        hintText: 'e.g., Class Representative',
                        prefixIcon: Icon(
                          Icons.title,
                          color: Colors.blue.shade700,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue.shade700,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDateTimePicker(
                      "Select Start Date & Time",
                      startDateTime,
                      Icons.calendar_today,
                      Colors.green.shade700,
                      (dateTime) {
                        setDialogState(() => startDateTime = dateTime);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDateTimePicker(
                      "Select End Date & Time",
                      endDateTime,
                      Icons.event_available,
                      Colors.red.shade700,
                      (dateTime) {
                        if (startDateTime != null &&
                            dateTime.isBefore(startDateTime!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              content: Text(
                                "End date cannot be before start date",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                          return;
                        }
                        setDialogState(() => endDateTime = dateTime);
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.outfit(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (_electionNameController.text.isEmpty ||
                                startDateTime == null ||
                                endDateTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red.shade800,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  content: Text(
                                    "Please fill all fields",
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                              return;
                            }
                            final newElection = Election(
                              name: _electionNameController.text,
                              start: startDateTime,
                              end: endDateTime,
                            );
                            electionbase.createElection(newElection);
                            _electionNameController.clear();
                            setState(() {
                              _startDateTime = null;
                              _endDateTime = null;
                            });
                            Navigator.pop(context);

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Election created successfully",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: Colors.green.shade800,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Create",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
    );
  }

  Widget _buildDateTimePicker(
    String label,
    DateTime? dateTime,
    IconData icon,
    Color iconColor,
    Function(DateTime) onDatePicked,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
        color: Colors.white,
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          dateTime == null
              ? label
              : DateFormat('yyyy-MM-dd HH:mm').format(dateTime),
          style: GoogleFonts.outfit(
            fontWeight: dateTime == null ? FontWeight.w400 : FontWeight.w600,
            color: dateTime == null ? Colors.grey.shade700 : Colors.black,
          ),
        ),
        trailing: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () async {
          DateTime? picked = await _pickDateTime();
          if (picked != null) onDatePicked(picked);
        },
      ),
    );
  }

  Future<DateTime?> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade900,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade900,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return null;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade900,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade900,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void logout() async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Logout Confirmation",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Are you sure you want to logout?",
              style: GoogleFonts.outfit(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.outfit(color: Colors.grey.shade700),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Logout", style: GoogleFonts.outfit()),
              ),
            ],
          );
        },
      );

      if (confirm) {
        await authService.signOut();
      }
    } catch (e) {
      print(e);
    }
  }
  //   Future<void> deleteElection(String electionId) async {
  //   final response = await Supabase.instance.client
  //       .from('elections')
  //       .delete()
  //       .eq('id', electionId);

  //   if (response.error != null) {
  //     print('Error deleting election: ${response.error!.message}');
  //   } else {
  //     print('Election deleted successfully');
  //     // You can also show a snackbar or refresh the UI
  //   }
  // }
  // String electionId =${elec['id']}

  void delete(Election elec) async {
    try {
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Delete Confirmation",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Are you sure you want to Delete?",
              style: GoogleFonts.outfit(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.outfit(color: Colors.grey.shade700),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Delete", style: GoogleFonts.outfit()),
              ),
            ],
          );
        },
      );

      if (confirm) {
        // await authService.signOut();
        await electionbase.deleteElection(elec);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.blue.shade900,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'UNIVOTE',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade800, Colors.indigo.shade900],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: -50,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -30,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              StreamBuilder(
                stream: _stream,
                builder: (context, snapshot) {
                  int activeCount = 0;
                  if (snapshot.hasData) {
                    final elections = snapshot.data;
                    if (elections != null) {
                      final now = DateTime.now();
                      activeCount =
                          elections
                              .where(
                                (elec) =>
                                    DateTime.parse(
                                      elec['start'],
                                    ).isBefore(now) &&
                                    DateTime.parse(elec['end']).isAfter(now),
                              )
                              .length;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Badge(
                      isLabelVisible: activeCount > 0,
                      label: Text('$activeCount'),
                      child: IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          // Show notifications
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "You have $activeCount active election(s)",
                                style: GoogleFonts.outfit(),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              GestureDetector(
                onTap: () async {
                  final profile = await getUserProfile();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(profile: profile),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  // child: CircleAvatar(
                  //   backgroundColor: Colors.white,
                  //   child: Text(
                  //     'AB',
                  //     style: GoogleFonts.outfit(
                  //       color: Colors.blue.shade900,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blue.shade900),
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: logout,
                tooltip: 'Logout',
              ),
              const SizedBox(width: 8),

              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade900,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dashboard,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Admin Dashboard",
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            Text(
                              "Manage your elections in one place",
                              style: GoogleFonts.outfit(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats cards
                    StreamBuilder(
                      stream: _stream,
                      builder: (context, snapshot) {
                        int activeCount = 0;
                        int upcomingCount = 0;
                        int pastCount = 0;

                        if (snapshot.hasData) {
                          final elections = snapshot.data;
                          if (elections != null) {
                            final now = DateTime.now();
                            activeCount =
                                elections
                                    .where(
                                      (elec) =>
                                          DateTime.parse(
                                            elec['start'],
                                          ).isBefore(now) &&
                                          DateTime.parse(
                                            elec['end'],
                                          ).isAfter(now),
                                    )
                                    .length;

                            upcomingCount =
                                elections
                                    .where(
                                      (elec) => DateTime.parse(
                                        elec['start'],
                                      ).isAfter(now),
                                    )
                                    .length;

                            pastCount =
                                elections
                                    .where(
                                      (elec) => DateTime.parse(
                                        elec['end'],
                                      ).isBefore(now),
                                    )
                                    .length;

                            // Placeholder for total votes
                          }
                        }

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade900,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Election Statistics",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    _buildStatCard(
                                      "Active Elections",
                                      "$activeCount",
                                      Icons.how_to_vote,
                                      Colors.blue.shade700,
                                      Colors.blue.shade100,
                                    ),
                                    _buildStatCard(
                                      "Upcoming",
                                      "$upcomingCount",
                                      Icons.upcoming,
                                      Colors.orange.shade700,
                                      Colors.orange.shade100,
                                    ),
                                    _buildStatCard(
                                      "Completed",
                                      "$pastCount",
                                      Icons.check_circle,
                                      Colors.green.shade700,
                                      Colors.green.shade100,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.settings, color: Colors.blue.shade900),
                            const SizedBox(width: 8),
                            Text(
                              "Manage Elections",
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _showElectionDialog,
                      icon: const Icon(Icons.add),
                      label: Text(
                        'Create Election',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Active Elections
          _buildElectionSection(
            "Active Elections",
            Icons.how_to_vote,
            Colors.blue.shade700,
            Colors.blue.shade50,
            (elections, now) =>
                elections
                    .where(
                      (elec) =>
                          DateTime.parse(elec['start']).isBefore(now) &&
                          DateTime.parse(elec['end']).isAfter(now),
                    )
                    .toList(),
            (elec, timeLeft) => _buildActiveElectionCard(elec, timeLeft),
            "No active elections at the moment",
          ),

          // Upcoming Elections
          _buildElectionSection(
            "Upcoming Elections",
            Icons.upcoming,
            Colors.orange.shade700,
            Colors.orange.shade50,
            (elections, now) =>
                elections
                    .where((elec) => DateTime.parse(elec['start']).isAfter(now))
                    .toList(),
            (elec, timeLeft) => _buildUpcomingElectionCard(elec, timeLeft),
            "No upcoming elections scheduled",
          ),

          // Past Elections
          _buildElectionSection(
            "Past Elections",
            Icons.history,
            Colors.grey.shade700,
            Colors.grey.shade50,
            (elections, now) =>
                elections
                    .where((elec) => DateTime.parse(elec['end']).isBefore(now))
                    .toList(),
            (elec, timeLeft) => _buildPastElectionCard(elec),
            "No past elections found",
          ),

          // Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  "© 2025 UniVote. All rights reserved.",
                  style: GoogleFonts.outfit(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElectionSection(
    String title,
    IconData icon,
    Color color,
    Color bgColor,
    List<dynamic> Function(List<dynamic>, DateTime) filterFunction,
    Widget Function(dynamic, Duration?) cardBuilder,
    String emptyMessage,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 210, // Increased height for more spacious cards
              child: StreamBuilder(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder:
                          (context, index) => buildShimmerElectionCard(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade800,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Error loading elections",
                              style: GoogleFonts.outfit(
                                color: Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final elections = snapshot.data;
                  if (elections == null || elections.isEmpty) {
                    return _buildEmptyState(emptyMessage);
                  }

                  final now = DateTime.now();
                  final filteredElections = filterFunction(elections, now);

                  if (filteredElections.isEmpty) {
                    return _buildEmptyState(emptyMessage);
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredElections.length,
                    itemBuilder: (context, index) {
                      final elec = filteredElections[index];
                      Duration? timeLeft;

                      if (title == "Active Elections") {
                        timeLeft = DateTime.parse(elec['end']).difference(now);
                      } else if (title == "Upcoming Elections") {
                        timeLeft = DateTime.parse(
                          elec['start'],
                        ).difference(now);
                      }

                      return cardBuilder(elec, timeLeft);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.outfit(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveElectionCard(dynamic elec, Duration? timeLeft) {
    String formatDuration(Duration duration) {
      if (duration.inDays > 0) {
        return '${duration.inDays} days ${duration.inHours % 24} hours';
      } else if (duration.inHours > 0) {
        return '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
      } else {
        return '${duration.inMinutes} minutes';
      }
    }

    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue.shade50],
        ),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          elec['name'],
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Active',
                              style: GoogleFonts.outfit(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ends in: ${formatDuration(timeLeft!)}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Started: ${DateFormat('MMM dd, HH:mm').format(DateTime.parse(elec['start']))}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final profile = await getUserProfile();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AdminElectionDetails(
                                    elec: elec,
                                    profile: profile,
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: Text(
                          'View',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue.shade700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                        ),
                      ),
                      
                      // ElevatedButton.icon(
                      //   onPressed: () {
                      //     elec['publish']
                      //         ? PersistentNavBarNavigator.pushNewScreen(
                      //           context,
                      //           screen: ResultDetailsPage(
                      //             election: Election.fromMap(elec),
                      //           ),
                      //           withNavBar: false,
                      //         )
                      //         : ScaffoldMessenger.of(context).showSnackBar(
                      //           SnackBar(
                      //             content: Row(
                      //               children: [
                      //                 const Icon(
                      //                   Icons.error_outline,
                      //                   color: Colors.white,
                      //                 ),
                      //                 const SizedBox(width: 8),
                      //                 const Text("Results not published"),
                      //               ],
                      //             ),
                      //             backgroundColor: Colors.redAccent,
                      //             behavior: SnackBarBehavior.floating,
                      //             shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(10),
                      //             ),
                      //           ),
                      //         );
                      //     ;
                      //   },
                      //   icon: const Icon(Icons.poll, size: 16),
                      //   label: Text(
                      //     'Results',
                      //     style: GoogleFonts.outfit(
                      //       fontWeight: FontWeight.w600,
                      //       fontSize: 14,
                      //     ),
                      //   ),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.blue.shade900,
                      //     foregroundColor: Colors.white,
                      //     elevation: 2,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 12,
                      //       vertical: 0,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingElectionCard(dynamic elec, Duration? timeLeft) {
    String formatDuration(Duration duration) {
      if (duration.inDays > 0) {
        return '${duration.inDays} days ${duration.inHours % 24} hours';
      } else if (duration.inHours > 0) {
        return '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
      } else {
        return '${duration.inMinutes} minutes';
      }
    }

    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.orange.shade50],
        ),
        border: Border.all(color: Colors.orange.shade200, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          elec['name'],
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Upcoming',
                              style: GoogleFonts.outfit(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Starts in: ${formatDuration(timeLeft!)}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.event, size: 14, color: Colors.grey.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Duration: ${DateFormat('MMM dd, HH:mm').format(DateTime.parse(elec['start']))} - ${DateFormat('MMM dd, HH:mm').format(DateTime.parse(elec['end']))}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final profile = await getUserProfile();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AdminElectionDetails(
                                    elec: elec,
                                    profile: profile,
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: Text(
                          'View',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange.shade700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                        ),
                      ),
                      // OutlinedButton.icon(
                      //   onPressed: () {

                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(
                      //         content: Text(
                      //           'Deleting election: ${elec['name']}',
                      //         ),
                      //         behavior: SnackBarBehavior.floating,
                      //       ),
                      //     );
                      //   },

                      //   icon: const Icon(Icons.delete, size: 16),
                      //   label: Text(
                      //     'Delete',
                      //     style: GoogleFonts.outfit(
                      //       fontWeight: FontWeight.w600,
                      //       fontSize: 14,
                      //     ),
                      //   ),
                      //   style: OutlinedButton.styleFrom(
                      //     side: BorderSide(color: Colors.orange.shade700),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     foregroundColor: Colors.orange.shade700,
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 12,
                      //       vertical: 0,
                      //     ),
                      //   ),
                      // ),
                     OutlinedButton.icon(
  onPressed: () {
    print("Delete button pressed"); 
    // delete(elec); 
    final election = Election.fromMap(elec); // Convert the map
    delete(election); 
  },
  icon: const Icon(Icons.delete, size: 16),
  label: Text(
    'Delete',
    style: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
  ),
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: Colors.orange.shade700),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    foregroundColor: Colors.orange.shade700,
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 0,
    ),
  ),
)

                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastElectionCard(dynamic elec) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          elec['name'],
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ended',
                              style: GoogleFonts.outfit(
                                color: Colors.grey.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ended on: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(elec['end']))}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Duration: ${DateFormat('MMM dd').format(DateTime.parse(elec['start']))} - ${DateFormat('MMM dd').format(DateTime.parse(elec['end']))}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final profile = await getUserProfile();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AdminElectionDetails(
                                    elec: elec,
                                    profile: profile,
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: Text(
                          'View',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                        ),
                      ),
                      // ElevatedButton.icon(
                      //   onPressed: () {
                      //     // View results
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(
                      //         content: Text(
                      //           'Viewing results for ${elec['name']}',
                      //         ),
                      //         behavior: SnackBarBehavior.floating,
                      //       ),
                      //     );
                      //   },
                      //   icon: const Icon(Icons.bar_chart, size: 16),
                      //   label: Text(
                      //     'Results',
                      //     style: GoogleFonts.outfit(
                      //       fontWeight: FontWeight.w600,
                      //       fontSize: 14,
                      //     ),
                      //   ),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.green.shade800,
                      //     foregroundColor: Colors.white,
                      //     elevation: 2,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 12,
                      //       vertical: 0,
                      //     ),
                      //   ),
                      // ),
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
                          backgroundColor: Colors.grey.shade800,
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
          ],
        ),
      ),
    );
  }
}

Widget buildShimmerElectionCard() {
  return Container(
    width: 320,
    margin: const EdgeInsets.only(right: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade100,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 180,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 70,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: 160,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  width: 100,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
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
