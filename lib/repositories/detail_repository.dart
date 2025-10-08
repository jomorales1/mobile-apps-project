import 'package:app_museos/model/detail_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailRepository {
  final String _tableName = 'Especie';
  final _supabase = Supabase.instance.client;


  Future<Detail?> fetchDetailId(String expoId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', expoId)
          .limit(1)
          .maybeSingle();
      if (response != null) {
        return Detail.fromJson(response);
      } else {
        print('No detail found with id: $expoId');
        return null;
      }
    } catch (e) {
      print('Error fetching detail by id: $e');
      return null;
    }
  }
}