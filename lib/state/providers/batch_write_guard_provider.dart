import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks active batch write operations to guard app navigation/exit.
class BatchWriteGuardController extends Notifier<int> {
  @override
  int build() => 0;

  /// Marks the start of a guarded batch write operation.
  void enter() {
    state = state + 1;
  }

  /// Marks completion of a guarded batch write operation.
  void exit() {
    if (state <= 0) {
      state = 0;
      return;
    }
    state = state - 1;
  }
}

/// Internal active-operation counter.
final NotifierProvider<BatchWriteGuardController, int>
batchWriteGuardControllerProvider =
    NotifierProvider<BatchWriteGuardController, int>(
      BatchWriteGuardController.new,
    );

/// Whether a guarded batch write operation is currently running.
final isBatchWriteInProgressProvider = Provider<bool>((ref) {
  return ref.watch(batchWriteGuardControllerProvider) > 0;
});
