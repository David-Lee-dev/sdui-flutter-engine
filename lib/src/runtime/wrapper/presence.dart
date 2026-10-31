import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/presence_config.dart';
import '../engine_presentation.dart';
import '../environment/_base.dart';
import '../util/engine_curve.dart';

/// The presence phases a `_motion` entry plays in (`on:`).
enum MotionPhase { enter, exit, both }

/// How a presence slot holds a structural output.
enum PresenceMode {
  /// In a box that animates its size and clips while it does.
  box,

  /// As the direct widget of its parent, because the output is a parent-data
  /// widget (`expanded`, `positioned`, ...): exits are visual only and a
  /// leaving output is not shielded from input.
  inPlace,
}

/// A motion layer that plays in its nearest presence slot's phases.
abstract interface class PresenceMember {
  MotionPhase get phase;

  /// Whether the motion changes its own layout size (a reveal), so the slot
  /// leaves the space to it.
  bool get affectsLayout;

  /// Starts the exit run, the motion played backwards, and returns how long
  /// it takes.
  Duration playExit();

  /// Returns from an exit run to the rest state, at once unless [animate].
  void cancelExit({bool animate = true});
}

/// The presence slot a [PresenceMember] registers with.
abstract interface class PresenceHandle {
  void add(PresenceMember member);

  void remove(PresenceMember member);

  /// How long an entrance motion waits: in `sequential` order the slot
  /// expands first.
  Duration get enterDelay;

  /// A view of [outer] that serves the values it last read, and holds back
  /// change notifications, while the slot exits.
  Environment view(Environment outer);
}

/// Exposes the nearest presence slot to the subtree it holds.
class PresenceScope extends InheritedWidget {
  const PresenceScope._({
    super.key,
    required this.handle,
    required this.exiting,
    required super.child,
  });

  final PresenceHandle handle;

  /// Whether this slot, or one around it, is playing its exit.
  final bool exiting;

  /// The nearest slot, without depending on it.
  static PresenceHandle? handleOf(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<PresenceScope>()?.widget
              as PresenceScope?)
          ?.handle;

  /// Whether the subtree at [context] is leaving; rebuilds when it changes.
  static bool exitingOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PresenceScope>()?.exiting ??
      false;

  @override
  bool updateShouldNotify(PresenceScope oldWidget) =>
      exiting != oldWidget.exiting || handle != oldWidget.handle;
}

/// Turns the keyed output of a structural directive into enter, exit and
/// swap transitions.
///
/// Keys are compared with the previous build: a new key enters, a missing
/// key exits in its previous place, and a key that returns while exiting
/// reverses in place on the same element. [PresenceGroup.single] holds one
/// output (a swap shows both while the size goes from one to the other);
/// [PresenceGroup.list] holds each item in its own slot and hands them to
/// [builder]. The first build, reduced motion, muted tickers and a disabled
/// [config] never animate. A controller exists only while a slot moves.
class PresenceGroup extends StatefulWidget {
  PresenceGroup.single({
    super.key,
    required Object? childKey,
    required Widget? child,
    required this.config,
    this.mode = PresenceMode.box,
  }) : items = childKey == null || child == null
           ? const []
           : [(childKey, child)],
       builder = null,
       axis = null;

  const PresenceGroup.list({
    super.key,
    required this.items,
    required Widget Function(List<Widget>) this.builder,
    required Axis this.axis,
    required this.config,
    this.mode = PresenceMode.box,
  });

  final List<(Object, Widget)> items;

  /// Builds the list container from the item slots (list mode).
  final Widget Function(List<Widget>)? builder;

  /// The axis an item slot grows along (list mode); a single slot grows in
  /// both.
  final Axis? axis;

  final PresenceConfig config;

  final PresenceMode mode;

  /// Keeps every group under [context] instant for the rest of this frame:
  /// a scope reseed replaces values, it does not transition them.
  static void settleFrame(BuildContext context) {
    if (_settling.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _settling.clear());
    }
    _settling.add(context as Element);
  }

  static final Set<Element> _settling = {};

  @override
  State<PresenceGroup> createState() => _PresenceGroupState();
}

