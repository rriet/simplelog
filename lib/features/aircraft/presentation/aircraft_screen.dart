import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/app_message_dialog.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:simplelog/core/text/search_normalizer.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/features/aircraft/application/providers/aircraft_feature_providers.dart';
import 'package:simplelog/features/aircraft/presentation/aircraft_edit_screen.dart';
import 'package:simplelog/features/aircraft/presentation/widgets/aircraft_details_dialog.dart';
import 'package:simplelog/features/aircraft/presentation/widgets/aircraft_list.dart';
import 'package:simplelog/features/aircraft/presentation/widgets/aircraft_search_bar.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

/// Field to search against when filtering the aircraft list.
enum AircraftSearchBy {
  /// Search in all supported fields.
  all,

  /// Search by registration only.
  registration,

  /// Search by aircraft type.
  type,

  /// Search by aircraft family.
  family,

  /// Search by notes.
  notes,
}

/// Main aircraft management screen for aircraft and simulator records.
class AircraftScreen extends ConsumerStatefulWidget {
  /// Creates the aircraft management screen.
  const AircraftScreen({super.key});

  @override
  ConsumerState<AircraftScreen> createState() => _AircraftScreenState();
}

class _AircraftScreenState extends ConsumerState<AircraftScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _fabOpen = false;

  void _setSearchBy(AircraftSearchBy value) {
    setState(() => _searchBy = value);
  }

  AircraftSearchBy _searchBy = AircraftSearchBy.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleLock(AircraftRow row) async {
    final controller = ref.read(aircraftControllerProvider.notifier);
    await controller.toggleLock(row.aircraft);
  }

  Future<void> _toggleFavorite(AircraftRow row) async {
    final controller = ref.read(aircraftControllerProvider.notifier);
    await controller.toggleFavorite(row.aircraft);
  }

  Future<void> _confirmDelete(AircraftRow row) async {
    final dataController = ref.read(aircraftDataControllerProvider.notifier);
    final validation = await dataController.validateDelete(row.aircraft);
    if (!validation.isValid) {
      if (!mounted) return;
      await _showValidationError(validation);
      return;
    }
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await DeleteConfirmationDialog.show(
      context,
      title: l10n.confirmDeleteTitle,
      content: l10n.confirmDeleteAircraft(row.registration),
      cancelLabel: l10n.cancelAction,
      deleteLabel: l10n.deleteAction,
    );

    if (confirmed && mounted) {
      await dataController.delete(row.aircraft);
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

  Future<void> _showAircraftDetails(AircraftRow row) async {
    final logbookUseCases = ref.read(logbookUseCasesProvider);
    await showAircraftDetailsDialog(
      context,
      row: row,
      logbookUseCases: logbookUseCases,
      onEntryTap: (entry) => LogbookEntryDialogs.show(
        context,
        entry: entry,
        useCases: logbookUseCases,
      ),
    );
  }

  Future<void> _createAircraft() async {
    await _openCreateAircraft(isSimulator: false);
  }

  Future<void> _createSimulator() async {
    await _openCreateAircraft(isSimulator: true);
  }

  Future<void> _openCreateAircraft({required bool isSimulator}) async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final placeholder = Aircraft(
      id: kPlaceholderId,
      aircraftTypeId: 0,
      registration: '',
      isSimulator: isSimulator,
      isFavorite: false,
      isLocked: false,
    );

    if (isCompact) {
      await AppNavigator.pushMaterial<void>(
        context,
        (_) => AircraftEditScreen(
          item: placeholder,
          isCreate: true,
          initialIsSimulator: isSimulator,
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => AircraftEditScreen(
        item: placeholder,
        isCreate: true,
        initialIsSimulator: isSimulator,
      ),
    );
  }

  Future<void> _editAircraft(AircraftRow row) async {
    final isCompact = MediaQuery.of(context).size.width < 600;

    if (isCompact) {
      await AppNavigator.pushMaterial<void>(
        context,
        (_) => AircraftEditScreen(
          item: row.aircraft,
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => AircraftEditScreen(
        item: row.aircraft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final aircraft = ref.watch(aircraftProvider(''));
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Stack(
      children: [
        Column(
          children: [
            AircraftSearchBar(
              controller: _searchController,
              label: l10n.searchAircraft,
              onChanged: (value) => setState(() => _query = value),
              trailing: SizedBox(
                width: isCompact ? 132 : 190,
                child: DropdownButtonFormField<AircraftSearchBy>(
                  isExpanded: true,
                  initialValue: _searchBy,
                  decoration: InputDecoration(
                    labelText: l10n.searchByLabel,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: AircraftSearchBy.all,
                      child: Text(l10n.optionAll),
                    ),
                    DropdownMenuItem(
                      value: AircraftSearchBy.registration,
                      child: Text(l10n.fieldRegistration),
                    ),
                    DropdownMenuItem(
                      value: AircraftSearchBy.type,
                      child: Text(l10n.searchFieldType),
                    ),
                    DropdownMenuItem(
                      value: AircraftSearchBy.family,
                      child: Text(l10n.fieldFamily),
                    ),
                    DropdownMenuItem(
                      value: AircraftSearchBy.notes,
                      child: Text(l10n.fieldNotes),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    _setSearchBy(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: aircraft.when(
                data: (items) => AircraftList(
                  items: _applySearchFilter(items, _query, _searchBy),
                  isCompact: isCompact,
                  onToggleFavorite: _toggleFavorite,
                  onToggleLock: _toggleLock,
                  onEdit: _editAircraft,
                  onDelete: _confirmDelete,
                  onOpenDetails: _showAircraftDetails,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text(error.toString()),
                ),
              ),
            ),
          ],
        ),
        if (_fabOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _fabOpen = false),
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: SafeArea(
            top: false,
            child: _AircraftFabMenu(
              isOpen: _fabOpen,
              onToggle: () => setState(() => _fabOpen = !_fabOpen),
              onCreateAircraft: () async {
                setState(() => _fabOpen = false);
                await _createAircraft();
              },
              onCreateSimulator: () async {
                setState(() => _fabOpen = false);
                await _createSimulator();
              },
            ),
          ),
        ),
      ],
    );
  }

  List<AircraftRow> _applySearchFilter(
    List<AircraftRow> source,
    String query,
    AircraftSearchBy searchBy,
  ) {
    final normalized = normalizeLooseSearch(query);
    if (normalized.isEmpty) return source;

    bool matches(AircraftRow row) {
      final registration = normalizeLooseSearch(row.registration);
      final typeCode = normalizeLooseSearch(row.type?.code ?? '');
      final typeName = normalizeLooseSearch(row.type?.longName ?? '');
      final family = normalizeLooseSearch(row.type?.family ?? '');
      final notes = normalizeLooseSearch(row.aircraft.notes ?? '');

      switch (searchBy) {
        case AircraftSearchBy.registration:
          return registration.contains(normalized);
        case AircraftSearchBy.type:
          return typeCode.contains(normalized) || typeName.contains(normalized);
        case AircraftSearchBy.family:
          return family.contains(normalized);
        case AircraftSearchBy.notes:
          return notes.contains(normalized);
        case AircraftSearchBy.all:
          return registration.contains(normalized) ||
              typeCode.contains(normalized) ||
              typeName.contains(normalized) ||
              family.contains(normalized) ||
              notes.contains(normalized);
      }
    }

    return source.where(matches).toList(growable: false);
  }
}

class _AircraftFabMenu extends StatelessWidget {
  const _AircraftFabMenu({
    required this.isOpen,
    required this.onToggle,
    required this.onCreateAircraft,
    required this.onCreateSimulator,
  });

  final bool isOpen;
  final VoidCallback onToggle;
  final Future<void> Function() onCreateAircraft;
  final Future<void> Function() onCreateSimulator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isOpen)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _AircraftFabAction(
                  icon: Icons.airplanemode_active_outlined,
                  label: AppLocalizations.of(context)!.createAircraftTitle,
                  onTap: onCreateAircraft,
                ),
                const SizedBox(height: 10),
                _AircraftFabAction(
                  icon: Icons.videogame_asset_outlined,
                  label: AppLocalizations.of(context)!.createSimulatorTitle,
                  onTap: onCreateSimulator,
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: onToggle,
          child: Icon(isOpen ? Icons.close : Icons.add),
        ),
      ],
    );
  }
}

class _AircraftFabAction extends StatelessWidget {
  const _AircraftFabAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              child: Icon(icon, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
