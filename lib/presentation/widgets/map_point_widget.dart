import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_museos/model/exposicion_model.dart';
import 'package:app_museos/presentation/screens/detalle_expo_view.dart';

class MapPointWidget extends StatefulWidget {
  final MapPoint point;
  final ValueNotifier<double> scaleNotifier;

  const MapPointWidget({super.key, required this.point, required this.scaleNotifier});

  @override
  _MapPointWidgetState createState() => _MapPointWidgetState();
}

class _MapPointWidgetState extends State<MapPointWidget> {
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _getImageUrl();
  }

  void _getImageUrl() {
    final url = Supabase.instance.client.storage
        .from('MuseoAPP')
        .getPublicUrl(widget.point.image.trim());
    if(mounted){
      setState(() {
        _imageUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.scaleNotifier,
      builder: (context, scale, child) {
        double baseRadius = 15.0;
        double pointRadius = (baseRadius / scale).clamp(5.0, 25.0);

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetalleExpoView(
                  exposicion_model: widget.point,
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
                if (_imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: _imageUrl!,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: pointRadius,
                      backgroundColor: Colors.white,
                      backgroundImage: imageProvider,
                    ),
                    placeholder: (context, url) => CircleAvatar(
                      radius: pointRadius,
                      backgroundColor: Colors.grey[200],
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[400],
                        size: pointRadius,
                      ),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: pointRadius,
                      backgroundColor: Colors.grey[200],
                      child: Icon(
                        Icons.museum,
                        color: Colors.grey[600],
                        size: pointRadius,
                      ),
                    ),
                  )
                else
                  CircleAvatar(
                    radius: pointRadius,
                    backgroundColor: Colors.grey[200],
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[400],
                      size: pointRadius,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