enum _Kind { enter, exit, swap }

class _PresenceGroupState extends State<PresenceGroup>
    with TickerProviderStateMixin {
  late List<_Entry> _entries = [
    for (final (key, child) in widget.items) _Entry(this, key, child),
  ];

  bool _reduce = false;

  /// The ticker mode notifier watched while a slot moves, so a hidden page
  /// settles at once instead of freezing half way.
  ValueListenable<bool>? _tickerMode;

  bool get _animates =>
      widget.config.enabled &&
      !_reduce &&
      TickerMode.getNotifier(context).value &&
      !_settlesThisFrame;

  bool get _settlesThisFrame {
    final settling = PresenceGroup._settling;
    if (settling.isEmpty) return false;
    var found = false;
    context.visitAncestorElements((e) => !(found = settling.contains(e)));
    return found;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_reduce) _settleAll();
  }

  @override
  void didUpdateWidget(PresenceGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.items;
    final keys = {for (final (key, _) in next) key};
    final known = {for (final e in _entries) e.key: e};
    final animates = _animates;

    final entering = <_Entry>[];
    final present = <_Entry>[];
    for (final (key, child) in next) {
      final entry = known[key];
      if (entry == null) {
        final created = _Entry(this, key, child, present: false);
        entering.add(created);
        present.add(created);
        continue;
      }
      entry.child = child;
      if (!entry.present) entering.add(entry);
      present.add(entry);
    }
    final leaving = [
      for (final e in _entries)
        if (!keys.contains(e.key) && e.present) e,
    ];
    final single = widget.builder == null;
    _entries = single
        ? [
            for (final e in _entries)
              if (!keys.contains(e.key)) e,
            ...present,
          ]
        : _merge(_entries, present, keys);

    final swap = single && entering.isNotEmpty && leaving.isNotEmpty;
    final inPlace = widget.mode == PresenceMode.inPlace;
    var exitLength = Duration.zero;
    for (final e in leaving) {
      if (!animates || (single && inPlace && present.isNotEmpty)) {
        e.present = false;
        _settle(e);
      } else {
        final length = _exit(e, swap: swap);
        if (length > exitLength) exitLength = length;
      }
    }
    if (single && inPlace) {
      // Only one output fits a parent-data position: an arriving one
      // replaces every leaving one at once.
      for (final e in [..._entries]) {
        if (!keys.contains(e.key) && present.isNotEmpty) _settle(e);
      }
    }
    for (final e in entering) {
      if (!animates) {
        _restore(e, animate: false);
        _settle(e);
      } else {
        _enter(
          e,
          swap: swap,
          delay: swap && widget.config.sequential ? exitLength : Duration.zero,
        );
      }
    }
  }

  /// The next item order with each leaving item kept after the item it
  /// followed before.
  static List<_Entry> _merge(
    List<_Entry> old,
    List<_Entry> next,
    Set<Object> keys,
  ) {
    final index = {for (final (i, e) in old.indexed) e.key: i};
    final merged = <_Entry>[];
    var last = -1;
    void flush(int until) {
      for (var i = last + 1; i < until; i++) {
        if (!keys.contains(old[i].key)) merged.add(old[i]);
      }
    }

    for (final e in next) {
      final at = index[e.key];
      if (at != null && at > last) {
        flush(at);
        last = at;
      }
      merged.add(e);
    }
    flush(old.length);
    return merged;
  }

  ({Duration duration, Curve curve}) _timing(_Kind kind) {
    final style = EnginePresentation.value.presence;
    final (duration, curve) = switch (kind) {
      _Kind.enter => (style.enter, style.enterCurve),
      _Kind.exit => (style.exit, style.exitCurve),
      _Kind.swap => (style.swap, style.swapCurve),
    };
    final config = widget.config;
    final ms = config.durationMs;
    return (
      duration: ms == null ? duration : Duration(milliseconds: ms),
      curve: config.curve == null
          ? curve
          : EngineCurve.resolve(config.curve, fallback: curve),
    );
  }

  /// Whether a run animates the slot's size (a swap always moves it).
  bool _sized(bool swap) =>
      swap || (widget.config.space && widget.mode == PresenceMode.box);

  /// Brings [e] back: its view replays held notifications and its exit
  /// motions return to rest, at once unless [animate].
  void _restore(_Entry e, {required bool animate}) {
    e.present = true;
    e._view?._release();
    for (final m in [...e._members]) {
      if (m.phase != MotionPhase.enter) m.cancelExit(animate: animate);
    }
  }

  void _enter(_Entry e, {required bool swap, required Duration delay}) {
    final from = e.value;
    _restore(e, animate: true);
    final timing = _timing(swap ? _Kind.swap : _Kind.enter);
    final space = _sized(swap) ? timing.duration * (1 - from) : Duration.zero;
    e._enterDelay = widget.config.sequential ? delay + space : delay;
    _run(
      e,
      from: from,
      to: 1,
      delay: delay,
      space: space,
      total: delay + space,
      curve: timing.curve,
      swap: swap,
    );
  }

  /// Starts [e]'s exit and returns how long its exit motions play.
  Duration _exit(_Entry e, {required bool swap}) {
    final from = e.value;
    e.present = false;
    _releaseFocus(e);
    e._enterDelay = Duration.zero;
    var visual = Duration.zero;
    for (final m in [...e._members]) {
      if (m.phase == MotionPhase.enter) continue;
      final length = m.playExit();
      if (length > visual) visual = length;
    }
    final timing = _timing(swap ? _Kind.swap : _Kind.exit);
    final space = _sized(swap) ? timing.duration * from : Duration.zero;
    final delay = widget.config.sequential ? visual : Duration.zero;
    final total = delay + space > visual ? delay + space : visual;
    _run(
      e,
      from: from,
      to: 0,
      delay: delay,
      space: space,
      total: total,
      curve: timing.curve,
      swap: swap,
    );
    return visual;
  }

  /// Takes keyboard focus, and so the keyboard, out of [e]'s leaving
  /// output.
  static void _releaseFocus(_Entry e) {
    final focused = FocusManager.instance.primaryFocus;
    final context = focused?.context;
    if (context == null) return;
    var inside = false;
    context.visitAncestorElements((a) {
      final w = a.widget;
      inside = w is PresenceScope && identical(w.handle, e);
      return !inside;
    });
    if (inside) focused!.unfocus();
  }

  void _run(
    _Entry e, {
    required double from,
    required double to,
    required Duration delay,
    required Duration space,
    required Duration total,
    required Curve curve,
    required bool swap,
  }) {
    if (total <= Duration.zero) {
      _settle(e);
      return;
    }
    e
      .._from = from
      .._to = to
      .._delay = delay
      .._space = space
      .._curve = curve
      .._swap = swap;
    final controller = e._controller ??= AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _settle(e));
        }
      });
    controller
      ..duration = total
      ..forward(from: 0);
    _tickerMode ??= TickerMode.getNotifier(context)..addListener(_onTickerMode);
  }

  /// Ends [e]'s run: a leaving slot goes, an arriving one rests.
  void _settle(_Entry e) {
    e._controller?.dispose();
    e._controller = null;
    e._swap = false;
    e._enterDelay = Duration.zero;
    if (!e.present) _entries.remove(e);
    if (_tickerMode != null && !_entries.any((e) => e.running)) {
      _tickerMode!.removeListener(_onTickerMode);
      _tickerMode = null;
    }
  }

  void _settleAll() {
    for (final e in [..._entries]) {
      if (e.running) _settle(e);
    }
  }

  void _onTickerMode() {
    if (_tickerMode?.value ?? true) return;
    setState(_settleAll);
  }

  @override
  void dispose() {
    _tickerMode?.removeListener(_onTickerMode);
    for (final e in _entries) {
      e._controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final around = PresenceScope.exitingOf(context);
    Widget slot(_Entry e) => PresenceScope._(
      key: ValueKey(e.key),
      handle: e,
      exiting: !e.present || around,
      child: e.child,
    );

    final builder = widget.builder;
    if (widget.mode == PresenceMode.inPlace) {
      if (builder != null) return builder([for (final e in _entries) slot(e)]);
      return _entries.isEmpty ? const SizedBox.shrink() : slot(_entries.last);
    }
    if (builder == null) {
      if (_entries.isEmpty) return const SizedBox.shrink();
      final moving = [for (final e in _entries) ?e._controller];
      return _PresenceBox(
        entries: [..._entries],
        animation: moving.isEmpty ? null : Listenable.merge(moving),
        children: [for (final e in _entries) slot(e)],
      );
    }
    return builder([
      for (final e in _entries)
        _PresenceBox(
          key: ValueKey(e.key),
          entries: [e],
          axis: widget.axis,
          animation: e._controller,
          children: [slot(e)],
        ),
    ]);
  }
}

