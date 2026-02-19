import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_filters.dart';
import 'package:simplelog/features/dashboard/application/providers/dashboard_providers.dart';
import 'package:simplelog/features/dashboard/domain/dashboard_models.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_repository_provider.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_year_list.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(dashboardCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const _DashboardSetupDialog(),
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
                  return const Center(
                    child: Text('No active rules configured.'),
                  );
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
                      itemBuilder: (context, index) => _RuleCard(card: cards[index]),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
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
    final repo = ref.read(dashboardRepositoryProvider);
    final color = switch (card.status) {
      LimitCardStatus.green => Colors.green,
      LimitCardStatus.yellow => Colors.amber,
      LimitCardStatus.red => Colors.red,
    };
    final progress = card.limitValue <= 0
        ? 0.0
        : (card.currentValue / card.limitValue).clamp(0.0, 1.2);
    final valueLabel = _formatValueByUnit(card.currentValue, card.rule.limitUnit);
    final limitLabel = _formatValueByUnit(card.limitValue, card.rule.limitUnit);
    final remainingAbsLabel = _formatValueByUnit(
      card.remainingValue.abs(),
      card.rule.limitUnit,
    );
    final dateFormat = DateFormat("dd MMM yyyy HH:mm 'UTC'");
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (_) => _RuleDetailsDialog(
              ruleName: card.rule.ruleName,
              ruleMetric: card.rule.metric,
              detailsWindowStart: card.windowStart,
              detailsWindowEnd: card.windowEnd,
              dataFuture: repo.loadRuleDetails(card.rule),
            ),
          );
        },
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
                        ? '$remainingAbsLabel remaining'
                        : '$remainingAbsLabel over limit')
                    : (card.remainingValue >= 0
                        ? '$remainingAbsLabel above minimum'
                        : '$remainingAbsLabel below minimum'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${dateFormat.format(card.windowStart.toUtc())} - ${dateFormat.format(card.windowEnd.toUtc())}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatValueByUnit(double value, String unit) {
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
      return '${value.toStringAsFixed(2)} days';
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

    Widget content = Column(
      children: [
        ListTile(
          title: Text(ruleName),
          subtitle: const Text('Rule Totals'),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
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
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final details = snapshot.data;
              if (details == null) {
                return const Center(child: Text('No data.'));
              }
              final dateFormat = DateFormat("dd MMM yyyy HH:mm 'UTC'");
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dateFormat.format(details.windowStart.toUtc())} - ${dateFormat.format(details.windowEnd.toUtc())}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    _TotalsSection(totals: details.totals),
                    const SizedBox(height: 14),
                    Text(
                      'Events in calculation',
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
                            return const Center(
                              child: Text('No events in this window.'),
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
    final rows = <({String label, String value})>[
      (label: 'Flights', value: '${totals.flightsCount}'),
      (label: 'Block', value: _formatMinutes(totals.blockMinutes)),
      (label: 'Flight', value: _formatMinutes(totals.flightMinutes)),
      (label: 'Night', value: _formatMinutes(totals.nightMinutes)),
      (label: 'IFR', value: _formatMinutes(totals.ifrMinutes)),
      (label: 'Instrument', value: _formatMinutes(totals.instrumentMinutes)),
      (label: 'Duty', value: _formatMinutes(totals.dutyMinutes)),
      (label: 'Landings', value: '${totals.landings}'),
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
  ConsumerState<_DashboardSetupDialog> createState() => _DashboardSetupDialogState();
}

class _DashboardSetupDialogState extends ConsumerState<_DashboardSetupDialog> {
  static const Set<String> _countMetrics = {
    'takeoff',
    'takeoff_day',
    'takeoff_night',
    'landings',
    'landings_day',
    'landings_night',
    'instrument_approaches',
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
      'hours' || 'days' || 'weeks' || 'months' || 'years' =>
        (clean, 'same_time'),
      _ => (_defaultWindowType, _defaultWindowReference),
    };
  }

  String _encodeWindowType(String type, String reference) => '$type|$reference';

  @override
  Widget build(BuildContext context) {
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
                title: const Text('Dashboard Setup'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
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
                      label: const Text('Add Rule'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rulesAsync.when(
                  data: (rules) {
                    if (rules.isEmpty) {
                      return const Center(child: Text('No rules configured.'));
                    }
                    return ListView.separated(
                      itemCount: rules.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final rule = rules[index];
                        return ListTile(
                          title: Text(rule.ruleName),
                          subtitle: Text(
                            '${rule.ruleType} • ${rule.metric} • ${_windowLabel(rule.windowType, rule.windowValue)}',
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
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
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
    var metric = existing?.metric ?? 'block';
    var ruleType = existing?.ruleType ?? 'maximum';
    final parsedWindowType = _parseWindowType(existing?.windowType ?? '');
    var windowType = parsedWindowType.$1;
    var windowReference = parsedWindowType.$2;
    var limitUnit = existing?.limitUnit ?? (_isCountMetric(metric) ? 'count' : 'hours');
    if (!context.mounted) return;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(isEditing ? 'Edit Rule' : 'Create Rule'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ruleNameController,
                    decoration: const InputDecoration(labelText: 'Rule name'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: metric,
                    decoration: const InputDecoration(labelText: 'Metric'),
                    items: const [
                      DropdownMenuItem(value: 'duty', child: Text('Duty')),
                      DropdownMenuItem(value: 'block', child: Text('Block')),
                      DropdownMenuItem(value: 'flight', child: Text('Flight')),
                      DropdownMenuItem(value: 'night', child: Text('Night')),
                      DropdownMenuItem(value: 'ifr', child: Text('IFR')),
                      DropdownMenuItem(value: 'instrument', child: Text('Instrument')),
                      DropdownMenuItem(value: 'takeoff', child: Text('Takeoff')),
                      DropdownMenuItem(value: 'takeoff_day', child: Text('Takeoff Day')),
                      DropdownMenuItem(value: 'takeoff_night', child: Text('Takeoff Night')),
                      DropdownMenuItem(value: 'landings', child: Text('Landings')),
                      DropdownMenuItem(value: 'landings_day', child: Text('Landings Day')),
                      DropdownMenuItem(value: 'landings_night', child: Text('Landings Night')),
                      DropdownMenuItem(
                        value: 'instrument_approaches',
                        child: Text('Instrument Approaches'),
                      ),
                      DropdownMenuItem(value: 'pic', child: Text('PIC Time')),
                      DropdownMenuItem(value: 'sic', child: Text('SIC Time')),
                      DropdownMenuItem(value: 'picus', child: Text('PICUS Time')),
                      DropdownMenuItem(value: 'dual', child: Text('Dual Time')),
                      DropdownMenuItem(
                        value: 'instructor',
                        child: Text('Instructor Time'),
                      ),
                      DropdownMenuItem(
                        value: 'cross_country',
                        child: Text('Cross Country'),
                      ),
                    ],
                    onChanged: (value) => setState(() {
                      metric = value ?? metric;
                      limitUnit = _isCountMetric(metric) ? 'count' : 'hours';
                    }),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: ruleType,
                    decoration: const InputDecoration(labelText: 'Rule type'),
                    items: const [
                      DropdownMenuItem(value: 'minimum', child: Text('Minimum')),
                      DropdownMenuItem(value: 'maximum', child: Text('Maximum')),
                    ],
                    onChanged: (value) => setState(() => ruleType = value ?? ruleType),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: windowType,
                    decoration: const InputDecoration(labelText: 'Window type'),
                    items: const [
                      DropdownMenuItem(value: 'hours', child: Text('Hours')),
                      DropdownMenuItem(value: 'days', child: Text('Days')),
                      DropdownMenuItem(value: 'weeks', child: Text('Weeks')),
                      DropdownMenuItem(value: 'months', child: Text('Months')),
                      DropdownMenuItem(value: 'years', child: Text('Years')),
                      DropdownMenuItem(value: 'calendar_months', child: Text('Calendar Months')),
                      DropdownMenuItem(value: 'calendar_years', child: Text('Calendar Years')),
                      DropdownMenuItem(value: 'calendar_days', child: Text('Calendar Days')),
                      DropdownMenuItem(
                        value: 'calendar_quarter',
                        child: Text('Calendar Quarter'),
                      ),
                    ],
                    onChanged: (value) => setState(() => windowType = value ?? windowType),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: windowReference,
                    decoration: const InputDecoration(labelText: 'Start reference'),
                    items: const [
                      DropdownMenuItem(value: 'same_time', child: Text('Same time (now)')),
                      DropdownMenuItem(value: 'midnight_local', child: Text('Midnight Local')),
                      DropdownMenuItem(value: 'midnight_utc', child: Text('Midnight UTC')),
                    ],
                    onChanged: (value) =>
                        setState(() => windowReference = value ?? windowReference),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: windowController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Window value'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: limitController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Limit value'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: limitUnit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: const [
                      DropdownMenuItem(value: 'hours', child: Text('Hours')),
                      DropdownMenuItem(value: 'minutes', child: Text('Minutes')),
                      DropdownMenuItem(value: 'days', child: Text('Days')),
                      DropdownMenuItem(value: 'count', child: Text('Count')),
                    ],
                    onChanged: (value) => setState(() => limitUnit = value ?? limitUnit),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: yellowController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Warn yellow before'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: redController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Warn red before'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(isEditing ? 'Save' : 'Create'),
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
  }

  String _buildDefaultRuleName({
    required String metric,
    required String ruleType,
    required String windowType,
    required int windowValue,
  }) {
    final metricLabel = switch (metric) {
      'duty' => 'Duty',
      'block' => 'Block',
      'flight' => 'Flight',
      'night' => 'Night',
      'ifr' => 'IFR',
      'instrument' => 'Instrument',
      'takeoff' => 'Takeoff',
      'takeoff_day' => 'Takeoff Day',
      'takeoff_night' => 'Takeoff Night',
      'landings' => 'Landings',
      'landings_day' => 'Landings Day',
      'landings_night' => 'Landings Night',
      'instrument_approaches' => 'Instrument Approaches',
      'pic' => 'PIC Time',
      'sic' => 'SIC Time',
      'picus' => 'PICUS Time',
      'dual' => 'Dual Time',
      'instructor' => 'Instructor Time',
      'cross_country' => 'Cross Country',
      _ => metric,
    };
    final typeLabel = ruleType == 'minimum' ? 'Min' : 'Max';
    final windowLabel = _windowLabel(windowType, windowValue);
    return '$metricLabel • $typeLabel • $windowLabel';
  }

  String _windowLabel(String storedType, int value) {
    final parsed = _parseWindowType(storedType);
    final windowBase = parsed.$1;
    final reference = parsed.$2;
    final baseLabel = switch (windowBase) {
      'hours' => '$value hours',
      'days' => '$value days',
      'weeks' => '$value weeks',
      'months' => '$value months',
      'years' => '$value years',
      'calendar_quarter' => 'Calendar quarter ($value)',
      _ => '$windowBase $value',
    };
    final referenceLabel = switch (reference) {
      'same_time' => 'Same time',
      'midnight_local' => 'Midnight Local',
      'midnight_utc' => 'Midnight UTC',
      _ => reference,
    };
    return '$baseLabel • $referenceLabel';
  }
}
