class TriviaQuestion {
  final int id;
  final int especieId;
  final String pregunta;
  TriviaQuestion({
    required this.id,
    required this.especieId,
    required this.pregunta,
  });
  factory TriviaQuestion.fromJson(Map<String, dynamic> json) => TriviaQuestion(
    id: json['id'] ?? 0,
    especieId: json['especie_id'] ?? 0,
    pregunta: json['pregunta'] ?? '',
  );
}

class TriviaOption {
  final int id;
  final int preguntaId;
  final String opcion;
  final bool esCorrecta;
  TriviaOption({
    required this.id,
    required this.preguntaId,
    required this.opcion,
    required this.esCorrecta,
  });
  factory TriviaOption.fromJson(Map<String, dynamic> json) => TriviaOption(
    id: json['id'] ?? 0,
    preguntaId: json['pregunta_id'] ?? 0,
    opcion: json['opcion'] ?? '',
    esCorrecta: (json['es_correcta'] ?? false) == true,
  );
}
