import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/features/dashboard/application/providers/dashboard_providers.dart';
import 'package:simplelog/features/dashboard/domain/dashboard_models.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_repository_provider.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_year_list.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';

/// High-level overview with recent flight and duty limits visualized in cards.
class DashboardScreen extends ConsumerWidget {
  /// Creates the dashboard screen.
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cardsAsync = ref.watch(dashboardCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => unawaited(
              showDialog<void>(
                context: context,
                builder: (_) => const _DashboardSetupDialog(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: cardsAsync.when(
              data: (cards) {
                if (cards.isEmpty) {
                  return Center(child: Text(l10n.dashboardNoActiveRules));
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1100
                        ? 3
                        : constraints.maxWidth >= 760
                        ? 2
                        : 1;
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.45,
                      ),
                      itemCount: cards.length,
                      itemBuilder: (context, index) =>
                          _RuleCard(card: cards[index]),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('${l10n.errorLabel}: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends ConsumerWidget {
  const _RuleCard({required this.card});

  final DashboardRuleCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(dashboardRepositoryProvider);
    final color = switch (card.status) {
      LimitCardStatus.green => Colors.green,
      LimitCardStatus.yellow => Colors.amber,
      LimitCardStatus.red => Colors.red,
    };
    final progress = card.limitValue <= 0
        ? 0.0
        : (card.currentValue / card.limitValue).clamp(0.0, 1.2);
    final valueLabel = _formatValueByUnit(
      card.currentValue,
      card.rule.limitUnit,
      l10n,
    );
    final limitLabel = _formatValueByUnit(
      card.limitValue,
      card.rule.limitUnit,
      l10n,
    );
    final remainingAbsLabel = _formatValueByUnit(
      card.remainingValue.abs(),
      card.rule.limitUnit,
      l10n,
    );
    final dateFormat = DateFormat("dd MMM yyyy HH:mm 'UTC'");
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => unawaited(
          showDialog<void>(
            context: context,
            builder: (_) => _RuleDetailsDialog(
              ruleName: card.rule.ruleName,
              ruleMetric: card.rule.metric,
              detailsWindowStart: card.windowStart,
              detailsWindowEnd: card.windowEnd,
              dataFuture: repo.loadRuleDetails(card.rule),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.rule.ruleName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress <= 1 ? progress : 1,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              const SizedBox(height: 8),
              Text(
                '$valueLabel / $limitLabel',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                card.rule.ruleType == 'maximum'
                    ? (card.remainingValue >= 0
                          ? '$remainingAbsLabel '
                                '${l10n.dashboardRemainingSuffix}'
                          : '$remainingAbsLabel '
                                '${l10n.dashboardOverLimitSuffix}')
                    : (card.remainingValue >= 0
                          ? '$remainingAbsLabel '
                                '${l10n.dashboardAboveMinimumSuffix}'
                          : '$remainingAbsLabel '
                                '${l10n.dashboardBelowMinimumSuffix}'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${dateFormat.format(card.windowStart.toUtc())} - '
                '${dateFormat.format(card.windowEnd.toUtc())}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatValueByUnit(double value, String unit, AppLocalizations l10n) {
    final normalizedUnit = unit.trim().toLowerCase();
    if (normalizedUnit == 'hours') {
      return _formatMinutesAsHourMinute((value * 60).round());
    }
    if (normalizedUnit == 'minutes') {
      return _formatMinutesAsHourMinute(value.round());
    }
    if (normalizedUnit == 'count') {
      return value.round().toString();
    }
    if (normalizedUnit == 'days') {
      return '${value.toStringAsFixed(2)} ${l10n.dashboardDaysUnit}';
    }
    return value.toStringAsFixed(1);
  }

  String _formatMinutesAsHourMinute(int minutes) {
    final safeMinutes = minutes < 0 ? -minutes : minutes;
    final hoursPart = safeMinutes ~/ 60;
    final minutesPart = safeMinutes % 60;
    return '$hoursPart:${minutesPart.toString().padLeft(2, '0')}h';
  }
}

class _RuleDetailsDialog extends ConsumerWidget {
  const _RuleDetailsDialog({
    required this.ruleName,
    required this.ruleMetric,
    required this.detailsWindowStart,
    required this.detailsWindowEnd,
    required this.dataFuture,
  });

  final String ruleName;
  final String ruleMetric;
  final DateTime detailsWindowStart;
  final DateTime detailsWindowEnd;
  final Future<DashboardRuleDetails> dataFuture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final logbookUseCases = ref.read(logbookUseCasesProvider);
    final entriesFuture = logbookUseCases.fetchLogbookPage(
      LogbookFilters(
        from: detailsWindowStart,
        to: detailsWindowEnd,
        types: const {
          LogbookEventType.flight,
          LogbookEventType.simulatorTraining,
          LogbookEventType.positioning,
          LogbookEventType.dutyPeriod,
        },
      ),
      limit: 5000,
      offset: 0,
    );

    final compact = MediaQuery.of(context).size.width < 700;

    final Widget content = Column(
      children: [
        ListTile(
          title: Text(ruleName),
          subtitle: Text(l10n.dashboardRuleTotals),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => AppNavigator.pop(context),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: FutureBuilder<DashboardRuleDetails>(
            future: dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('${l10n.errorLabel}: ${snapshot.error}'),
                );
              }
              final details = snapshot.data;
              if (details == null) {
                return Center(child: Text(l10n.dashboardNoData));
              }
              final dateFormat = DateFormat("dd MMM yyyy HH:mm 'UTC'");
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dateFormat.format(details.windowStart.toUtc())} - '
                      '${dateFormat.format(details.windowEnd.toUtc())}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    _TotalsSection(totals: details.totals),
                    const SizedBox(height: 14),
                    Text(
                      l10n.dashboardEventsInCalculation,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: FutureBuilder<List<LogbookEntry>>(
                        future: entriesFuture,
                        builder: (context, entriesSnapshot) {
                          if (entriesSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final entries =
                              entriesSnapshot.data ?? const <LogbookEntry>[];
                          final filtered = _filterEntriesForRuleType(
                            entries,
                            ruleMetric: ruleMetric,
                          );
                          if (filtered.isEmpty) {
                            return Center(
                              child: Text(l10n.dashboardNoEventsInWindow),
                            );
                          }
                          return LogbookEntriesYearList(
                            entries: filtered,
                            onEntryTap: (entry) => LogbookEntryDialogs.show(
                              context,
                              entry: entry,
                              useCases: logbookUseCases,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );

    if (compact) {
      return Scaffold(body: SafeArea(child: content));
    }

    return Dialog(
      child: SizedBox(
        width: 900,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.86,
          ),
          child: content,
        ),
      ),
    );
  }

  List<LogbookEntry> _filterEntriesForRuleType(
    List<LogbookEntry> entries, {
    required String ruleMetric,
  }) {
    final metric = ruleMetric.toLowerCase();
    if (metric == 'duty' || metric == 'duty_time') {
      return entries
          .where((entry) => entry.type == LogbookEventType.dutyPeriod)
          .toList(growable: false);
    }
    return entries
        .where((entry) => entry.type == LogbookEventType.flight)
        .toList(growable: false);
  }
}

class _TotalsSection extends StatelessWidget {
  const _TotalsSection({required this.totals});

  final DashboardTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = <({String label, String value})>[
      (label: l10n.dashboardFlightsLabel, value: '${totals.flightsCount}'),
      (
        label: l10n.dashboardBlockLabel,
        value: _formatMinutes(totals.blockMinutes),
      ),
      (
        label: l10n.dashboardFlightLabel,
        value: _formatMinutes(totals.flightMinutes),
      ),
      (
        label: l10n.dashboardNightLabel,
        value: _formatMinutes(totals.nightMinutes),
      ),
      (label: l10n.dashboardIfrLabel, value: _formatMinutes(totals.ifrMinutes)),
      (
        label: l10n.dashboardInstrumentLabel,
        value: _formatMinutes(totals.instrumentMinutes),
      ),
      (
        label: l10n.dashboardDutyLabel,
        value: _formatMinutes(totals.dutyMinutes),
      ),
      (label: l10n.dashboardLandingsLabel, value: '${totals.landings}'),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            if (compact) {
              return Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    _TotalLine(label: rows[i].label, value: rows[i].value),
                    if (i != rows.length - 1) const Divider(height: 12),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < rows.length; i += 2) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _TotalLine(
                          label: rows[i].label,
                          value: rows[i].value,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: i + 1 < rows.length
                            ? _TotalLine(
                                label: rows[i + 1].label,
                                value: rows[i + 1].value,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  if (i + 2 < rows.length) const Divider(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  static String _formatMinutes(int minutes) {
    final safeMinutes = minutes < 0 ? -minutes : minutes;
    final hoursPart = safeMinutes ~/ 60;
    final minutesPart = safeMinutes % 60;
    return '$hoursPart:${minutesPart.toString().padLeft(2, '0')}h';
  }
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _DashboardSetupDialog extends ConsumerStatefulWidget {
  const _DashboardSetupDialog();

  @override
  ConsumerState<_DashboardSetupDialog> createState() =>
      _DashboardSetupDialogState();
}

class _DashboardSetupDialogState extends ConsumerState<_DashboardSetupDialog> {
  static const String _metricDuty = 'duty';
  static const String _metricBlock = 'block';
  static const String _metricFlight = 'flight';
  static const String _metricNight = 'night';
  static const String _metricIfr = 'ifr';
  static const String _metricInstrument = 'instrument';
  static const String _metricTakeoff = 'takeoff';
  static const String _metricTakeoffDay = 'takeoff_day';
  static const String _metricTakeoffNight = 'takeoff_night';
  static const String _metricLandings = 'landings';
  static const String _metricLandingsDay = 'landings_day';
  static const String _metricLandingsNight = 'landings_night';
  static const String _metricInstrumentApproaches = 'instrument_approaches';
  static const String _metricPic = 'pic';
  static const String _metricSic = 'sic';
  static const String _metricPicus = 'picus';
  static const String _metricDual = 'dual';
  static const String _metricInstructor = 'instructor';
  static const String _metricCrossCountry = 'cross_country';

  static const String _ruleTypeMinimum = 'minimum';
  static const String _ruleTypeMaximum = 'maximum';

  static const String _windowHours = 'hours';
  static const String _windowDays = 'days';
  static const String _windowWeeks = 'weeks';
  static const String _windowMonths = 'months';
  static const String _windowYears = 'years';
  static const String _windowCalendarMonths = 'calendar_months';
  static const String _windowCalendarYears = 'calendar_years';
  static const String _windowCalendarDays = 'calendar_days';
  static const String _windowCalendarQuarter = 'calendar_quarter';

  static const String _referenceSameTime = 'same_time';
  static const String _referenceMidnightLocal = 'midnight_local';
  static const String _referenceMidnightUtc = 'midnight_utc';

  static const String _unitHours = 'hours';
  static const String _unitMinutes = 'minutes';
  static const String _unitDays = 'days';
  static const String _unitCount = 'count';

  static const Set<String> _countMetrics = {
    _metricTakeoff,
    _metricTakeoffDay,
    _metricTakeoffNight,
    _metricLandings,
    _metricLandingsDay,
    _metricLandingsNight,
    _metricInstrumentApproaches,
  };

  static bool _isCountMetric(String metric) => _countMetrics.contains(metric);
  static const String _defaultWindowType = 'days';
  static const String _defaultWindowReference = 'same_time';

  (String, String) _parseWindowType(String raw) {
    final clean = raw.trim().toLowerCase();
    if (clean.contains('|')) {
      final parts = clean.split('|');
      if (parts.length == 2) return (parts[0], parts[1]);
    }
    return switch (clean) {
      'calendar_days' => ('days', 'midnight_local'),
      'calendar_month' || 'calendar_months' => ('months', 'midnight_local'),
      'calendar_year' || 'calendar_years' => ('years', 'midnight_local'),
      'rolling_days' || 'consecutive_days' => ('days', 'same_time'),
      'hours' ||
      'days' ||
      'weeks' ||
      'months' ||
      'years' => (clean, 'same_time'),
      _ => (_defaultWindowType, _defaultWindowReference),
    };
  }

  String _encodeWindowType(String type, String reference) => '$type|$reference';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rulesAsync = ref.watch(dashboardRulesProvider);
    return Dialog(
      child: SizedBox(
        width: 700,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(l10n.dashboardSetupTitle),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => AppNavigator.pop(context),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () => _showRuleDialog(context),
                      icon: const Icon(Icons.add_chart_outlined),
                      label: Text(l10n.dashboardAddRule),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rulesAsync.when(
                  data: (rules) {
                    if (rules.isEmpty) {
                      return Center(
                        child: Text(l10n.dashboardNoRulesConfigured),
                      );
                    }
                    return ListView.separated(
                      itemCount: rules.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final rule = rules[index];
                        final windowLabel = _windowLabel(
                          rule.windowType,
                          rule.windowValue,
                        );
                        return ListTile(
                          title: Text(rule.ruleName),
                          subtitle: Text(
                            '${rule.ruleType} • ${rule.metric} • '
                            '$windowLabel',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _showRuleDialog(
                                  context,
                                  existing: rule,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => ref
                                    .read(dashboardRepositoryProvider)
                                    .deleteRule(rule.ruleId),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Center(child: Text('${l10n.errorLabel}: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRuleDialog(
    BuildContext context, {
    LimitRule? existing,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(dashboardRepositoryProvider);
    final isEditing = existing != null;
    final ruleNameController = TextEditingController(
      text: existing?.ruleName ?? '',
    );
    final windowController = TextEditingController(
      text: (existing?.windowValue ?? 365).toString(),
    );
    final limitController = TextEditingController(
      text: (existing?.limitValue ?? 1000).toString(),
    );
    final yellowController = TextEditingController(
      text: (existing?.warnYellowBefore ?? 100).toString(),
    );
    final redController = TextEditingController(
      text: (existing?.warnRedBefore ?? 50).toString(),
    );
    var metric = existing?.metric ?? _metricBlock;
    var ruleType = existing?.ruleType ?? _ruleTypeMaximum;
    final parsedWindowType = _parseWindowType(existing?.windowType ?? '');
    var windowType = parsedWindowType.$1;
    var windowReference = parsedWindowType.$2;
    var limitUnit =
        existing?.limitUnit ??
        (_isCountMetric(metric) ? _unitCount : _unitHours);
    if (!context.mounted) return;

    try {
      final created = await showDialog<bool>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text(
                isEditing
                    ? l10n.dashboardEditRuleTitle
                    : l10n.dashboardCreateRuleTitle,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: ruleNameController,
                      decoration: InputDecoration(
                        labelText: l10n.dashboardRuleNameLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: metric,
                      decoration: InputDecoration(
                        labelText: l10n.dashboardMetricLabel,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: _metricDuty,
                          child: Text(l10n.dashboardDutyLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricBlock,
                          child: Text(l10n.dashboardBlockLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricFlight,
                          child: Text(l10n.dashboardFlightLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricNight,
                          child: Text(l10n.dashboardNightLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricIfr,
                          child: Text(l10n.dashboardIfrLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricInstrument,
                          child: Text(l10n.dashboardInstrumentLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricTakeoff,
                          child: Text(l10n.dashboardTakeoffLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricTakeoffDay,
                          child: Text(l10n.dashboardTakeoffDayLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricTakeoffNight,
                          child: Text(l10n.dashboardTakeoffNightLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricLandings,
                          child: Text(l10n.dashboardLandingsLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricLandingsDay,
                          child: Text(l10n.dashboardLandingsDayLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricLandingsNight,
                          child: Text(l10n.dashboardLandingsNightLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricInstrumentApproaches,
                          child: Text(l10n.dashboardInstrumentApproachesLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricPic,
                          child: Text(l10n.dashboardPicTimeLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricSic,
                          child: Text(l10n.dashboardSicTimeLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricPicus,
                          child: Text(l10n.dashboardPicusTimeLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricDual,
                          child: Text(l10n.dashboardDualTimeLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricInstructor,
                          child: Text(l10n.dashboardInstructorTimeLabel),
                        ),
                        DropdownMenuItem(
                          value: _metricCrossCountry,
                          child: Text(l10n.dashboardCrossCountryLabel),
                        ),
                      ],
                      onChanged: (value) => setState(() {
                        metric = value ?? metric;
                        limitUnit = _isCountMetric(metric)
                            ? _unitCount
                            : _unitHours;
                      }),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: ruleType,
                      decoration: InputDecoration(
                        labelText: l10n.dashboardRuleTypeLabel,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: _ruleTypeMinimum,
                          child: Text(l10n.dashboardMinimumLabel),
                        ),
                        DropdownMenuItem(
                          value: _ruleTypeMaximum,
                          child: Text(l10n.dashboardMaximumLabel),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => ruleType = value ?? ruleType),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: windowType,
                      decoration: InputDecoration(
                        labelText: l10n.dashboardWindowTypeLabel,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: _windowHours,
                          child: Text(l10n.dashboardHoursUnit),
                        ),
                        DropdownMenuItem(
                          value: _windowDays,
                          child: Text(l10n.dashboardDaysUnit),
                        ),
                        DropdownMenuItem(
                          value: _windowWeeks,
                          child: Text(l10n.dashboardWeeksUnit),
                        ),
                        DropdownMenuItem(
                          value: _windowMonths,
                          child: Text(l10n.dashboardMonthsUnit),
                        ),
                        DropdownMenuItem(
                          value: _windowYears,
                          child: Text(l10n.dashboardYearsUnit),
                        ),
                        DropdownMenuItem(
                          value: _windowCalendarMonths,
                          child: Text(l10n.dashboardCalendarMonthsLabel),
                        ),
                        DropdownMenuItem(
                          value: _windowCalendarYears,
                          child: Text(l10n.dashboardCalendarYearsLabel),
                        ),
                        DropdownMenuItem(
                          value: _windowCalendarDays,
                          child: Text(l10n.dashboardCalendarDaysLabel),
                        ),
                        DropdownMenuItem(
                          value: _windowCalendarQuarter,
                          child: Text(l10n.dashboardCalendarQuarterLabel),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => windowType = value ?? windowType),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: windowReference,
                      decoration: InputDecoration(
                        labelText: l10n.dashboardStartReferenceLabel,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: _referenceSameTime,
                          child: Text(l10n.dashboardSameTimeNowLabel),
                        ),
                        DropdownMenuItem(
                          value: _referenceMidnightLocal,
                          child: Text(l10n.dashboardMidnightLocalLabel),
                        ),
                        DropdownMenuItem(
                          value: _referenceMidnightUtc,
                          child: Text(l10n.dashboardMidnightUtcLabel),
                        ),
                      ],
                      onChanged: (value) => setState(
                        () => windowReference = value ?? windowReference,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: windowController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.dashboardWindowValueLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildThresholdFields(
                      l10n: l10n,
                      limitController: limitController,
                      yellowController: yellowController,
                      redController: redController,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: limitUnit,
                      decoration: InputDecoration(
                        labelText: l10n.dashboardUnitLabel,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: _unitHours,
                          child: Text(l10n.dashboardHoursUnit),
                        ),
                        DropdownMenuItem(
                          value: _unitMinutes,
                          child: Text(l10n.dashboardMinutesUnit),
                        ),
                        DropdownMenuItem(
                          value: _unitDays,
                          child: Text(l10n.dashboardDaysUnit),
                        ),
                        DropdownMenuItem(
                          value: _unitCount,
                          child: Text(l10n.dashboardCountUnit),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => limitUnit = value ?? limitUnit),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => AppNavigator.pop(context, false),
                  child: Text(l10n.cancelAction),
                ),
                FilledButton(
                  onPressed: () => AppNavigator.pop(context, true),
                  child: Text(
                    isEditing ? l10n.saveAction : l10n.dashboardCreateAction,
                  ),
                ),
              ],
            ),
          );
        },
      );
      if (created != true) return;
      final storedWindowType = _encodeWindowType(windowType, windowReference);
      final ruleName = ruleNameController.text.trim().isEmpty
          ? _buildDefaultRuleName(
              metric: metric,
              ruleType: ruleType,
              windowType: storedWindowType,
              windowValue: int.tryParse(windowController.text.trim()) ?? 365,
            )
          : ruleNameController.text.trim();
      final windowValue = int.tryParse(windowController.text.trim()) ?? 365;
      final limitValue = double.tryParse(limitController.text.trim()) ?? 0;
      final yellow = double.tryParse(yellowController.text.trim()) ?? 0;
      final red = double.tryParse(redController.text.trim()) ?? 0;

      if (isEditing) {
        final updated = existing.copyWith(
          ruleName: ruleName,
          metric: metric,
          ruleType: ruleType,
          windowType: storedWindowType,
          windowValue: windowValue,
          limitValue: limitValue,
          limitUnit: limitUnit,
          warnYellowBefore: yellow,
          warnRedBefore: red,
        );
        await repo.updateRule(updated);
        return;
      }

      await repo.createRule(
        LimitRulesCompanion.insert(
          ruleName: ruleName,
          metric: metric,
          ruleType: ruleType,
          windowType: storedWindowType,
          windowValue: windowValue,
          limitValue: limitValue,
          limitUnit: limitUnit,
          warnYellowBefore: Value(yellow),
          warnRedBefore: Value(red),
          active: const Value(true),
        ),
      );
    } finally {
      ruleNameController.dispose();
      windowController.dispose();
      limitController.dispose();
      yellowController.dispose();
      redController.dispose();
    }
  }

  String _buildDefaultRuleName({
    required String metric,
    required String ruleType,
    required String windowType,
    required int windowValue,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final metricLabel = switch (metric) {
      'duty' => l10n.dashboardDutyLabel,
      'block' => l10n.dashboardBlockLabel,
      'flight' => l10n.dashboardFlightLabel,
      'night' => l10n.dashboardNightLabel,
      'ifr' => l10n.dashboardIfrLabel,
      'instrument' => l10n.dashboardInstrumentLabel,
      'takeoff' => l10n.dashboardTakeoffLabel,
      'takeoff_day' => l10n.dashboardTakeoffDayLabel,
      'takeoff_night' => l10n.dashboardTakeoffNightLabel,
      'landings' => l10n.dashboardLandingsLabel,
      'landings_day' => l10n.dashboardLandingsDayLabel,
      'landings_night' => l10n.dashboardLandingsNightLabel,
      'instrument_approaches' => l10n.dashboardInstrumentApproachesLabel,
      'pic' => l10n.dashboardPicTimeLabel,
      'sic' => l10n.dashboardSicTimeLabel,
      'picus' => l10n.dashboardPicusTimeLabel,
      'dual' => l10n.dashboardDualTimeLabel,
      'instructor' => l10n.dashboardInstructorTimeLabel,
      'cross_country' => l10n.dashboardCrossCountryLabel,
      _ => metric,
    };
    final typeLabel = ruleType == 'minimum'
        ? l10n.dashboardMinimumShortLabel
        : l10n.dashboardMaximumShortLabel;
    final windowLabel = _windowLabel(windowType, windowValue);
    return '$metricLabel • $typeLabel • $windowLabel';
  }

  String _windowLabel(String storedType, int value) {
    final l10n = AppLocalizations.of(context)!;
    final parsed = _parseWindowType(storedType);
    final windowBase = parsed.$1;
    final reference = parsed.$2;
    final baseLabel = switch (windowBase) {
      'hours' => '$value ${l10n.dashboardHoursUnit}',
      'days' => '$value ${l10n.dashboardDaysUnit}',
      'weeks' => '$value ${l10n.dashboardWeeksUnit}',
      'months' => '$value ${l10n.dashboardMonthsUnit}',
      'years' => '$value ${l10n.dashboardYearsUnit}',
      'calendar_quarter' => '${l10n.dashboardCalendarQuarterLabel} ($value)',
      _ => '$windowBase $value',
    };
    final referenceLabel = switch (reference) {
      'same_time' => l10n.dashboardSameTimeLabel,
      'midnight_local' => l10n.dashboardMidnightLocalLabel,
      'midnight_utc' => l10n.dashboardMidnightUtcLabel,
      _ => reference,
    };
    return '$baseLabel • $referenceLabel';
  }

  Widget _numericSettingsField({
    required TextEditingController controller,
    required String label,
    bool decimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }

  List<Widget> _buildThresholdFields({
    required AppLocalizations l10n,
    required TextEditingController limitController,
    required TextEditingController yellowController,
    required TextEditingController redController,
  }) {
    return [
      _numericSettingsField(
        controller: limitController,
        label: l10n.dashboardLimitValueLabel,
        decimal: true,
      ),
      const SizedBox(height: 8),
      _numericSettingsField(
        controller: yellowController,
        label: l10n.dashboardWarnYellowBeforeLabel,
        decimal: true,
      ),
      const SizedBox(height: 8),
      _numericSettingsField(
        controller: redController,
        label: l10n.dashboardWarnRedBeforeLabel,
        decimal: true,
      ),
      const SizedBox(height: 8),
    ];
  }
}
