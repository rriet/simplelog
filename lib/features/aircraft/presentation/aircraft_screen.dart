import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/features/aircraft/application/providers/aircraft_feature_providers.dart';

import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/aircraft_row.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_year_list.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';
import 'package:simplelog/state/controllers/validation_result.dart';
import 'package:simplelog/presentation/shared/widgets/delete_confirmation_dialog.dart';
import 'aircraft_edit_screen.dart';
import 'widgets/aircraft_search_bar.dart';
import 'widgets/aircraft_list.dart';

class AircraftScreen extends ConsumerStatefulWidget {
  const AircraftScreen({super.key});

  @override
  ConsumerState<AircraftScreen> createState() => _AircraftScreenState();
}

class _AircraftScreenState extends ConsumerState<AircraftScreen> {
  final _searchController = TextEditingController();
  String _query = '';

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
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.validationErrorTitle),
        content: Text(validation.message ?? l10n.validationErrorGeneric),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
    );
  }

  Future<void> _showAircraftDetails(AircraftRow row) async {
    final l10n = AppLocalizations.of(context)!;
    final logbookUseCases = ref.read(logbookUseCasesProvider);
    final entriesFuture =
        logbookUseCases.fetchEntriesForAircraft(row.aircraft.id);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aircraft'),
        content: SizedBox(
          width: 480,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              _AircraftHeader(row: row),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.screenLogbook,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<LogbookEntry>>(
                  future: entriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final entries = snapshot.data ?? [];
                    if (entries.isEmpty) {
                      return Center(
                        child: Text(l10n.emptyResults),
                      );
                    }
                    return LogbookEntriesYearList(
                      entries: entries,
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.okAction),
          ),
        ],
      ),
    );
  }

  Future<void> _createAircraft() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    final placeholder = Aircraft(
      id: kPlaceholderId,
      aircraftTypeId: 0,
      registration: '',
      mtow: null,
      isSimulator: false,
      isFavorite: false,
      isLocked: false,
    );

    if (isCompact) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AircraftEditScreen(
            item: placeholder,
            isCreate: true,
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 520,
          height: 640,
          child: AircraftEditScreen(
            item: placeholder,
            isCreate: true,
          ),
        ),
      ),
    );
  }

  Future<void> _editAircraft(AircraftRow row) async {
    final isCompact = MediaQuery.of(context).size.width < 600;

    if (isCompact) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AircraftEditScreen(
            item: row.aircraft,
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 520,
          height: 640,
          child: AircraftEditScreen(
            item: row.aircraft,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final aircraft = ref.watch(aircraftProvider(_query));
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        AircraftSearchBar(
          controller: _searchController,
          label: l10n.searchAircraft,
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: aircraft.when(
            data: (items) => AircraftList(
              items: items,
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
        const SizedBox(height: 8),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.only(right: 16, bottom: 8),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _createAircraft,
              tooltip: l10n.createAircraftTitle,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}

class _AircraftHeader extends StatelessWidget {
  const _AircraftHeader({required this.row});

  final AircraftRow row;

  @override
  Widget build(BuildContext context) {
    final typeLabel = [
      if (row.type?.code != null && row.type!.code.trim().isNotEmpty)
        row.type!.code,
      if (row.type?.longName != null && row.type!.longName.trim().isNotEmpty)
        row.type!.longName,
    ].join(' • ');
    final subtitle = [
      if (typeLabel.isNotEmpty) typeLabel,
      if (row.aircraft.isSimulator) 'Simulator',
    ].join(' • ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.registration,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (row.aircraft.notes != null && row.aircraft.notes!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              row.aircraft.notes!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
