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
  void submitVote() async {
    if (selectedCandidate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Center(
            child: Text(
              "Please select a candidate to vote for",
              style: GoogleFonts.outfit(fontSize: 15),
            ),
          ),
        ),
      );
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    try {
      await supabase.from('votes').insert({
        'voter_id': user!.id,
        'candidate_id': selectedCandidate!['name'] == 'NOTA' ? null :selectedCandidate!['id'],
        'election_id': widget.elec['id'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vote submitted successfully! ✅',
            style: GoogleFonts.outfit(fontSize: 15),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (e.toString().contains('duplicate key value')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You have already voted in this election! ❌',
              style: GoogleFonts.outfit(fontSize: 15),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.outfit(fontSize: 15),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // try {
    //   await Supabase.instance.client.from('votes').insert({
    //     'candidate_id': selectedCandidate!['id'],
    //     'candidate_name': selectedCandidate!['name'],
    //     'user_id': Supabase.instance.client.auth.currentUser?.id,
    //   });

    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("You voted for ${selectedCandidate!['name']}",
    //     style: GoogleFonts.outfit(fontSize: 15))),
    //   );

    //   setState(() {
    //     selectedCandidate = null;
    //   });
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Failed to submit vote. Error: $e",
    //     style: GoogleFonts.outfit(fontSize: 15))),
    //   );
    // }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Vote for Your Candidate',
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),

          itemCount: candidates.length,
          itemBuilder: (context, index) {
            final candidate = candidates[index];

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Card(
                elevation: selectedCandidate == candidate ? 5 : 0,
                shadowColor: const Color.fromARGB(255, 45, 219, 54),
                
                color:
                    selectedCandidate == candidate
                        ? const Color.fromARGB(255, 45, 219, 54)
                        : Colors.white,
                shape: RoundedRectangleBorder(
                  
                  borderRadius: BorderRadius.circular(15),
                ),
                child: RadioListTile<Map<String, dynamic>>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Text(
                    candidate['name'],
                    style: GoogleFonts.outfit(
                      fontSize: selectedCandidate == candidate ? 20 : 16,
                      fontWeight: FontWeight.w600,
                      color:
                          /*selectedCandidate == candidate
                              ? Colors.blue
                              :*/
                          Colors.black87,
                    ),
                  ),
                  value: candidate,
                  groupValue: selectedCandidate,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() {
                      selectedCandidate = value;
                    });
                  },
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
          },
        ),
      ),
      bottomNavigationBar: Stack(
        children: [
          // Gradient Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          // Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: submitVote,
              child: const Text(
                'SUBMIT VOTE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
