class Election {
  int? id;
  String name;
  DateTime? start;
  DateTime? end;
  int noOfCandidates;
  List<String>? candidates;

  Election({
    this.id,
    required this.name,
    this.candidates,
    required this.start,
    required this.end,
    this.noOfCandidates=0,
  });

  factory Election.fromMap(Map<String, dynamic> map) {
    return Election(
      id: map['id'] as int?,
      name: map['name'],
      candidates: map['candidates'],
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
      noOfCandidates: map['noOfCandidates'],
    );
  }

  Map<String,dynamic> toMap(){
    return {
      'name':name,
      'candidates':candidates,
      'start':start!.toIso8601String(),
      'end':end!.toIso8601String(),
      'noOfCandidates':noOfCandidates
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
    this.approved=false,
    this.votes=0,
    required this.uid,
    this.isWinner=false
  });

  // Convert Candidate object to Map (for Supabase)
  Map<String, dynamic> toMap() {
    return {
      'election_id': electionId,
      'name': name,
      'rollno': rollno
    };
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
      uid:map['uid']
    );
  }
}


