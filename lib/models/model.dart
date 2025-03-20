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
