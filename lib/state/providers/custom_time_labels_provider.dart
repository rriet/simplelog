import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _customTimeLabelsKey = 'custom_time_labels';

class CustomTimeLabels {
  const CustomTimeLabels({
    this.custom1 = 'Custom 1',
    this.custom2 = 'Custom 2',
    this.custom3 = 'Custom 3',
    this.custom4 = 'Custom 4',
  });

  final String custom1;
  final String custom2;
  final String custom3;
  final String custom4;

  CustomTimeLabels copyWith({
    String? custom1,
    String? custom2,
    String? custom3,
    String? custom4,
  }) {
    return CustomTimeLabels(
      custom1: custom1 ?? this.custom1,
      custom2: custom2 ?? this.custom2,
      custom3: custom3 ?? this.custom3,
      custom4: custom4 ?? this.custom4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'custom1': custom1,
      'custom2': custom2,
      'custom3': custom3,
      'custom4': custom4,
    };
  }

  static CustomTimeLabels fromJson(String? raw) {
    if (raw == null || raw.isEmpty) return const CustomTimeLabels();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return const CustomTimeLabels();
    return CustomTimeLabels(
      custom1: _clean(decoded['custom1'], 'Custom 1'),
      custom2: _clean(decoded['custom2'], 'Custom 2'),
      custom3: _clean(decoded['custom3'], 'Custom 3'),
      custom4: _clean(decoded['custom4'], 'Custom 4'),
    );
  }

  static String _clean(dynamic value, String fallback) {
    final text = (value as String? ?? '').trim();
    return text.isEmpty ? fallback : text;
  }
}

class CustomTimeLabelsNotifier extends AsyncNotifier<CustomTimeLabels> {
  @override
  Future<CustomTimeLabels> build() async {
    final prefs = await SharedPreferences.getInstance();
    return CustomTimeLabels.fromJson(prefs.getString(_customTimeLabelsKey));
  }

  Future<void> setLabels(CustomTimeLabels value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customTimeLabelsKey, jsonEncode(value.toJson()));
    state = AsyncData(value);
  }
}

final customTimeLabelsProvider =
    AsyncNotifierProvider<CustomTimeLabelsNotifier, CustomTimeLabels>(
  CustomTimeLabelsNotifier.new,
);
