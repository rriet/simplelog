import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplelog/data/import/simplelog_import_options.dart';

class SimpleLogImportOptionsDialog extends StatefulWidget {
  const SimpleLogImportOptionsDialog({
    super.key,
    required this.fileName,
    this.initial = const SimpleLogImportOptions(),
  });

  final String fileName;
  final SimpleLogImportOptions initial;

  static Future<SimpleLogImportOptions?> show(
    BuildContext context, {
    required String fileName,
  }) {
    return showDialog<SimpleLogImportOptions>(
      context: context,
      builder: (context) =>
          SimpleLogImportOptionsDialog(fileName: fileName),
    );
  }

  @override
  State<SimpleLogImportOptionsDialog> createState() =>
      _SimpleLogImportOptionsDialogState();
}

class _SimpleLogImportOptionsDialogState
    extends State<SimpleLogImportOptionsDialog> {
  late bool _recalcNight;
  late bool _recalcTotal;
  late bool _recalcTakeoffLanding;
  late bool _recalcCrossCountry;
  late bool _recalcInstrument;
  late MergeStrategy _airportStrategy;
  late MergeStrategy _crewStrategy;
  late MergeStrategy _aircraftStrategy;
  late MergeStrategy _aircraftTypeStrategy;

  late final TextEditingController _crossCountryThresholdController;
  late final TextEditingController _instrumentPercentController;
  late final TextEditingController _instrumentMinController;
  late final TextEditingController _instrumentSubtractController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _recalcNight = initial.recalculateNightTime;
    _recalcTotal = initial.recalculateTotalTime;
    _recalcTakeoffLanding = initial.recalculateTakeoffLanding;
    _recalcCrossCountry = initial.recalculateCrossCountry;
    _recalcInstrument = initial.recalculateInstrument;
    _airportStrategy = initial.airportStrategy;
    _crewStrategy = initial.crewStrategy;
    _aircraftStrategy = initial.aircraftStrategy;
    _aircraftTypeStrategy = initial.aircraftTypeStrategy;

    _crossCountryThresholdController =
        TextEditingController(text: initial.crossCountryThresholdNm.toString());
    _instrumentPercentController =
        TextEditingController(text: initial.instrumentPercent.toString());
    _instrumentMinController =
        TextEditingController(text: initial.instrumentMinimumMinutes.toString());
    _instrumentSubtractController =
        TextEditingController(text: initial.instrumentSubtractMinutes.toString());
  }

  @override
  void dispose() {
    _crossCountryThresholdController.dispose();
    _instrumentPercentController.dispose();
    _instrumentMinController.dispose();
    _instrumentSubtractController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return AlertDialog(
      title: const Text('Import Options'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File: ${widget.fileName}'),
              const SizedBox(height: 8),
              const Text(
                'Defaults: No recalculation. Existing data is kept.',
              ),
              const SizedBox(height: 16),
              Text('Recalculate', style: titleStyle),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Night time'),
                value: _recalcNight,
                onChanged: (value) =>
                    setState(() => _recalcNight = value ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Total time (updates PIC/SIC/etc)'),
                value: _recalcTotal,
                onChanged: (value) =>
                    setState(() => _recalcTotal = value ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Takeoff / Landing day-night'),
                value: _recalcTakeoffLanding,
                onChanged: (value) => setState(
                    () => _recalcTakeoffLanding = value ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Cross-country'),
                value: _recalcCrossCountry,
                onChanged: (value) => setState(
                    () => _recalcCrossCountry = value ?? false),
              ),
              _NumberField(
                label: 'Cross-country threshold (NM)',
                controller: _crossCountryThresholdController,
                enabled: _recalcCrossCountry,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Instrument time'),
                value: _recalcInstrument,
                onChanged: (value) =>
                    setState(() => _recalcInstrument = value ?? false),
              ),
              _NumberField(
                label: 'Instrument percent (0-100)',
                controller: _instrumentPercentController,
                enabled: _recalcInstrument,
              ),
              _NumberField(
                label: 'Instrument minimum minutes',
                controller: _instrumentMinController,
                enabled: _recalcInstrument,
              ),
              _NumberField(
                label: 'Instrument subtract minutes',
                controller: _instrumentSubtractController,
                enabled: _recalcInstrument,
              ),
              const SizedBox(height: 12),
              Text('Merge strategy', style: titleStyle),
              const SizedBox(height: 8),
              _StrategyDropdown(
                label: 'Airports',
                value: _airportStrategy,
                onChanged: (value) =>
                    setState(() => _airportStrategy = value),
              ),
              _StrategyDropdown(
                label: 'Crew',
                value: _crewStrategy,
                onChanged: (value) => setState(() => _crewStrategy = value),
              ),
              _StrategyDropdown(
                label: 'Aircraft',
                value: _aircraftStrategy,
                onChanged: (value) =>
                    setState(() => _aircraftStrategy = value),
              ),
              _StrategyDropdown(
                label: 'Aircraft Type',
                value: _aircraftTypeStrategy,
                onChanged: (value) =>
                    setState(() => _aircraftTypeStrategy = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_buildOptions()),
          child: const Text('Import'),
        ),
      ],
    );
  }

  SimpleLogImportOptions _buildOptions() {
    return SimpleLogImportOptions(
      recalculateNightTime: _recalcNight,
      recalculateTotalTime: _recalcTotal,
      recalculateTakeoffLanding: _recalcTakeoffLanding,
      recalculateCrossCountry: _recalcCrossCountry,
      crossCountryThresholdNm:
          int.tryParse(_crossCountryThresholdController.text.trim()) ?? 50,
      recalculateInstrument: _recalcInstrument,
      instrumentPercent:
          int.tryParse(_instrumentPercentController.text.trim()) ?? 0,
      instrumentMinimumMinutes:
          int.tryParse(_instrumentMinController.text.trim()) ?? 0,
      instrumentSubtractMinutes:
          int.tryParse(_instrumentSubtractController.text.trim()) ?? 0,
      airportStrategy: _airportStrategy,
      crewStrategy: _crewStrategy,
      aircraftStrategy: _aircraftStrategy,
      aircraftTypeStrategy: _aircraftTypeStrategy,
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    required this.enabled,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _StrategyDropdown extends StatelessWidget {
  const _StrategyDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final MergeStrategy value;
  final ValueChanged<MergeStrategy> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<MergeStrategy>(
        key: ValueKey(value),
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(
            value: MergeStrategy.keep,
            child: Text('Keep'),
          ),
          DropdownMenuItem(
            value: MergeStrategy.override,
            child: Text('Override'),
          ),
          DropdownMenuItem(
            value: MergeStrategy.mix,
            child: Text('Mix'),
          ),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}
