import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/models/model.dart';

class CandidBase {
  final database = Supabase.instance.client.from('candidates');

  Future createCandid(Candidate cand) async {
    try {
      await database.insert(cand.toMap());
    } catch (e) {
      print(e);
    }
  }

  final stream = Supabase.instance.client
      .from('candidates')
      .stream(primaryKey: ['id'])
      .map((data) => data.map((elecMap) => Candidate.fromMap(elecMap)).toList());

  Future updateCand(
    Candidate oldCand,
    Map<String, dynamic> updatedFields,
  ) async {
    await database.update(updatedFields).eq('id', oldCand.id!);
  }

  Future updateStatus(
    int id,
    Map<String, dynamic> updatedFields,
  ) async {
    await database.update(updatedFields).eq('id', id);
  }

  Future deleteCand(Candidate cand) async {
    await database.delete().eq('id', cand.id!);
  }
}
