import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/models/model.dart';

class ElectionBase {
  final database = Supabase.instance.client.from('elections');

  Future createElection(Election elec) async {
    try {
      await database.insert(elec.toMap());
    } catch (e) {
      print(e);
    }
  }

  final stream = Supabase.instance.client
      .from('elections')
      .stream(primaryKey: ['id'])
      .map((data) => data.map((elecMap) => Election.fromMap(elecMap)).toList());

  Future updateElection(
    Election oldElec,
    Map<String, dynamic> updatedFields,
  ) async {
    await database.update(updatedFields).eq('id', oldElec.id!);
  }

  Future deleteElection(Election elec) async {
    await database.delete().eq('id', elec.id!);
  }
}
