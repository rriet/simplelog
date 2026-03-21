import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/data/models/crew_extensions.dart';
import 'package:simplelog/data/models/crew_row.dart';
import 'package:simplelog/domain/usecases/logbook_use_cases.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_lazy_panel.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entry_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays crew details with quick contact actions and related logbook items.
class CrewInfoDialog {
  const CrewInfoDialog._();

  /// Opens the crew information dialog for the selected [row].
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

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: SizedBox(
          width: 420,
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context)!.screenCrew),
                trailing: TextButton(
                  onPressed: () => AppNavigator.pop(dialogContext),
                  child: Text(AppLocalizations.of(context)!.reportsDone),
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
                        child: LogbookEntriesLazyPanel(
                          pageLoader: (limit, offset) =>
                              useCases.fetchEntriesForCrewPage(
                                row.crew.id,
                                limit: limit,
                                offset: offset,
                              ),
                          summaryLoader: () =>
                              useCases.fetchFlightSummaryForCrew(row.crew.id),
                          onEntryTap: (entry) => LogbookEntryDialogs.show(
                            context,
                            entry: entry,
                            useCases: useCases,
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
                _buildContactActionTile(
                  context: context,
                  icon: Icons.phone,
                  title: l10n.callNumber,
                  subtitle: phoneDisplay,
                  onTap: () async {
                    AppNavigator.pop(context);
                    await launchUrl(Uri(scheme: 'tel', path: phone));
                  },
                ),
                _buildContactActionTile(
                  context: context,
                  icon: Icons.message,
                  title: l10n.textNumber,
                  subtitle: phoneDisplay,
                  onTap: () async {
                    AppNavigator.pop(context);
                    await launchUrl(Uri(scheme: 'sms', path: phone));
                  },
                ),
                _buildContactActionTile(
                  context: context,
                  icon: Icons.copy,
                  title: l10n.copyNumber,
                  subtitle: phoneDisplay,
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: phone));
                    if (context.mounted) AppNavigator.pop(context);
                  },
                ),
              ],
              if (email.isNotEmpty) ...[
                _buildContactActionTile(
                  context: context,
                  icon: Icons.email,
                  title: l10n.sendEmail,
                  subtitle: email,
                  onTap: () async {
                    AppNavigator.pop(context);
                    await launchUrl(Uri(scheme: 'mailto', path: email));
                  },
                ),
                _buildContactActionTile(
                  context: context,
                  icon: Icons.copy,
                  title: l10n.copyEmail,
                  subtitle: email,
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: email));
                    if (context.mounted) AppNavigator.pop(context);
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

  static Widget _buildContactActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Future<void> Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () async => onTap(),
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
                _ContactLinkRow(
                  icon: Icons.phone,
                  text: phoneDisplay,
                  onTap: onPhoneTap,
                ),
              ],
              if (email.isNotEmpty) ...[
                const SizedBox(height: 4),
                _ContactLinkRow(
                  icon: Icons.email,
                  text: email,
                  onTap: onEmailTap,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactLinkRow extends StatelessWidget {
  const _ContactLinkRow({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
