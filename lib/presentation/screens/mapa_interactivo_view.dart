import 'dart:math' as math;

import 'package:app_museos/model/exposicion_model.dart';
import 'package:app_museos/presentation/screens/detalle_expo_view.dart';
import 'package:app_museos/presentation/screens/lista_expo_view.dart';
import 'package:app_museos/repositories/exposicion_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class MapaInteractivoView extends StatelessWidget {
  const MapaInteractivoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Museum3DMap(),
      bottomSheet: Container(
        height: 90,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              spreadRadius: 0,
              color: Colors.black.withOpacity(0.15),
              offset: Offset(0, -4),
            ),
          ],
        ),
          child: SafeArea(
            child: Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.museum_outlined, size: 20),
                label: Text(
                  "Ver Exposiciones",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B5E20).withOpacity(0.08), // Verde oscuro suave
                  foregroundColor: Color(0xFF1B5E20), // Verde oscuro
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Color(0xFF1B5E20).withOpacity(0.25), // Borde verde oscuro
                      width: 1,
                    ),
                  ),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    transitionAnimationController: AnimationController(
                      vsync: Navigator.of(context),
                      duration: Duration(milliseconds: 1000),
                    )..forward(),
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: const ListaExpoView(),
                    ),
                  );
                },
              ),
            ),
          ),
      ),
    );
  }
}

class Museum3DMap extends StatefulWidget {
  const Museum3DMap({super.key});

  @override
  _Museum3DMapState createState() => _Museum3DMapState();
}

class _Museum3DMapState extends State<Museum3DMap> {
  double rotationX = 0.2;
  double rotationY = -0.2;
  double scale = 1.0;
  Offset translation = Offset.zero;

  bool rotateMode = false;

  final double svgWidth = 210;
  final double svgHeight = 297;

  List<MapPoint> points = [];
  bool isLoading = true;
  String? errorMessage;


  final ValueNotifier<double> scaleNotifier = ValueNotifier(1.0);
  double _initialScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadPointsFromFirebase();
  }

  Future<void> _loadPointsFromFirebase() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedPoints = await ExposicionRepository().fetchExposiciones();

      setState(() {
        points = loadedPoints;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar los puntos: $e';
        isLoading = false;
      });
      print('Error loading points from Firebase: $e');
    }
  }


   Future<String?> cargarImagen(image) async {
    try {
      // Obtener la URL pública de la imagen
      final url = Supabase.instance.client.storage
          .from('MuseoAPP')
          .getPublicUrl(image);
      return url;
    } catch (e) {
      print('⚠️ Error al cargar imagen: $e');
      return null;
    }
  }

  @override
  void dispose() {
    scaleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando mapa...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red[700]),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPointsFromFirebase,
              icon: Icon(Icons.refresh),
              label: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        GestureDetector(
          onScaleStart: (details) {
            _initialScale = scale;
          },
          onScaleUpdate: (details) {
            setState(() {
              if (details.pointerCount == 2) {
                scale = (_initialScale * details.scale).clamp(1.0, 5.0);
                scaleNotifier.value = scale;
              } else if (details.pointerCount == 1) {
                if (rotateMode) {
                  rotationY += details.focalPointDelta.dx * 0.01;
                  rotationX -= details.focalPointDelta.dy * 0.01;
                  rotationY = rotationY.clamp(-math.pi / 4, math.pi / 4);
                  rotationX = rotationX.clamp(-math.pi / 4, math.pi / 4);
                } else {
                  translation += details.focalPointDelta;
                }
              }
            });
          },
          child: Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(translation.dx, translation.dy)
                ..setEntry(3, 2, 0.001)
                ..rotateX(rotationX)
                ..rotateY(rotationY)
                ..scale(scale),
              child: AspectRatio(
                aspectRatio: svgWidth / svgHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double containerWidth = constraints.maxWidth;
                    final double containerHeight = constraints.maxHeight;

                    final double scaleX = containerWidth / svgWidth;
                    final double scaleY = containerHeight / svgHeight;

                    return Stack(
                      children: [
                        SvgPicture.asset(
                          "assets/mapa3.svg",
                          width: containerWidth,
                          height: containerHeight,
                          fit: BoxFit.fill,
                        ),
                        ...points.map((p) {
                          final double left = p.x * scaleX;
                          final double top = p.y * scaleY;

                          return ValueListenableBuilder<double>(
                            valueListenable: scaleNotifier,
                            builder: (context, currentScale, child) {
                              double baseRadius = 15.0;
                              double pointRadius =
                                  (baseRadius / currentScale).clamp(5.0, 25.0);
                              
                              double fontSize = (12.0 / currentScale).clamp(8.0, 14.0);

                              return Positioned(
                                left: left - 40,
                                top: top - pointRadius,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => DetalleExpoView(
                                          exposicion_model: p,
                                        ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: 80,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        AnimatedContainer(
                                          duration: Duration(milliseconds: 100),
                                          curve: Curves.easeOut,
                                          width: pointRadius * 2,
                                          height: pointRadius * 2,
                                          child: FutureBuilder<String?>(
                                            future: cargarImagen(p.image),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                // Mientras carga, muestra un placeholder
                                                return CircleAvatar(
                                                  radius: pointRadius,
                                                  backgroundColor: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.image,
                                                    color: Colors.grey[400],
                                                    size: pointRadius,
                                                  ),
                                                );
                                              }
                                              
                                              if (snapshot.hasData && snapshot.data != null) {
                                                // Si hay imagen, la muestra
                                                return CircleAvatar(
                                                  radius: pointRadius,
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: NetworkImage(snapshot.data!),
                                                  onBackgroundImageError: (exception, stackTrace) {
                                                    print('Error cargando imagen: $exception');
                                                  },
                                                );
                                              } else {
                                                // Si no hay imagen o hubo error, muestra un ícono por defecto
                                                return CircleAvatar(
                                                  radius: pointRadius,
                                                  backgroundColor: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.museum,
                                                    color: Colors.grey[600],
                                                    size: pointRadius,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.95),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.15),
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            p.label,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                              letterSpacing: 0.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          top: 50,
          child: GestureDetector(
            onTap: () {
              setState(() {
                rotateMode = !rotateMode;
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                rotateMode ? Icons.sync : Icons.open_with,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  
}