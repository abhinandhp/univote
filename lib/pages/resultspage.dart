import 'package:flutter/material.dart';

// Model for Election
class Election {
  final String title;
  final String winner;
  final int winnerVotes;
  final List<CandidateResult> candidates;

  Election({
    required this.title,
    required this.winner,
    required this.winnerVotes,
    required this.candidates,
  });
}

// Model for Candidate Results
class CandidateResult {
  final String name;
  final int votes;
  final String party;

  CandidateResult({
    required this.name,
    required this.votes,
    required this.party,
  });
}

// Election Results List Page
class Resultspage extends StatelessWidget {
  // Sample elections data
  final List<Election> completedElections = [
    Election(
      title: 'President Election',
      winner: 'Emily Johnson',
      winnerVotes: 1245,
      candidates: [
        CandidateResult(name: 'Emily Johnson', votes: 1245, party: 'Forward Party'),
        CandidateResult(name: 'Michael Rodriguez', votes: 1134, party: 'Campus Progress'),
      ],
    ),
    Election(
      title: 'Vice President Election',
      winner: 'Sarah Kim',
      winnerVotes: 1378,
      candidates: [
        CandidateResult(name: 'Sarah Kim', votes: 1378, party: 'Student Voice'),
        CandidateResult(name: 'David Chen', votes: 1001, party: 'Campus Unity'),
      ],
    ),
    Election(
      title: 'Secretary Election',
      winner: 'Alex Martinez',
      winnerVotes: 1156,
      candidates: [
        CandidateResult(name: 'Alex Martinez', votes: 1156, party: 'Student Progress'),
        CandidateResult(name: 'Emma Thompson', votes: 1045, party: 'Campus Innovators'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Elections'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: completedElections.length,
        itemBuilder: (context, index) {
          final election = completedElections[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                election.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('Winner: ${election.winner}'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ElectionDetailPage(election: election),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Election Detail Page
class ElectionDetailPage extends StatelessWidget {
  final Election election;

  const ElectionDetailPage({Key? key, required this.election}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(election.title),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Winner Block
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Winner',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    election.winner,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${election.winnerVotes} Votes',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),

            // Candidate Results List
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Candidate Results',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 16),
                  ...election.candidates.map((candidate) => _buildCandidateResultTile(candidate)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateResultTile(CandidateResult candidate) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          candidate.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(candidate.party),
        trailing: Text(
          '${candidate.votes} Votes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: candidate.name == election.winner ? Colors.green : Colors.black,
          ),
        ),
      ),
    );
  }
}

