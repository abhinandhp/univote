import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Election {
  int? id;
  String name;
  DateTime? start;
  DateTime? end;
  String winner;

  Election({
    this.id,
    required this.name,
    required this.start,
    required this.end,
    this.winner = 'Not Declared',
  });

  factory Election.fromMap(Map<String, dynamic> map) {
    return Election(
      id: map['id'] as int?,
      name: map['name'],
      winner: map['winner'],
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'start': start!.toIso8601String(),
      'end': end!.toIso8601String(),
    };
  }
}

class Candidate {
  final int? id;
  final int electionId;
  final String name;
  String rollno;
  int votes;
  bool isWinner;
  bool approved;
  String uid;

  Candidate({
    this.id,
    required this.electionId,
    required this.name,
    required this.rollno,
    this.approved = false,
    this.votes = 0,
    required this.uid,
    this.isWinner = false,
  });

  // Convert Candidate object to Map (for Supabase)
  Map<String, dynamic> toMap() {
    return {'election_id': electionId, 'name': name, 'rollno': rollno};
  }

  // Convert Map from Supabase to Candidate object
  factory Candidate.fromMap(Map<String, dynamic> map) {
    return Candidate(
      id: map['id'],
      electionId: map['election_id'],
      name: map['name'],
      rollno: map['rollno'],
      votes: map['votes'],
      isWinner: map['isWinner'],
      uid: map['uid'],
    );
  }
}

Widget buildPieChart(List<Map<String, dynamic>> candidates) {
  final totalVotes = candidates.fold<int>(
    0,
    (sum, c) => sum + ((c['voteCount'] ?? 0) as int),
  );

  if (totalVotes == 0) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'No votes have been cast yet.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  return SizedBox(
    height: 300,
    child: PieChart(
      PieChartData(
        sections:
            candidates.map((candidate) {
              final name = candidate['name'] ?? 'NOTA';
              final votes = (candidate['voteCount'] as int).toDouble();
              final color =
                  name == 'NOTA'
                      ? Colors.grey
                      : Colors.primaries[candidates.indexOf(candidate) %
                          Colors.primaries.length];

              return PieChartSectionData(
                value: votes,
                title: '$name\n${votes.toInt()}',
                radius: 60,
                color: color,
                titleStyle: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              );
            }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    ),
  );
}
