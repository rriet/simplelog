import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/features/crew/application/providers/crew_feature_providers.dart';

import 'package:simplelog/data/database/app_database.dart';
import 'package:simplelog/presentation/shared/widgets/form_text_field.dart';
import 'package:simplelog/state/controllers/validation_result.dart';

class CrewEditScreen extends ConsumerStatefulWidget {
  const CrewEditScreen({
    super.key,
    required this.item,
    this.isCreate = false,
  });

  final CrewData item;
  final bool isCreate;

  @override
  ConsumerState<CrewEditScreen> createState() => _CrewEditScreenState();
}

class _CrewEditScreenState extends ConsumerState<CrewEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _notesController;
  late final TextEditingController _phoneController;
  late bool _isSelf;
  late bool _isFavorite;
  Uint8List? _pictureBytes;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController =
        TextEditingController(text: widget.isCreate ? '' : item.name);
    _emailController =
        TextEditingController(text: widget.isCreate ? '' : (item.email ?? ''));
    _notesController =
        TextEditingController(text: widget.isCreate ? '' : (item.notes ?? ''));
    _phoneController =
        TextEditingController(text: widget.isCreate ? '' : (item.phone ?? ''));
    _isSelf = widget.isCreate ? false : item.isSelf;
    _isFavorite = widget.isCreate ? false : item.isFavorite;
    _pictureBytes = widget.isCreate ? null : item.picture;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim().isEmpty
        ? const Value(null)
        : Value(_emailController.text.trim());
    final notes = _notesController.text.trim().isEmpty
        ? const Value(null)
        : Value(_notesController.text.trim());
    final phone = _phoneController.text.trim().isEmpty
        ? const Value(null)
        : Value(_phoneController.text.trim());
    final picture = _pictureBytes == null
        ? const Value<Uint8List?>(null)
        : Value(_pictureBytes);

    final controller = ref.read(crewDataControllerProvider.notifier);
    ValidationResult validation;

    if (widget.isCreate) {
      final companion = CrewCompanion.insert(
        name: name,
        email: email,
        notes: notes,
        phone: phone,
        picture: picture,
        isSelf: _isSelf,
        isFavorite: _isFavorite,
        isLocked: false,
      );
      validation = await controller.validateCreate(companion);
      if (!validation.isValid) {
        await _showValidationError(validation);
        return;
      }
      await controller.create(companion);
    } else {
      final item = widget.item;
      final updated = item.copyWith(
        name: name,
        email: email,
        notes: notes,
        phone: phone,
        picture: picture,
        isSelf: _isSelf,
        isFavorite: _isFavorite,
      );
      validation = await controller.validateUpdate(updated);
      if (!validation.isValid) {
        await _showValidationError(validation);
        return;
      }
      await controller.update(updated);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
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

  Future<void> _pickAndCrop(ImageSource source) async {
    final bytes = await Navigator.of(context, rootNavigator: true)
        .push<Uint8List?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _PhotoPickRoute(
          source: source,
          title: AppLocalizations.of(context)!.cropPhotoTitle,
        ),
      ),
    );

    if (!mounted || bytes == null) {
      return;
    }
    setState(() => _pictureBytes = bytes);
  }

  Future<void> _pickFromFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final bytes = result.files.first.bytes;
    if (bytes == null || !mounted) {
      return;
    }
    setState(() => _pictureBytes = bytes);
  }

  Future<void> _showPhotoMenu({
    required String cameraLabel,
    required String galleryLabel,
    required String removeLabel,
  }) async {
    final isDesktop = Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux;
    final selection = await showModalBottomSheet<_PhotoAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDesktop)
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(cameraLabel),
                onTap: () => Navigator.of(context).pop(_PhotoAction.camera),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(galleryLabel),
              onTap: () => Navigator.of(context).pop(_PhotoAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(removeLabel),
              enabled: _pictureBytes != null,
              onTap: () => Navigator.of(context).pop(_PhotoAction.remove),
            ),
          ],
        ),
      ),
    );

    switch (selection) {
      case _PhotoAction.camera:
        await _pickAndCrop(ImageSource.camera);
        break;
      case _PhotoAction.gallery:
        if (isDesktop) {
          await _pickFromFiles();
        } else {
          await _pickAndCrop(ImageSource.gallery);
        }
        break;
      case _PhotoAction.remove:
        setState(() => _pictureBytes = null);
        break;
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreate ? l10n.createCrewTitle : l10n.editCrewTitle),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.saveAction),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PictureField(
              label: l10n.fieldPicture,
              bytes: _pictureBytes,
              hint: l10n.pictureHint,
              onTap: () => _showPhotoMenu(
                cameraLabel: l10n.photoCamera,
                galleryLabel: l10n.photoLibrary,
                removeLabel: l10n.removePicture,
              ),
            ),
            FormTextField(
              controller: _nameController,
              label: l10n.fieldName,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.nameRequired;
                }
                return null;
              },
            ),
            FormTextField(
              controller: _emailController,
              label: l10n.fieldEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            FormTextField(
              controller: _phoneController,
              label: l10n.fieldPhone,
              keyboardType: TextInputType.phone,
            ),
            FormTextField(
              controller: _notesController,
              label: l10n.fieldNotes,
              maxLines: 4,
            ),
            SwitchListTile(
              title: Text(l10n.fieldIsSelf),
              value: _isSelf,
              onChanged: (value) => setState(() => _isSelf = value),
            ),
            SwitchListTile(
              title: Text(l10n.fieldIsFavorite),
              value: _isFavorite,
              onChanged: (value) => setState(() => _isFavorite = value),
            ),
          ],
        ),
      ),
    );
  }
}


class _PictureField extends StatelessWidget {
  const _PictureField({
    required this.label,
    required this.bytes,
    required this.hint,
    required this.onTap,
  });

  final String label;
  final Uint8List? bytes;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(48),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundImage:
                            bytes == null ? null : MemoryImage(bytes!),
                        child: bytes == null
                            ? const Icon(Icons.person, size: 36)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _PhotoAction { camera, gallery, remove }

class _PhotoPickRoute extends StatefulWidget {
  const _PhotoPickRoute({
    required this.source,
    required this.title,
  });

  final ImageSource source;
  final String title;

  @override
  State<_PhotoPickRoute> createState() => _PhotoPickRouteState();
}

class _PhotoPickRouteState extends State<_PhotoPickRoute> {
  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: widget.source);
    if (!mounted) {
      return;
    }
    if (file == null) {
      Navigator.of(context).pop();
      return;
    }

    final sourcePath = await _prepareSourcePath(file.path);
    if (widget.source == ImageSource.camera &&
        defaultTargetPlatform == TargetPlatform.iOS) {
      final bytes = await File(sourcePath).readAsBytes();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(bytes);
      return;
    }
    CroppedFile? cropped;
    try {
      cropped = await ImageCropper()
          .cropImage(
            sourcePath: sourcePath,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: widget.title,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                title: widget.title,
              ),
            ],
          )
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      final bytes = await File(sourcePath).readAsBytes();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(bytes);
      return;
    } catch (_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      return;
    }

    if (!mounted) {
      return;
    }

    if (cropped == null) {
      Navigator.of(context).pop();
      return;
    }

    final bytes = await cropped.readAsBytes();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(bytes);
  }

  Future<String> _prepareSourcePath(String path) async {
    if (widget.source != ImageSource.camera ||
        defaultTargetPlatform != TargetPlatform.iOS) {
      return path;
    }
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}/crew_camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(path).copy(tempPath);
      return tempPath;
    } catch (_) {
      return path;
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
