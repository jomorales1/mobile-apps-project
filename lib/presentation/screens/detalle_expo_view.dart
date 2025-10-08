import 'package:app_museos/model/detail_model.dart';
import 'package:app_museos/model/exposicion_model.dart';
import 'package:app_museos/repositories/detail_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

class DetalleExpoView extends StatefulWidget {
  final MapPoint exposicion_model;

  const DetalleExpoView({Key? key, required this.exposicion_model}) : super(key: key);

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
  
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    cargarDetalle();
    cargarImagen();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => position = p);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  Future<void> cargarImagen() async {
    try {
      // Cargar imagen principal
      final url = Supabase.instance.client.storage
          .from('MuseoAPP')
          .getPublicUrl(widget.exposicion_model.image);
      
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
    if (detail?.imagenDistribucion == null || detail!.imagenDistribucion.isEmpty) return;
    
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
      final result = await DetailRepository().fetchDetailId(widget.exposicion_model.id);
      setState(() {
        detail = result;
        isLoading = false;
      });

      if (result != null) {
        print('✅ Detalle cargado: $result');
        // Cargar recursos adicionales
        cargarImagenDistribucion();
        cargarAudio();
      } else {
        print('⚠️ No se encontró el detalle');
      }
    } catch (e) {
      print('❌ Error al cargar detalle: $e');
      setState(() => isLoading = false);
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
                    // App Bar con imagen - manteniendo el diseño original
                    SliverAppBar(
                      expandedHeight: 400,
                      pinned: true,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          detail?.nombre ?? widget.exposicion_model.label,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                            // Nombre y nombre científico
                            Text(
                              detail?.nombre ?? '',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (detail?.nombreCientifico != null) ...[
                              const SizedBox(height: 8),
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

                            // Reproductor de audio
                            if (audioUrl != null) ...[
                              _buildMinimalCard(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: _toggleAudio,
                                          icon: Icon(
                                            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                            size: 48,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  trackHeight: 2,
                                                  thumbShape: const RoundSliderThumbShape(
                                                    enabledThumbRadius: 6,
                                                  ),
                                                ),
                                                child: Slider(
                                                  value: position.inSeconds.toDouble(),
                                                  max: duration.inSeconds.toDouble(),
                                                  activeColor: Colors.black87,
                                                  inactiveColor: Colors.grey[300],
                                                  onChanged: (value) async {
                                                    final position = Duration(seconds: value.toInt());
                                                    await _audioPlayer.seek(position);
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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


                            // Subtítulo
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


                            // Descripción principal (texto1)
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

                            // Imagen de distribución
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

                            // Ciclo de vida
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

                            // Dato curioso
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
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.museum_outlined,
          size: 80,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildMinimalCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
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
}