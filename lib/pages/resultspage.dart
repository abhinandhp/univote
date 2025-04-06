import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:univote/pages/resultdetails.dart';
import 'package:univote/models/model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/supabase/electionservice.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late Future<List<Election>> _electionFuture;
  final ElectionService _electionService = ElectionService(
    Supabase.instance.client,
  );
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _refreshElections();
  }

  void _refreshElections() {
    setState(() {
      _electionFuture = _electionService.fetchCompletedElections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Text(
          ' Results',
          style: GoogleFonts.ultra(
            color: const Color.fromARGB(255, 35, 19, 108),
            fontSize: 30,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.refresh_bold,
              color: Color.fromARGB(255, 24, 13, 91),
              size: 20,
            ),
            onPressed: _refreshElections,
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: TextField(
              controller: _searchController,

              decoration: InputDecoration(
                labelText: "Search Elections",
                labelStyle: GoogleFonts.outfit(),

                prefixIcon: const Icon(
                  LineIcons.searchengin,
                  size: 34,
                  color: Color.fromARGB(255, 243, 170, 33),
                ),
                hoverColor: const Color.fromARGB(255, 24, 13, 91),
                focusColor: const Color.fromARGB(255, 24, 13, 91),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
            ),
          ),

          // FutureBuilder for fetching elections
          Expanded(
            child: FutureBuilder<List<Election>>(
              future: _electionFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.outfit(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _refreshElections,
                          child: Text('Retry', style: GoogleFonts.outfit()),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No completed elections found.',
                      style: GoogleFonts.outfit(),
                    ),
                  );
                }

                // Filter elections based on search query
                List<Election> filteredElections =
                    snapshot.data!
                        .where(
                          (election) => election.name.toLowerCase().contains(
                            _searchQuery,
                          ),
                        )
                        .toList();

                if (filteredElections.isEmpty) {
                  return Center(
                    child: Text(
                      'No results match your search.',
                      style: GoogleFonts.outfit(),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredElections.length,
                  itemBuilder: (context, index) {
                    final election = filteredElections[index];
                    return GestureDetector(
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ResultDetailsPage(election: election),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      child: ElectionCard(election: election),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 85),
        ],
      ),
    );
  }
}

class ElectionCard extends StatelessWidget {
  final Election election;

  const ElectionCard({Key? key, required this.election}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final endDate = dateFormat.format(election.end!);
    final winnerVotePercentage = 68;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF303F9F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 8,
                //     vertical: 4,
                //   ),
                //   decoration: BoxDecoration(
                //     color: Colors.white.withOpacity(0.2),
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Text(
                //     "position",
                //     style: const TextStyle(color: Colors.white, fontSize: 12),
                //   ),
                // ),
                const SizedBox(height: 8),
                Text(
                  election.name,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ended: $endDate',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 2),
                    color: Colors.grey[300],
                  ),
                  child: Center(
                    child: Text(
                      '?',
                      style: GoogleFonts.outfit(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        election.winner,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Winner',
                            style: GoogleFonts.outfit(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'votes ?? 0',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '$winnerVotePercentage% of votes',
                                style: GoogleFonts.outfit(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
