/// Identifies the render protocol produced by a widget or layout strategy.
///
/// Box and sliver children must match their parent's protocol. The template
/// validator tracks this value so incompatible placement fails at mount time
/// instead of triggering a Flutter render assertion outside node isolation.
enum LayoutProtocol { box, sliver }
