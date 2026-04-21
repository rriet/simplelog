import 'package:flutter_test/flutter_test.dart';
import 'package:simplelog/core/flight/ifr_calculation.dart';

void main() {
  test('subtracts minutes before applying IFR percentage', () {
    final result = calculateIfrMinutes(
      totalMinutes: 120,
      percent: 50,
      subtractMinutes: 30,
      minimumMinutes: 40,
    );

    expect(result, 45);
  });

  test('enforces minimum after subtraction and percentage', () {
    final result = calculateIfrMinutes(
      totalMinutes: 60,
      percent: 50,
      subtractMinutes: 20,
      minimumMinutes: 30,
    );

    expect(result, 30);
  });

  test('never exceeds total block minutes', () {
    final result = calculateIfrMinutes(
      totalMinutes: 20,
      percent: 100,
      subtractMinutes: 0,
      minimumMinutes: 40,
    );

    expect(result, 20);
  });

  test('clamps negative intermediate values to zero', () {
    final result = calculateIfrMinutes(
      totalMinutes: 10,
      percent: 100,
      subtractMinutes: 20,
      minimumMinutes: 0,
    );

    expect(result, 0);
  });
}
