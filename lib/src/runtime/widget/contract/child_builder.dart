import 'package:flutter/widgets.dart';

/// Builds child [index] on demand with optional variables for its local scope.
typedef ChildBuilder = Widget? Function(int index, {Map<String, Object?> vars});
