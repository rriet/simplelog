import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/adaptive_form_shell.dart';

Widget _testHost({
  required double width,
  required bool fullScreen,
  Widget? leading,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: Size(width, 800),
    ),
    child: MaterialApp(
      home: AdaptiveFormShell(
        onClose: () {},
        title: 'title',
        fullScreen: fullScreen,
        leading: leading,
        actions: const [Text('Action')],
        contentView: const SizedBox(height: 120, child: Text('Content')),
      ),
    ),
  );
}

void main() {
  testWidgets('compact + fullScreen=true uses scaffold presentation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testHost(
        width: 390,
        fullScreen: true,
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('title'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
  });

  testWidgets('compact + fullScreen=false uses popup presentation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testHost(
        width: 390,
        fullScreen: false,
      ),
    );

    expect(find.byType(Scaffold), findsNothing);
    expect(find.text('title'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
  });

  testWidgets('wide screen uses popup presentation with long title', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testHost(
        width: 1200,
        fullScreen: true,
      ),
    );

    expect(find.byType(Scaffold), findsNothing);
    expect(find.text('title'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
  });

  testWidgets('custom leading overrides default close/back control', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testHost(
        width: 1200,
        fullScreen: true,
        leading: const SizedBox.shrink(),
      ),
    );

    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.text('title'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
  });
}
