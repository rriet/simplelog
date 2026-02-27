import 'dart:convert';
import 'dart:typed_data';

/// Endorsement information attached to a signed logbook entry.
class EndorsementData {
  /// Creates endorsement details.
  const EndorsementData({
    required this.name,
    required this.certificate,
    required this.expiry,
    required this.type,
    this.signatureImage,
  });

  /// Endorser full name.
  final String name;

  /// Certificate number.
  final String certificate;

  /// Expiry date string in `yyyy-MM-dd` format.
  final String expiry;

  /// Certificate or endorsement type.
  final String type;

  /// Signature image bytes.
  final Uint8List? signatureImage;

  /// Returns true when all metadata and signature are empty.
  bool get isEmpty {
    return name.trim().isEmpty &&
        certificate.trim().isEmpty &&
        expiry.trim().isEmpty &&
        type.trim().isEmpty &&
        (signatureImage == null || signatureImage!.isEmpty);
  }

  /// Returns true when the entry has an endorsement signature.
  bool get hasSignature => signatureImage != null && signatureImage!.isNotEmpty;

  /// Serializes only metadata to JSON.
  String toJsonString() {
    return jsonEncode({
      'name': name.trim(),
      'certificate': certificate.trim(),
      'expiry': expiry.trim(),
      'type': type.trim(),
    });
  }

  /// Parses metadata JSON and attaches the optional signature image.
  static EndorsementData? fromJsonString(
    String? json, {
    Uint8List? signatureImage,
  }) {
    final raw = json?.trim();
    if (raw == null || raw.isEmpty) {
      if (signatureImage == null || signatureImage.isEmpty) {
        return null;
      }
      return EndorsementData(
        name: '',
        certificate: '',
        expiry: '',
        type: '',
        signatureImage: signatureImage,
      );
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return EndorsementData(
        name: (decoded['name'] as String?) ?? '',
        certificate: (decoded['certificate'] as String?) ?? '',
        expiry: (decoded['expiry'] as String?) ?? '',
        type: (decoded['type'] as String?) ?? '',
        signatureImage: signatureImage,
      );
    } on Object {
      return null;
    }
  }
}
