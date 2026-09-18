# Widget catalog

This catalog lists every template widget registered by the engine, grouped by purpose, plus the one explicitly internal catalog helper.

## Layout

Sizing, positioning, flex, and box composition.

| Name | Summary | Protocol | Loop wrapper? | Reference |
| --- | --- | --- | --- | --- |
| `align` | Builds Flutter's [Align] for an `align` node. | box | No | [Open](layout/align.md) |
| `aspect_ratio` | Builds Flutter's [AspectRatio] for an `aspectRatio` node. | box | No | [Open](layout/aspect_ratio.md) |
| `baseline` | Builds Flutter's [Baseline], supplying an empty child when the node has none. | box | No | [Open](layout/baseline.md) |
| `center` | Builds Flutter's [Center] for a `center` node. | box | No | [Open](layout/center.md) |
| `column` | Builds Flutter's [Column] for a `column` node. | box | Yes | [Open](layout/column.md) |
| `constrained_box` | Builds Flutter's [ConstrainedBox] with unconstrained defaults for invalid props. | box | No | [Open](layout/constrained_box.md) |
| `container` | Builds Flutter's [Container] from resolved box props. | box | No | [Open](layout/container.md) |
| `expanded` | Builds Flutter's [Expanded], supplying an empty child when required. | box | No | [Open](layout/expanded.md) |
| `fitted_box` | Builds Flutter's [FittedBox] for a `fittedBox` node. | box | No | [Open](layout/fitted_box.md) |
| `flex` | Builds Flutter's [Flex] for a `flex` node. | box | No | [Open](layout/flex.md) |
| `flexible` | Builds Flutter's [Flexible], supplying an empty child when required. | box | No | [Open](layout/flexible.md) |
| `fractionally_sized_box` | Builds Flutter's [FractionallySizedBox] for a `fractionallySizedBox` node. | box | No | [Open](layout/fractionally_sized_box.md) |
| `indexed_stack` | Builds Flutter's [IndexedStack] for an `indexedStack` node. | box | No | [Open](layout/indexed_stack.md) |
| `interactive_viewer` | Lets users pan and scale a child. | box | No | [Open](layout/interactive_viewer.md) |
| `intrinsic_height` | Builds Flutter's [IntrinsicHeight] for an `intrinsicHeight` node. | box | No | [Open](layout/intrinsic_height.md) |
| `intrinsic_width` | Builds Flutter's [IntrinsicWidth] for an `intrinsicWidth` node. | box | No | [Open](layout/intrinsic_width.md) |
| `limited_box` | Builds Flutter's [LimitedBox] for a `limitedBox` node. | box | No | [Open](layout/limited_box.md) |
| `list_body` | Builds Flutter's [ListBody] from the node's children. | box | No | [Open](layout/list_body.md) |
| `overflow_bar` | Builds Flutter's [OverflowBar] from the node's children. | box | No | [Open](layout/overflow_bar.md) |
| `overflow_box` | Builds Flutter's [OverflowBox] for an `overflowBox` node. | box | No | [Open](layout/overflow_box.md) |
| `padding` | Builds Flutter's [Padding], defaulting malformed padding to zero. | box | No | [Open](layout/padding.md) |
| `positioned` | Builds Flutter's [Positioned], supplying an empty child when required. | box | No | [Open](layout/positioned.md) |
| `positioned_fill` | Builds [Positioned.fill] for a `positionedFill` node. | box | No | [Open](layout/positioned_fill.md) |
| `row` | Builds Flutter's [Row] for a `row` node. | box | Yes | [Open](layout/row.md) |
| `safe_area` | Builds Flutter's [SafeArea], supplying an empty child when required. | box | No | [Open](layout/safe_area.md) |
| `sized_overflow_box` | Builds [SizedOverflowBox] from separate width and height props. | box | No | [Open](layout/sized_overflow_box.md) |
| `sizedbox` | Builds Flutter's [SizedBox] for a `sizedbox` node. | box | No | [Open](layout/sizedbox.md) |
| `spacer` | Builds Flutter's [Spacer] for use inside a flex layout. | box | No | [Open](layout/spacer.md) |
| `stack` | Builds Flutter's [Stack] from the node's children. | box | No | [Open](layout/stack.md) |
| `unconstrained_box` | Removes parent constraints from selected child axes. | box | No | [Open](layout/unconstrained_box.md) |
| `wrap` | Builds Flutter's [Wrap] from the node's children. | box | Yes | [Open](layout/wrap.md) |

