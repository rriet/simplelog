import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/app_message_dialog.dart';
import 'package:simplelog/core/text/search_normalizer.dart';
import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/features/crew/application/providers/crew_feature_providers.dart';
import 'package:simplelog/features/crew/presentation/crew_edit_screen.dart';
import 'package:simplelog/features/crew/presentation/widgets/crew_filters_dialog.dart';
import 'package:simplelog/features/crew/presentation/widgets/crew_info_dialog.dart';
import 'package:simplelog/features/crew/presentation/widgets/crew_list.dart';
import 'package:simplelog/features/crew/presentation/widgets/crew_search_bar.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

/// Main screen for browsing, filtering and managing crew members.
class CrewScreen extends ConsumerStatefulWidget {
  /// Creates the crew management screen.
  const CrewScreen({super.key});

  @override
  ConsumerState<CrewScreen> createState() => _CrewScreenState();
}

class _CrewScreenState extends ConsumerState<CrewScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  CrewSearchBy _searchBy = CrewSearchBy.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleLock(CrewRow row) async {
    final controller = ref.read(crewControllerProvider.notifier);
    await controller.toggleLock(row.crew);
  }

  Future<void> _toggleFavorite(CrewRow row) async {
    final controller = ref.read(crewControllerProvider.notifier);
    await controller.toggleFavorite(row.crew);
  }

  Future<void> _openFilters() async {
    final selected = await CrewFiltersDialog.show(
      context,
      initialSearchBy: _searchBy,
    );
    if (!mounted || selected == null) return;
    setState(() => _searchBy = selected);
  }

  String _searchLabel(AppLocalizations l10n) {
    switch (_searchBy) {
      case CrewSearchBy.all:
        return l10n.searchCrew;
      case CrewSearchBy.name:
        return 'Search Name';
      case CrewSearchBy.email:
        return 'Search Email';
      case CrewSearchBy.phone:
        return 'Search Phone';
      case CrewSearchBy.notes:
        return 'Search Notes';
    }
  }

  Future<void> _confirmDelete(CrewRow row) async {
    final dataController = ref.read(crewDataControllerProvider.notifier);
    final validation = await dataController.validateDelete(row.crew);
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
        content: Text(l10n.confirmDeleteCrew(row.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await dataController.delete(row.crew);
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

  Future<void> _showCrewDetails(CrewRow row) async {
    await CrewInfoDialog.show(
      context,
      row: row,
      useCases: ref.read(logbookUseCasesProvider),
    );
  }

  Future<void> _showLargePhoto(CrewRow row) async {
    final bytes = row.crew.picture;
    if (bytes == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.memory(bytes, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Future<void> _createCrew() async {
    final isCompact = MediaQuery.of(context).size.width < 600;
    const placeholder = CrewData(
      id: kPlaceholderId,
      name: '',
      isSelf: false,
      isFavorite: false,
      isLocked: false,
    );

    if (isCompact) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const CrewEditScreen(item: placeholder, isCreate: true),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: size.height * 0.9,
            ),
            child: const CrewEditScreen(item: placeholder, isCreate: true),
          ),
        );
      },
    );
  }

  Future<void> _editCrew(CrewRow row) async {
    final isCompact = MediaQuery.of(context).size.width < 600;

    if (isCompact) {
      await Navigator.of(
        context,
      ).push(
        MaterialPageRoute<void>(builder: (_) => CrewEditScreen(item: row.crew)),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: size.height * 0.9,
            ),
            child: CrewEditScreen(item: row.crew),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final crew = ref.watch(crewProvider(''));
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        CrewSearchBar(
          controller: _searchController,
          label: _searchLabel(l10n),
          onChanged: (value) => setState(() => _query = value),
          trailing: IconButton(
            tooltip: 'Filters',
            onPressed: _openFilters,
            icon: const Icon(Icons.filter_list),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: crew.when(
            data: (items) => CrewList(
              items: _applySearchFilter(items, _query, _searchBy),
              isCompact: isCompact,
              onToggleFavorite: _toggleFavorite,
              onToggleLock: _toggleLock,
              onEdit: _editCrew,
              onDelete: _confirmDelete,
              onOpenDetails: _showCrewDetails,
              onPhotoTap: _showLargePhoto,
            ),
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
              onPressed: _createCrew,
              tooltip: l10n.createCrewTitle,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }

  List<CrewRow> _applySearchFilter(
    List<CrewRow> source,
    String query,
    CrewSearchBy searchBy,
  ) {
    final normalized = normalizeCrewSearch(query);
    if (normalized.isEmpty) return source;

    bool matches(CrewRow row) {
      final name = normalizeCrewSearch(row.crew.name);
      final email = normalizeCrewSearch(row.crew.email ?? '');
      final phone = normalizeCrewSearch(row.crew.phone ?? '');
      final notes = normalizeCrewSearch(row.crew.notes ?? '');

      switch (searchBy) {
        case CrewSearchBy.name:
          return name.contains(normalized);
        case CrewSearchBy.email:
          return email.contains(normalized);
        case CrewSearchBy.phone:
          return phone.contains(normalized);
        case CrewSearchBy.notes:
          return notes.contains(normalized);
        case CrewSearchBy.all:
          return name.contains(normalized) ||
              email.contains(normalized) ||
              phone.contains(normalized) ||
              notes.contains(normalized);
      }
    }

    return source.where(matches).toList(growable: false);
  }
}
