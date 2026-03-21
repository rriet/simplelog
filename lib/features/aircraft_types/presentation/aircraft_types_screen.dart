import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/app_message_dialog.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/database/enums/aircraft_category.dart';
import 'package:simplelog/data/database/enums/engine_type.dart';
import 'package:simplelog/data/models/aircraft_type_row.dart';
import 'package:simplelog/features/aircraft_types/application/providers/aircraft_types_feature_providers.dart';
import 'package:simplelog/features/aircraft_types/presentation/aircraft_type_edit_screen.dart';
import 'package:simplelog/features/aircraft_types/presentation/widgets/aircraft_type_search_bar.dart';
import 'package:simplelog/features/aircraft_types/presentation/widgets/aircraft_types_list.dart';
import 'package:simplelog/features/aircraft_types/presentation/widgets/family_group.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_lazy_panel.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

/// Main aircraft type management screen.
class AircraftTypesScreen extends ConsumerStatefulWidget {
  /// Creates the aircraft type management screen.
  const AircraftTypesScreen({super.key});

  @override
  ConsumerState<AircraftTypesScreen> createState() =>
      _AircraftTypesScreenState();
}

class _AircraftTypesScreenState extends ConsumerState<AircraftTypesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleLock(AircraftTypeRow row) async {
    final controller = ref.read(aircraftTypesControllerProvider.notifier);
    await controller.toggleLock(row.type);
  }

  Future<void> _confirmDelete(AircraftTypeRow row) async {
    final dataController = ref.read(
      aircraftTypeDataControllerProvider.notifier,
    );
    final validation = await dataController.validateDelete(row.type);
    if (!validation.isValid) {
      if (!mounted) return;
      await _showValidationError(validation);
      return;
    }
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteAircraftType(row.code)),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => AppNavigator.pop(context, true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await dataController.delete(row.type);
    }
  }

  Future<void> _showValidationError(ValidationResult validation) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showAppMessageDialog(
      context,
      title: l10n.validationErrorTitle,
      message: validation.message ?? l10n.validationErrorGeneric,
      okLabel: l10n.okAction,
    );
  }

  Future<void> _createAircraftType() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const placeholder = AircraftType(
      id: kPlaceholderId,
      code: '',
      family: '',
      longName: '',
      category: AircraftCategory.landplane,
      engineType: EngineType.piston,
      mtow: 0,
      engineCount: 1,
      multiPilot: false,
      complex: false,
      efis: false,
      highPerformance: false,
      isLocked: false,
    );

    if (isCompact) {
      await AppNavigator.pushMaterial<void>(
        context,
        (_) => const AircraftTypeEditScreen(item: placeholder, isCreate: true),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => const AircraftTypeEditScreen(
        item: placeholder,
        isCreate: true,
      ),
    );
  }

  Future<void> _editAircraftType(AircraftTypeRow row) async {
    final isCompact = MediaQuery.of(context).size.width < 600;

    if (isCompact) {
      await AppNavigator.pushMaterial<void>(
        context,
        (_) => AircraftTypeEditScreen(item: row.type),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => AircraftTypeEditScreen(item: row.type),
    );
  }

  Future<void> _showAircraftTypeDetails(AircraftTypeRow row) async {
    final l10n = AppLocalizations.of(context)!;
    final logbookUseCases = ref.read(logbookUseCasesProvider);

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 500,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              _buildDetailsHeaderTile(
                title: row.code,
                subtitle: row.type.longName.trim().isEmpty
                    ? 'Aircraft Type'
                    : row.type.longName.trim(),
                onDone: () => AppNavigator.pop(context),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.screenLogbook,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: LogbookEntriesLazyPanel(
                          pageLoader: (limit, offset) =>
                              logbookUseCases.fetchEntriesForAircraftTypePage(
                                row.type.id,
                                limit: limit,
                                offset: offset,
                              ),
                          summaryLoader: () =>
                              logbookUseCases.fetchFlightSummaryForAircraftType(
                                row.type.id,
                              ),
                          onEntryTap: (entry) => LogbookEntryDialogs.show(
                            context,
                            entry: entry,
                            useCases: logbookUseCases,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFamilyDetails(FamilyGroup group) async {
    final logbookUseCases = ref.read(logbookUseCasesProvider);
    final typeIds = group.rows
        .map((row) => row.type.id)
        .toSet()
        .toList(growable: false);

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 500,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              _buildDetailsHeaderTile(
                title: 'Family: ${group.family}',
                subtitle: 'Flights',
                onDone: () => AppNavigator.pop(context),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LogbookEntriesLazyPanel(
                    pageLoader: (limit, offset) =>
                        logbookUseCases.fetchEntriesForAircraftTypeFamilyPage(
                          typeIds,
                          limit: limit,
                          offset: offset,
                        ),
                    summaryLoader: () => logbookUseCases
                        .fetchFlightSummaryForAircraftTypeFamily(typeIds),
                    onEntryTap: (entry) => LogbookEntryDialogs.show(
                      context,
                      entry: entry,
                      useCases: logbookUseCases,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FamilyGroup> _groupByFamily(List<AircraftTypeRow> rows) {
    final groups = <FamilyGroup>[];
    String? currentFamily;
    var currentRows = <AircraftTypeRow>[];

    void flush() {
      final family = currentFamily;
      if (family == null) return;
      groups.add(
        FamilyGroup(
          family: family,
          rows: List<AircraftTypeRow>.from(currentRows),
        ),
      );
    }

    for (final row in rows) {
      final family = row.family.trim().isEmpty ? '-' : row.family.trim();
      if (currentFamily != family) {
        flush();
        currentFamily = family;
        currentRows = [];
      }
      currentRows.add(row);
    }
    flush();

    return groups;
  }

  Widget _buildDetailsHeaderTile({
    required String title,
    required String subtitle,
    required VoidCallback onDone,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: TextButton(
        onPressed: onDone,
        child: Text(AppLocalizations.of(context)!.reportsDone),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final aircraftTypes = ref.watch(aircraftTypesProvider(_query));
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        AircraftTypeSearchBar(
          controller: _searchController,
          label: l10n.searchAircraftTypes,
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: aircraftTypes.when(
            data: (items) {
              if (items.isEmpty) {
                return Center(child: Text(l10n.emptyResults));
              }

              final groups = _groupByFamily(items);
              return AircraftTypesList(
                groups: groups,
                isCompact: isCompact,
                onToggleLock: _toggleLock,
                onEdit: _editAircraftType,
                onDelete: _confirmDelete,
                onOpenDetails: _showAircraftTypeDetails,
                onOpenFamilyDetails: _showFamilyDetails,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
          ),
        ),
        const SizedBox(height: 8),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.only(right: 16, bottom: 8),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _createAircraftType,
              tooltip: l10n.createAircraftTypeTitle,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
