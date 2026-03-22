import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/app_message_dialog.dart';
import 'package:simplelog/features/database/application/automatic_backup_service.dart';

/// Dialog to configure automatic backup destination and retention.
class AutomaticBackupSettingsDialog extends StatefulWidget {
  /// Creates automatic backup settings dialog.
  const AutomaticBackupSettingsDialog({super.key});

  /// Opens the settings dialog.
  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const AutomaticBackupSettingsDialog(),
    );
  }

  @override
  State<AutomaticBackupSettingsDialog> createState() =>
      _AutomaticBackupSettingsDialogState();
}

class _AutomaticBackupSettingsDialogState
    extends State<AutomaticBackupSettingsDialog> {
  final _destinationController = TextEditingController();
  final _versionsController = TextEditingController();
  bool _isLoading = true;
  bool _enabled = false;
  String _destinationFolder = '';

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _versionsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = await AutomaticBackupService.instance.loadSettings();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _enabled = settings.enabled;
      _destinationFolder = settings.destinationFolder;
      _destinationController.text = settings.destinationFolder;
      _versionsController.text = settings.maxVersions.toString();
    });
  }

  Future<void> _toggleEnabled() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_enabled && _destinationFolder.trim().isEmpty) {
      await showAppMessageDialog(
        context,
        message: l10n.databaseAutomaticBackupFolderRequired,
      );
      return;
    }
    setState(() {
      _enabled = !_enabled;
    });
  }

  Future<void> _pickFolder() async {
    final selectedPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: AppLocalizations.of(context)!.databaseAutomaticBackupTitle,
    );
    if (selectedPath == null || selectedPath.trim().isEmpty) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _destinationFolder = selectedPath.trim();
      _destinationController.text = _destinationFolder;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final parsedVersions = int.tryParse(_versionsController.text.trim());
    if (parsedVersions == null || parsedVersions < 1) {
      await showAppMessageDialog(
        context,
        message: l10n.databaseAutomaticBackupVersionsInvalid,
      );
      return;
    }
    if (_enabled && _destinationFolder.trim().isEmpty) {
      await showAppMessageDialog(
        context,
        message: l10n.databaseAutomaticBackupFolderRequired,
      );
      return;
    }
    await AutomaticBackupService.instance.saveSettings(
      AutomaticBackupSettings(
        enabled: _enabled,
        destinationFolder: _destinationFolder.trim(),
        maxVersions: parsedVersions,
      ),
    );
    if (!mounted) return;
    await showAppMessageDialog(
      context,
      message: l10n.databaseAutomaticBackupSaved,
    );
    if (!mounted) return;
    AppNavigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.databaseAutomaticBackupSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _enabled
                            ? l10n.databaseAutomaticBackupEnabledStatus
                            : l10n.databaseAutomaticBackupDisabledStatus,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _toggleEnabled,
                      icon: Icon(
                        _enabled ? Icons.toggle_on : Icons.toggle_off,
                      ),
                      label: Text(
                        _enabled
                            ? l10n.databaseAutomaticBackupDisableAction
                            : l10n.databaseAutomaticBackupEnableAction,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _destinationController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: l10n.databaseAutomaticBackupDestinationLabel,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _pickFolder,
                    icon: const Icon(Icons.folder_open),
                    label: Text(l10n.databaseAutomaticBackupChooseFolderAction),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _versionsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.databaseAutomaticBackupVersionsLabel,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
    );

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: l10n.databaseAutomaticBackupTitle,
      popupMaxWidth: 620,
      actions: [
        TextButton(
          onPressed: _save,
          child: Text(l10n.saveAction),
        ),
      ],
      contentView: content,
    );
  }
}
