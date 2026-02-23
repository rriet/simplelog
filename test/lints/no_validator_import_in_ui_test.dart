import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UI screens/widgets must not import *validator* files', () async {
    final projectRoot = Directory.current.path;
    final libDir = Directory('$projectRoot/lib');
    final violations = <String>[];

    await for (final entity in libDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      final path = entity.path;
      if (!path.endsWith('.dart')) continue;
      if (!path.endsWith('_screen.dart') && !path.endsWith('_widget.dart')) {
        continue;
      }

      final content = await entity.readAsString();
      final lines = content.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (!line.trimLeft().startsWith('import ')) continue;
        if (line.toLowerCase().contains('validator')) {
          final relativePath = path.replaceFirst('$projectRoot/', '');
          violations.add('$relativePath:${i + 1}: $line');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Validator imports are not allowed in *_screen.dart '
          'or *_widget.dart files.\n'
          '${violations.join('\n')}',
    );
  });
}