/// One keyed output of a [PresenceGroup] and the run that moves it.
final class _Entry implements PresenceHandle {
  _Entry(this._group, this.key, this.child, {this.present = true});

  final _PresenceGroupState _group;
  final Object key;
  Widget child;

  /// Whether the output is in the latest build; a leaving one is not.
  bool present;

  final Set<PresenceMember> _members = {};
  _PresenceEnv? _view;

  AnimationController? _controller;
  double _from = 1;
  double _to = 1;
  Duration _delay = Duration.zero;
  Duration _space = Duration.zero;
  Curve _curve = Curves.linear;
  bool _swap = false;
  Duration _enterDelay = Duration.zero;

  bool get running => _controller != null;

  /// Eased progress of the space run, `1` at rest.
  double get value {
    final c = _controller;
    if (c == null) return present ? 1 : 0;
    final elapsed = c.duration!.inMicroseconds * c.value;
    final delay = _delay.inMicroseconds;
    final space = _space.inMicroseconds;
    final p = space <= 0
        ? (elapsed >= delay ? 1.0 : 0.0)
        : ((elapsed - delay) / space).clamp(0.0, 1.0);
    return _from + (_to - _from) * _curve.transform(p);
  }

  bool _plays(PresenceMember m) =>
      present ? m.phase != MotionPhase.exit : m.phase != MotionPhase.enter;

