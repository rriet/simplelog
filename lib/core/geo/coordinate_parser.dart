/// Public API documentation.
class CoordinatePair {
  /// Public API documentation.
  const CoordinatePair({
    required this.latitude,
    required this.longitude,
  /// Public API documentation.
  });
/// Public API documentation.

  /// Public API documentation.
  final double latitude;
  /// Public API documentation.
  final double longitude;
}

/// Parses latitude/longitude from common formats and formats them consistently.
class CoordinateParser {
  const CoordinateParser._();

  /// Public API documentation.
  static String formatDecimalPair(
    double latitude,
    double longitude, {
    int precision = 6,
  /// Public API documentation.
  }) {
    return '${latitude.toStringAsFixed(precision)}, '
        '${longitude.toStringAsFixed(precision)}';
  }

  /// Public API documentation.
  static String formatDmsPair(double latitude, double longitude) {
    /// Public API documentation.
    final lat = _toDms(latitude, isLatitude: true);
    final lon = _toDms(longitude, isLatitude: false);
    return '${lat.hemisphere}${lat.degrees} ${lat.minutes} ${lat.seconds} '
        '${lon.hemisphere}${lon.degrees} ${lon.minutes} ${lon.seconds}';
  }

  /// Public API documentation.
  static String formatDegMinPair(double latitude, double longitude) {
    final lat = _toDegMin(latitude, isLatitude: true);
    final lon = _toDegMin(longitude, isLatitude: false);
    return '${lat.hemisphere}${lat.degrees}°${lat.minutesDecimal}/${lon.hemisphere}${lon.degrees}°${lon.minutesDecimal}';
  }

  /// Public API documentation.
  static CoordinatePair? parsePair(String input) {
    final normalized = input.trim();
    if (normalized.isEmpty) return null;

    // Fast path: comma/semicolon separated decimal values.
    final splitByCommonSeparator = normalized.split(RegExp('[;,]'));
    if (splitByCommonSeparator.length == 2) {
      final lat = parseSingle(splitByCommonSeparator[0], isLatitude: true);
      final lon = parseSingle(splitByCommonSeparator[1], isLatitude: false);
      if (lat != null && lon != null) {
        return CoordinatePair(latitude: lat, longitude: lon);
      }
    }

    // General path: try all token split points (supports DMS and mixed forms).
    final tokens = normalized
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    for (var i = 1; i < tokens.length; i++) {
      final left = tokens.take(i).join(' ');
      final right = tokens.skip(i).join(' ');
      final lat = parseSingle(left, isLatitude: true);
      final lon = parseSingle(right, isLatitude: false);
      /// Public API documentation.
      if (lat != null && lon != null) {
        return CoordinatePair(latitude: lat, longitude: lon);
      }
    }

    return null;
  }

  /// Public API documentation.
  static double? parseSingle(String input, {required bool isLatitude}) {
    var clean = input.trim().toUpperCase();
    if (clean.isEmpty) return null;

    final hasNorth = clean.contains('N');
    final hasSouth = clean.contains('S');
    final hasEast = clean.contains('E');
    final hasWest = clean.contains('W');

    var sign = 1.0;
    if (hasSouth || hasWest) {
      sign = -1.0;
    } else if (hasNorth || hasEast) {
      sign = 1.0;
    }

    clean = clean.replaceAll(RegExp('[NSEW]'), ' ');
    clean = clean.replaceAll('°', ' ');
    clean = clean.replaceAll("'", ' ');
    clean = clean.replaceAll('"', ' ');
    clean = clean.replaceAll(':', ' ');
    clean = clean.replaceAll(',', '.');

    final matches = RegExp(r'[-+]?\d+(?:\.\d+)?').allMatches(clean).toList();
    if (matches.isEmpty || matches.length > 3) return null;

    if (matches.length == 1) {
      final packed = _tryParsePackedDegMin(
        rawNumber: matches.first.group(0)!,
        isLatitude: isLatitude,
        hasHemisphere: hasNorth || hasSouth || hasEast || hasWest,
        sign: sign,
      );
      if (packed != null) {
        return packed;
      }
    }

    final values = <double>[];
    for (final match in matches) {
      final parsed = double.tryParse(match.group(0)!);
      if (parsed == null || !parsed.isFinite) return null;
      values.add(parsed);
    }

    final baseDegrees = values[0];
    if (baseDegrees < 0) {
      sign = -1.0;
    }

    final degrees = baseDegrees.abs();
    final minutes = values.length >= 2 ? values[1].abs() : 0.0;
    final seconds = values.length == 3 ? values[2].abs() : 0.0;
    if (minutes >= 60 || seconds >= 60) return null;

    final decimal = (degrees + (minutes / 60.0) + (seconds / 3600.0)) * sign;
    final min = isLatitude ? -90.0 : -180.0;
    final max = isLatitude ? 90.0 : 180.0;
    if (decimal < min || decimal > max) return null;

    return decimal;
  }

