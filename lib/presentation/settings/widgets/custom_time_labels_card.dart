import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/riverpod/async_value_compat_extensions.dart';
import 'package:simplelog/state/providers/custom_time_labels_provider.dart';

class CustomTimeLabelsCard extends ConsumerStatefulWidget {
  const CustomTimeLabelsCard({super.key});

  @override
  ConsumerState<CustomTimeLabelsCard> createState() =>
      _CustomTimeLabelsCardState();
}

class _CustomTimeLabelsCardState extends ConsumerState<CustomTimeLabelsCard> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  final _c3 = TextEditingController();
  final _c4 = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    _c4.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = CustomTimeLabels(
      custom1: _c1.text.trim().isEmpty ? 'Custom 1' : _c1.text.trim(),
      custom2: _c2.text.trim().isEmpty ? 'Custom 2' : _c2.text.trim(),
      custom3: _c3.text.trim().isEmpty ? 'Custom 3' : _c3.text.trim(),
      custom4: _c4.text.trim().isEmpty ? 'Custom 4' : _c4.text.trim(),
    );
    await ref.read(customTimeLabelsProvider.notifier).setLabels(value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom time labels saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelsAsync = ref.watch(customTimeLabelsProvider);
    final labels = labelsAsync.valueOrNull;
    if (!_loaded && labels != null) {
      _c1.text = labels.custom1;
      _c2.text = labels.custom2;
      _c3.text = labels.custom3;
      _c4.text = labels.custom4;
      _loaded = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Time Labels',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _c1,
          decoration: const InputDecoration(labelText: 'Custom 1'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _c2,
          decoration: const InputDecoration(labelText: 'Custom 2'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _c3,
          decoration: const InputDecoration(labelText: 'Custom 3'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _c4,
          decoration: const InputDecoration(labelText: 'Custom 4'),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: labelsAsync.isLoading ? null : _save,
            child: const Text('Save Labels'),
          ),
        ),
      ],
    );
  }
}