  /// The share of its child's size the slot takes.
  double get size {
    if (!_group.widget.config.space) return present ? 1 : 0;
    if (_members.any((m) => m.affectsLayout && _plays(m))) return 1;
    return value;
  }

  /// Whether the slot clips its child while it grows or collapses.
  bool get clips => running && _group.widget.config.space;

  /// The crossfade of a swap for an output without its own phase motions.
  double? get alpha => _swap && !_members.any(_plays) ? value : null;

  @override
  void add(PresenceMember member) => _members.add(member);

  @override
  void remove(PresenceMember member) => _members.remove(member);

  @override
  Duration get enterDelay => _enterDelay;

  @override
  Environment view(Environment outer) {
    final current = _view;
    if (current != null && identical(current.inner, outer)) return current;
    return _view = _PresenceEnv(this, outer, current?._memo);
  }
}

/// [_Entry.view]: reads through to the chain while the slot is present,
/// remembering each value; serves those values and holds notifications
/// while it exits; and replays one held notification when it returns.
final class _PresenceEnv extends Environment {
  _PresenceEnv(this._entry, this.inner, [Map<String, Object?>? memo])
    : _memo = memo ?? {};

  final _Entry _entry;
  final Environment inner;
  final Map<String, Object?> _memo;

  /// The relays that have listeners.
  final Set<_Gate> _gates = {};

  bool get _frozen => !_entry.present;

  @override
  Environment? get parent => inner;

  @override
  bool has(String name) {
    if (_frozen && _memo.containsKey(name)) return true;
    for (Environment? e = inner; e != null; e = e.parent) {
      if (e.has(name)) {
        _memo[name] = e.read(name);
        return true;
      }
    }
    return false;
  }

  @override
  Object? read(String name) =>
      _memo.containsKey(name) || has(name) ? _memo[name] : null;

