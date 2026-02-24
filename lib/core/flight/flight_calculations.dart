import 'dart:math';

/// Optimized FlightCalculations class with performance improvements
class FlightCalculations {
  /// Public API documentation.
  FlightCalculations({
    required this.latDep,
    required this.longDep,
    required this.latArr,
    required this.longArr,
    required this.depTimeEpochSeconds,
    required this.arrTimeEpochSeconds,
  }) {
    sunriseDep = calcSunriseUTC(depTimeEpochSeconds, latDep, longDep);
    sunsetDep = calcSunsetUTC(depTimeEpochSeconds, latDep, longDep);
    sunriseArr = calcSunriseUTC(arrTimeEpochSeconds, latArr, longArr);
    sunsetArr = calcSunsetUTC(arrTimeEpochSeconds, latArr, longArr);

    dayTakeOff = isDay(depTimeEpochSeconds, sunriseDep, sunsetDep, latDep);
    dayLanding = isDay(arrTimeEpochSeconds, sunriseArr, sunsetArr, latArr);

    flightTimeMinutes = flightTime(depTimeEpochSeconds, arrTimeEpochSeconds);
    flightDistanceNm = flightDistance(latDep, longDep, latArr, longArr);
  }

  /// Public API documentation.

  /// Public API documentation.
  final double latDep;

  /// Public API documentation.
  final double longDep;

  /// Public API documentation.
  final double latArr;

  /// Public API documentation.
  final double longArr;

  /// Public API documentation.
  final int depTimeEpochSeconds;

  /// Public API documentation.
  final int arrTimeEpochSeconds;

  /// Public API documentation.

  /// Public API documentation.
  late final int sunriseDep;

  /// Public API documentation.
  late final int sunsetDep;

  /// Public API documentation.
  late final int sunriseArr;

  /// Public API documentation.
  late final int sunsetArr;

  /// Public API documentation.
  late final int flightTimeMinutes;

  /// Public API documentation.
  late final double flightDistanceNm;

  /// Public API documentation.
  late final bool dayTakeOff;

  /// Public API documentation.
  late final bool dayLanding;

  /// Public API documentation.
  int? _nightTimeMinutes;

  /// Lazily calculated to avoid unnecessary expensive work.
  int get nightTimeMinutes =>
      _nightTimeMinutes ??= _calculatePreciseNightTime();

  // Cached constants for performance
  static const double _sunsetAngleDeg = 90.833;
  static final double _cosSunsetAngle = cos(_sunsetAngleDeg * pi / 180.0);

  /// Public API documentation.
  String get sunriseTime => _formatMinutes(sunriseDep);

  /// Public API documentation.
  String get sunsetTime => _formatMinutes(sunsetDep);

  String _formatMinutes(int minutes) {
    final hour = (minutes ~/ 60).toString().padLeft(2, '0');
    final min = (minutes % 60).toString().padLeft(2, '0');
    return '$hour:$min';
  }