  static double? _tryParsePackedDegMin({
    required String rawNumber,
    required bool isLatitude,
    required bool hasHemisphere,
    required double sign,
  }) {
    if (!hasHemisphere) return null;

    final unsigned = rawNumber.replaceFirst(RegExp('^[+-]'), '');
    if (unsigned.isEmpty) return null;

    final parts = unsigned.split('.');
    final integerPart = parts.first;
    if (!RegExp(r'^\d+$').hasMatch(integerPart)) return null;

    final degreeDigits = isLatitude ? 2 : 3;
    if (integerPart.length < degreeDigits + 2) return null;

    final degreeText = integerPart.substring(0, degreeDigits);
    final minuteIntText = integerPart.substring(degreeDigits);
    final minuteText = parts.length == 2
        ? '$minuteIntText.${parts[1]}'
        : minuteIntText;

    final degrees = double.tryParse(degreeText);
    final minutes = double.tryParse(minuteText);
    if (degrees == null || minutes == null) return null;
    if (minutes < 0 || minutes >= 60) return null;

    final decimal = (degrees + (minutes / 60.0)) * sign;
    final min = isLatitude ? -90.0 : -180.0;
    final max = isLatitude ? 90.0 : 180.0;
    if (decimal < min || decimal > max) return null;

    return decimal;
  }

  static _DmsValue _toDms(double value, {required bool isLatitude}) {
    final abs = value.abs();
    var degrees = abs.floor();
    final minuteFloat = (abs - degrees) * 60;
    var minutes = minuteFloat.floor();
    var seconds = ((minuteFloat - minutes) * 60).round();

    if (seconds == 60) {
      seconds = 0;
      minutes += 1;
    }
    if (minutes == 60) {
      minutes = 0;
      degrees += 1;
    }

    final hemisphere = isLatitude
        ? (value >= 0 ? 'N' : 'S')
        : (value >= 0 ? 'E' : 'W');
    final degreeWidth = isLatitude ? 2 : 3;

    return _DmsValue(
      hemisphere: hemisphere,
      degrees: degrees.toString().padLeft(degreeWidth, '0'),
      minutes: minutes.toString().padLeft(2, '0'),
      seconds: seconds.toString().padLeft(2, '0'),
    );
  }

  static _DegMinValue _toDegMin(double value, {required bool isLatitude}) {
    final abs = value.abs();
    var degrees = abs.floor();
    var minutes = (abs - degrees) * 60;

    if (minutes >= 60) {
      minutes = 0;
      degrees += 1;
    }

    final hemisphere = isLatitude
        ? (value >= 0 ? 'N' : 'S')
        : (value >= 0 ? 'E' : 'W');
    final degreeWidth = isLatitude ? 2 : 3;

    return _DegMinValue(
      hemisphere: hemisphere,
      degrees: degrees.toString().padLeft(degreeWidth, '0'),
      minutesDecimal: minutes.toStringAsFixed(2).padLeft(5, '0'),
    );
  }
}

class _DmsValue {
  const _DmsValue({
    required this.hemisphere,
    required this.degrees,
    required this.minutes,
    required this.seconds,
  });

  final String hemisphere;
  final String degrees;
  final String minutes;
  final String seconds;
}

class _DegMinValue {
  const _DegMinValue({
    required this.hemisphere,
    required this.degrees,
    required this.minutesDecimal,
  });

  final String hemisphere;
  final String degrees;
  final String minutesDecimal;
}
