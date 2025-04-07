// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_animate/flutter_animate.dart';

// class VotingPage extends StatefulWidget {
//   final List<Map<String, dynamic>> nominees;
//   final Map<String, dynamic> elec;
//   const VotingPage({super.key, required this.nominees, required this.elec});

//   @override
//   State<VotingPage> createState() => _VotingPageState();
// }

// class _VotingPageState extends State<VotingPage> {
//   Map<String, dynamic>? selectedCandidate;
//   late List<Map<String, dynamic>> candidates;
//   void submitVote() async {
//     if (selectedCandidate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.red,
//           content: Center(
//             child: Text(
//               "Please select a candidate to vote for",
//               style: GoogleFonts.outfit(fontSize: 15),
//             ),
//           ),
//         ),
//       );
//       return;
//     }

//     final supabase = Supabase.instance.client;
//     final user = supabase.auth.currentUser;

//     try {
//       await supabase.from('votes').insert({
//         'voter_id': user!.id,
//         'candidate_id': selectedCandidate!['name'] == 'NOTA' ? null :selectedCandidate!['id'],
//         'election_id': widget.elec['id'],
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Vote submitted successfully! ✅',
//             style: GoogleFonts.outfit(fontSize: 15),
//           ),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       if (e.toString().contains('duplicate key value')) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'You have already voted in this election! ❌',
//               style: GoogleFonts.outfit(fontSize: 15),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Error: ${e.toString()}',
//               style: GoogleFonts.outfit(fontSize: 15),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }

//     // try {
//     //   await Supabase.instance.client.from('votes').insert({
//     //     'candidate_id': selectedCandidate!['id'],
//     //     'candidate_name': selectedCandidate!['name'],
//     //     'user_id': Supabase.instance.client.auth.currentUser?.id,
//     //   });

//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     SnackBar(content: Text("You voted for ${selectedCandidate!['name']}",
//     //     style: GoogleFonts.outfit(fontSize: 15))),
//     //   );

//     //   setState(() {
//     //     selectedCandidate = null;
//     //   });
//     // } catch (e) {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     SnackBar(content: Text("Failed to submit vote. Error: $e",
//     //     style: GoogleFonts.outfit(fontSize: 15))),
//     //   );
//     // }
//   }

//   @override
//   void initState() {
//     candidates = widget.nominees;
//     candidates.add({
//       'id': -1,
//       'created_at': '2025-03-26T18:28:06.153021+00:00',
//       'name': 'NOTA',
//       'rollno': "#########",
//       'electionId': -1,
//       'approved': true,
//       'uid': "######",
//     });

