import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/database/enums/crew_position.dart';
import 'package:simplelog/features/logbook/presentation/widgets/add_crew_dialog.dart';

void main() {
  Widget host({
    required Future<CrewDraftSelection?> Function(BuildContext context) open,
    required ValueChanged<CrewDraftSelection?> onResult,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                final result = await open(context);
                onResult(result);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('add crew dialog returns selected crew and position', (
    tester,
  ) async {
    CrewDraftSelection? received;
    await tester.pumpWidget(
      host(
        open: (context) => showAddCrewDialog(
          context: context,
          crewLabel: (crewId) => crewId == null ? 'Not selected' : 'Self',
          initialCrewId: 1,
        ),
        onResult: (result) => received = result,
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Add crew'), findsOneWidget);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(received, isNotNull);
    expect(received!.crewId, 1);
    expect(received!.position, CrewPosition.other);
  });

  testWidgets('add crew dialog closes with null when pressing close', (
    tester,
  ) async {
    CrewDraftSelection? received = const CrewDraftSelection(
      crewId: 99,
      position: CrewPosition.pic,
    );
    await tester.pumpWidget(
      host(
        open: (context) => showAddCrewDialog(
          context: context,
          crewLabel: (crewId) => crewId == null ? 'Not selected' : 'Self',
          initialCrewId: 1,
        ),
        onResult: (result) => received = result,
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Add crew'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    expect(received, isNull);
  });
}
