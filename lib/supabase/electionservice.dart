import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/models/model.dart';

class ElectionService {
  final SupabaseClient _supabaseClient;

  ElectionService(this._supabaseClient);

  /// Fetch all completed elections (i.e., elections that have ended)
  Future<List<Election>> fetchCompletedElections() async {
    try {
      final List<dynamic> electionsData = await _supabaseClient
          .from('elections')
          .select()
          .lte('end', DateTime.now().toIso8601String())
          .eq('publish', true);

      List<Election> completedElections =
          electionsData.map((electionData) {
            return Election(
              id: electionData['id'] ?? 0,
              name: electionData['name'] ?? 'Unknown Election',
              start:
                  DateTime.tryParse(electionData['start'] ?? '') ??
                  DateTime(2000, 1, 1),
              end:
                  DateTime.tryParse(electionData['end'] ?? '') ??
                  DateTime(2000, 1, 1),
              candidates:
                  (electionData['candidates'] as List<dynamic>?)
                      ?.cast<String>() ??
                  [],
              noOfCandidates: electionData['noOfCandidates'] ?? 0,
            );
          }).toList();

      return completedElections;
    } catch (e) {
      print('Error fetching completed elections: $e');
      return _getMockElections();
    }
  }

  /// Fetch all candidates for a given election ID
  Future<List<Candidate>> fetchCandidatesForElection(int electionId) async {
    try {
      final List<dynamic> candidatesData = await _supabaseClient
          .from('candidates')
          .select()
          .eq('electionId', electionId)
          .eq('approved', true);

      List<Candidate> candidates =
          candidatesData.map((candidateJson) {
            return Candidate.fromMap(candidateJson);
          }).toList();

      // Determine the winner
      Candidate? winner =
          candidates.isNotEmpty
              ? candidates.reduce((a, b) => a.votes > b.votes ? a : b)
              : null;

      // Update winner status
      candidates =
          candidates.map((candidate) {
            return Candidate(
              id: candidate.id,
              name: candidate.name,
              rollno: candidate.rollno,
              electionId: candidate.electionId,
              uid: candidate.uid,
              votes: candidate.votes,
              approved: candidate.approved,
              isWinner: candidate.id == winner?.id,
            );
          }).toList();

      return candidates;
    } catch (e) {
      print('Error fetching candidates for election ID $electionId: $e');
      return [];
    }
  }

  List<Election> _getMockElections() {
    return [
      Election(
        id: 1,
        name: 'Student Council President',
        start: DateTime(2024, 3, 1),
        end: DateTime(2024, 3, 15),
        candidates: ['Alex Johnson', 'Sam Rodriguez'],
        noOfCandidates: 2,
      ),
    ];
  }
}
