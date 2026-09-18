/// Reports a structural or syntactic template failure during parsing or compilation.
///
/// This exception represents a template defect rather than a data-dependent
/// interpretation failure. [path] identifies the failing tree position and
/// [message] describes the violation.
final class InvalidTemplateException implements Exception {
  const InvalidTemplateException(this.path, this.message);

  /// The tree path of the failing node.
  final String path;

  /// A description of the template violation.
  final String message;

  @override
  String toString() => 'InvalidTemplateException at $path: $message';
}
