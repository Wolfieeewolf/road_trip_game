import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

class MiniMap extends StatelessWidget {
  const MiniMap({
    super.key,
    required this.center,
    required this.markers,
    this.height = 220,
    this.zoom = 14,
  });

  final ll.LatLng center;
  final List<Marker> markers;
  final double height;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.roadtripgame',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }
}