  @override
  Listenable? listen(Set<String> keys) {
    final source = inner.listen(keys);
    if (source == null) return null;
    return _Gate(this, source);
  }

  void _release() {
    for (final gate in [..._gates]) {
      gate._release();
    }
  }
}

/// Relays a chain notification unless its view is frozen; joins its view
/// with its first listener and is disposed with its last.
///
/// A gate made while the view is frozen starts held: it may replace one that
/// held a notification.
final class _Gate extends ChangeNotifier {
  _Gate(this._env, this._source) : _held = _env._frozen;

  final _PresenceEnv _env;
  final Listenable _source;
  int _listeners = 0;
  bool _held;

  @override
  void addListener(VoidCallback listener) {
    if (_listeners++ == 0) {
      _source.addListener(_relay);
      _env._gates.add(this);
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (--_listeners > 0) return;
    _source.removeListener(_relay);
    _env._gates.remove(this);
    dispose();
  }

  void _relay() {
    if (_env._frozen) {
      _held = true;
      return;
    }
    notifyListeners();
  }

  void _release() {
    if (!_held) return;
    _held = false;
    notifyListeners();
  }
}

class _PresenceBox extends MultiChildRenderObjectWidget {
  const _PresenceBox({
    super.key,
    required this.entries,
    required this.animation,
    required super.children,
    this.axis,
  });

  final List<_Entry> entries;
  final Listenable? animation;
  final Axis? axis;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderPresence(
    entries: entries,
    animation: animation,
    axis: axis,
    textDirection: Directionality.maybeOf(context),
  );

  @override
  void updateRenderObject(BuildContext context, _RenderPresence renderObject) {
    renderObject
      ..entries = entries
      ..animation = animation
      ..axis = axis
      ..textDirection = Directionality.maybeOf(context);
  }
}

class _PresenceParentData extends ContainerBoxParentData<RenderBox> {}

/// Lays every child out with the incoming constraints at its start corner
/// and sizes itself to the sum of each child's size times its entry's share
/// along the animated axes ([axis], or both when `null`), the largest child
/// across. Leaving children take no input and no semantics.
class _RenderPresence extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _PresenceParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _PresenceParentData> {
  _RenderPresence({
    required List<_Entry> entries,
    required Listenable? animation,
    required Axis? axis,
    required TextDirection? textDirection,
  }) : _entries = entries,
       _animation = animation,
       _axis = axis,
       _textDirection = textDirection;

  List<_Entry> _entries;
  set entries(List<_Entry> value) {
    final unchanged = _unchanged(value);
    _entries = value;
    _present = [for (final e in value) e.present];
    if (unchanged) return;
    markNeedsLayout();
    markNeedsCompositingBitsUpdate();
    markNeedsSemanticsUpdate();
  }

  bool _unchanged(List<_Entry> next) {
    if (next.length != _entries.length) return false;
    for (var i = 0; i < next.length; i++) {
      if (!identical(next[i], _entries[i])) return false;
      if (next[i].present != _present[i]) return false;
    }
    return true;
  }

  /// Each entry's [_Entry.present] at the last update, so a rebuild that
  /// changes nothing marks nothing dirty.
  late List<bool> _present = [for (final e in _entries) e.present];

  Listenable? _animation;
  set animation(Listenable? value) {
    if (identical(value, _animation)) return;
    if (attached) _animation?.removeListener(_tick);
    _animation = value;
    if (attached) _animation?.addListener(_tick);
    // A run starting or ending changes clipping and crossfading.
    markNeedsLayout();
    markNeedsCompositingBitsUpdate();
  }

  Axis? _axis;
  set axis(Axis? value) {
    if (value == _axis) return;
    _axis = value;
    markNeedsLayout();
  }

  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  final LayerHandle<ClipRectLayer> _clip = LayerHandle();

  _Entry? _entryAt(int index) =>
      index < _entries.length ? _entries[index] : null;

  void _tick() {
    markNeedsLayout();
    markNeedsCompositingBitsUpdate();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PresenceParentData) {
      child.parentData = _PresenceParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation?.addListener(_tick);
  }