//     candidates.sort((a, b) => a['id'].compareTo(b['id']));
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         title: Text(
//           'Vote for Your Candidate',
//           style: GoogleFonts.outfit(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Colors.blue.shade50, Colors.purple.shade50],
//           ),
//         ),
//         child: ListView.builder(
//           padding: const EdgeInsets.all(16),

//           itemCount: candidates.length,
//           itemBuilder: (context, index) {
//             final candidate = candidates[index];

//             return Container(
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               decoration: const BoxDecoration(
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Card(
//                 elevation: selectedCandidate == candidate ? 5 : 0,
//                 shadowColor: const Color.fromARGB(255, 45, 219, 54),

//                 color:
//                     selectedCandidate == candidate
//                         ? const Color.fromARGB(255, 45, 219, 54)
//                         : Colors.white,
//                 shape: RoundedRectangleBorder(

//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: RadioListTile<Map<String, dynamic>>(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   title: Text(
//                     candidate['name'],
//                     style: GoogleFonts.outfit(
//                       fontSize: selectedCandidate == candidate ? 20 : 16,
//                       fontWeight: FontWeight.w600,
//                       color:
//                           /*selectedCandidate == candidate
//                               ? Colors.blue
//                               :*/
//                           Colors.black87,
//                     ),
//                   ),
//                   value: candidate,
//                   groupValue: selectedCandidate,
//                   activeColor: Colors.black,
//                   onChanged: (value) {
//                     setState(() {
//                       selectedCandidate = value;
//                     });
//                   },
//                 ),
//               ),
//             ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
//           },
//         ),
//       ),
//       bottomNavigationBar: Stack(
//         children: [
//           // Gradient Background
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color(0xFF0F2027),
//                     Color(0xFF203A43),
//                     Color(0xFF2C5364),
//                   ],

//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(20),
//                 ),
//               ),
//             ),
//           ),
//           // Button
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white.withOpacity(0.2),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 minimumSize: Size(double.infinity, 50),
//               ),
//               onPressed: submitVote,
//               child: const Text(
//                 'SUBMIT VOTE',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VotingPage extends StatefulWidget {
  final List<Map<String, dynamic>> nominees;
  final Map<String, dynamic> elec;
  const VotingPage({super.key, required this.nominees, required this.elec});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  Map<String, dynamic>? selectedCandidate;
  late List<Map<String, dynamic>> candidates;
  bool isSubmitting = false;

  // Color palette
  final Color primaryColor = const Color(0xFF6C63FF);
  final Color secondaryColor = const Color(0xFF00C2CB);
  final Color accentColor = const Color(0xFFFF6584);
  final Color backgroundColor = const Color(0xFFF9F9FE);
  final Color darkColor = const Color(0xFF2A2A45);
  final Color lightColor = const Color(0xFFFFFFFF);

  void submitVote() async {
    if (selectedCandidate == null) {
      _showSnackBar(
        message: "Please select a candidate to vote for",
        isError: true,
      );
      return;
    }

    setState(() => isSubmitting = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    try {
      await supabase.from('votes').insert({
        'voter_id': user!.id,
        'candidate_id':
            selectedCandidate!['name'] == 'NOTA'
                ? null
                : selectedCandidate!['id'],
        'election_id': widget.elec['id'],
      });

      _showSnackBar(message: 'Vote submitted successfully! ✅', isSuccess: true);
    } catch (e) {
      if (e.toString().contains('duplicate key value')) {
        _showSnackBar(
          message: 'You have already voted in this election! ❌',
          isError: true,
        );
      } else {
        _showSnackBar(message: 'Error: ${e.toString()}', isError: true);
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showSnackBar({
    required String message,
    bool isError = false,
    bool isSuccess = false,
  }) {
    Color backgroundColor;
    IconData icon;

    if (isError) {
      backgroundColor = accentColor;
      icon = Icons.error_outline;
    } else if (isSuccess) {
      backgroundColor = secondaryColor;
      icon = Icons.check_circle_outline;
    } else {
      backgroundColor = primaryColor;
      icon = Icons.info_outline;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    candidates = widget.nominees;
    candidates.add({
      'id': -1,
      'created_at': '2025-03-26T18:28:06.153021+00:00',
      'name': 'NOTA',
      'rollno': "#########",
      'electionId': -1,
      'approved': true,
      'uid': "######",
    });

    candidates.sort((a, b) => a['id'].compareTo(b['id']));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Your Vote Matters',
          style: GoogleFonts.poppins(
            color: darkColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: darkColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              const Color(0xFFEFEFF9),
              const Color(0xFFE8E8F3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Election title and instructions
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.elec['title'] ?? 'Election',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: darkColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your preferred candidate and submit your vote. Your choice is confidential.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: darkColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              // Candidates list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    final candidate = candidates[index];
                    final isSelected = selectedCandidate == candidate;
                    final isNota = candidate['name'] == 'NOTA';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color:
                                isSelected
                                    ? primaryColor.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: isSelected ? 0 : -2,
                          ),
                        ],
                      ),
                      child: Material(
                        color: isSelected ? primaryColor : lightColor,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          splashColor: primaryColor.withOpacity(0.1),
                          highlightColor: primaryColor.withOpacity(0.05),
                          onTap: () {
                            setState(() {
                              selectedCandidate = candidate;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                // Avatar or indicator
                                Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? lightColor
                                            : isNota
                                            ? accentColor.withOpacity(0.1)
                                            : primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child:
                                        isNota
                                            ? Icon(
                                              Icons.not_interested,
                                              color:
                                                  isSelected
                                                      ? primaryColor
                                                      : accentColor,
                                              size: 24,
                                            )
                                            : Text(
                                              candidate['name']
                                                  .toString()
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    isSelected
                                                        ? primaryColor
                                                        : secondaryColor,
                                              ),
                                            ),
                                  ),
                                ),

                                // Candidate details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        candidate['name'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isSelected
                                                  ? lightColor
                                                  : darkColor,
                                        ),
                                      ),
                                      if (!isNota)
                                        Text(
                                          "Roll No: ${candidate['rollno']}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color:
                                                isSelected
                                                    ? lightColor.withOpacity(
                                                      0.8,
                                                    )
                                                    : darkColor.withOpacity(
                                                      0.6,
                                                    ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Selection indicator
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        isSelected
                                            ? lightColor
                                            : Colors.transparent,
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? lightColor
                                              : darkColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child:
                                      isSelected
                                          ? Icon(
                                            Icons.check,
                                            size: 16,
                                            color: primaryColor,
                                          )
                                          : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate(
                      effects: [
                        FadeEffect(
                          duration: 400.ms,
                          delay: Duration(milliseconds: 80 * index),
                        ),
                        SlideEffect(
                          begin: const Offset(0.05, 0),
                          end: const Offset(0, 0),
                          duration: 400.ms,
                          delay: Duration(milliseconds: 80 * index),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [darkColor, const Color(0xFF373756)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: darkColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selected candidate indicator
                if (selectedCandidate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: lightColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.how_to_vote,
                          size: 18,
                          color: secondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Selected: ${selectedCandidate!['name']}",
                          style: GoogleFonts.poppins(
                            color: lightColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 16),

                // Submit button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedCandidate != null
                            ? secondaryColor
                            : lightColor.withOpacity(0.2),
                    foregroundColor: lightColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                    elevation: selectedCandidate != null ? 4 : 0,
                    shadowColor:
                        selectedCandidate != null
                            ? secondaryColor.withOpacity(0.5)
                            : Colors.transparent,
                  ),
                  onPressed: isSubmitting ? null : submitVote,
                  child:
                      isSubmitting
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 20,
                                color: lightColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CONFIRM VOTE',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