## Scrolling

Scrollable boxes and sliver viewport pieces.

| Name | Summary | Protocol | Loop wrapper? | Reference |
| --- | --- | --- | --- | --- |
| `custom_scroll_view` | Builds a [CustomScrollView] from children that are already slivers. | box | No | [Open](scrolling/custom_scroll_view.md) |
| `dismissible` | Builds a [Dismissible] that dispatches the configured dismissal action. | box | Yes | [Open](scrolling/dismissible.md) |
| `grid_view` | Builds a non-lazy [GridView] from the node's already-built children. | box | No | [Open](scrolling/grid_view.md) |
| `list_view` | Builds a non-lazy [ListView] from the node's already-built children. | box | No | [Open](scrolling/list_view.md) |
| `nested_scroll_view` | Builds a [NestedScrollView] using positional child roles. | box | No | [Open](scrolling/nested_scroll_view.md) |
| `page_view` | Builds a stateful [PageView] and dispatches page indices as event data. | box | No | [Open](scrolling/page_view.md) |
| `refresh_indicator` | Builds a [RefreshIndicator] that awaits the configured engine action. | box | No | [Open](scrolling/refresh_indicator.md) |
| `scrollbar` | Builds Flutter's [Scrollbar] around the node's first child. | box | No | [Open](scrolling/scrollbar.md) |
| `single_child_scroll_view` | Builds Flutter's [SingleChildScrollView] for the node's first child. | box | No | [Open](scrolling/single_child_scroll_view.md) |
| `sliver_app_bar` | Assigns named engine slots to a Flutter [SliverAppBar]. | sliver | No | [Open](scrolling/sliver_app_bar.md) |
| `sliver_fill_remaining` | Builds [SliverFillRemaining] around the node's first box child. | sliver | No | [Open](scrolling/sliver_fill_remaining.md) |
| `sliver_grid` | Builds a non-lazy [SliverGrid] from the node's box children. | sliver | Yes | [Open](scrolling/sliver_grid.md) |
| `sliver_list` | Builds a non-lazy [SliverList] from the node's box children. | sliver | Yes | [Open](scrolling/sliver_list.md) |
| `sliver_padding` | Adds resolved padding around the node's first sliver child. | sliver | No | [Open](scrolling/sliver_padding.md) |
| `sliver_persistent_header` | Builds a [SliverPersistentHeader] with a fixed child and resolved extents. | sliver | No | [Open](scrolling/sliver_persistent_header.md) |
| `sliver_to_box_adapter` | Adapts the node's first box child to Flutter's sliver protocol. | sliver | No | [Open](scrolling/sliver_to_box_adapter.md) |

## Display

Text, imagery, indicators, and content presentation.

| Name | Summary | Protocol | Loop wrapper? | Reference |
| --- | --- | --- | --- | --- |
| `divider` | Draws a horizontal Material divider. | box | No | [Open](display/divider.md) |
| `icon` | Resolves an icon name through [IconCatalog] and builds a Material [Icon]. | box | No | [Open](display/icon.md) |
| `image` | Resolves an `image` node through the installed [ImageSource]. | box | No | [Open](display/image.md) |
| `list_tile` | Arranges leading, title, subtitle, and trailing named slots. | box | No | [Open](display/list_tile.md) |
| `rich_text` | Builds [RichText] from a list of inline-span descriptions. | box | No | [Open](display/rich_text.md) |
| `text` | Builds Flutter's [Text], stringifying non-null dynamic values leniently. | box | No | [Open](display/text.md) |
| `vertical_divider` | Draws a vertical Material divider. | box | No | [Open](display/vertical_divider.md) |

