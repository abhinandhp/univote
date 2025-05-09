import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/models/model.dart';
import 'package:univote/supabase/electionbase.dart';
import 'package:univote/supabase/electionservice.dart';

class AdminResultDetailsPage extends StatefulWidget {
  final Election election;

  const AdminResultDetailsPage({super.key, required this.election});

  @override
  State<AdminResultDetailsPage> createState() => _AdminResultDetailsPageState();
}

class _AdminResultDetailsPageState extends State<AdminResultDetailsPage> {
  final electionbase=ElectionBase();
  final ElectionService _electionService = ElectionService(
    Supabase.instance.client,
  );
  late Future<List<Map<String, dynamic>>> _resultsFuture;

  void _showColoredSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              backgroundColor == Colors.green
                  ? Icons.check_circle
                  : backgroundColor == Colors.red
                  ? Icons.error
                  : Icons.info,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
        elevation: 6,
      ),
    );
  }

  // Define a list of distinct colors for candidates
  final List<Map<String, dynamic>> candidateColorSchemes = [
    {
      'primary': const Color(0xFF5C6BC0), // Indigo
      'light': const Color(0xFFE8EAF6),
      'gradient': const [Color(0xFF5C6BC0), Color(0xFF3949AB)],
    },
    {
      'primary': const Color(0xFF26A69A), // Teal
      'light': const Color(0xFFE0F2F1),
      'gradient': const [Color(0xFF26A69A), Color(0xFF00897B)],
    },
    {
      'primary': const Color(0xFFEF5350), // Red
      'light': const Color(0xFFFFEBEE),
      'gradient': const [Color(0xFFEF5350), Color(0xFFE53935)],
    },
    {
      'primary': const Color(0xFF66BB6A), // Green
      'light': const Color(0xFFE8F5E9),
      'gradient': const [Color(0xFF66BB6A), Color(0xFF4CAF50)],
    },
    {
      'primary': const Color(0xFFFFB300), // Amber
      'light': const Color(0xFFFFF8E1),
      'gradient': const [Color(0xFFFFB300), Color(0xFFFFA000)],
    },
    {
      'primary': const Color(0xFF8D6E63), // Brown
      'light': const Color(0xFFEFEBE9),
      'gradient': const [Color(0xFF8D6E63), Color(0xFF795548)],
    },
    {
      'primary': const Color(0xFF7E57C2), // Deep Purple
      'light': const Color(0xFFEDE7F6),
      'gradient': const [Color(0xFF7E57C2), Color(0xFF673AB7)],
    },
    {
      'primary': const Color(0xFF42A5F5), // Blue
      'light': const Color(0xFFE3F2FD),
      'gradient': const [Color(0xFF42A5F5), Color(0xFF2196F3)],
    },
    {
      'primary': const Color(0xFFEC407A), // Pink
      'light': const Color(0xFFFCE4EC),
      'gradient': const [Color(0xFFEC407A), Color(0xFFE91E63)],
    },
    {
      'primary': const Color(0xFFFF7043), // Deep Orange
      'light': const Color(0xFFFBE9E7),
      'gradient': const [Color(0xFFFF7043), Color(0xFFFF5722)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _resultsFuture = _electionService.fetchResults(widget.election.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        title: Text(
          'Election Results',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3949AB)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFE53935),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFE53935),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final candidates = snapshot.data!;
          final totalVotes = candidates.fold<int>(
            0,
            (sum, c) => sum + ((c['voteCount'] ?? 0) as int),
          );

          if (candidates.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/empty_state.png',
                    height: 120,
                    // Replace with your actual image asset or remove if not available
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.ballot_outlined,
                          size: 80,
                          color: Color(0xFFBDBDBD),
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No candidates or votes found.',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            );
          }

          final firstVoteCount = candidates.first['voteCount'];
          final isDraw = candidates.every(
            (c) => c['voteCount'] == firstVoteCount,
          );

          // Sort candidates by vote count (highest first)
          candidates.sort(
            (a, b) => (b['voteCount'] ?? 0).compareTo(a['voteCount'] ?? 0),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Election header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.how_to_vote, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.election.name,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Total Votes: $totalVotes',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Start: ${widget.election.start ?? ''}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.event_available,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'End: ${widget.election.end ?? ''}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Candidates',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3949AB),
                ),
              ),
              const SizedBox(height: 16),

              // Candidate cards
              ...candidates.asMap().entries.map((entry) {
                final index = entry.key;
                final candidate = entry.value;
                final voteCount = candidate['voteCount'] ?? 0;
                final votePercentage =
                    totalVotes > 0 ? (voteCount / totalVotes * 100).round() : 0;
                final isWinner = !isDraw && index == 0;

                // Get color scheme based on index, with wraparound for more candidates than colors
                final colorScheme =
                    candidateColorSchemes[index % candidateColorSchemes.length];

                // For the winner, we can use a special gold color scheme if desired
                final Map<String, dynamic> tileColorScheme =
                    isWinner
                        ? {
                          'primary': const Color(0xFFFFB300),
                          'light': const Color(0xFFFFF8E1),
                          'gradient': const [
                            Color(0xFFFFB300),
                            Color(0xFFFFA000),
                          ],
                        }
                        : colorScheme;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side:
                        isWinner
                            ? const BorderSide(
                              color: Color(0xFFFFC107),
                              width: 2,
                            )
                            : BorderSide.none,
                  ),
                  elevation: 3,
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border:
                          isWinner
                              ? Border.all(
                                color: const Color(0xFFFFC107),
                                width: 2,
                              )
                              : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Avatar with initials
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: tileColorScheme['gradient'],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (tileColorScheme['primary']
                                              as Color)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    (candidate['name'] ?? 'N')[0].toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Name and winner badge
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      candidate['name'] ?? 'Unnamed',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (isWinner)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFFB300),
                                              Color(0xFFFFC107),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFFFFC107,
                                              ).withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.emoji_events,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Winner',
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Vote count and %
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: tileColorScheme['light'] as Color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$voteCount',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color:
                                            tileColorScheme['primary'] as Color,
                                      ),
                                    ),
                                    Text(
                                      '$votePercentage% of votes',
                                      style: GoogleFonts.outfit(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Vote progress bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Vote Count',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '$voteCount / $totalVotes',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 10,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor:
                                      totalVotes > 0
                                          ? voteCount / totalVotes
                                          : 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      gradient: LinearGradient(
                                        colors: tileColorScheme['gradient'],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (tileColorScheme['primary']
                                                  as Color)
                                              .withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
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
              }),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pie_chart, color: Color(0xFF3949AB)),
                        const SizedBox(width: 8),
                        Text(
                          'Votes Distribution',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3949AB),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    buildPieChart(candidates),
                  ],

                  
                ),
                
              ),
              const SizedBox(height: 32),
              Center(
  child: ElevatedButton(
    onPressed: ()async {
     final res=await electionbase.publishElection(widget.election,candidates[0]['name']);
      if (res==1){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text("Result published succesfully"),
              ],
            ),
            backgroundColor: Colors.greenAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text("Failed to publish"),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
    ),
    child: Text(
      'Publish',
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
const SizedBox(height: 120),
            ],
          );
        },
      ),
    );
  }
}
