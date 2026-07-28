import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplelog/data/models/reports_models.dart';

const _prefix = 'flight_animation_';
const _timingModeKey = '${_prefix}timing_mode';
const _styleKey = '${_prefix}style';
const _lookBehindKey = '${_prefix}look_behind';
const _lookAheadKey = '${_prefix}look_ahead';
const _cameraSpeedKey = '${_prefix}camera_speed';
const _cameraPaddingKey = '${_prefix}camera_padding';
const _fadePastFlightsKey = '${_prefix}fade_past_flights';
const _fadeDurationKey = '${_prefix}fade_duration';
const _finalFadeLevelKey = '${_prefix}final_fade_level';
const _durationKey = '${_prefix}duration';

/// SharedPreferences instance provider.
final _sharedPrefsProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

/// Persists the user's animation setup selections.
final flightAnimationPrefsProvider = AsyncNotifierProvider<
    FlightAnimationPrefsNotifier, FlightAnimationPrefs>(
  FlightAnimationPrefsNotifier.new,
);

/// In-memory + persisted animation preferences.
class FlightAnimationPrefs {
  /// Creates animation preferences.
  const FlightAnimationPrefs({
    this.timingMode = TimingMode.sequential,
    this.style = FlightAnimationStyle.manualZoom,
    this.lookBehind = 1,
    this.lookAhead = 1,
    this.cameraSpeed = 0.01,
    this.cameraPadding = 1.8,
    this.fadePastFlights = false,
    this.fadeDuration = 5,
    this.finalFadeLevel = 5,
    this.durationMinutes = 3,
  });

  /// Timing mode selection.
  final TimingMode timingMode;

  /// Animation style selection.
  final FlightAnimationStyle style;

  /// Look-behind percent.
  final double lookBehind;

  /// Look-ahead percent.
  final double lookAhead;

  /// Camera speed.
  final double cameraSpeed;

  /// Camera padding in degrees.
  final double cameraPadding;

  /// Whether to fade past flights.
  final bool fadePastFlights;

  /// Fade duration percent.
  final double fadeDuration;

  /// Final fade level percent.
  final double finalFadeLevel;

  /// Animation duration in minutes.
  final int durationMinutes;

  /// Creates a copy with the given fields replaced.
  FlightAnimationPrefs copyWith({
    TimingMode? timingMode,
    FlightAnimationStyle? style,
    double? lookBehind,
    double? lookAhead,
    double? cameraSpeed,
    double? cameraPadding,
    bool? fadePastFlights,
    double? fadeDuration,
    double? finalFadeLevel,
    int? durationMinutes,
  }) => FlightAnimationPrefs(
    timingMode: timingMode ?? this.timingMode,
    style: style ?? this.style,
    lookBehind: lookBehind ?? this.lookBehind,
    lookAhead: lookAhead ?? this.lookAhead,
    cameraSpeed: cameraSpeed ?? this.cameraSpeed,
    cameraPadding: cameraPadding ?? this.cameraPadding,
    fadePastFlights: fadePastFlights ?? this.fadePastFlights,
    fadeDuration: fadeDuration ?? this.fadeDuration,
    finalFadeLevel: finalFadeLevel ?? this.finalFadeLevel,
    durationMinutes: durationMinutes ?? this.durationMinutes,
  );
}

/// Manages animation preferences in SharedPreferences.
class FlightAnimationPrefsNotifier
    extends AsyncNotifier<FlightAnimationPrefs> {
  @override
  Future<FlightAnimationPrefs> build() async {
    final prefs = await ref.read(_sharedPrefsProvider.future);
    return FlightAnimationPrefs(
      timingMode: TimingMode.values.byName(
        prefs.getString(_timingModeKey) ?? TimingMode.sequential.name,
      ),
      style: FlightAnimationStyle.values.byName(
        prefs.getString(_styleKey) ?? FlightAnimationStyle.manualZoom.name,
      ),
      lookBehind: prefs.getDouble(_lookBehindKey) ?? 1,
      lookAhead: prefs.getDouble(_lookAheadKey) ?? 1,
      cameraSpeed: prefs.getDouble(_cameraSpeedKey) ?? 0.01,
      cameraPadding: prefs.getDouble(_cameraPaddingKey) ?? 1.8,
      fadePastFlights: prefs.getBool(_fadePastFlightsKey) ?? false,
      fadeDuration: prefs.getDouble(_fadeDurationKey) ?? 5,
      finalFadeLevel: prefs.getDouble(_finalFadeLevelKey) ?? 5,
      durationMinutes: prefs.getInt(_durationKey) ?? 3,
    );
  }

  /// Persists the full preferences immediately.
  Future<void> save(FlightAnimationPrefs value) async {
    final prefs = await ref.read(_sharedPrefsProvider.future);
    await Future.wait([
      prefs.setString(_timingModeKey, value.timingMode.name),
      prefs.setString(_styleKey, value.style.name),
      prefs.setDouble(_lookBehindKey, value.lookBehind),
      prefs.setDouble(_lookAheadKey, value.lookAhead),
      prefs.setDouble(_cameraSpeedKey, value.cameraSpeed),
      prefs.setDouble(_cameraPaddingKey, value.cameraPadding),
      prefs.setBool(_fadePastFlightsKey, value.fadePastFlights),
      prefs.setDouble(_fadeDurationKey, value.fadeDuration),
      prefs.setDouble(_finalFadeLevelKey, value.finalFadeLevel),
      prefs.setInt(_durationKey, value.durationMinutes),
    ]);
    state = AsyncData(value);
  }
}
