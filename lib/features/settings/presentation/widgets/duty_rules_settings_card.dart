import 'dart:async';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/inputs/clock_time_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/picker_with_add_input_field.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/airport_filters.dart';
import 'package:simplelog/data/models/airport_row.dart';
import 'package:simplelog/features/airports/application/providers/airport_repository_provider.dart';
import 'package:simplelog/features/airports/presentation/airport_edit_screen.dart';
import 'package:simplelog/features/airports/presentation/widgets/airport_picker_dialog.dart';
import 'package:simplelog/features/settings/presentation/widgets/settings_expandable_info_trailing.dart';
import 'package:simplelog/state/providers/database_provider.dart';
import 'package:simplelog/state/providers/duty_rules_settings_provider.dart';

/// Editable card for duty rules persisted in user settings.
class DutyRulesSettingsCard extends ConsumerStatefulWidget {
  /// Creates the card widget.
  const DutyRulesSettingsCard({
    super.key,
    this.showTitle = true,
    this.initiallyExpanded = false,
  });

  /// Whether the internal expansion tile title should be shown.
  final bool showTitle;

  /// Whether the expansion tile should start opened.
  final bool initiallyExpanded;

  @override
  ConsumerState<DutyRulesSettingsCard> createState() =>
      _DutyRulesSettingsCardState();
}

class _DutyRulesSettingsCardState extends ConsumerState<DutyRulesSettingsCard> {
  final ExpansibleController _expansionController = ExpansibleController();
  final _onBaseController = TextEditingController(
    text: ClockTimeInputField.formatMinutesOfDay(0),
  );
  final _offBaseController = TextEditingController(
    text: ClockTimeInputField.formatMinutesOfDay(0),
  );
  final _dutyEndAllowanceController = TextEditingController(
    text: ClockTimeInputField.formatMinutesOfDay(0),
  );
  final _minimumRestController = TextEditingController(
    text: ClockTimeInputField.formatMinutesOfDay(0),
  );

  DutyRulesSettings? _lastHydrated;
  int? _homeBaseAirportId;
  int _onBaseMinutes = 0;
  int _offBaseMinutes = 0;
  int _dutyEndAllowanceMinutes = 0;
  int _minimumRestMinutes = 0;
  late bool _isExpanded = widget.initiallyExpanded;
  bool _isHydrating = false;
  Timer? _saveDebounce;

  void _setHomeBaseAirportId(int id) {
    setState(() => _homeBaseAirportId = id);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _onBaseController.dispose();
    _offBaseController.dispose();
    _dutyEndAllowanceController.dispose();
    _minimumRestController.dispose();
    _expansionController.dispose();
    super.dispose();
  }

  bool _sameSettings(DutyRulesSettings a, DutyRulesSettings b) {
    return a.crewHomeBaseAirportId == b.crewHomeBaseAirportId &&
        a.reportingTimeOnBaseMinutes == b.reportingTimeOnBaseMinutes &&
        a.reportingTimeOffBaseMinutes == b.reportingTimeOffBaseMinutes &&
        a.dutyEndTimeAllowanceMinutes == b.dutyEndTimeAllowanceMinutes &&
        a.minimumRestTimeMinutes == b.minimumRestTimeMinutes;
  }

  void _hydrateIfNeeded(DutyRulesSettings settings) {
    if (_lastHydrated != null && _sameSettings(_lastHydrated!, settings)) {
      return;
    }
    _isHydrating = true;
    _homeBaseAirportId = settings.crewHomeBaseAirportId;
    _onBaseMinutes = settings.reportingTimeOnBaseMinutes;
    _offBaseMinutes = settings.reportingTimeOffBaseMinutes;
    _dutyEndAllowanceMinutes = settings.dutyEndTimeAllowanceMinutes;
    _minimumRestMinutes = settings.minimumRestTimeMinutes;
    _onBaseController.text = ClockTimeInputField.formatMinutesOfDay(
      _onBaseMinutes,
    );
    _offBaseController.text = ClockTimeInputField.formatMinutesOfDay(
      _offBaseMinutes,
    );
    _dutyEndAllowanceController.text = ClockTimeInputField.formatMinutesOfDay(
      _dutyEndAllowanceMinutes,
    );
    _minimumRestController.text = ClockTimeInputField.formatMinutesOfDay(
      _minimumRestMinutes,
    );
    _lastHydrated = settings;
    _isHydrating = false;
  }

  DutyRulesSettings _draft() {
    return DutyRulesSettings(
      crewHomeBaseAirportId: _homeBaseAirportId,
      reportingTimeOnBaseMinutes: _onBaseMinutes,
      reportingTimeOffBaseMinutes: _offBaseMinutes,
      dutyEndTimeAllowanceMinutes: _dutyEndAllowanceMinutes,
      minimumRestTimeMinutes: _minimumRestMinutes,
    );
  }

