import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/crew_extensions.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_year_list.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';
import 'package:simplelog/presentation/shared/widgets/logbook_summary_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class CrewInfoDialog {
  const CrewInfoDialog._();

  static Future<void> show(
    BuildContext context, {
    required CrewRow row,
    required LogbookUseCases useCases,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final phone = (row.crew.phone ?? '').trim();
    final phoneDisplay = row.crew.formattedPhone;
    final email = (row.crew.email ?? '').trim();
    final notes = (row.crew.notes ?? '').trim();
    final entriesFuture = useCases.fetchEntriesForCrew(row.crew.id);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: SizedBox(
          width: 420,
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              ListTile(
                title: const Text('Crew'),
                trailing: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
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
                        phoneDisplay: phoneDisplay,
                        email: email,
                        onPhoneTap: phone.isEmpty
                            ? null
                            : () => _showContactMenu(
                                  dialogContext,
                                  phone: phone,
                                  email: '',
                                ),
                        onEmailTap: email.isEmpty
                            ? null
                            : () => _showContactMenu(
                                  dialogContext,
                                  phone: '',
                                  email: email,
                                ),
                        onPhotoTap: () => _showLargePhoto(dialogContext, row),
                      ),
                      const SizedBox(height: 12),
                      if (notes.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.fieldNotes,
                            style: Theme.of(dialogContext).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            notes,
                            style: Theme.of(dialogContext).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.screenLogbook,
                          style: Theme.of(dialogContext).textTheme.titleSmall,
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
                              return Center(child: Text(l10n.emptyResults));
                            }
                            return Column(
                              children: [
                                LogbookSummaryPanel(entries: entries),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: LogbookEntriesYearList(
                                    entries: entries,
                                    onEntryTap: (entry) =>
                                        LogbookEntryDialogs.show(
                                      context,
                                      entry: entry,
                                      useCases: useCases,
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

  static Future<void> _showContactMenu(
    BuildContext context, {
    required String phone,
    required String email,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (phone.isEmpty && email.isEmpty) return;
    final phoneDisplay = formatPhoneDisplay(phone);

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
                  subtitle: Text(phoneDisplay),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await launchUrl(Uri(scheme: 'tel', path: phone));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.message),
                  title: Text(l10n.textNumber),
                  subtitle: Text(phoneDisplay),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await launchUrl(Uri(scheme: 'sms', path: phone));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: Text(l10n.copyNumber),
                  subtitle: Text(phoneDisplay),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: phone));
                    if (context.mounted) Navigator.of(context).pop();
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
                    await launchUrl(Uri(scheme: 'mailto', path: email));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: Text(l10n.copyEmail),
                  subtitle: Text(email),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: email));
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static Future<void> _showLargePhoto(BuildContext context, CrewRow row) async {
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
}

class _CrewDetailHeader extends StatelessWidget {
  const _CrewDetailHeader({
    required this.row,
    required this.phoneDisplay,
    required this.email,
    required this.onPhoneTap,
    required this.onEmailTap,
    required this.onPhotoTap,
  });

  final CrewRow row;
  final String phoneDisplay;
  final String email;
  final VoidCallback? onPhoneTap;
  final VoidCallback? onEmailTap;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final bytes = row.crew.picture;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.crew.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (phoneDisplay.isNotEmpty) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: onPhoneTap,
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          phoneDisplay,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (email.isNotEmpty) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: onEmailTap,
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      const Icon(Icons.email, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
