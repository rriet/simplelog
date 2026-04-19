import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:croppy/croppy.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/navigation/app_navigator.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/dialog_adaptive_presenter.dart';
import 'package:simplelog/core/presentation/widgets/display/square_outline_button.dart';
import 'package:simplelog/features/reports/presentation/providers/reports_preferences_provider.dart';
import 'package:simplelog/features/settings/presentation/widgets/settings_expandable_info_trailing.dart';

/// Expandable settings card for pilot identity and signature preferences.
class PilotProfileSettingsCard extends ConsumerStatefulWidget {
  /// Creates the settings card.
  const PilotProfileSettingsCard({super.key, this.initiallyExpanded = false});

  /// Whether the expansion tile should start opened.
  final bool initiallyExpanded;

  @override
  ConsumerState<PilotProfileSettingsCard> createState() =>
      _PilotProfileSettingsCardState();
}

class _PilotProfileSettingsCardState
    extends ConsumerState<PilotProfileSettingsCard> {
  final ExpansibleController _expansionController = ExpansibleController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _licensesController = TextEditingController();
  late bool _isExpanded = widget.initiallyExpanded;
  bool _isHydrating = false;
  Timer? _saveDebounce;
  Uint8List? _signatureImage;
  ReportPilotInfo? _lastHydrated;

  bool get _canUseCamera {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _expansionController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _licensesController.dispose();
    super.dispose();
  }

  bool _sameProfile(ReportPilotInfo a, ReportPilotInfo b) {
    final aSignature = a.signatureImage;
    final bSignature = b.signatureImage;
    final signatureMatches =
        (aSignature == null && bSignature == null) ||
        (aSignature != null &&
            bSignature != null &&
            listEquals(aSignature, bSignature));
    return a.name == b.name &&
        a.address == b.address &&
        a.licenses == b.licenses &&
        signatureMatches;
  }

  void _hydrateFromProfileIfNeeded(ReportPilotInfo profile) {
    if (_lastHydrated != null && _sameProfile(_lastHydrated!, profile)) {
      return;
    }
    _isHydrating = true;
    _nameController.text = profile.name;
    _addressController.text = profile.address;
    _licensesController.text = profile.licenses;
    _signatureImage = profile.signatureImage;
    _lastHydrated = profile;
    _isHydrating = false;
  }

  ReportPilotInfo _draftProfile() {
    return ReportPilotInfo(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      licenses: _licensesController.text.trim(),
      signatureImage: _signatureImage,
    );
  }

  Future<void> _saveNow() async {
    final current = ref.read(reportPilotInfoProvider);
    final next = _draftProfile();
    if (_sameProfile(current, next)) return;
    await ref.read(reportPilotInfoProvider.notifier).setValue(value: next);
    _lastHydrated = next;
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_saveNow());
    });
  }

  Widget _buildEditableProfileField({
    required String label,
    required TextEditingController controller,
    int minLines = 1,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (_) {
        if (_isHydrating) return;
        _scheduleSave();
      },
      onEditingComplete: () => unawaited(_saveNow()),
    );
  }

  Future<void> _showSignatureOptions() async {
    final action = await showModalBottomSheet<_SignatureAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSignatureActionTile(
              context: context,
              icon: Icons.gesture,
              title: 'Sign on screen',
              action: _SignatureAction.sign,
            ),
            if (_canUseCamera)
              _buildSignatureActionTile(
                context: context,
                icon: Icons.photo_camera_outlined,
                title: 'Take picture',
                action: _SignatureAction.camera,
              ),
            _buildSignatureActionTile(
              context: context,
              icon: Icons.image_outlined,
              title: 'Select picture file',
              action: _SignatureAction.file,
            ),
            _buildSignatureActionTile(
              context: context,
              icon: Icons.delete_outline,
              title: 'Clear signature',
              action: _SignatureAction.clear,
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _SignatureAction.sign:
        final bytes = await showSmallDialogScreen<Uint8List>(
          context: context,
          builder: (_) => const _SignaturePadDialog(),
        );
        if (bytes != null && mounted) {
          final normalized = await _normalizeSignatureBytes(bytes);
          if (!mounted) return;
          setState(() => _signatureImage = normalized);
          await _saveNow();
        }
      case _SignatureAction.camera:
        await _pickFromCamera();
      case _SignatureAction.file:
        await _pickFromFile();
      case _SignatureAction.clear:
        setState(() => _signatureImage = null);
        await _saveNow();
    }
    if (!mounted) return;
  }

  Widget _buildSignatureActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required _SignatureAction action,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => AppNavigator.pop(context, action),
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (image == null || !mounted) return;
      final sourcePath = await _prepareCameraSourcePath(image.path);
      final bytes = await _cropOrReadBytes(sourcePath: sourcePath);
      final normalized = await _normalizeSignatureBytes(bytes);
      if (!mounted) return;
      setState(() => _signatureImage = normalized);
      await _saveNow();
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.autoUi014)),
      );
    }
  }

  Future<void> _pickFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || !mounted) return;
      final file = result.files.single;
      final sourcePath = await _resolveImagePath(
        path: file.path,
        bytes: file.bytes,
      );
      if (sourcePath == null) return;
      final bytes = await _cropOrReadBytes(sourcePath: sourcePath);
      final normalized = await _normalizeSignatureBytes(bytes);
      if (!mounted) return;
      setState(() => _signatureImage = normalized);
      await _saveNow();
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.autoUi015)),
      );
    }
  }

  Future<String?> _resolveImagePath({
    required String? path,
    required Uint8List? bytes,
  }) async {
    if (path != null && path.isNotEmpty) {
      return path;
    }
    if (bytes == null || bytes.isEmpty) {
      return null;
    }
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(filePath).writeAsBytes(bytes, flush: true);
    return filePath;
  }

  Future<String> _prepareCameraSourcePath(String path) async {
    if (!Platform.isIOS) {
      return path;
    }
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}/signature_camera_'
          '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(path).copy(tempPath);
      return tempPath;
    } on Object {
      return path;
    }
  }

  Future<Uint8List> _cropOrReadBytes({required String sourcePath}) async {
    try {
      final result = await showAdaptiveImageCropper(
        context,
        imageProvider: FileImage(File(sourcePath)),
        allowedAspectRatios: const [
          CropAspectRatio(width: 3, height: 1),
        ],
      );
      if (result == null) {
        return File(sourcePath).readAsBytes();
      }
      final byteData = await result.uiImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      result.uiImage.dispose();
      if (byteData == null) {
        return File(sourcePath).readAsBytes();
      }
      return byteData.buffer.asUint8List();
    } on Object {
      return File(sourcePath).readAsBytes();
    }
  }

  Future<Uint8List> _normalizeSignatureBytes(Uint8List inputBytes) async {
    const signatureOutputWidth = 1200;
    const signatureOutputHeight = 400;
    final codec = await ui.instantiateImageCodec(inputBytes);
    final frame = await codec.getNextFrame();
    final source = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final targetWidth = signatureOutputWidth.toDouble();
    final targetHeight = signatureOutputHeight.toDouble();
    const padding = 18.0;
    final usableWidth = targetWidth - (padding * 2);
    final usableHeight = targetHeight - (padding * 2);
    final sx = usableWidth / source.width;
    final sy = usableHeight / source.height;
    final scale = math.min(sx, sy);
    final drawWidth = source.width * scale;
    final drawHeight = source.height * scale;
    final left = (targetWidth - drawWidth) / 2;
    final top = (targetHeight - drawHeight) / 2;

    final srcRect = Rect.fromLTWH(
      0,
      0,
      source.width.toDouble(),
      source.height.toDouble(),
    );
    final dstRect = Rect.fromLTWH(left, top, drawWidth, drawHeight);
    canvas.drawImageRect(source, srcRect, dstRect, Paint());

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      signatureOutputWidth,
      signatureOutputHeight,
    );
    source.dispose();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData == null) {
      return inputBytes;
    }
    return byteData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(reportPilotInfoProvider);
    _hydrateFromProfileIfNeeded(profile);
    final hasSignature =
        _signatureImage != null && _signatureImage!.isNotEmpty;

    return Card(
      child: ExpansionTile(
        initiallyExpanded: widget.initiallyExpanded,
        controller: _expansionController,
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        title: Text(l10n.settingsCalculationPilotProfileTitle),
        trailing: SettingsExpandableInfoTrailing(
          controller: _expansionController,
          isExpanded: _isExpanded,
          helpTitle: l10n.settingsPilotProfileHelpTitle,
          helpMessage: l10n.settingsPilotProfileHelpBody,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        children: [
          _buildEditableProfileField(
            label: l10n.settingsPilotProfileNameLabel,
            controller: _nameController,
          ),
          const SizedBox(height: 8),
          _buildEditableProfileField(
            label: l10n.settingsPilotProfileAddressLabel,
            controller: _addressController,
            minLines: 2,
            maxLines: null,
          ),
          const SizedBox(height: 8),
          _buildEditableProfileField(
            label: l10n.settingsPilotProfileLicensesLabel,
            controller: _licensesController,
            minLines: 2,
            maxLines: null,
          ),
          const SizedBox(height: 10),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.autoUi056),
            subtitle: hasSignature
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: SizedBox(
                      height: 56,
                      child: Image.memory(
                        _signatureImage!,
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  )
                : Text(l10n.autoUi044),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: SquareOutlineButton(
              label: l10n.autoUi057,
              icon: Icons.edit_outlined,
              onPressed: _showSignatureOptions,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable button to open the pilot profile popup.
class PilotProfileEditButton extends ConsumerWidget {
  /// Creates an edit button.
  const PilotProfileEditButton({super.key, this.label = 'Edit pilot profile'});

  /// Button label.
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SquareOutlineButton(
      label: label,
      icon: Icons.badge_outlined,
      onPressed: () => showPilotProfileEditorDialog(context),
    );
  }
}

/// Opens the pilot profile editor dialog.
Future<void> showPilotProfileEditorDialog(
  BuildContext context,
) async {
  await showDialog<void>(
    context: context,
    builder: (_) => const _PilotProfileEditorDialog(),
  );
}

class _PilotProfileEditorDialog extends ConsumerStatefulWidget {
  const _PilotProfileEditorDialog();

  @override
  ConsumerState<_PilotProfileEditorDialog> createState() =>
      _PilotProfileEditorDialogState();
}

class _PilotProfileEditorDialogState
    extends ConsumerState<_PilotProfileEditorDialog> {
  static const _signatureOutputWidth = 1200;
  static const _signatureOutputHeight = 400;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _licensesController = TextEditingController();
  bool _userEditedText = false;
  bool _userEditedSignature = false;
  Uint8List? _signatureImage;

  bool get _canUseCamera {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _licensesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(reportPilotInfoProvider);
    if (!_userEditedText) {
      _nameController.text = profile.name;
      _addressController.text = profile.address;
      _licensesController.text = profile.licenses;
    }
    if (!_userEditedSignature) {
      _signatureImage = profile.signatureImage;
    }

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileTextField(
            controller: _nameController,
            label: 'Name',
            onChanged: () => _userEditedText = true,
          ),
          const SizedBox(height: 10),
          _buildProfileTextField(
            controller: _addressController,
            label: 'Address',
            onChanged: () => _userEditedText = true,
            minLines: 2,
            maxLines: null,
          ),
          const SizedBox(height: 10),
          _buildProfileTextField(
            controller: _licensesController,
            label: 'Licenses',
            onChanged: () => _userEditedText = true,
            minLines: 2,
            maxLines: null,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.autoUi056,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 150,
            decoration: _outlinedPanelDecoration(context),
            child: _signatureImage == null
                ? Center(child: Text(AppLocalizations.of(context)!.autoUi044))
                : Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.memory(
                      _signatureImage!,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          SquareOutlineButton(
            label: AppLocalizations.of(context)!.autoUi057,
            icon: Icons.draw_outlined,
            onPressed: _showSignatureOptions,
          ),
        ],
      ),
    );

    return AdaptiveFormShell(
      onClose: () => AppNavigator.pop(context),
      title: AppLocalizations.of(context)!.autoUi047,
      fullScreen: false,
      popupMaxWidth: 720,
      actions: [
        _buildSaveAction(),
      ],
      contentView: body,
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onChanged,
    int minLines = 1,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: (_) => onChanged(),
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildSaveAction() {
    return _buildDialogSaveAction(context: context, onPressed: _save);
  }

  Future<void> _save() async {
    final next = ReportPilotInfo(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      licenses: _licensesController.text.trim(),
      signatureImage: _signatureImage,
    );
    await ref.read(reportPilotInfoProvider.notifier).setValue(value: next);
    if (!mounted) {
      return;
    }
    AppNavigator.pop(context);
  }

  Future<void> _showSignatureOptions() async {
    final action = await showModalBottomSheet<_SignatureAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSignatureActionTile(
              context: context,
              icon: Icons.gesture,
              title: 'Sign on screen',
              action: _SignatureAction.sign,
            ),
            if (_canUseCamera)
              _buildSignatureActionTile(
                context: context,
                icon: Icons.photo_camera_outlined,
                title: 'Take picture',
                action: _SignatureAction.camera,
              ),
            _buildSignatureActionTile(
              context: context,
              icon: Icons.image_outlined,
              title: 'Select picture file',
              action: _SignatureAction.file,
            ),
            _buildSignatureActionTile(
              context: context,
              icon: Icons.delete_outline,
              title: 'Clear signature',
              action: _SignatureAction.clear,
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _SignatureAction.sign:
        final bytes = await showSmallDialogScreen<Uint8List>(
          context: context,
          builder: (_) => const _SignaturePadDialog(),
        );
        if (bytes != null && mounted) {
          final normalized = await _normalizeSignatureBytes(bytes);
          if (!mounted) return;
          _userEditedSignature = true;
          if (mounted) {
            setState(() => _signatureImage = normalized);
          }
        }
      case _SignatureAction.camera:
        await _pickFromCamera();
      case _SignatureAction.file:
        await _pickFromFile();
      case _SignatureAction.clear:
        _userEditedSignature = true;
        if (mounted) {
          setState(() => _signatureImage = null);
        }
    }
  }

  Widget _buildSignatureActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required _SignatureAction action,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => AppNavigator.pop(context, action),
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (image == null || !mounted) {
        return;
      }
      final sourcePath = await _prepareCameraSourcePath(image.path);
      final bytes = await _cropOrReadBytes(sourcePath: sourcePath);
      final normalized = await _normalizeSignatureBytes(bytes);
      if (!mounted) return;
      _userEditedSignature = true;
      if (mounted) {
        setState(() => _signatureImage = normalized);
      }
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.autoUi014)),
      );
    }
  }

  Future<void> _pickFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || !mounted) {
        return;
      }
      final file = result.files.single;
      final sourcePath = await _resolveImagePath(
        path: file.path,
        bytes: file.bytes,
      );
      if (sourcePath == null) {
        return;
      }
      final bytes = await _cropOrReadBytes(sourcePath: sourcePath);
      final normalized = await _normalizeSignatureBytes(bytes);
      if (!mounted) return;
      _userEditedSignature = true;
      if (mounted) {
        setState(() => _signatureImage = normalized);
      }
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.autoUi015)),
      );
    }
  }

  Future<String?> _resolveImagePath({
    required String? path,
    required Uint8List? bytes,
  }) async {
    if (path != null && path.isNotEmpty) {
      return path;
    }
    if (bytes == null || bytes.isEmpty) {
      return null;
    }
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(filePath).writeAsBytes(bytes, flush: true);
    return filePath;
  }

  Future<String> _prepareCameraSourcePath(String path) async {
    if (!Platform.isIOS) {
      return path;
    }
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}/signature_camera_'
          '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(path).copy(tempPath);
      return tempPath;
    } on Object {
      return path;
    }
  }

  Future<Uint8List> _cropOrReadBytes({required String sourcePath}) async {
    try {
      final result = await showAdaptiveImageCropper(
        context,
        imageProvider: FileImage(File(sourcePath)),
        allowedAspectRatios: const [
          CropAspectRatio(width: 3, height: 1),
        ],
      );
      if (result == null) {
        return File(sourcePath).readAsBytes();
      }
      final byteData = await result.uiImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      result.uiImage.dispose();
      if (byteData == null) {
        return File(sourcePath).readAsBytes();
      }
      return byteData.buffer.asUint8List();
    } on Object {
      return File(sourcePath).readAsBytes();
    }
  }

  Future<Uint8List> _normalizeSignatureBytes(Uint8List inputBytes) async {
    final codec = await ui.instantiateImageCodec(inputBytes);
    final frame = await codec.getNextFrame();
    final source = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final targetWidth = _signatureOutputWidth.toDouble();
    final targetHeight = _signatureOutputHeight.toDouble();
    const padding = 18.0;
    final usableWidth = targetWidth - (padding * 2);
    final usableHeight = targetHeight - (padding * 2);
    final sx = usableWidth / source.width;
    final sy = usableHeight / source.height;
    final scale = math.min(sx, sy);
    final drawWidth = source.width * scale;
    final drawHeight = source.height * scale;
    final left = (targetWidth - drawWidth) / 2;
    final top = (targetHeight - drawHeight) / 2;

    final srcRect = Rect.fromLTWH(
      0,
      0,
      source.width.toDouble(),
      source.height.toDouble(),
    );
    final dstRect = Rect.fromLTWH(left, top, drawWidth, drawHeight);
    canvas.drawImageRect(source, srcRect, dstRect, Paint());

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      _signatureOutputWidth,
      _signatureOutputHeight,
    );
    source.dispose();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData == null) {
      return inputBytes;
    }
    return byteData.buffer.asUint8List();
  }
}

