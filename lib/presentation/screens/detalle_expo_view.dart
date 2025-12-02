import 'package:app_museos/presentation/screens/ar_view.dart';
import 'package:app_museos/presentation/screens/model_3d_view_screen.dart';
import 'package:app_museos/model/detail_model.dart';
import 'package:app_museos/model/trivia_model.dart';
import 'package:app_museos/model/exposicion_model.dart';
import 'package:app_museos/repositories/detail_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class DetalleExpoView extends StatefulWidget {
  final MapPoint exposicion_model;

  const DetalleExpoView({super.key, required this.exposicion_model});

  @override
  State<DetalleExpoView> createState() => _DetalleExpoViewState();
}

class _DetalleExpoViewState extends State<DetalleExpoView> {
  Detail? detail;
  bool isLoading = true;
  String? imageUrl;
  String? imageDistribucionUrl;
  String? audioUrl;
  bool imageExists = false;
  TriviaQuestion? triviaQuestion;
  List<TriviaOption> triviaOptions = [];
  bool triviaLoading = true;
  int? selectedOptionId;
  bool triviaAnswered = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  void initState() {
    super.initState();
    cargarDetalle();
    cargarImagen();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    try {
      _durSub?.cancel();
      _posSub?.cancel();
      _stateSub?.cancel();
      _audioPlayer.stop();
      _audioPlayer.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _setupAudioPlayer() {
    _durSub = _audioPlayer.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => duration = d);
    });

