import 'package:app_museos/model/exposicion_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExposicionRepository {
  final String _tableName = 'MapPoint';
  final _supabase = Supabase.instance.client;

  Future<List<MapPoint>> fetchExposiciones() async {
    try {
      final response = await Supabase.instance.client
          .from('MapPoint')
          .select();
      final loadedPoints = (response as List)
          .map((data) => MapPoint.fromJson(data))
          .toList();
      return loadedPoints;
    } catch (e) {
      return [];
    }
  }

  Future<List<MapPoint>> fetchExposicionesByLabelLike(String label) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .like('label', '%$label%');
      return response.map<MapPoint>((data) => MapPoint.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }
}
