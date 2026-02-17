import 'validation_result.dart';

abstract class DataController<T, C> {
  Future<ValidationResult> validateCreate(C companion);
  Future<ValidationResult> validateUpdate(T item);
  Future<ValidationResult> validateDelete(T item);
  Future<int?> create(C companion);
  Future<void> update(T item);
  Future<void> delete(T item);
}
