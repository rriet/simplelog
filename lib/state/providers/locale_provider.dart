import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Stores the user-selected locale override. `null` means system locale.
final localeProvider = StateProvider<Locale?>((ref) => null);
