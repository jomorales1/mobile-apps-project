class SpeciesNode {
  final String name;
  final String? id;
  final List<SpeciesNode> children;

  SpeciesNode({required this.name, this.id, this.children = const []});

  factory SpeciesNode.fromJson(Map<String, dynamic> json) {
    var childrenJson = json['children'] as List<dynamic>?;
    var children = childrenJson != null
        ? childrenJson.map((child) => SpeciesNode.fromJson(child)).toList()
        : <SpeciesNode>[];
    return SpeciesNode(name: json['name'], id: json['id'], children: children);
  }
}
