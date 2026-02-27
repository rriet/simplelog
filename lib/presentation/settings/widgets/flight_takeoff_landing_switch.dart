import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/providers/flight_form_settings_provider.dart';

/// Public API documentation.
class FlightTakeoffLandingSwitch extends ConsumerWidget {
  /// Public API documentation.
  const FlightTakeoffLandingSwitch({
    super.key,
    this.contentPadding,
  });

  /// Optional tile content padding.
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(flightFormTakeoffLandingLogProvider);
    return enabled.when(
      data: (value) => SwitchListTile(
        contentPadding: contentPadding ?? EdgeInsets.zero,
        title: const Text('Log takeoff and landing times'),
        value: value,
        onChanged: (next) {
          unawaited(
            ref
                .read(flightFormTakeoffLandingLogProvider.notifier)
                .setValue(
                  enabled: next,
                ),
          );
        },
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const Text('Unable to load option'),
    );
  }
}
