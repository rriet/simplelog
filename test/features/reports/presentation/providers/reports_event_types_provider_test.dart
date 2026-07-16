import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/features/reports/presentation/providers/reports_preferences_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reports event type selection defaults positioning to true', () {
    const selection = ReportsEventTypesSelection();
    expect(selection.positioning, isTrue);
  });

  test(
    'reports event type selection keeps positioning true when key missing',
    () {
      final selection = ReportsEventTypesSelection.fromJson(const {
        'flights': true,
        'simulator': true,
        'duty': true,
      });
      expect(selection.positioning, isTrue);
    },
  );

  test('reports event type selection honors explicit positioning false', () {
    final selection = ReportsEventTypesSelection.fromJson(const {
      'flights': true,
      'simulator': true,
      'duty': true,
      'positioning': false,
    });
    expect(selection.positioning, isFalse);
  });

  test('reports event types provider starts with positioning enabled', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(reportsEventTypesProvider);
    expect(state.positioning, isTrue);
  });
}
