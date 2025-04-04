
import 'package:flutter/material.dart';
import 'package:univote/models/model.dart';


class CandidateResultCard extends StatelessWidget {
  final Candidate candidate;
  final int totalVotes;

  const CandidateResultCard({
    Key? key,
    required this.candidate,
    required this.totalVotes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final votePercentage = totalVotes > 0
        ? (60 / totalVotes * 100).round()
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: true//candidate.isWinner
            ? const BorderSide(color: Colors.amber, width: 2)
            : BorderSide.none,
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Winner',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '{candidate.votes}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '$votePercentage% of votes',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ResultProgressBar(
              value: 23,//candidate.votes,
              max: totalVotes,
              isWinner: true//candidate.isWinner,
            ),
          ],
        ),
      ),
    );
  }

}

class ResultProgressBar extends StatelessWidget {
  final int value;
  final int max;
  final bool isWinner;

  const ResultProgressBar({
    Key? key,
    required this.value,
    required this.max,
    required this.isWinner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = max > 0 ? value / max : 0;
    
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: 57,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: isWinner
                ? const LinearGradient(
                    colors: [Colors.amber, Color(0xFFFFD54F)],
                  )
                : const LinearGradient(
                    colors: [Colors.blue, Color(0xFF64B5F6)],
                  ),
          ),
        ),
      ),
    );
  }
}
