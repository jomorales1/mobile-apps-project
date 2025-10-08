class Detail {
  final int id;
  final String nombre;
  final String nombreCientifico;
  final String imagen;
  final String subtitulo;
  final String texto1;
  final String imagenDistribucion;
  final String audio;
  final String datoCurioso;
  final String cicloVida;
  final DateTime? fechaCreacion;

  Detail({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.imagen,
    required this.subtitulo,
    required this.texto1,
    required this.imagenDistribucion,
    required this.audio,
    required this.datoCurioso,
    required this.cicloVida,
    this.fechaCreacion,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      nombreCientifico: json['nombre_cientifico'] ?? '',
      imagen: json['imagen'] ?? '',
      subtitulo: json['subtitulo'] ?? '',
      texto1: json['texto1'] ?? '',
      imagenDistribucion: json['imagen_distribucion'] ?? '',
      audio: json['audio'] ?? '',
      datoCurioso: json['dato_curioso'] ?? '',
      cicloVida: json['ciclo_vida'] ?? '',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nombre_cientifico': nombreCientifico,
      'imagen': imagen,
      'subtitulo': subtitulo,
      'texto1': texto1,
      'imagen_distribucion': imagenDistribucion,
      'audio': audio,
      'dato_curioso': datoCurioso,
      'ciclo_vida': cicloVida,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
    };
  }
}
