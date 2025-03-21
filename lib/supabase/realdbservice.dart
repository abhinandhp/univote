import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/models/model.dart';

class RealDBService {
  late SupabaseClient client;

  RealDBService() {
    client = Supabase.instance.client;
  }

  Stream getAll() {
    return client.from('elections').stream(primaryKey: ["id"])
      ..map(
        (data) => data.map((elecMap) => Election.fromMap(elecMap)).toList(),
      ).handleError((error) {
        print("Stream Error: $error");
        client.realtime.getChannels().forEach((channel) async {
          await client.realtime.removeChannel(channel);
        });
        client.realtime.channel('elections').subscribe();
      });
  }
}