    _posSub = _audioPlayer.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => position = p);
    });

    _stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  Future<void> cargarImagen() async {
    try {
      final url = Supabase.instance.client.storage
          .from('MuseoAPP')
          .getPublicUrl(widget.exposicion_model.image.trim());

      setState(() {
        imageUrl = url;
        imageExists = true;
      });
    } catch (e) {
      print('⚠️ Error al cargar imagen: $e');
      setState(() {
        imageExists = false;
      });
    }
  }

  Future<void> cargarImagenDistribucion() async {
    if (detail?.imagenDistribucion == null ||
        detail!.imagenDistribucion.isEmpty) {
      return;
    }

    try {
      final url = Supabase.instance.client.storage
          .from('MuseoAPP')
          .getPublicUrl(detail!.imagenDistribucion);

      setState(() {
        imageDistribucionUrl = url;
      });
    } catch (e) {
      print('⚠️ Error al cargar imagen de distribución: $e');
    }
  }

  Future<void> cargarAudio() async {
    if (detail?.audio == null || detail!.audio.isEmpty) return;

    try {
      final url = Supabase.instance.client.storage
          .from('AudioMuseoAPP')
          .getPublicUrl(detail!.audio);

      setState(() {
        audioUrl = url;
      });
    } catch (e) {
      print('⚠️ Error al cargar audio: $e');
    }
  }

  Future<void> cargarDetalle() async {
    try {
      final result = await DetailRepository().fetchDetailId(
        widget.exposicion_model.id,
      );
      setState(() {
        detail = result;
        isLoading = false;
      });

      if (result != null) {
        print('✅ Detalle cargado: $result');
        cargarImagenDistribucion();
        cargarAudio();
        cargarTrivia();
      } else {
        print('⚠️ No se encontró el detalle');
      }
    } catch (e) {
      print('❌ Error al cargar detalle: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> cargarTrivia() async {
    if (detail == null) return;
    try {
      final supabase = Supabase.instance.client;
      final preguntasRes = await supabase
          .from('preguntas_trivia')
          .select()
          .eq('especie_id', detail!.id)
          .limit(1);
      if (preguntasRes.isEmpty) {
        setState(() => triviaLoading = false);
        return;
      }
      final pregunta = TriviaQuestion.fromJson(preguntasRes.first);
      final opcionesRes = await supabase
          .from('opciones_trivia')
          .select()
          .eq('pregunta_id', pregunta.id);
      final opts = opcionesRes.map((e) => TriviaOption.fromJson(e)).toList();
      setState(() {
        triviaQuestion = pregunta;
        triviaOptions = opts;
        triviaLoading = false;
      });
    } catch (e) {
      print('❌ Error cargando trivia: $e');
      setState(() => triviaLoading = false);
    }
  }

  Future<void> _toggleAudio() async {
    if (audioUrl == null) return;

    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(audioUrl!));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : detail == null
          ? const Center(child: Text('No se encontró información del detalle.'))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 400,
                  pinned: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: imageExists && imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackBackground();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildFallbackBackground();
                            },
                          )
                        : _buildFallbackBackground(),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail?.nombre ?? '',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: -0.1,
                          ),
                        ),
                        if (detail?.nombreCientifico != null) ...[
                          Text(
                            detail!.nombreCientifico,
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        if (audioUrl != null) ...[
                          _buildMinimalCard(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: _toggleAudio,
                                      icon: Icon(
                                        isPlaying
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_filled,
                                        size: 48,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                                  trackHeight: 2,
                                                  thumbShape:
                                                      const RoundSliderThumbShape(
                                                        enabledThumbRadius: 6,
                                                      ),
                                                ),
                                            child: Slider(
                                              value: position.inSeconds
                                                  .toDouble(),
                                              max: duration.inSeconds
                                                  .toDouble(),
                                              activeColor: Colors.black87,
                                              inactiveColor: Colors.grey[300],
                                              onChanged: (value) async {
                                                final position = Duration(
                                                  seconds: value.toInt(),
                                                );
                                                await _audioPlayer.seek(
                                                  position,
                                                );
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  _formatDuration(position),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                Text(
                                                  _formatDuration(duration),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (detail?.subtitulo != null) ...[
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                detail!.subtitulo,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (detail?.texto1 != null) ...[
                          _buildMinimalCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Descripción'),
                                const SizedBox(height: 8),
                                Text(
                                  detail!.texto1,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (imageDistribucionUrl != null) ...[
                          const Text(
                            'Distribución Geográfica',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              imageDistribucionUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.map_outlined,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (detail?.cicloVida != null) ...[
                          const Text(
                            'Ciclo de Vida',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildMinimalCard(
                            child: Text(
                              detail!.cicloVida,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (detail?.datoCurioso != null) ...[
                          const Text(
                            'Dato Curioso',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildMinimalCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.lightbulb_outline,
                                    size: 24,
                                    color: Colors.amber[700],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    detail!.datoCurioso,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Trivia section (before 3D model)
                        if (!triviaLoading && triviaQuestion != null) ...[
                          const Text(
                            'Trivia',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTriviaCard(),
                          const SizedBox(height: 24),
                        ] else if (triviaLoading) ...[
                          const SizedBox(
                            height: 120,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (detail?.modelo != null) ...[
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black87,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Model3DViewScreen(modelPath: detail!.modelo),
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.threed_rotation, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Ver Modelo 3D',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black87,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ARViewScreen(modelPath: detail!.modelo),
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.view_in_ar, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Ver en Realidad Aumentada',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[50]!, Colors.grey[100]!],
        ),
      ),
      child: Center(
        child: Icon(Icons.museum_outlined, size: 80, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildMinimalCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey[500],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTriviaCard() {
    if (triviaQuestion == null) {
      return _buildMinimalCard(
        child: const Text(
          'No hay trivia disponible para esta especie.',
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
      );
    }
    return _buildMinimalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            triviaQuestion!.pregunta,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...triviaOptions.map((opt) => _buildTriviaOption(opt)),
          if (triviaAnswered) ...[
            const SizedBox(height: 12),
            Text(
              _feedbackText(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _answeredCorrectly()
                    ? Colors.green[700]
                    : Colors.red[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTriviaOption(TriviaOption opt) {
    final isSelected = selectedOptionId == opt.id;
    final correct = opt.esCorrecta;
    Color baseColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    Icon? leadingIcon;
    if (triviaAnswered) {
      if (correct && isSelected) {
        baseColor = Colors.green.shade300;
        borderColor = Colors.green.shade600;
        leadingIcon = const Icon(Icons.check_circle, color: Colors.white);
      } else if (correct && !isSelected) {
        baseColor = Colors.green.shade100;
        borderColor = Colors.green.shade400;
        leadingIcon = const Icon(Icons.check, color: Colors.green);
      } else if (!correct && isSelected) {
        baseColor = Colors.red.shade300;
        borderColor = Colors.red.shade600;
        leadingIcon = const Icon(Icons.cancel, color: Colors.white);
      }
    } else if (isSelected) {
      baseColor = Colors.blue.shade50;
      borderColor = Colors.blue.shade300;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: triviaAnswered
            ? null
            : () {
                setState(() {
                  selectedOptionId = opt.id;
                  triviaAnswered = true;
                });
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                leadingIcon,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  opt.opcion,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: triviaAnswered && correct && isSelected
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _answeredCorrectly() {
    final selected = triviaOptions.firstWhere(
      (o) => o.id == selectedOptionId,
      orElse: () =>
          TriviaOption(id: -1, preguntaId: -1, opcion: '', esCorrecta: false),
    );
    return selected.esCorrecta;
  }

  String _feedbackText() => _answeredCorrectly()
      ? '¡Correcto!'
      : 'Incorrecto. La respuesta correcta está marcada en verde.';
}
