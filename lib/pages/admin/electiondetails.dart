import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/supabase/candidbase.dart';

final supabase = Supabase.instance.client;

class AdminElectionDetails extends StatefulWidget {
  final Map<String, dynamic> elec;
  const AdminElectionDetails({super.key, required this.elec});
  @override
  State<AdminElectionDetails> createState() => _AdminElectionDetailsState();
}

class _AdminElectionDetailsState extends State<AdminElectionDetails> {
  final candibase = CandidBase();

  final client = Supabase.instance.client;

  void approve(int id) {
    candibase.updateStatus(id, {"approved": true});
  }

  final _stream = supabase.from('candidates').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> elec = widget.elec;

    DateTime now = DateTime.now();

    // Calculate the difference
    Duration remaining = DateTime.parse(elec["end"]).difference(now);

    // Extract days, hours, minutes
    int days = remaining.inDays;
    int hours = remaining.inHours % 24;
    int minutes = remaining.inMinutes % 60;

    String timeres;
    if (remaining.isNegative || remaining.inSeconds == 0) {
      timeres = "Voting Ended";
    } else {
      timeres = 'Voting ends in $days days $hours hours $minutes minutes';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Election Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      elec['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'B22 Computer Science',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 4),
                    Text(timeres, style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Election Timeline',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('• Registration: Feb 20 - Feb 25, 2025'),
                      Text('• Voting: Feb 26 - Mar 2, 2025'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Candidates',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  try {
                    await client.from('candidates').insert({
                      'name': "newunni",
                      'rollno': "B220097EC",
                      'electionId': 1,
                    });
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text("add"),
              ),
              SizedBox(
                height: 800,
                child: StreamBuilder(
                  stream:
                      _stream, //Supabase.instance.client.from('candidates').select(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData) {
                      return Center(child: Text("Nothing to display"));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    final cands = snapshot.data as List<dynamic>;
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: cands.length,
                      itemBuilder: (context, index) {
                        final candidate = cands[index];
                        bool stat = candidate['approved'];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              child: Text(
                                candidate['name']![0].toString().toUpperCase(),
                              ),
                            ),
                            title: Text(candidate['name']!),
                            subtitle: Text(candidate['rollno']),
                            trailing:
                                stat
                                    ? Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                      size: 30,
                                    )
                                    : TextButton(
                                      onPressed: () {
                                        approve(candidate['id']);
                                      },
                                      child: Text(
                                        'Approve',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'CAST YOUR VOTE',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
