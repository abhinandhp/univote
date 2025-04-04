
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/models/model.dart';
import 'package:univote/pages/result_card.dart';


class ResultDetailsScreen extends StatefulWidget {
  //final String electionId;

  const ResultDetailsScreen({
    Key? key,
    //required this.electionId,
  }) : super(key: key);

  @override
  State<ResultDetailsScreen> createState() => _ResultDetailsScreenState();
}

class _ResultDetailsScreenState extends State<ResultDetailsScreen> {
  //late ElectionService _electionService;
  //late Future<Election?> _electionFuture;
  bool _isLoading = true;
  String? _error;

  // @override
  // void initState() {
  //   super.initState();
  //   final supabase = Supabase.instance.client;
  //   //_electionService = ElectionService(supabase);
  //   _loadElection();
  // }

  // void _loadElection() {
  //   _electionFuture = _electionService.fetchElectionById(widget.electionId);
  //   _electionFuture.then((_) {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }).catchError((e) {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //         _error = e.toString();
  //       });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Election Details'),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load election details',
              style: TextStyle(color: Colors.red[700], fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                //_loadElection();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder(
      future: Future.delayed(Durations.long1),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Election not found'));
        }

        final election = snapshot.data!;
        // Sort candidates by votes (highest first)
        final sortedCandidates = [...election.candidates]
          ..sort((a, b) => b.votes.compareTo(a.votes));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                election.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildElectionMeta(election),
              if (election.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  election.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Results for ${election.position}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...sortedCandidates.map((candidate) {
                        return CandidateResultCard(
                          candidate: candidate,
                          totalVotes: election.totalVotes,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildElectionMeta(Election election) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final startDate = dateFormat.format(election.start!);
    final endDate = dateFormat.format(election.end!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '$startDate - $endDate',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.people, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '{election.totalVotes} total votes',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}