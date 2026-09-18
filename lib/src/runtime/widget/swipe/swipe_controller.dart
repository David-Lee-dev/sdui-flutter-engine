import 'package:flutter/foundation.dart';

/// A single swipe area's bridge to the shared [SwipeController].
///
/// Each `swipe_pane` owns one link wrapping its `PageController`; the controller
/// uses it to mirror the pane during another pane's drag ([syncTo]), to move it
/// on a settled/programmatic change ([moveTo]), and to read its live continuous
/// position back so decoupled watchers (the indicator) can glide ([currentPage]).
///
/// All positions crossing this interface are **virtual** pages, not logical dot
/// indices: when the owning controller loops, panes run on an unbounded virtual
/// axis (see [SwipeController]) and only the controller folds virtual back to a
/// logical `0 .. length-1` at its reporting edges.
abstract interface class SwipePaneLink {
  /// Identity of the owning pane, used to skip mirroring a pane onto itself.
  Object get owner;

  /// The pane's current continuous virtual page, or `null` when it has no
  /// viewport yet.
  double? get currentPage;

  /// Jumps the pane to a fractional virtual [page] without animation
  /// (frame-by-frame mirroring while another pane is dragged).
  void syncTo(double page);

  /// Moves the pane to an integer virtual [page], animating unless told
  /// otherwise.
  Future<void> moveTo(int index, {bool animate = true});
}

/// The single source of truth for a `swipe_layout`'s position.
///
/// Holds the continuous page (for smooth mid-drag propagation) and the settled
/// integer index (the discrete value bridged to scope). Panes *drive* it while
/// dragged and *follow* it otherwise; indicators only follow and can seek. All
/// panes share one controller, so N swipe areas and M indicators stay in sync.
///
/// Feedback loops are prevented by [_activeSource]: only the pane that owns the
/// current gesture writes through [drive]; every other link is mirrored and
/// never writes back.
///
/// ## Looping
///
/// When [loop] is set the controller works on an **unbounded virtual axis**
/// instead of a bounded `0 .. length-1` one. Panes render an endless
/// `PageView` whose page `i` shows content `i % length`, so dragging right off
/// the last item continues *forward* into the first — never a backward rewind.
///
/// The virtual axis is anchored [virtualBase] pages in (a large multiple of
/// [length]) so there is effectively unlimited runway both directions. Every
/// value panes exchange with the controller ([drive], [endInteraction],
/// [SwipePaneLink]) is a virtual page; the controller folds it back to a
/// logical index only where the outside world observes it — [index] (scope
/// write-back), [logicalPage] (indicator offset), and [onSettled]. With [loop]
/// off, [virtualBase] is `0` and virtual equals logical, so every path reduces
/// to the original bounded behaviour.
class SwipeController extends ChangeNotifier {
  SwipeController({
    required int length,
    int initialIndex = 0,
    bool loop = false,
  }) : assert(length > 0, 'length must be positive'),
       _length = length,
       _loop = loop,
       _base = loop ? length * _anchorCycles : 0,
       _index = _fold(initialIndex, length, loop),
       _page =
           ((loop ? length * _anchorCycles : 0) +
                   _fold(initialIndex, length, loop))
               .toDouble();

  /// Backward virtual runway, in cycles, when [loop] is on. Forward is truly
  /// unbounded via a null-count `PageView.builder`; this only bounds the
  /// (unreachable in practice) backward direction. Large enough that a session
  /// never drifts to the edge, so the loop feels endless both ways.
  static const int _anchorCycles = 10000;

  int _length;
  final bool _loop;
  int _base;
  double _page;
  int _index;
  Object? _activeSource;
  final List<SwipePaneLink> _links = <SwipePaneLink>[];

  /// Invoked after a position settles (drag release, tap, autoplay, programmatic
  /// move); the layout bridges the settled logical index to scope through this.
  ValueChanged<int>? onSettled;

  /// Invoked when the user begins dragging any pane; the layout pauses autoplay.
  VoidCallback? onInteractionStart;

  /// Invoked when the user's drag settles; the layout schedules autoplay resume.
  VoidCallback? onInteractionEnd;

  /// The number of pages.
  int get length => _length;

  /// Whether the controller runs on the unbounded, wrapping virtual axis.
  bool get loop => _loop;

  /// The virtual page a pane's `PageController` starts at (`0` when not
  /// looping). A pane seeds `initialPage: virtualBase + index`.
  int get virtualBase => _base;

  /// The settled logical index, always `0 .. length-1`.
  int get index => _index;