  @override
  void detach() {
    _animation?.removeListener(_tick);
    super.detach();
  }

  @override
  void dispose() {
    _clip.layer = null;
    super.dispose();
  }

  @override
  bool get alwaysNeedsCompositing => _entries.any((e) => e.alpha != null);

  Size _measure(Size Function(RenderBox) sizeOf, BoxConstraints constraints) {
    var width = 0.0;
    var height = 0.0;
    var child = firstChild;
    var i = 0;
    while (child != null) {
      final share = _entryAt(i)?.size ?? 1;
      final s = sizeOf(child);
      width = _axis == Axis.vertical
          ? math.max(width, s.width)
          : width + s.width * share;
      height = _axis == Axis.horizontal
          ? math.max(height, s.height)
          : height + s.height * share;
      child = childAfter(child);
      i++;
    }
    return constraints.constrain(Size(width, height));
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      _measure((child) => child.getDryLayout(constraints), constraints);

  @override
  void performLayout() {
    size = _measure((child) {
      child.layout(constraints, parentUsesSize: true);
      return child.size;
    }, constraints);
    final rtl = _textDirection == TextDirection.rtl;
    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as _PresenceParentData;
      data.offset = Offset(
        rtl && _axis != Axis.vertical ? size.width - child.size.width : 0,
        0,
      );
      child = data.nextSibling;
    }
  }

  double _intrinsic(double Function(RenderBox) of, {required bool sums}) {
    var result = 0.0;
    var child = firstChild;
    var i = 0;
    while (child != null) {
      final value = of(child);
      result = sums
          ? result + value * (_entryAt(i)?.size ?? 1)
          : math.max(result, value);
      child = childAfter(child);
      i++;
    }
    return result;
  }

  bool get _sumsWidth => _axis != Axis.vertical;
  bool get _sumsHeight => _axis != Axis.horizontal;

  @override
  double computeMinIntrinsicWidth(double height) =>
      _intrinsic((c) => c.getMinIntrinsicWidth(height), sums: _sumsWidth);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _intrinsic((c) => c.getMaxIntrinsicWidth(height), sums: _sumsWidth);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _intrinsic((c) => c.getMinIntrinsicHeight(width), sums: _sumsHeight);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _intrinsic((c) => c.getMaxIntrinsicHeight(width), sums: _sumsHeight);

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    var child = firstChild;
    var i = 0;
    while (child != null) {
      if (_entryAt(i)?.present ?? true) {
        final distance = child.getDistanceToActualBaseline(baseline);
        final data = child.parentData! as _PresenceParentData;
        return distance == null ? null : distance + data.offset.dy;
      }
      child = childAfter(child);
      i++;
    }
    return null;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    var i = childCount - 1;
    while (child != null) {
      final data = child.parentData! as _PresenceParentData;
      if ((_entryAt(i)?.present ?? true) &&
          result.addWithPaintOffset(
            offset: data.offset,
            position: position,
            hitTest: (result, transformed) =>
                child!.hitTest(result, position: transformed),
          )) {
        return true;
      }
      child = data.previousSibling;
      i--;
    }
    return false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    var child = firstChild;
    var i = 0;
    while (child != null) {
      if (_entryAt(i)?.present ?? true) visitor(child);
      child = childAfter(child);
      i++;
    }
  }

  void _paintChildren(PaintingContext context, Offset offset) {
    var child = firstChild;
    var i = 0;
    while (child != null) {
      final data = child.parentData! as _PresenceParentData;
      final alpha = _entryAt(i)?.alpha;
      final at = offset + data.offset;
      final painted = child;
      if (alpha == null) {
        context.paintChild(painted, at);
      } else if (alpha > 0) {
        context.pushOpacity(
          at,
          (alpha.clamp(0.0, 1.0) * 255).round(),
          (context, offset) => context.paintChild(painted, offset),
        );
      }
      child = data.nextSibling;
      i++;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_entries.any((e) => e.clips)) {
      _clip.layer = null;
      _paintChildren(context, offset);
      return;
    }
    _clip.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      _paintChildren,
      oldLayer: _clip.layer,
    );
  }
}
