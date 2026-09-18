/// Exposes the transactional state capability needed by action drivers.
abstract class StateWriter {
  void commit(Map<String, Object?> changes);
}
