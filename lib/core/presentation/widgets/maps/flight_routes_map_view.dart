import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:simplelog/core/maps/map_tile_caching.dart';

/// One route segment between two coordinates.
class FlightRoutePair {
  /// Creates a route pair from [from] to [to].
  const FlightRoutePair({
    required this.from,
    required this.to,
  });

  /// Start point.
  final LatLng from;

  /// End point.
  final LatLng to;
}

/// Shared flight-routes map view with great-circle rendering.
class FlightRoutesMapView extends StatefulWidget {
  /// Creates a map from route [pairs].
  const FlightRoutesMapView({
    required this.pairs,
    required this.airportCountLabel,
    super.key,
    this.showLines = true,
  });

  /// Route pairs to render.
  final List<FlightRoutePair> pairs;

  /// Top-left label (for example: "Airports: 2").
  final String airportCountLabel;

  /// Whether route lines are shown.
  final bool showLines;

  @override
  State<FlightRoutesMapView> createState() => _FlightRoutesMapViewState();
}

class _FlightRoutesMapViewState extends State<FlightRoutesMapView> {
  final _mapController = MapController();
  static const Color _lineColor = Color(0x994A90E2);
  static const Color _dotColor = Color(0xFF1565C0);
  late double _zoom = _initialZoom();
  static const LatLng _fallbackCenter = LatLng(20, 0);

  double _initialZoom() {
    if (widget.pairs.isEmpty) return 2;
    var minLat = double.infinity;
    var maxLat = -double.infinity;
    var minLon = double.infinity;
    var maxLon = -double.infinity;
    for (final pair in widget.pairs) {
      for (final point in [pair.from, pair.to]) {
        minLat = math.min(minLat, point.latitude);
        maxLat = math.max(maxLat, point.latitude);
        minLon = math.min(minLon, point.longitude);
        maxLon = math.max(maxLon, point.longitude);
      }
    }
    final latSpan = maxLat - minLat;
    final lonSpan = maxLon - minLon;
    final maxSpan = math.max(latSpan, lonSpan);
    if (maxSpan > 110) return 2;
    if (maxSpan > 55) return 3;
    if (maxSpan > 25) return 4;
    if (maxSpan > 12) return 5;
    if (maxSpan > 6) return 6;
    return 7;
  }

  LatLng _initialCenter() {
    if (widget.pairs.isEmpty) return _fallbackCenter;
    var latTotal = 0.0;
    var lonTotal = 0.0;
    var count = 0;
    for (final pair in widget.pairs) {
      latTotal += pair.from.latitude + pair.to.latitude;
      lonTotal += pair.from.longitude + pair.to.longitude;
      count += 2;
    }
    return LatLng(latTotal / count, lonTotal / count);
  }

  List<LatLng> _greatCirclePoints(LatLng from, LatLng to, {int segments = 48}) {
    final lat1 = from.latitude * math.pi / 180.0;
    final lon1 = from.longitude * math.pi / 180.0;
    final lat2 = to.latitude * math.pi / 180.0;
    final lon2 = to.longitude * math.pi / 180.0;

    final d =
        2 *
        math.asin(
          math.sqrt(
            math.pow(math.sin((lat2 - lat1) / 2), 2).toDouble() +
                math.cos(lat1) *
                    math.cos(lat2) *
                    math.pow(math.sin((lon2 - lon1) / 2), 2).toDouble(),
          ),
        );
    if (d == 0 || d.isNaN) return [from, to];

    final points = <LatLng>[];
    final sinD = math.sin(d);
    for (var i = 0; i <= segments; i++) {
      final f = i / segments;
      final a = math.sin((1 - f) * d) / sinD;
      final b = math.sin(f * d) / sinD;

      final x =
          a * math.cos(lat1) * math.cos(lon1) +
          b * math.cos(lat2) * math.cos(lon2);
      final y =
          a * math.cos(lat1) * math.sin(lon1) +
          b * math.cos(lat2) * math.sin(lon2);
      final z = a * math.sin(lat1) + b * math.sin(lat2);

      final lat = math.atan2(z, math.sqrt(x * x + y * y));
      final lon = math.atan2(y, x);
      points.add(LatLng(lat * 180.0 / math.pi, lon * 180.0 / math.pi));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final lines = <Polyline>[];
    final markers = <Marker>[];
    for (final pair in widget.pairs) {
      if (widget.showLines) {
        lines.add(
          Polyline(
            points: _greatCirclePoints(pair.from, pair.to),
            strokeWidth: 2,
            color: _lineColor,
          ),
        );
      }
      markers.addAll([
        Marker(
          point: pair.from,
          width: 14,
          height: 14,
          child: const Icon(Icons.circle, size: 9, color: _dotColor),
        ),
        Marker(
          point: pair.to,
          width: 14,
          height: 14,
          child: const Icon(Icons.circle, size: 9, color: _dotColor),
        ),
      ]);
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _initialCenter(),
            initialZoom: _zoom,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.rietlabs.simplelog',
              tileProvider: NetworkTileProvider(
                cachingProvider: appMapCachingProvider(),
              ),
            ),
            PolylineLayer(polylines: lines),
            MarkerLayer(markers: markers),
          ],
        ),
        Positioned(
          left: 12,
          top: 12,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(widget.airportCountLabel),
            ),
          ),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Card(
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    _zoom += 1;
                    _mapController.move(_mapController.camera.center, _zoom);
                  },
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: () {
                    _zoom -= 1;
                    _mapController.move(_mapController.camera.center, _zoom);
                  },
                  icon: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