  /// Whether a pane is currently being dragged by the user.
  bool get isInteracting => _activeSource != null;

  /// The continuous virtual position, preferring the first live pane so watchers
  /// glide during drags, ballistic snaps, and programmatic moves alike. Falls
  /// back to the settled position before any pane has a viewport. Clamped to the
  /// bounded range only when not looping.
  double get page {
    final max = (_length - 1).toDouble();
    for (final link in _links) {
      final live = link.currentPage;
      if (live != null) return _loop ? live : live.clamp(0.0, max);
    }
    return _page;
  }

  /// The continuous position folded into logical dot-space `[0, length)`, for
  /// indicators. When looping this wraps (e.g. gliding off dot `length-1`
  /// re-enters at dot `0`); otherwise it equals [page].
  double get logicalPage {
    if (!_loop) return page;
    final rel = (page - _base) % _length;
    return rel < 0 ? rel + _length : rel;
  }

  /// Folds a possibly out-of-range value into a valid index: wrapping when
  /// [loop] is on, clamping otherwise.
  static int _fold(int value, int length, bool loop) =>
      loop ? ((value % length) + length) % length : value.clamp(0, length - 1);

  int _wrap(int value) => ((value % _length) + _length) % _length;

  /// Registers a pane and snaps it to the current position.
  void registerLink(SwipePaneLink link) {
    _links.add(link);
    link.syncTo(_page);
  }

  /// Removes a pane (on dispose).
  void unregisterLink(SwipePaneLink link) => _links.remove(link);

  /// Rebroadcasts a pane's per-frame movement so watchers repaint. Panes call
  /// this from their controller listener; it is a no-op to logical state.
  void notifyTick() => notifyListeners();

  /// Marks [source] as the gesture owner. The first gesture wins so a second
  /// finger on another pane cannot fight the active one.
  void beginInteraction(Object source) {
    if (_activeSource != null) return;
    _activeSource = source;
    onInteractionStart?.call();
  }

  /// Propagates the owner pane's live virtual [page] to every other pane.
  /// Ignored unless [source] owns the current interaction.
  void drive(Object source, double page) {
    if (!identical(_activeSource, source)) return;
    _page = _loop ? page : page.clamp(0.0, (_length - 1).toDouble());
    for (final link in _links) {
      if (!identical(link.owner, source)) link.syncTo(_page);
    }
    notifyListeners();
  }

  /// Ends [source]'s interaction, settling every other pane to the virtual
  /// [landedPage] (the source snaps itself via its own physics).
  void endInteraction(Object source, int landedPage) {
    if (!identical(_activeSource, source)) return;
    _activeSource = null;
    _commit(landedPage.toDouble(), animate: true, exclude: source);
    onInteractionEnd?.call();
  }

  /// Moves programmatically (indicator tap, scope-driven change, autoplay tick)
  /// to logical [index], animating every pane. When looping, the pane travels to
  /// the nearest virtual page showing that item, so a wrap advances forward.
  Future<void> goTo(int index, {bool animate = true}) {
    final target = _loop
        ? _nearestVirtual(index)
        : index.clamp(0, _length - 1).toDouble();
    return _commit(target, animate: animate, exclude: null);
  }

  /// Updates the page count, re-folding the current index if the range shrank.
  void setLength(int length) {
    if (length <= 0 || length == _length) return;
    _length = length;
    _base = _loop ? length * _anchorCycles : 0;
    _index = _loop ? _wrap(_index) : _index.clamp(0, _length - 1);
    _page = (_base + _index).toDouble();
    notifyListeners();
  }

  /// The virtual page nearest the current position whose content is logical
  /// [index]. Picks the equivalent cycle closest to [page] so a settle animates
  /// the short way — including forward across the last→first seam.
  double _nearestVirtual(int index) {
    final wrapped = _wrap(index);
    final k = ((_page - _base - wrapped) / _length).round();
    return (_base + wrapped + k * _length).toDouble();
  }

  Future<void> _commit(
    double target, {
    required bool animate,
    required Object? exclude,
  }) {
    _page = target;
    final rounded = target.round();
    _index = _loop ? _wrap(rounded - _base) : rounded.clamp(0, _length - 1);
    notifyListeners();
    // The settle is logically complete now; report it synchronously so the
    // scope bridge reflects the index immediately rather than after the panes'
    // animations finish. The returned future only tracks those animations.
    onSettled?.call(_index);
    return Future.wait(<Future<void>>[
      for (final link in _links)
        if (exclude == null || !identical(link.owner, exclude))
          link.moveTo(rounded, animate: animate),
    ]);
  }
}