## Input

Controlled inputs that read and write scoped state.

| Name | Summary | Protocol | Loop wrapper? | Reference |
| --- | --- | --- | --- | --- |
| `checkbox` | Builds a controlled Flutter [Checkbox] from the bound engine value. | box | No | [Open](input/checkbox.md) |
| `cupertino_switch` | Builds a controlled iOS-style [CupertinoSwitch] using the engine's truthiness rules. | box | No | [Open](input/cupertino_switch.md) |
| `dropdown` | Builds a controlled dropdown from scalar value/label options. | box | No | [Open](input/dropdown.md) |
| `radio` | Builds one controlled radio option from the bound engine value. | box | No | [Open](input/radio.md) |
| `slider` | Builds a controlled Flutter [Slider] from the bound engine value. | box | No | [Open](input/slider.md) |
| `text_field` | Builds a controlled [TextField] synchronized with the bound engine value. | box | No | [Open](input/text_field.md) |
| `toggle` | Builds a controlled Flutter [Switch] using the engine's truthiness rules. | box | No | [Open](input/toggle.md) |

## Feedback

User feedback surfaces.

| Name | Summary | Protocol | Loop wrapper? | Reference |
| --- | --- | --- | --- | --- |
| `badge` | Places a label or dot badge over a child widget. | box | No | [Open](feedback/badge.md) |
| `circular_progress_indicator` | Shows determinate or indeterminate circular progress. | box | No | [Open](feedback/circular_progress_indicator.md) |
| `linear_progress_indicator` | Shows determinate or indeterminate linear progress. | box | No | [Open](feedback/linear_progress_indicator.md) |
| `loading_indicator` | Shows a branded indeterminate spinner. | box | No | [Open](feedback/loading_indicator.md) |
| `tooltip` | Shows a text label after hovering or long-pressing its child. | box | No | [Open](feedback/tooltip.md) |

## Navigation

Scaffolds, bars, and tab navigation.

| Name | Summary | Protocol | Loop wrapper? | Reference |
| --- | --- | --- | --- | --- |
| `app_bar` | Arranges `leading` / `title` / `actions` for a fixed app bar's content. | box | No | [Open](navigation/app_bar.md) |
| `default_tab_controller` | Provides one [DefaultTabController] to the node's first child. | box | No | [Open](navigation/default_tab_controller.md) |
| `scaffold` | Assigns named engine slots to the corresponding [Scaffold] regions. | box | No | [Open](navigation/scaffold.md) |
| `tab` | Assigns named `icon` and `child` slots to a Flutter [Tab]. | box | No | [Open](navigation/tab.md) |
| `tab_bar` | Builds a [TabBar] that shares its nearest default tab controller. | box | No | [Open](navigation/tab_bar.md) |
| `tab_bar_view` | Builds a [TabBarView] that shares its nearest default tab controller. | box | No | [Open](navigation/tab_bar_view.md) |

## Effects

Clipping, filtering, transforms, visibility, and pointer effects.

