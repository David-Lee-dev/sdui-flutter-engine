/// Converts a template number to an `int` by truncation, or `null` when [v]
/// is not a finite number.
///
/// Every count, index, width and precision a template supplies goes through
/// this, so `NaN` and `±Infinity` (for example `10.0 ** 400`) are one
/// invalid case at each site instead of a Dart `UnsupportedError`. Finite
/// values beyond the `int` range saturate, as `toInt` does.
int? templateInt(Object? v) {
  if (v is int) return v;
  if (v is num && v.isFinite) return v.toInt();
  return null;
}
