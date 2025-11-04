import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/species_node.dart';

class TreeLoader {
  static Future<SpeciesNode> loadTree() async {
    final data = await rootBundle.loadString('assets/data/tree_of_life.json');
    final jsonResult = jsonDecode(data);
    return SpeciesNode.fromJson(jsonResult);
  }
}
