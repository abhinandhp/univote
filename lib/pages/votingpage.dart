import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  Map<String, dynamic>? selectedCandidate;
  final _stream = Supabase.instance.client.from('candidates').stream(primaryKey: ['id']);

  void submitVote() async {
    if (selectedCandidate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a candidate to vote for.")),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('votes').insert({
        'candidate_id': selectedCandidate!['id'],
        'candidate_name': selectedCandidate!['name'],
        'user_id': Supabase.instance.client.auth.currentUser?.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You voted for ${selectedCandidate!['name']}")),
      );

      setState(() {
        selectedCandidate = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit vote. Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Vote for Your Candidate', 
          style: TextStyle(
            color: Colors.black87, 
            fontWeight: FontWeight.bold
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
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                    return const Center(child: Text("No candidates available"));
                  }

                  final candidates = (snapshot.data as List<dynamic>)
                      .where((cand) => cand['approved'] == true)
                      .toList();

                  return ListView.builder(
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
                            )
                          ],
                        ),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: RadioListTile<Map<String, dynamic>>(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Text(
                              candidate['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selectedCandidate == candidate 
                                  ? Colors.blue 
                                  : Colors.black87,
                              ),
                            ),
                            value: candidate,
                            groupValue: selectedCandidate,
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              setState(() {
                                selectedCandidate = value;
                              });
                            },
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Stack(
        children: [
          // Gradient Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
              onPressed: selectedCandidate != null ? submitVote : null,
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
