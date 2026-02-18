import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/state/providers/flight_form_settings_provider.dart';

class FlightTakeoffLandingSwitch extends ConsumerWidget {
  const FlightTakeoffLandingSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(flightFormTakeoffLandingLogProvider);
    return enabled.when(
      data: (value) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Log takeoff and landing times'),
        value: value,
        onChanged: (next) {
          ref.read(flightFormTakeoffLandingLogProvider.notifier).setValue(next);
        },
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Unable to load option'),
    );
  }
}

