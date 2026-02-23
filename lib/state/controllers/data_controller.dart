import 'package:simplelog/state/controllers/validation_result.dart';

/// Generic CRUD controller contract used by presentation flows.
abstract class DataController<T, C> {
  /// Validates a create command before persisting.
  Future<ValidationResult> validateCreate(C companion);

  /// Validates an update command before persisting.
  Future<ValidationResult> validateUpdate(T item);

  /// Validates a delete command before executing.
  Future<ValidationResult> validateDelete(T item);

  /// Persists a new entity and returns its id when available.
  Future<int?> create(C companion);

  /// Persists changes for an existing entity.
  Future<void> update(T item);

  /// Deletes an existing entity.
  Future<void> delete(T item);
}
