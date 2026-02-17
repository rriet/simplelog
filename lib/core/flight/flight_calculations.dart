import 'dart:math';

/// Optimized FlightCalculations class with performance improvements
class FlightCalculations {
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

    nightTimeMinutes = _calculatePreciseNightTime();
  }

  final double latDep;
  final double longDep;
  final double latArr;
  final double longArr;
  final int depTimeEpochSeconds;
  final int arrTimeEpochSeconds;

  late final int sunriseDep;
  late final int sunsetDep;
  late final int sunriseArr;
  late final int sunsetArr;
  late final int flightTimeMinutes;
  late final double flightDistanceNm;
  late final bool dayTakeOff;
  late final bool dayLanding;
  late final int nightTimeMinutes;

  // Cached constants for performance
  static const double _sunsetAngleDeg = 90.833;
  static final double _cosSunsetAngle = cos(_sunsetAngleDeg * pi / 180.0);

  String get sunriseTime => _formatMinutes(sunriseDep);
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
      final isArcticSummer = latitude > arcticCircle && 
                             doy > 79 && doy < 267;
      
      // Antarctic summer: ~Sep 23 to ~Mar 21 (spans new year)
      final isAntarcticSummer = latitude < antarcticCircle && 
                                (doy < 83 || doy > 263);
      
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
    final a = sin(dLat / 2) * sin(dLat / 2) +
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
    final x = cos(latDepR) * sin(latArrR) -
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
    
    var longNext = longDepR +
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

  /// OPTIMIZED: Calculate precise night time with adaptive step size
  int _calculatePreciseNightTime() {
    // Handle edge case: zero or negative flight time
    if (flightTimeMinutes <= 0) {
      return dayTakeOff ? 0 : 1;
    }

    var nightTime = 0;

    final depTime = DateTime.fromMillisecondsSinceEpoch(
      depTimeEpochSeconds * 1000,
      isUtc: true,
    );
    var latNow = latDep;
    var longNow = longDep;
    final milesPerMinute = flightDistanceNm / flightTimeMinutes;
    var isDayNow = dayTakeOff;

    // Adaptive step size for performance
    int step = 5; // Start with 5-minute increments
    int lastTransitionMinute = -100;
    double cachedBearing = flightBearing(latNow, longNow, latArr, longArr);
    int bearingUpdateCounter = 0;

    for (int minute = 0; minute < flightTimeMinutes;) {
      final currentTime = depTime.add(Duration(minutes: minute));

      // Update bearing every 10 minutes (it changes slowly)
      if (bearingUpdateCounter % 10 == 0) {
        cachedBearing = flightBearing(latNow, longNow, latArr, longArr);
      }
      bearingUpdateCounter++;

      // Calculate position
      final stepUsed = min(step, flightTimeMinutes - minute);
      final distance = milesPerMinute * stepUsed;
      final (newLat, newLon) = flightNextWaypoint(
        latNow,
        longNow,
        cachedBearing,
        distance,
      );
      latNow = newLat;
      longNow = newLon;

      // Check day/night status
      final epochSeconds = currentTime.millisecondsSinceEpoch ~/ 1000;
      final sunriseNow = calcSunriseUTC(epochSeconds, latNow, longNow);
      final sunsetNow = calcSunsetUTC(epochSeconds, latNow, longNow);
      final dayNow = isDay(epochSeconds, sunriseNow, sunsetNow, latNow);

      // If transition detected and we're in coarse mode, switch to fine mode
      if (isDayNow != dayNow && step > 1) {
        // Backtrack and recalculate with 1-minute precision
        minute -= step;
        step = 1;
        lastTransitionMinute = minute;
        bearingUpdateCounter = 0;
        
        // Recalculate position from departure
        latNow = latDep;
        longNow = longDep;
        for (int m = 1; m <= minute; m++) {
          final bearing = flightBearing(latNow, longNow, latArr, longArr);
          final (lat, lon) = flightNextWaypoint(
            latNow,
            longNow,
            bearing,
            milesPerMinute,
          );
          latNow = lat;
          longNow = lon;
        }
        continue;
      }

      // Count night minutes
      if (!dayNow && minute > 0) {
        nightTime += stepUsed;
      }

      // Return to coarse stepping after transition (120 minutes later)
      if (step == 1 && minute > lastTransitionMinute + 120) {
        step = 5;
      }

      isDayNow = dayNow;
      minute += stepUsed;
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
    longitude = longitude * -1;
    
    final date = DateTime.fromMillisecondsSinceEpoch(
      epochSeconds * 1000,
      isUtc: true,
    );
    final jd = calcJD(date.year, date.month, date.day);
    final t = calcTimeJulianCent(jd);

    final noonmin = calcSolNoonUTC(t, longitude);
    final tnoon = calcTimeJulianCent(jd + noonmin / 1440.0);

    // First pass approximation
    var eqTime = calcEquationOfTime(tnoon);
    var solarDec = calcSunDeclination(tnoon);
    var hourAngle = calcHourAngleSunrise(latitude, solarDec);

    var delta = longitude - _radToDeg(hourAngle);
    var timeDiff = 4 * delta;
    var timeUTC = 720 + timeDiff - eqTime;

    // Second pass with fractional day
    final newt = calcTimeJulianCent(
      calcJDFromJulianCent(t) + timeUTC / 1440.0,
    );
    eqTime = calcEquationOfTime(newt);
    solarDec = calcSunDeclination(newt);
    hourAngle = calcHourAngleSunrise(latitude, solarDec);
    delta = longitude - _radToDeg(hourAngle);
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
    longitude = longitude * -1;
    
    final date = DateTime.fromMillisecondsSinceEpoch(
      epochSeconds * 1000,
      isUtc: true,
    );
    final jd = calcJD(date.year, date.month, date.day);
    final t = calcTimeJulianCent(jd);

    final noonmin = calcSolNoonUTC(t, longitude);
    final tnoon = calcTimeJulianCent(jd + noonmin / 1440.0);

    // First pass approximation
    var eqTime = calcEquationOfTime(tnoon);
    var solarDec = calcSunDeclination(tnoon);
    var hourAngle = calcHourAngleSunset(latitude, solarDec);

    var delta = longitude - _radToDeg(hourAngle);
    var timeDiff = 4 * delta;
    var timeUTC = 720 + timeDiff - eqTime;

    // Second pass with fractional day
    final newt = calcTimeJulianCent(
      calcJDFromJulianCent(t) + timeUTC / 1440.0,
    );
    eqTime = calcEquationOfTime(newt);
    solarDec = calcSunDeclination(newt);
    hourAngle = calcHourAngleSunset(latitude, solarDec);
    delta = longitude - _radToDeg(hourAngle);
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
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floorToDouble();
    final b = 2 - a + (a / 4).floorToDouble();
    return (365.25 * (year + 4716)).floorToDouble() +
        (30.6001 * (month + 1)).floorToDouble() +
        day + b - 1524.5;
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
    return 0.016708634 -
        jCenturies * (0.000042037 + 0.0000001267 * jCenturies);
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

    final etime = y * sin2l0 -
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
    var solNoonUTC = 720 + (longitude * 4) - eqTime;

    final newt = calcTimeJulianCent(
      calcJDFromJulianCent(jCenturies) - 0.5 + solNoonUTC / 1440.0,
    );
    eqTime = calcEquationOfTime(newt);
    solNoonUTC = 720 + (longitude * 4) - eqTime;
    return solNoonUTC;
  }

  // Helper methods
  double _degToRad(double angleDeg) => angleDeg * pi / 180.0;
  double _radToDeg(double angleRad) => angleRad * 180.0 / pi;

  int _dayOfYear(DateTime date) {
    final start = DateTime.utc(date.year, 1, 1);
    return date.difference(start).inDays + 1;
  }
}
