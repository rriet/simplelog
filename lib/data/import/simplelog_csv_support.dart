/// Shared helpers for CSV-based imports.
class SimpleLogCsvSupport {
  /// Legacy SimpleLog CSV header used for format detection.
  static const simpleLogOldHeader =
      '"Date (DD/MM/YYYY)","Departure Time (HH:MM)","Arrival Time (HH:MM)","Departure Epoch","Arrival Epoch","Departure Icao","Departure Iata","Departure Airport Name","Departure City","Departure Country","Departure Latitude","Departure Longitude","Arrival Icao","Arrival Iata","Arrival Airport Name","Arrival City","Arrival Country","Arrival Latitude","Arrival Longitude","Aircraft Registration","Aircraft MTOW","Aircraft Simulator","Model Make & Model","Model Group","Model Engine Type","Model MTOW","Model Multi Engine","Model Multi Pilot","Model EFIS","Model Seaplane","PIC Name","PIC Email","PIC Phone","PIC Comments","SIC Name","SIC Email","SIC Phone","SIC Comments","Pilot Function","Remarks","Private notes","Takeoff day","Takeoff night","Landing day","Landing night","IFR Approaches","Approach Type","IFR Minutes","Night Minutes","Corss country Minutes","PIC Minutes","PICUS Minutes","SIC Minutes","Dual Minutes","Instructor Minutes","Simulator Minutes","Custom Time 1 Minutes","Custom Time 2 Minutes","Custom Time 3 Minutes","Custom Time 4 Minutes","Total Minutes"';

  /// Parses a CSV payload while respecting quoted fields.
  static List<List<String>> parseCsv(String content) {
    final rows = <List<String>>[];
    final buffer = StringBuffer();
    var row = <String>[];
    var inQuotes = false;

    for (var i = 0; i < content.length; i += 1) {
      final char = content[i];
      if (char == '"') {
        final next = i + 1 < content.length ? content[i + 1] : '';
        if (inQuotes && next == '"') {
          buffer.write('"');
          i += 1;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }
      if (char == ',' && !inQuotes) {
        row.add(buffer.toString());
        buffer.clear();
        continue;
      }
      if ((char == '\n' || char == '\r') && !inQuotes) {
        if (char == '\r' && i + 1 < content.length && content[i + 1] == '\n') {
          i += 1;
        }
        row.add(buffer.toString());
        buffer.clear();
        if (row.any((value) => value.trim().isNotEmpty)) {
          rows.add(row);
        }
        row = <String>[];
        continue;
      }
      buffer.write(char);
    }

    if (buffer.isNotEmpty || row.isNotEmpty) {
      row.add(buffer.toString());
      if (row.any((value) => value.trim().isNotEmpty)) {
        rows.add(row);
      }
    }
    return rows;
  }

  /// Normalizes a CSV header for format detection.
  static String normalizeHeader(String header) {
    return header.replaceAll('"', '').replaceAll(' ', '');
  }

  /// Removes quote wrappers and surrounding whitespace.
  static String clean(String value) => value.replaceAll('"', '').trim();
}
