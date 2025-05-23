import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/pages/votingpage.dart';
import 'package:univote/supabase/candidbase.dart';
import 'package:flutter/services.dart';

final supabase = Supabase.instance.client;

class AppTheme {
  static const Color primaryColor = Color(0xFF1A237E); // Deep indigo
  static const Color accentColor = Color(0xFF4CAF50); // Green
  static const Color backgroundColor = Color(0xFFF5F7FA); // Light gray
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2C3E50); // Dark blue-gray
  static const Color textSecondary = Color(0xFF7F8C8D); // Medium gray

  static BoxShadow defaultShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: Offset(0, 4),
  );

  static BorderRadius defaultRadius = BorderRadius.circular(16);

  static TextStyle headingStyle = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle bodyStyle = GoogleFonts.outfit(
    fontSize: 16,
    color: textPrimary,
  );

  static TextStyle captionStyle = GoogleFonts.outfit(
    fontSize: 14,
    color: textSecondary,
  );
}

// Reusable custom button widget
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final IconData? icon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.color = AppTheme.accentColor,
    this.textColor = Colors.white,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor),
              SizedBox(width: 10),
            ],
            Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom card for displaying candidates
class CandidateCard extends StatefulWidget {
  final Map<String, dynamic> candidate;

  const CandidateCard({Key? key, required this.candidate}) : super(key: key);

  @override
  State<CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends State<CandidateCard> {

  final candibase = CandidBase();
  void approve(int id) {
    candibase.updateStatus(id, {"approved": true});
  }
  
  @override
  Widget build(BuildContext context) {

    bool stat = widget.candidate['approved'];
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: AppTheme.defaultRadius,
        boxShadow: [AppTheme.defaultShadow],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Hero(
          tag: 'candidate-${widget.candidate['id']}',
          child: CircleAvatar(
            radius: 24,
            backgroundColor:
                Colors.primaries[widget.candidate['name'].hashCode %
                    Colors.primaries.length],
            child: Text(
              widget.candidate['name'][0].toString().toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          widget.candidate['name'],
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            widget.candidate['rollno'],
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        //  trailing: GestureDetector(
        //   onTap:  (){
        //     approve(widget.candidate['id']);
        //   },
        //   child: Icon(Icons.check_circle_outline, color: AppTheme.primaryColor)),
        trailing:
            stat
                ? Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 30,
                )
  : TextButton(
    onPressed: () {
      approve(widget.candidate['id']);
      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (context) => AlertDialog(
          content: Text('Candidate Confirmed'),
        ),
      );

      // Auto close the dialog after 1.5 seconds
      Future.delayed(Duration(seconds: 1, milliseconds: 500), () {
        Navigator.of(context, rootNavigator: true).pop();
      });
    },
    child: Text('Approve', style: TextStyle(color: Colors.blue)),
  ),
      ),
    );
  }
}

// Election info card
class ElectionInfoCard extends StatelessWidget {
  final Map<String, dynamic> elec;
  final String timeRemaining;

  const ElectionInfoCard({
    Key? key,
    required this.elec,
    required this.timeRemaining,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF303F9F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1A237E).withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.how_to_vote_rounded, color: Colors.white, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  elec['name'],
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            'B22 Computer Science',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  timeRemaining == "Voting Ended"
                      ? Icons.timer_off
                      : Icons.timer,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  timeRemaining,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminElectionDetails extends StatefulWidget {
  final Map<String, dynamic> elec;
  final Map<String, dynamic> profile;
  const AdminElectionDetails({
    super.key,
    required this.elec,
    required this.profile,
  });
  @override
  State<AdminElectionDetails> createState() => _AdminElectionDetailsState();
}

class _AdminElectionDetailsState extends State<AdminElectionDetails>
    with SingleTickerProviderStateMixin {
  final candibase = CandidBase();
  final client = Supabase.instance.client;
  late Stream<List<Map<String, dynamic>>> _stream;
  late AnimationController _animationController;
  late Animation<double> _animation;

  void approve(int id) {
    candibase.updateStatus(id, {"approved": true});
  }

  @override
  void initState() {
    super.initState();
    _stream = client
        .from('candidates')
        .stream(primaryKey: ['id'])
        .eq('electionId', widget.elec['id']);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Confirm Nomination",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          content: Text(
            "Are you sure you want to submit your nomination for this election?",
            style: GoogleFonts.outfit(color: AppTheme.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.outfit(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
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
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Nomination submitted for approval!",
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } on PostgrestException catch (e) {
                  if (e.code == '23505') {
                    // 23505 = Unique constraint violation in PostgreSQL
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "You have already applied for this election.",
                                style: GoogleFonts.outfit(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.orange.shade800,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: Text(
                          "Database Error: ${e.message}",
                          style: GoogleFonts.outfit(color: Colors.white),
                        ),
                        backgroundColor: Colors.red.shade800,
                      ),
                    );
                  }
                } catch (e) {
                  print(e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Error: ${e.toString()}",
                        style: GoogleFonts.outfit(color: Colors.white),
                      ),
                      backgroundColor: Colors.red.shade800,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
                Navigator.of(
                  context,
                ).pop(); // Close the dialog after submission
              },
              child: Text(
                "Confirm",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
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
      timeres = 'Voting ends in $days d $hours h $minutes m';
    }

    bool isNominationPhase = DateTime.parse(
      elec['start'],
    ).isAfter(DateTime.now());
    bool isVotingPhase =
        DateTime.parse(elec['start']).isBefore(DateTime.now()) &&
        DateTime.parse(elec['end']).isAfter(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Election Details',
          style: GoogleFonts.outfit(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: FadeTransition(
        opacity: _animation,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Election Info Card
                    ElectionInfoCard(elec: elec, timeRemaining: timeres),

                    SizedBox(height: 24),

                    // Section Header
                    Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Candidates',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Candidates List
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: StreamBuilder(
                        stream: _stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade400,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Error: ${snapshot.error}",
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              (snapshot.data as List).isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    color: Colors.grey.shade400,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "No candidates yet",
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Filter only approved candidates
                          final approvedCands =
                              (snapshot.data as List<dynamic>);

                          nominees = approvedCands.cast<Map<String, dynamic>>();

                          if (approvedCands.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.hourglass_empty,
                                    color: Colors.amber.shade400,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "No approved candidates yet",
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 100),
                            itemCount: approvedCands.length,
                            itemBuilder: (context, index) {
                              final candidate = approvedCands[index];
                              return CandidateCard(candidate: candidate);
                            },
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 80), // Space for bottom button
                  ],
                  
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
