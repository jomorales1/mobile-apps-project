import 'dart:math' as math;

import 'package:app_museos/presentation/screens/detalle_expo_view.dart';
import 'package:app_museos/presentation/screens/lista_expo_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MapaInteractivoView extends StatelessWidget {
  const MapaInteractivoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Museum3DMap(),

      bottomSheet: Container(
        height: 80,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black26,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Center(
          child: ElevatedButton.icon(
            icon: Icon(Icons.museum),
            label: Text("Lista de Exposiciones"),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // 👈 permite ocupar más pantalla
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const ListaExpoView(),
              );
            },
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

  bool rotateMode = false; // alterna entre mover o rotar

  final double svgWidth = 210;
  final double svgHeight = 297;

  final List<_MapPoint> points = [
    _MapPoint(id: "raton", x: 60, y: 120, image: "assets/raton.png"),
    _MapPoint(id: "pato", x: 140, y: 100, image: "assets/pato.png"),
    _MapPoint(id: "serpiente", x: 80, y: 90, image: "assets/serpiente.png"),
  ];

  final ValueNotifier<double> scaleNotifier = ValueNotifier(1.0);

  double _initialScale = 1.0;

  @override
  void dispose() {
    scaleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onScaleStart: (details) {
            _initialScale = scale;
          },
          onScaleUpdate: (details) {
            setState(() {
              if (details.pointerCount == 2) {
                // pinch zoom
                scale = (_initialScale * details.scale).clamp(1.0, 5.0);
                scaleNotifier.value = scale;
              } else if (details.pointerCount == 1) {
                if (rotateMode) {
                  // rotación con un dedo
                  rotationY += details.focalPointDelta.dx * 0.01;
                  rotationX -= details.focalPointDelta.dy * 0.01;
                  rotationY = rotationY.clamp(-math.pi / 4, math.pi / 4);
                  rotationX = rotationX.clamp(-math.pi / 4, math.pi / 4);
                } else {
                  // mover con un dedo
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

                              return Positioned(
                                left: left - pointRadius,
                                top: top - pointRadius,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => DetalleExpoView(nombreExposicion: p.id),
                                      ),
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 100),
                                    curve: Curves.easeOut,
                                    width: pointRadius * 2,
                                    height: pointRadius * 2,
                                    child: CircleAvatar(
                                      radius: pointRadius,
                                      backgroundColor: Colors.white,
                                      backgroundImage: AssetImage(p.image),
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

        // Botón flotante para activar modo rotar (ahora en la parte superior)
        Positioned(
          right: 20,
          top: 40,
          child: FloatingActionButton(
            child: Icon(rotateMode ? Icons.sync : Icons.open_with),
            onPressed: () {
              setState(() {
                rotateMode = !rotateMode;
              });
            },
          ),
        ),
      ],
    );
  }
}

class _MapPoint {
  final String id;
  final double x;
  final double y;
  final String image;

  _MapPoint(
      {required this.id, required this.x, required this.y, required this.image});
}



