import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/models/model.dart';

class ElectionService {
  final SupabaseClient _supabaseClient;

  ElectionService(this._supabaseClient);


  Future<List<Election>> adminfetchCompletedElections() async {
    try {
      final List<dynamic> electionsData = await _supabaseClient
          .from('elections')
          .select()
          .lte('end', DateTime.now().toIso8601String());

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
              winner: electionData['winner'] ?? 'Not Declared',
            );
          }).toList();

      return completedElections;
    } catch (e) {
      print('Error fetching completed elections: $e');
      return _getMockElections();
    }
  }

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
              winner: electionData['winner'] ?? 'Not Declared',
            );
          }).toList();

      return completedElections;
    } catch (e) {
      print('Error fetching completed elections: $e');
      return _getMockElections();
    }
  }

  Future<List<Map<String, dynamic>>> fetchResults(int id) async {
    final candidatesResponse = await _supabaseClient
        .from('candidates')
        .select()
        .eq('electionId', id)
        .eq('approved', true);

    final List<Map<String, dynamic>> candidates =
        List<Map<String, dynamic>>.from(candidatesResponse);

    // Fetch and count NOTA votes
    final notaVotesResponse = await _supabaseClient
        .from('votes')
        .select('id')
        .filter('candidate_id', 'is', null)
        .eq('election_id', id);

    final int notaVoteCount = notaVotesResponse.length;

    // Count votes for each candidate
    for (var candidate in candidates) {
      final voteResponse = await _supabaseClient
          .from('votes')
          .select('id')
          .eq('candidate_id', candidate['id']);

      candidate['voteCount'] = voteResponse.length;
    }

    // Add NOTA as a special candidate entry
    candidates.add({
      'id': null,
      'name': 'NOTA',
      'voteCount': notaVoteCount,
      'rollno': '-',
    });

    // Sort by vote count descending
    candidates.sort(
      (a, b) => (b['voteCount'] as int).compareTo(a['voteCount'] as int),
    );

    return candidates;
  }

  Future<List<Map<String, dynamic>>> fetchAllResults(int id) async { //for admin
    final candidatesResponse = await _supabaseClient
        .from('candidates')
        .select()
        .eq('electionId', id);
//.eq('approved', true);

    final List<Map<String, dynamic>> candidates =
        List<Map<String, dynamic>>.from(candidatesResponse);

    // Fetch and count NOTA votes
    final notaVotesResponse = await _supabaseClient
        .from('votes')
        .select('id')
        .filter('candidate_id', 'is', null)
        .eq('election_id', id);

    final int notaVoteCount = notaVotesResponse.length;

    // Count votes for each candidate
    for (var candidate in candidates) {
      final voteResponse = await _supabaseClient
          .from('votes')
          .select('id')
          .eq('candidate_id', candidate['id']);

      candidate['voteCount'] = voteResponse.length;
    }

    // Add NOTA as a special candidate entry
    candidates.add({
      'id': null,
      'name': 'NOTA',
      'voteCount': notaVoteCount,
      'rollno': '-',
    });

    // Sort by vote count descending
    candidates.sort(
      (a, b) => (b['voteCount'] as int).compareTo(a['voteCount'] as int),
    );

    return candidates;
  }

  List<Election> _getMockElections() {
    return [
      Election(
        id: 1,
        name: 'Student Council President',
        start: DateTime(2024, 3, 1),
        end: DateTime(2024, 3, 15),
      ),
    ];
  }
}
