import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/state/providers/flight_form_settings_provider.dart';

/// Displays and persists the takeoff/landing times preference.
///
/// Reads the current boolean value from [flightFormTakeoffLandingLogProvider]
/// and writes changes back when toggled by the user.
class FlightTakeoffLandingSwitch extends ConsumerWidget {
  /// Creates the switch tile.
  ///
  /// [contentPadding] lets callers align this tile with surrounding controls.
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
        title: Text(AppLocalizations.of(context)!.autoUi039),
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
      error: (_, _) => Text(AppLocalizations.of(context)!.autoUi065),
    );
  }
}