| Name | Summary | Protocol | Loop wrapper? | Reference |
| --- | --- | --- | --- | --- |
| `absorb_pointer` | Builds Flutter's [AbsorbPointer] to absorb pointer events. | box | No | [Open](effects/absorb_pointer.md) |
| `backdrop_filter` | Blurs content painted behind its child. | box | No | [Open](effects/backdrop_filter.md) |
| `clip_oval` | Builds Flutter's [ClipOval] for a `clipOval` node. | box | No | [Open](effects/clip_oval.md) |
| `clip_rect` | Builds Flutter's [ClipRect] for a `clipRect` node. | box | No | [Open](effects/clip_rect.md) |
| `clip_rrect` | Builds Flutter's [ClipRRect] for a `clipRRect` node. | box | No | [Open](effects/clip_rrect.md) |
| `color_filtered` | Tints its child's painted output with a color blend. | box | No | [Open](effects/color_filtered.md) |
| `decorated_box` | Builds Flutter's [DecoratedBox] for a `decoratedBox` node. | box | No | [Open](effects/decorated_box.md) |
| `ignore_pointer` | Builds Flutter's [IgnorePointer] to pass pointer events through. | box | No | [Open](effects/ignore_pointer.md) |
| `image_filtered` | Applies a blur filter to its child's painted output. | box | No | [Open](effects/image_filtered.md) |
| `offstage` | Builds Flutter's [Offstage] for an `offstage` node. | box | No | [Open](effects/offstage.md) |
| `opacity` | Builds Flutter's [Opacity] with a value clamped to Flutter's valid range. | box | No | [Open](effects/opacity.md) |
| `physical_model` | Clips and elevates its child as a physical shape. | box | No | [Open](effects/physical_model.md) |
| `rotated_box` | Builds Flutter's [RotatedBox] for a `rotatedBox` node. | box | No | [Open](effects/rotated_box.md) |
| `shader_mask` | Paints a gradient over its child, tinting the child's painted pixels with it (`blend_mode: src_in`) — the way to render gradient text or icons. | box | No | [Open](effects/shader_mask.md) |
| `transform` | Builds Flutter's [Transform] from a resolved matrix and alignment. | box | No | [Open](effects/transform.md) |
| `visibility` | Builds Flutter's [Visibility] with independently resolved preservation flags. | box | No | [Open](effects/visibility.md) |

## Custom

Engine-specific widgets; includes the explicitly unregistered internal helper for source-tree completeness.

| Name | Summary | Protocol | Loop wrapper? | Reference |
| --- | --- | --- | --- | --- |
| `anchor` | Registers an `anchor` node's first child under its non-empty `id`. | box | No | [Open](custom/anchor.md) |
| `anchor_scope` | Owns the stacking context `anchor`s inside it fly within. | box | No | [Open](custom/anchor_scope.md) |
| `auto_scroll` | A seamless, infinitely repeating scrolling marquee. | box | Yes | [Open](custom/auto_scroll.md) |
| `chart` | A data-driven line, area, or bar chart. | box | No | [Open](custom/chart.md) |
| `collapsing_header` | Builds a [SliverPersistentHeader] whose child receives scroll-state variables. | sliver | No | [Open](custom/collapsing_header.md) |
| `scratch_card` | Reveals its first child as the user rubs the second away. | box | No | [Open](custom/scratch_card.md) |
| `serpentine` | Measures rows, draws their serpentine track, then paints cells. | box | Yes | [Open](custom/serpentine.md) |
| `serpentine_row` | Lays out one measured row of serpentine board cells. | box | Yes | [Open](custom/serpentine_row.md) |
| `skeleton` | One loading-placeholder bone (a rounded box) for a `_skeleton` outline. | box | No | [Open](custom/skeleton.md) |
| `speech_balloon` | Paints a rounded balloon with an integrated bezier nip. | box | No | [Open](custom/speech_balloon.md) |
| `spin_grid` | Lays out children in a grid and cycles one highlighted cell. | box | Yes | [Open](custom/spin_grid.md) |
| `swipe_indicator` | A page indicator that follows its `swipe_layout`'s [SwipeController]. | box | No | [Open](custom/swipe_indicator.md) |
| `swipe_layout` | Owns the [SwipeController] shared by a swipe layout's panes and indicators. | box | No | [Open](custom/swipe_layout.md) |
| `swipe_pane` | A swipe area bound to its `swipe_layout`'s [SwipeController]. | box | No | [Open](custom/swipe_pane.md) |
| `video` | Builds a policy-backed video player with optional playback interaction. | box | No | [Open](custom/video.md) |
| `nested_body` (internal) | Unregistered helper used by `nested_scroll_view`; not valid as a template type. | box | No | [Open](custom/nested_body.md) |

All registered widget nodes can carry the common directives described in [Concepts](../concepts.md), including `_loop`, `_scope`, `_motion`, and supported `_on` events. Protocol enforcement occurs before mounting.
