import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/features/logbook/application/providers/logbook_feature_providers.dart';
import 'package:simplelog/features/crew/application/providers/crew_feature_providers.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/data/models/crew_extensions.dart';
import 'package:simplelog/core/constants/app_constants.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_year_list.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';
import 'package:simplelog/presentation/shared/widgets/logbook_summary_panel.dart';
import 'package:simplelog/state/controllers/validation_result.dart';
import 'crew_edit_screen.dart';
import 'widgets/crew_search_bar.dart';
import 'widgets/crew_list.dart';

class CrewScreen extends ConsumerStatefulWidget {
  const CrewScreen({super.key});

  @override
  ConsumerState<CrewScreen> createState() => _CrewScreenState();
}

class _CrewScreenState extends ConsumerState<CrewScreen> {
  final _searchController = TextEditingController();
  String _query = '';

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
        content: Text(
          l10n.confirmDeleteCrew(row.name),
        ),
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

  Future<void> _showCrewDetails(CrewRow row) async {
    final l10n = AppLocalizations.of(context)!;
    final logbookUseCases = ref.read(logbookUseCasesProvider);
    final phone = (row.crew.phone ?? '').trim();
    final email = (row.crew.email ?? '').trim();
    final entriesFuture = logbookUseCases.fetchEntriesForCrew(row.crew.id);

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 420,
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              ListTile(
                title: const Text('Crew'),
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _CrewDetailHeader(
                        row: row,
                        onPhotoTap: () => _showLargePhoto(row),
                      ),
                      const SizedBox(height: 12),
                      if (phone.isNotEmpty)
                        InkWell(
                          onTap: () => _showContactMenu(phone: phone, email: ''),
                          child: Row(
                            children: [
                              const Icon(Icons.phone, size: 18),
                              const SizedBox(width: 8),
                              Text('${l10n.fieldPhone}: $phone'),
                            ],
                          ),
                        ),
                      if (phone.isNotEmpty) const SizedBox(height: 6),
                      if (email.isNotEmpty)
                        InkWell(
                          onTap: () => _showContactMenu(phone: '', email: email),
                          child: Row(
                            children: [
                              const Icon(Icons.email, size: 18),
                              const SizedBox(width: 8),
                              Text('${l10n.fieldEmail}: $email'),
                            ],
                          ),
                        ),
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                            return Column(
                              children: [
                                LogbookSummaryPanel(entries: entries),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: LogbookEntriesYearList(
                                    entries: entries,
                                    onEntryTap: (entry) => LogbookEntryDialogs.show(
                                      context,
                                      entry: entry,
                                      useCases: logbookUseCases,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
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

  Future<void> _showContactMenu({
    required String phone,
    required String email,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (phone.isEmpty && email.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (phone.isNotEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(l10n.callNumber),
                  subtitle: Text(phone),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final uri = Uri(scheme: 'tel', path: phone);
                    await launchUrl(uri);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.message),
                  title: Text(l10n.textNumber),
                  subtitle: Text(phone),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final uri = Uri(scheme: 'sms', path: phone);
                    await launchUrl(uri);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: Text(l10n.copyNumber),
                  subtitle: Text(phone),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: phone));
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
              if (email.isNotEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(l10n.sendEmail),
                  subtitle: Text(email),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final uri = Uri(scheme: 'mailto', path: email);
                    await launchUrl(uri);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: Text(l10n.copyEmail),
                  subtitle: Text(email),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: email));
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
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
    final placeholder = CrewData(
      id: kPlaceholderId,
      name: '',
      email: null,
      notes: null,
      phone: null,
      picture: null,
      isSelf: false,
      isFavorite: false,
      isLocked: false,
    );

    if (isCompact) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CrewEditScreen(
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
          child: CrewEditScreen(
            item: placeholder,
            isCreate: true,
          ),
        ),
      ),
    );
  }

  Future<void> _editCrew(CrewRow row) async {
    final isCompact = MediaQuery.of(context).size.width < 600;

    if (isCompact) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CrewEditScreen(
            item: row.crew,
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
          child: CrewEditScreen(
            item: row.crew,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final crew = ref.watch(crewProvider(_query));
    final isCompact = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        CrewSearchBar(
          controller: _searchController,
          label: l10n.searchCrew,
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: crew.when(
            data: (items) => CrewList(
              items: items,
              isCompact: isCompact,
              onToggleFavorite: _toggleFavorite,
              onToggleLock: _toggleLock,
              onEdit: _editCrew,
              onDelete: _confirmDelete,
              onOpenDetails: _showCrewDetails,
              onPhotoTap: _showLargePhoto,
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
              onPressed: _createCrew,
              tooltip: l10n.createCrewTitle,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}

class _CrewDetailHeader extends StatelessWidget {
  const _CrewDetailHeader({
    required this.row,
    required this.onPhotoTap,
  });

  final CrewRow row;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final bytes = row.crew.picture;
    return Column(
      children: [
        GestureDetector(
          onTap: onPhotoTap,
          child: CircleAvatar(
            radius: 40,
            backgroundImage: bytes == null ? null : MemoryImage(bytes),
            child: bytes == null
                ? Text(
                    row.crew.initials,
                    style: Theme.of(context).textTheme.titleMedium,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          row.crew.name,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