  /// Determines if it is daytime at a specific location and time
  bool isDay(
    int epochSeconds,
    int sunrise,
    int sunset,
    double latitude,
  ) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      epochSeconds * 1000,
      isUtc: true,
    );
    final doy = _dayOfYear(date);
    final timeMinutes = date.hour * 60 + date.minute;

    // Handle polar day/night scenarios
    if (sunrise == 0 && sunset == 0) {
      const arcticCircle = 66.4;
      const antarcticCircle = -66.4;

      // Arctic summer (24hr daylight): ~Mar 21 to ~Sep 23
      final isArcticSummer = latitude > arcticCircle && doy > 79 && doy < 267;

      // Antarctic summer: ~Sep 23 to ~Mar 21 (spans new year)
      final isAntarcticSummer =
          latitude < antarcticCircle && (doy < 83 || doy > 263);

      return isArcticSummer || isAntarcticSummer;
    }

    // Standard day/night determination
    if (sunrise < sunset) {
      return timeMinutes >= sunrise && timeMinutes < sunset;
    } else {
      return timeMinutes >= sunrise || timeMinutes < sunset;
    }
  }

  /// Calculate flight time in minutes
  /// Fixed: Using integer division instead of rounding
  int flightTime(int chockOff, int chockOn) {
    return (chockOn - chockOff) ~/ 60;
  }

  /// Calculate great circle distance in nautical miles
  double flightDistance(
    double latDep,
    double longDep,
    double latArr,
    double longArr,
  ) {
    final dLat = _degToRad(latArr - latDep);
    final dLon = _degToRad(longArr - longDep);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(latDep)) *
            cos(_degToRad(latArr)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * asin(sqrt(a));
    return 3443.89849 * c; // Earth radius in nautical miles
  }

  /// Calculate bearing between two points
  double flightBearing(
    double latDep,
    double longDep,
    double latArr,
    double longArr,
  ) {
    final latDepR = _degToRad(latDep);
    final longDepR = _degToRad(longDep);
    final latArrR = _degToRad(latArr);
    final longArrR = _degToRad(longArr);

    final y = sin(longArrR - longDepR) * cos(latArrR);
    final x =
        cos(latDepR) * sin(latArrR) -
        sin(latDepR) * cos(latArrR) * cos(longArrR - longDepR);

    var bearing = _radToDeg(atan2(y, x));
    if (bearing < 0) {
      bearing = 360 + bearing;
    }
    return bearing;
  }

  /// Calculate next waypoint given current position, bearing, and distance
  (double lat, double lon) flightNextWaypoint(
    double latDep,
    double longDep,
    double bearing,
    double distance,
  ) {
    final latDepR = _degToRad(latDep);
    final longDepR = _degToRad(longDep);
    final bearingR = _degToRad(bearing);

    const radius = 3443.89849; // Earth radius in nautical miles

    var latNext = asin(
      sin(latDepR) * cos(distance / radius) +
          cos(latDepR) * sin(distance / radius) * cos(bearingR),
    );

    var longNext =
        longDepR +
        atan2(
          sin(bearingR) * sin(distance / radius) * cos(latDepR),
          cos(distance / radius) - sin(latDepR) * sin(latNext),
        );

    latNext = _radToDeg(latNext);
    longNext = _radToDeg(longNext);

    // Normalize longitude to [-180, 180]
    if (longNext > 180) longNext -= 360;
    if (longNext < -180) longNext += 360;

    return (latNext, longNext);
  }

  /// Calculate precise night time minute-by-minute along the great-circle path.
  /// This intentionally matches the legacy SimpleLog behavior.
  int _calculatePreciseNightTime() {
    if (flightTimeMinutes <= 0) {
      return dayTakeOff ? 0 : 1;
    }

    var nightTime = dayTakeOff ? 0 : 1;
    var now = DateTime.fromMillisecondsSinceEpoch(
      depTimeEpochSeconds * 1000,
      isUtc: true,
    );
    final arr = DateTime.fromMillisecondsSinceEpoch(
      arrTimeEpochSeconds * 1000,
      isUtc: true,
    );
    var latNow = latDep;
    var longNow = longDep;
    final milesPerMinute = flightDistanceNm / flightTimeMinutes;
    var isDayState = dayTakeOff;
    const coarseStepMinutes = 5;

    while (now.isBefore(arr)) {
      final remainingMinutes = arr.difference(now).inMinutes;
      final stepMinutes = min(coarseStepMinutes, remainingMinutes);
      final startNow = now;
      final startLat = latNow;
      final startLon = longNow;
      final startIsDay = isDayState;

      final coarseBearing = flightBearing(latNow, longNow, latArr, longArr);
      final (coarseLat, coarseLon) = flightNextWaypoint(
        latNow,
        longNow,
        coarseBearing,
        milesPerMinute * stepMinutes,
      );
      final coarseNow = now.add(Duration(minutes: stepMinutes));
      final coarseEpochSeconds = coarseNow.millisecondsSinceEpoch ~/ 1000;
      final coarseSunrise = calcSunriseUTC(
        coarseEpochSeconds,
        coarseLat,
        coarseLon,
      );
      final coarseSunset = calcSunsetUTC(
        coarseEpochSeconds,
        coarseLat,
        coarseLon,
      );
      final coarseIsDay = isDay(
        coarseEpochSeconds,
        coarseSunrise,
        coarseSunset,
        coarseLat,
      );

      if (coarseIsDay == startIsDay) {
        if (!startIsDay) {
          final nightDelta = coarseNow.isBefore(arr)
              ? stepMinutes
              : max(0, stepMinutes - 1);
          nightTime += nightDelta;
        }
        now = coarseNow;
        latNow = coarseLat;
        longNow = coarseLon;
        isDayState = coarseIsDay;
        continue;
      }

      // Transition detected in this coarse window.
      // Re-run minute-by-minute and recompute bearing each minute to keep
      // long-haul transition timing stable.
      now = startNow;
      latNow = startLat;
      longNow = startLon;
      isDayState = startIsDay;
      for (var minute = 0; minute < stepMinutes; minute++) {
        now = now.add(const Duration(minutes: 1));

        final bearing = flightBearing(latNow, longNow, latArr, longArr);
        final (nextLat, nextLon) = flightNextWaypoint(
          latNow,
          longNow,
          bearing,
          milesPerMinute,
        );
        latNow = nextLat;
        longNow = nextLon;

        final epochSeconds = now.millisecondsSinceEpoch ~/ 1000;
        final sunriseNow = calcSunriseUTC(epochSeconds, latNow, longNow);
        final sunsetNow = calcSunsetUTC(epochSeconds, latNow, longNow);
        final isDayNow = isDay(epochSeconds, sunriseNow, sunsetNow, latNow);

        if (isDayState == isDayNow && !isDayState && now.isBefore(arr)) {
          nightTime += 1;
        }
        isDayState = isDayNow;
      }
    }

    return nightTime;
  }

  /// Find the most recent sunrise (for reference/debugging)
  ({double julianDay, double time}) findRecentSunrise(
    int epochSeconds,
    double latitude,
    double longitude,
  ) {
    var date = DateTime.fromMillisecondsSinceEpoch(
      epochSeconds * 1000,
      isUtc: true,
    );
    var jd = calcJD(date.year, date.month, date.day);
    var time = calcSunriseUTC(epochSeconds, latitude, longitude).toDouble();

    while (time <= 0) {
      date = date.subtract(const Duration(days: 1));
      jd = calcJD(date.year, date.month, date.day);
      time = calcSunriseUTC(
        date.millisecondsSinceEpoch ~/ 1000,
        latitude,
        longitude,
      ).toDouble();
    }

    return (julianDay: jd, time: time);
  }

  /// Calculate sunrise time in UTC minutes from midnight
  int calcSunriseUTC(int epochSeconds, double latitude, double longitude) {
    if (!latitude.isFinite || !longitude.isFinite) return 0;
    // Negate longitude because the NOAA algorithm expects
    // positive = WEST (opposite of standard convention where positive = EAST)
    final adjustedLongitude = longitude * -1;

    final date = DateTime.fromMillisecondsSinceEpoch(
      epochSeconds * 1000,
      isUtc: true,
    );
    final jd = calcJD(date.year, date.month, date.day);
    final t = calcTimeJulianCent(jd);

    final noonmin = calcSolNoonUTC(t, adjustedLongitude);
    final tnoon = calcTimeJulianCent(jd + noonmin / 1440.0);

    // First pass approximation
    var eqTime = calcEquationOfTime(tnoon);
    var solarDec = calcSunDeclination(tnoon);
    var hourAngle = calcHourAngleSunrise(latitude, solarDec);

    var delta = adjustedLongitude - _radToDeg(hourAngle);
    var timeDiff = 4 * delta;
    var timeUTC = 720 + timeDiff - eqTime;

    // Second pass with fractional day
    final newt = calcTimeJulianCent(
      calcJDFromJulianCent(t) + timeUTC / 1440.0,
    );
    eqTime = calcEquationOfTime(newt);
    solarDec = calcSunDeclination(newt);
    hourAngle = calcHourAngleSunrise(latitude, solarDec);
    delta = adjustedLongitude - _radToDeg(hourAngle);
    timeDiff = 4 * delta;
    timeUTC = 720 + timeDiff - eqTime;

    // Normalize to [0, 1440) range
    if (timeUTC >= 1440) timeUTC -= 1440;
    if (timeUTC < 0) timeUTC += 1440;

    if (!timeUTC.isFinite) return 0;
    return timeUTC.round();
  }

  /// Calculate sunset time in UTC minutes from midnight
  int calcSunsetUTC(int epochSeconds, double latitude, double longitude) {
    if (!latitude.isFinite || !longitude.isFinite) return 0;
    // Negate longitude because the NOAA algorithm expects
    // positive = WEST (opposite of standard convention where positive = EAST)
    final adjustedLongitude = longitude * -1;

    final date = DateTime.fromMillisecondsSinceEpoch(
      epochSeconds * 1000,
      isUtc: true,
    );
    final jd = calcJD(date.year, date.month, date.day);
    final t = calcTimeJulianCent(jd);

    final noonmin = calcSolNoonUTC(t, adjustedLongitude);
    final tnoon = calcTimeJulianCent(jd + noonmin / 1440.0);

    // First pass approximation
    var eqTime = calcEquationOfTime(tnoon);
    var solarDec = calcSunDeclination(tnoon);
    var hourAngle = calcHourAngleSunset(latitude, solarDec);

    var delta = adjustedLongitude - _radToDeg(hourAngle);
    var timeDiff = 4 * delta;
    var timeUTC = 720 + timeDiff - eqTime;

    // Second pass with fractional day
    final newt = calcTimeJulianCent(
      calcJDFromJulianCent(t) + timeUTC / 1440.0,
    );
    eqTime = calcEquationOfTime(newt);
    solarDec = calcSunDeclination(newt);
    hourAngle = calcHourAngleSunset(latitude, solarDec);
    delta = adjustedLongitude - _radToDeg(hourAngle);
    timeDiff = 4 * delta;
    timeUTC = 720 + timeDiff - eqTime;

    // Normalize to [0, 1440) range
    if (timeUTC >= 1440) timeUTC -= 1440;
    if (timeUTC < 0) timeUTC += 1440;

    if (!timeUTC.isFinite) return 0;
    return timeUTC.round();
  }

  /// Calculate hour angle at sunset
  double calcHourAngleSunset(double latitude, double solarDec) {
    final latRad = _degToRad(latitude);
    final sdRad = _degToRad(solarDec);
    final denom = cos(latRad) * cos(sdRad);
    if (denom == 0) return 0;
    final raw = _cosSunsetAngle / denom - tan(latRad) * tan(sdRad);
    final clamped = raw.clamp(-1.0, 1.0);
    return -acos(clamped);
  }

  /// Calculate hour angle at sunrise
  double calcHourAngleSunrise(double latitude, double solarDec) {
    final latRad = _degToRad(latitude);
    final sdRad = _degToRad(solarDec);
    final denom = cos(latRad) * cos(sdRad);
    if (denom == 0) return 0;
    final raw = _cosSunsetAngle / denom - tan(latRad) * tan(sdRad);
    final clamped = raw.clamp(-1.0, 1.0);
    return acos(clamped);
  }

  /// Calculate sun's declination
  double calcSunDeclination(double jCenturies) {
    final e = calcObliquityCorrection(jCenturies);
    final lambda = calcSunApparentLong(jCenturies);
    final sint = sin(_degToRad(e)) * sin(_degToRad(lambda));
    return _radToDeg(asin(sint));
  }

  /// Calculate sun's apparent longitude
  double calcSunApparentLong(double jCenturies) {
    final o = calcSunTrueLong(jCenturies);
    final omega = 125.04 - 1934.136 * jCenturies;
    return o - 0.00569 - 0.00478 * sin(_degToRad(omega));
  }

  /// Calculate sun's true longitude
  double calcSunTrueLong(double jCenturies) {
    final l0 = calcGeomMeanLongSun(jCenturies);
    final c = calcSunEqOfCenter(jCenturies);
    return l0 + c;
  }

  /// Calculate equation of center for the sun
  double calcSunEqOfCenter(double jCenturies) {
    final m = calcGeomMeanAnomalySun(jCenturies);
    final mrad = _degToRad(m);
    final sinm = sin(mrad);
    final sin2m = sin(mrad + mrad);
    final sin3m = sin(mrad + mrad + mrad);
    return sinm * (1.914602 - jCenturies * (0.004817 + 0.000014 * jCenturies)) +
        sin2m * (0.019993 - 0.000101 * jCenturies) +
        sin3m * 0.000289;
  }

  /// Convert calendar date to Julian Day
  double calcJD(int year, int month, int day) {
    var adjustedYear = year;
    var adjustedMonth = month;
    if (adjustedMonth <= 2) {
      adjustedYear -= 1;
      adjustedMonth += 12;
    }
    final a = (adjustedYear / 100).floorToDouble();
    final b = 2 - a + (a / 4).floorToDouble();
    return (365.25 * (adjustedYear + 4716)).floorToDouble() +
        (30.6001 * (adjustedMonth + 1)).floorToDouble() +
        day +
        b -
        1524.5;
  }

  /// Convert Julian Day to Julian centuries since J2000.0
  double calcTimeJulianCent(double jd) {
    return (jd - 2451545.0) / 36525.0;
  }

  /// Convert Julian centuries to Julian Day
  double calcJDFromJulianCent(double jCenturies) {
    return jCenturies * 36525.0 + 2451545.0;
  }

  /// Calculate mean obliquity of the ecliptic
  double calcMeanObliquityOfEcliptic(double t) {
    final seconds = 21.448 - t * (46.8150 + t * (0.00059 - t * 0.001813));
    return 23.0 + (26.0 + (seconds / 60.0)) / 60.0;
  }

  /// Calculate corrected obliquity of the ecliptic
  double calcObliquityCorrection(double jCenturies) {
    final e0 = calcMeanObliquityOfEcliptic(jCenturies);
    final omega = 125.04 - 1934.136 * jCenturies;
    return e0 + 0.00256 * cos(_degToRad(omega));
  }

  /// Calculate geometric mean longitude of the sun
  double calcGeomMeanLongSun(double jCenturies) {
    var l0 = 280.46646 + jCenturies * (36000.76983 + 0.0003032 * jCenturies);
    while (l0 > 360.0) {
      l0 -= 360.0;
    }
    while (l0 < 0.0) {
      l0 += 360.0;
    }
    return l0;
  }

  /// Calculate eccentricity of Earth's orbit
  double calcEccentricityEarthOrbit(double jCenturies) {
    return 0.016708634 - jCenturies * (0.000042037 + 0.0000001267 * jCenturies);
  }

  /// Calculate geometric mean anomaly of the sun
  double calcGeomMeanAnomalySun(double jCenturies) {
    return 357.52911 + jCenturies * (35999.05029 - 0.0001537 * jCenturies);
  }

  /// Calculate equation of time
  double calcEquationOfTime(double jCenturies) {
    final epsilon = calcObliquityCorrection(jCenturies);
    final l0 = calcGeomMeanLongSun(jCenturies);
    final e = calcEccentricityEarthOrbit(jCenturies);
    final m = calcGeomMeanAnomalySun(jCenturies);

    var y = tan(_degToRad(epsilon) / 2.0);
    y *= y;

    final sin2l0 = sin(2.0 * _degToRad(l0));
    final sinm = sin(_degToRad(m));
    final cos2l0 = cos(2.0 * _degToRad(l0));
    final sin4l0 = sin(4.0 * _degToRad(l0));
    final sin2m = sin(2.0 * _degToRad(m));

    final etime =
        y * sin2l0 -
        2.0 * e * sinm +
        4.0 * e * y * sinm * cos2l0 -
        0.5 * y * y * sin4l0 -
        1.25 * e * e * sin2m;

    return _radToDeg(etime) * 4.0;
  }

  /// Calculate solar noon in UTC
  double calcSolNoonUTC(double jCenturies, double longitude) {
    final tnoon = calcTimeJulianCent(
      calcJDFromJulianCent(jCenturies) + longitude / 360.0,
    );
    var eqTime = calcEquationOfTime(tnoon);
    final solNoonUTC = 720 + (longitude * 4) - eqTime;

    final newt = calcTimeJulianCent(
      calcJDFromJulianCent(jCenturies) - 0.5 + solNoonUTC / 1440.0,
    );
    eqTime = calcEquationOfTime(newt);
    return 720 + (longitude * 4) - eqTime;
  }

  // Helper methods
  double _degToRad(double angleDeg) => angleDeg * pi / 180.0;
  double _radToDeg(double angleRad) => angleRad * 180.0 / pi;

  int _dayOfYear(DateTime date) {
    final start = DateTime.utc(date.year);
    return date.difference(start).inDays + 1;
  }
}
