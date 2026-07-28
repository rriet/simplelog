import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/maps/map_tile_caching.dart';
import 'package:simplelog/data/models/reports_models.dart';

/// Map screen that displays selected flights as great-circle routes with
/// airport markers and timed animation.
class FlightAnimationScreen extends StatefulWidget {
  /// Creates the flight animation map screen.
  const FlightAnimationScreen({required this.result, super.key});

  /// Phase-one setup output containing flights, duration and style.
  final FlightAnimationSetupResult result;

  @override
  State<FlightAnimationScreen> createState() => _FlightAnimationScreenState();
}

class _FlightAnimationScreenState extends State<FlightAnimationScreen>
    with SingleTickerProviderStateMixin {
  final _mapController = MapController();

  static const Color _activeLineColor = Color(0xFF4A90E2);
  static const Color _completedLineColor = Color(0xFF2196F3);
  static const Color _dotColor = Color(0xFF1565C0);
  static const Color _aircraftColor = Color(0xFFE53935);

  late final List<FlightRoute> _routes;
  late final Map<String, LatLng> _uniqueAirports;
  late final Map<String, int> _lastFlightForAirport;
  late final LatLngBounds _bounds;
  late final _FlightTimeline _timeline;

  AnimationController? _animController;
  double _animValue = 0;
  bool _isPlaying = false;
  bool _tilesReady = false;
  int _currentFlightIndex = -1;
  double _currentFlightProgress = 0;

  // Smooth camera state for automatic mode.
  LatLng? _camTarget;
  double? _camTargetZoom;

  @override
  void initState() {
    super.initState();
    _routes = _buildRoutes();
    _uniqueAirports = _collectUniqueAirports();
    _lastFlightForAirport = _computeLastFlightForAirport();
    _bounds = _computeBounds();
    _timeline = _FlightTimeline(
      routes: _routes,
      totalMinutes: widget.result.durationMinutes,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureAnimController();
  }

  void _ensureAnimController() {
    if (_animController != null) return;
    final durationMs = widget.result.durationMinutes * 60 * 1000;
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..addListener(_onAnimTick);
    // Kick off tile preloading after first frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) => _preloadTiles());
  }

  /// Pre-load map tiles for the zoom levels the animation will visit so
  /// the map doesn't appear blank during playback.
  Future<void> _preloadTiles() async {
    try {
      if (!mounted || _routes.isEmpty) return;
      final zoomLevels = _zoomLevelsForAnimation();
      for (final zoom in zoomLevels) {
        if (!mounted) return;
        _mapController.move(_bounds.center, zoom);
        // Give the tile layer time to issue network requests.
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
      // Return to the proper initial view.
      _setFitAllCamera();
    } on Object catch (e) {
      debugPrint('Tile preload failed: $e');
      _setFitAllCamera();
    }
    if (mounted) setState(() => _tilesReady = true);
  }

  /// Returns the distinct zoom levels the camera will use during
  /// animation so we can pre-fetch those tiles.
  List<double> _zoomLevelsForAnimation() {
    final levels = <double>{};
    const paddingDeg = 2.0;
    for (final route in _routes) {
      final bounds = _routeBounds(route, paddingDeg);
      levels.add(_zoomForBounds(bounds).roundToDouble());
    }
    levels.add(_zoomForBounds(_bounds).roundToDouble());
    return levels.toSet().toList()..sort();
  }

  LatLngBounds _routeBounds(FlightRoute route, double paddingDeg) {
    return _latLngBounds(
      math.min(route.from.latitude, route.to.latitude) - paddingDeg,
      math.min(route.from.longitude, route.to.longitude) - paddingDeg,
      math.max(route.from.latitude, route.to.latitude) + paddingDeg,
      math.max(route.from.longitude, route.to.longitude) + paddingDeg,
    );
  }

  static LatLngBounds _latLngBounds(
    double south,
    double west,
    double north,
    double east,
  ) {
    final s = south.clamp(-89.9, 89.9);
    final w = west.clamp(-179.9, 179.9);
    final n = math.max(s, north.clamp(-89.9, 89.9));
    final e = math.max(w, east.clamp(-179.9, 179.9));
    return LatLngBounds(LatLng(s, w), LatLng(n, e));
  }

  @override
  void dispose() {
    _animController
      ?..removeListener(_onAnimTick)
      ..dispose();
    super.dispose();
  }

  // --- Animation logic ---

  bool _shouldMoveCamera() {
    return widget.result.style == FlightAnimationStyle.automatic;
  }

  void _onAnimTick() {
    if (!mounted) return;
    final value = _animController!.value;
    final entry = _timeline.entryAt(value);
    setState(() {
      _animValue = value;
      _currentFlightIndex = entry?.index ?? -1;
      _currentFlightProgress = entry?.progress ?? 0;
    });
    if (_shouldMoveCamera()) {
      _moveCameraAutomatic(value);
    }
    // Auto-stop when animation completes.
    if (_animController!.isCompleted) {
      _isPlaying = false;
    }
  }

  /// Smoothly pans and zooms the camera to include all flights in the
  /// current look-behind / look-ahead window.
  void _moveCameraAutomatic(double animValue) {
    final behindFraction = widget.result.lookBehindPercent / 100;
    final aheadFraction = widget.result.lookAheadPercent / 100;
    final windowStart = (animValue - behindFraction).clamp(0.0, 1.0);
    final windowEnd = (animValue + aheadFraction).clamp(0.0, 1.0);

    // Find flights whose time window overlaps [windowStart, windowEnd].
    var minLat = 90.0;
    var maxLat = -90.0;
    var minLon = 180.0;
    var maxLon = -180.0;
    for (final entry in _timeline.entries) {
      if (entry.endFraction > windowStart &&
          entry.startFraction < windowEnd) {
        final r = entry.route;
        for (final p in [r.from, r.to]) {
          minLat = math.min(minLat, p.latitude);
          maxLat = math.max(maxLat, p.latitude);
          minLon = math.min(minLon, p.longitude);
          maxLon = math.max(maxLon, p.longitude);
        }
      }
    }
    final pad = widget.result.cameraPadding;
    final targetCenter = _latLngBounds(
      minLat - pad, minLon - pad, maxLat + pad, maxLon + pad,
    ).center;
    final targetZoom = _zoomForBounds(_latLngBounds(
      minLat - pad, minLon - pad, maxLat + pad, maxLon + pad,
    ));

    // Initialize on first call.
    if (_camTarget == null) {
      _camTarget = targetCenter;
      _camTargetZoom = targetZoom;
      _mapController.move(targetCenter, targetZoom);
      return;
    }

    // Lerp toward the target.
    final t = widget.result.cameraSpeed;
    final newLat =
        _camTarget!.latitude +
        (targetCenter.latitude - _camTarget!.latitude) * t;
    final newLng =
        _camTarget!.longitude +
        (targetCenter.longitude - _camTarget!.longitude) * t;
    final newZoom =
        _camTargetZoom! +
        (targetZoom - _camTargetZoom!) * t;
    _camTarget = LatLng(newLat, newLng);
    _camTargetZoom = newZoom;
    _mapController.move(_camTarget!, newZoom);
  }

  double _zoomForBounds(LatLngBounds bounds) {
    final latSpan = bounds.north - bounds.south;
    final lonSpan = bounds.east - bounds.west;
    final maxSpan = math.max(latSpan, lonSpan);
    if (maxSpan <= 0 || maxSpan.isNaN) return 5;
    final z = math.log(1125 / maxSpan) / math.ln2;
    if (z.isNaN || z.isInfinite) return 5;
    return z.clamp(1.0, 18.0);
  }

  // --- Playback controls ---

  void _play() {
    if (_animController == null) return;
    if (_animController!.isCompleted) {
      _animController!.reset();
      _camTarget = null;
      _camTargetZoom = null;
      setState(() {
        _animValue = 0;
        _currentFlightIndex = -1;
        _currentFlightProgress = 0;
      });
    }
    setState(() => _isPlaying = true);
    unawaited(_animController!.forward());
  }

  void _pause() {
    _animController?.stop();
    setState(() => _isPlaying = false);
  }

  void _restart() {
    _animController
      ?..stop()
      ..reset();
    _camTarget = null;
    _camTargetZoom = null;
    setState(() {
      _isPlaying = false;
      _animValue = 0;
      _currentFlightIndex = -1;
      _currentFlightProgress = 0;
    });
    _setFitAllCamera();
  }

  void _setFitAllCamera() {
    if (_routes.isEmpty) return;
    const padding = 5.0;
    final paddedBounds = _latLngBounds(
      _bounds.south - padding,
      _bounds.west - padding,
      _bounds.north + padding,
      _bounds.east + padding,
    );
    _mapController.fitCamera(
      CameraFit.bounds(bounds: paddedBounds),
    );
  }

  // --- Data helpers ---

  List<FlightRoute> _buildRoutes() {
    final routes = <FlightRoute>[];
    for (final flight in widget.result.flights) {
      final from = LatLng(flight.departureLatitude, flight.departureLongitude);
      final to = LatLng(flight.arrivalLatitude, flight.arrivalLongitude);
      routes.add(
        FlightRoute(
          flight: flight,
          from: from,
          to: to,
          points: _greatCirclePoints(from, to),
        ),
      );
    }
    return routes;
  }

  Map<String, LatLng> _collectUniqueAirports() {
    final airports = <String, LatLng>{};
    for (final flight in widget.result.flights) {
      final depCode = flight.departureAirport.trim();
      final arrCode = flight.arrivalAirport.trim();
      if (depCode.isNotEmpty) {
        airports.putIfAbsent(
          depCode,
          () => LatLng(flight.departureLatitude, flight.departureLongitude),
        );
      }
      if (arrCode.isNotEmpty) {
        airports.putIfAbsent(
          arrCode,
          () => LatLng(flight.arrivalLatitude, flight.arrivalLongitude),
        );
      }
    }
    return airports;
  }

  Map<String, int> _computeLastFlightForAirport() {
    final lastFlight = <String, int>{};
    for (var i = 0; i < _routes.length; i++) {
      final dep = _routes[i].flight.departureAirport.trim();
      final arr = _routes[i].flight.arrivalAirport.trim();
      if (dep.isNotEmpty) lastFlight[dep] = i;
      if (arr.isNotEmpty) lastFlight[arr] = i;
    }
    return lastFlight;
  }

  LatLngBounds _computeBounds() {
    var minLat = 90.0;
    var maxLat = -90.0;
    var minLon = 180.0;
    var maxLon = -180.0;
    for (final route in _routes) {
      for (final point in [route.from, route.to]) {
        minLat = math.min(minLat, point.latitude);
        maxLat = math.max(maxLat, point.latitude);
        minLon = math.min(minLon, point.longitude);
        maxLon = math.max(maxLon, point.longitude);
      }
    }
    return _latLngBounds(minLat, minLon, maxLat, maxLon);
  }

  LatLng _mapCenter() {
    if (_routes.isEmpty) return const LatLng(20, 0);
    return _bounds.center;
  }

  double _initialZoom() {
    if (_routes.isEmpty) return 2;
    return _zoomForBounds(_bounds);
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final flightCount = widget.result.flights.length;
    final airportCount = _uniqueAirports.length;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.flightAnimationTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                '$flightCount flights · $airportCount airports',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: _tilesReady ? 1 : 0,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _mapCenter(),
                initialZoom: _initialZoom(),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.rietlabs.simplelog',
                  tileProvider: NetworkTileProvider(
                    cachingProvider: appMapCachingProvider(),
                  ),
                ),
                PolylineLayer(polylines: _buildPolylines()),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: _buildFlightInfoCard(),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: _buildControls(),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: _buildZoomControls(),
          ),
          if (_animController != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildProgressBar(),
            ),
        ],
      ),
    );
  }

  List<Polyline> _buildPolylines() {
    if (_currentFlightIndex < 0) return const [];
    final polylines = <Polyline>[];
    final fadeEnabled = widget.result.fadePastFlights;
    final fadeDurationFraction = widget.result.fadeDurationPercent / 100;
    final finalAlpha = widget.result.finalFadeLevelPercent / 100;
    for (var i = 0; i <= _currentFlightIndex && i < _routes.length; i++) {
      final route = _routes[i];
      Color color;
      List<LatLng> points;
      double strokeWidth;

      if (i < _currentFlightIndex) {
        var opacity = 1.0;
        if (fadeEnabled) {
          final entry = _timeline.entries[i];
          final fadeStart = entry.endFraction;
          final fadeEnd = fadeStart + fadeDurationFraction;
          if (_animValue >= fadeEnd) {
            opacity = finalAlpha;
          } else if (_animValue > fadeStart) {
            final t =
                (_animValue - fadeStart) / (fadeEnd - fadeStart);
            opacity = 1.0 - (1.0 - finalAlpha) * t;
          }
        }
        color = _completedLineColor.withValues(alpha: opacity);
        points = route.points;
        strokeWidth = 2.5;
      } else {
        color = _activeLineColor;
        final revealCount =
            (_currentFlightProgress * (route.points.length - 1)).ceil() + 1;
        final end = revealCount.clamp(1, route.points.length);
        points = route.points.sublist(0, end);
        strokeWidth = 3;
      }

      polylines.add(
        Polyline(points: points, strokeWidth: strokeWidth, color: color),
      );
    }
    return polylines;
  }

  List<Marker> _buildMarkers() {
    if (_currentFlightIndex < 0) return const [];
    final markers = <Marker>[];
    final fadeEnabled = widget.result.fadePastFlights;
    final fadeDurationFraction = widget.result.fadeDurationPercent / 100;
    final finalAlpha = widget.result.finalFadeLevelPercent / 100;
    final visibleAirports = <String>{};
    for (var i = 0; i <= _currentFlightIndex && i < _routes.length; i++) {
      final flight = _routes[i].flight;
      final depCode = flight.departureAirport.trim();
      final arrCode = flight.arrivalAirport.trim();
      if (depCode.isNotEmpty) visibleAirports.add(depCode);
      if (arrCode.isNotEmpty) visibleAirports.add(arrCode);
    }
    for (final entry in _uniqueAirports.entries) {
      if (!visibleAirports.contains(entry.key)) continue;
      var opacity = 1.0;
      if (fadeEnabled) {
        final lastIdx = _lastFlightForAirport[entry.key];
        if (lastIdx != null && lastIdx < _currentFlightIndex) {
          final timelineEntry = _timeline.entries[lastIdx];
          final fadeStart = timelineEntry.endFraction;
          final fadeEnd = fadeStart + fadeDurationFraction;
          if (_animValue >= fadeEnd) {
            opacity = finalAlpha;
          } else if (_animValue > fadeStart) {
            final t = (_animValue - fadeStart) / (fadeEnd - fadeStart);
            opacity = 1.0 - (1.0 - finalAlpha) * t;
          }
        }
      }
      markers.add(
        Marker(
          point: entry.value,
          width: 18,
          height: 18,
          child: Tooltip(
            message: entry.key,
            child: Icon(
              Icons.circle,
              size: 12,
              color: _dotColor.withValues(alpha: opacity),
            ),
          ),
        ),
      );
    }
    if (_currentFlightIndex < _routes.length) {
      final route = _routes[_currentFlightIndex];
      final pos = _interpolateAlongRoute(
        route.points,
        _currentFlightProgress,
      );
      markers.add(
        Marker(
          point: pos,
          width: 28,
          height: 28,
          child: const Icon(
            Icons.airplanemode_active,
            size: 22,
            color: _aircraftColor,
          ),
        ),
      );
    }
    return markers;
  }

  LatLng _interpolateAlongRoute(List<LatLng> points, double progress) {
    if (points.isEmpty) return const LatLng(0, 0);
    if (points.length == 1) return points.first;
    final f = progress.clamp(0.0, 1.0);
    final index = f * (points.length - 1);
    final i = index.floor();
    final t = index - i;
    if (i >= points.length - 1) return points.last;
    final a = points[i];
    final b = points[i + 1];
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  Widget _buildFlightInfoCard() {
    final l10n = AppLocalizations.of(context)!;
    final hasFlight =
        _currentFlightIndex >= 0 && _currentFlightIndex < _routes.length;
    final flight = hasFlight ? _routes[_currentFlightIndex].flight : null;
    final date = flight?.date;
    final dateStr = date != null
        ? '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}'
        : null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.flightAnimationBrand,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (flight != null) ...[
              const SizedBox(height: 4),
              Text(
                flight.aircraftFamily,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (dateStr != null) ...[
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 22,
              onPressed: _restart,
              icon: const Icon(Icons.replay),
              tooltip: l10n.flightAnimationRestart,
            ),
            IconButton(
              iconSize: 28,
              onPressed: _isPlaying ? _pause : _play,
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              tooltip: _isPlaying
                  ? l10n.flightAnimationPause
                  : l10n.flightAnimationPlay,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              );
            },
            icon: const Icon(Icons.add, size: 20),
          ),
          IconButton(
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              );
            },
            icon: const Icon(Icons.remove, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return ValueListenableBuilder<double>(
      valueListenable: ValueNotifier(_animValue),
      builder: (context, value, _) {
        return LinearProgressIndicator(
          value: value,
          minHeight: 4,
          backgroundColor: Colors.black12,
        );
      },
    );
  }

  /// Computes great-circle intermediate points between [from] and [to]
  /// using the Haversine formula and spherical linear interpolation (slerp).
  static List<LatLng> _greatCirclePoints(
    LatLng from,
    LatLng to, {
    int segments = 80,
  }) {
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
}

/// Maps the global animation timeline to per-flight time windows based on
/// each flight's block time proportion of the total duration.
class _FlightTimeline {
  _FlightTimeline({
    required List<FlightRoute> routes,
    required int totalMinutes,
  }) : entries = _buildEntries(routes, totalMinutes);

  final List<_FlightTimelineEntry> entries;

  static List<_FlightTimelineEntry> _buildEntries(
    List<FlightRoute> routes,
    int totalMinutes,
  ) {
    if (routes.isEmpty) return const [];
    final totalBlock = routes.fold<int>(
      0,
      (sum, r) => sum + math.max(1, r.flight.totalMinutes),
    );
    final totalMs = totalMinutes * 60 * 1000;
    final entries = <_FlightTimelineEntry>[];
    var startMs = 0;
    for (var i = 0; i < routes.length; i++) {
      final flightMin = math.max(1, routes[i].flight.totalMinutes);
      final fraction = flightMin / totalBlock;
      final durationMs = (totalMs * fraction).round();
      final startFraction = startMs / totalMs;
      final endFraction = (startMs + durationMs) / totalMs;
      entries.add(
        _FlightTimelineEntry(
          index: i,
          route: routes[i],
          startFraction: startFraction,
          endFraction: endFraction,
        ),
      );
      startMs += durationMs;
    }
    return entries;
  }

  /// Returns the timeline entry and local progress for a global [value]
  /// in the range 0..1.
  _FlightTimelineEntry? entryAt(double value) {
    if (entries.isEmpty) return null;
    for (final entry in entries) {
      if (value <= entry.endFraction || entry == entries.last) {
        final span = entry.endFraction - entry.startFraction;
        final progress = span > 0
            ? ((value - entry.startFraction) / span).clamp(0.0, 1.0)
            : 1.0;
        return entry..progress = progress;
      }
    }
    return null;
  }
}

class _FlightTimelineEntry {
  _FlightTimelineEntry({
    required this.index,
    required this.route,
    required this.startFraction,
    required this.endFraction,
  });

  final int index;
  final FlightRoute route;
  final double startFraction;
  final double endFraction;
  double progress = 0;
}