  Future<void> _saveNow() async {
    final current = ref.read(dutyRulesSettingsProvider).valueOrNull;
    final next = _draft();
    if (current != null && _sameSettings(current, next)) return;
    await ref.read(dutyRulesSettingsProvider.notifier).setValue(next);
    _lastHydrated = next;
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_saveNow());
    });
  }

  String _airportLabelForId(int? id, List<AirportRow> airports) {
    if (id == null) return 'Not selected';
    for (final row in airports) {
      if (row.airport.id != id) continue;
      final name = (row.airport.name ?? '').trim();
      return name.isEmpty ? row.airport.icao : '${row.airport.icao} - $name';
    }
    return 'Airport ID: $id';
  }

  Future<void> _pickHomeBaseAirport() async {
    final selected = await AirportPickerDialog.show(
      context,
      title: 'Select home base airport',
    );
    if (selected == null) return;
    if (!mounted) return;
    _setHomeBaseAirportId(selected.id);
    await _saveNow();
  }

  Future<void> _createAndSelectHomeBaseAirport() async {
    const placeholder = Airport(
      id: kPlaceholderId,
      icao: '',
      latitude: 0,
      longitude: 0,
      isFavorite: false,
      isLocked: false,
    );
    final result = await showDialog<dynamic>(
      context: context,
      builder: (_) =>
          const AirportEditScreen(item: placeholder, isCreate: true),
    );
    if (!mounted) return;

    final db = ref.read(databaseProvider);
    var airportId = result is int ? result : null;
    if (airportId == null && result != null) {
      final created =
          await (db.select(db.airports)
                ..orderBy([(t) => OrderingTerm.desc(t.id)])
                ..limit(1))
              .getSingleOrNull();
      airportId = created?.id;
    }
    if (airportId == null) return;
    _setHomeBaseAirportId(airportId);
    await _saveNow();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(dutyRulesSettingsProvider);
    final airportsAsync = ref.watch(
      airportsProvider(
        const AirportSearchParams(
          query: '',
          filters: AirportFilters(),
        ),
      ),
    );

    final settings = settingsAsync.valueOrNull ?? const DutyRulesSettings();
    final airports = airportsAsync.valueOrNull ?? const <AirportRow>[];
    _hydrateIfNeeded(settings);
    final l10n = AppLocalizations.of(context)!;

    final hasLoadError = settingsAsync.hasError || airportsAsync.hasError;

    return Card(
      child: ExpansionTile(
        initiallyExpanded: widget.initiallyExpanded,
        title: widget.showTitle
            ? Text(l10n.autoUi023)
            : const SizedBox.shrink(),
        controller: _expansionController,
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        trailing: SettingsExpandableInfoTrailing(
          controller: _expansionController,
          isExpanded: _isExpanded,
          helpTitle: l10n.settingsDutyRulesHelpTitle,
          helpMessage: l10n.settingsDutyRulesHelpBody,
        ),
        tilePadding: widget.showTitle
            ? null
            : const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        children: [
          if (settingsAsync.isLoading || airportsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(),
            ),
          if (hasLoadError)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.autoUi064),
              ),
            ),
          PickerWithAddInputField(
            label: l10n.autoUi016,
            valueText: _airportLabelForId(_homeBaseAirportId, airports),
            onTap: _pickHomeBaseAirport,
            onAdd: _createAndSelectHomeBaseAirport,
            addTooltip: 'Add airport',
          ),
          const SizedBox(height: 8),
          ClockTimeInputField(
            controller: _onBaseController,
            label: l10n.autoUi050,
            fallbackMinutes: _onBaseMinutes,
            onChangedMinutes: (minutes) {
              if (_isHydrating) return;
              _onBaseMinutes = minutes;
              _scheduleSave();
            },
          ),
          const SizedBox(height: 8),
          ClockTimeInputField(
            controller: _offBaseController,
            label: l10n.autoUi049,
            fallbackMinutes: _offBaseMinutes,
            onChangedMinutes: (minutes) {
              if (_isHydrating) return;
              _offBaseMinutes = minutes;
              _scheduleSave();
            },
          ),
          const SizedBox(height: 8),
          ClockTimeInputField(
            controller: _dutyEndAllowanceController,
            label: l10n.autoUi025,
            fallbackMinutes: _dutyEndAllowanceMinutes,
            onChangedMinutes: (minutes) {
              if (_isHydrating) return;
              _dutyEndAllowanceMinutes = minutes;
              _scheduleSave();
            },
          ),
          const SizedBox(height: 8),
          ClockTimeInputField(
            controller: _minimumRestController,
            label: l10n.autoUi041,
            fallbackMinutes: _minimumRestMinutes,
            onChangedMinutes: (minutes) {
              if (_isHydrating) return;
              _minimumRestMinutes = minutes;
              _scheduleSave();
            },
          ),
        ],
      ),
    );
  }
}
