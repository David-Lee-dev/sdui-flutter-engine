/// Defines the canonical `_on` event vocabulary by owning widget or wrapper.
///
/// Compilation, routing, and validation share these sets to prevent their event
/// definitions from diverging.
final class InteractionEvents {
  const InteractionEvents._();

  /// Gesture events supported by the interaction wrapper.
  static const Set<String> gesture = {'tap', 'double_tap', 'long_press'};

  /// Value events supported by bound input widgets.
  static const Set<String> input = {'change', 'submit'};

  /// Events that bubble from scrollable subtrees.
  static const Set<String> scroll = {'end_reached', 'start_reached', 'scroll'};

  /// All recognized interaction events used during compilation.
  static const Set<String> all = {...gesture, ...input, ...scroll};
}
