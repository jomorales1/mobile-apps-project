class MapPoint {
  final String id;
  final double x;
  final double y;
  final String image;
  final String label;
  final String description;

  MapPoint({
    required this.id,
    required this.x,
    required this.y,
    required this.image,
    required this.label,
    required this.description,
  });

  factory MapPoint.fromJson(Map<String, dynamic> data) {
    return MapPoint(
      id: data['id']?.toString() ?? '',
      x: (data['x'] ?? 0).toDouble(),
      y: (data['y'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      label: data['label'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'image': image,
      'label': label,
      'description': description,
    };
  }
}