enum _SignatureAction {
  sign,
  camera,
  file,
  clear,
}

class _SignaturePadDialog extends StatefulWidget {
  const _SignaturePadDialog();

  @override
  State<_SignaturePadDialog> createState() => _SignaturePadDialogState();
}

class _SignaturePadDialogState extends State<_SignaturePadDialog> {
  final List<List<Offset>> _strokes = <List<Offset>>[];
  Size _canvasSize = const Size(600, 200);
  static const _strokeWidth = 3.5;
  static const _outputWidth = 1200;
  static const _outputHeight = 400;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 760,
      child: AdaptiveFormShell(
        onClose: () => AppNavigator.pop(context),
        title: AppLocalizations.of(context)!.autoUi054,
        fullScreen: false,
        actions: [
          _buildDialogSaveAction(context: context, onPressed: _save),
        ],
        contentView: SizedBox(
          height: 420,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      var width = constraints.maxWidth;
                      var height = width / 3;
                      if (height > constraints.maxHeight) {
                        height = constraints.maxHeight;
                        width = height * 3;
                      }
                      _canvasSize = Size(width, height);
                      return Center(
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: Container(
                            decoration: _outlinedPanelDecoration(context),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanStart: (details) {
                                setState(() {
                                  _strokes.add(<Offset>[details.localPosition]);
                                });
                              },
                              onPanUpdate: (details) {
                                if (_strokes.isEmpty) {
                                  return;
                                }
                                setState(() {
                                  _strokes.last.add(details.localPosition);
                                });
                              },
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _SignaturePainter(strokes: _strokes),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SquareOutlineButton(
                    label: AppLocalizations.of(context)!.reportsClearAction,
                    icon: Icons.delete_outline,
                    onPressed: () => setState(_strokes.clear),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final bytes = await _exportSignaturePng();
    if (!mounted) {
      return;
    }
    AppNavigator.pop(context, bytes);
  }

  Future<Uint8List?> _exportSignaturePng() async {
    if (_strokes.isEmpty) {
      return null;
    }
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final scaleX = _outputWidth / _canvasSize.width;
    final scaleY = _outputHeight / _canvasSize.height;
    final strokeScale = (scaleX + scaleY) / 2;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = _strokeWidth * strokeScale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in _strokes) {
      if (stroke.length < 2) {
        if (stroke.isNotEmpty) {
          final point = Offset(
            stroke.first.dx * scaleX,
            stroke.first.dy * scaleY,
          );
          canvas.drawCircle(
            point,
            (_strokeWidth * strokeScale) * 0.75,
            Paint()..color = Colors.black,
          );
        }
        continue;
      }
      final first = stroke.first;
      final path = Path()..moveTo(first.dx * scaleX, first.dy * scaleY);
      for (var i = 1; i < stroke.length; i++) {
        final point = stroke[i];
        path.lineTo(point.dx * scaleX, point.dy * scaleY);
      }
      canvas.drawPath(path, paint);
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(_outputWidth, _outputHeight);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }
}

Widget _buildDialogSaveAction({
  required BuildContext context,
  required VoidCallback onPressed,
}) {
  return TextButton(
    onPressed: onPressed,
    child: Text(AppLocalizations.of(context)!.saveAction),
  );
}

BoxDecoration _outlinedPanelDecoration(BuildContext context) {
  return BoxDecoration(
    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    borderRadius: BorderRadius.circular(8),
  );
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter({required this.strokes});

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = _SignaturePadDialogState._strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.isEmpty) {
        continue;
      }
      if (stroke.length == 1) {
        canvas.drawCircle(
          stroke.first,
          _SignaturePadDialogState._strokeWidth * 0.75,
          Paint()..color = Colors.black,
        );
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        final point = stroke[i];
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}
