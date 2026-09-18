import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import 'package:sdui_engine/src/compile/schema/widget_schema.dart';
import 'contract/spec.dart';

import 'catalog/primitive/absorb_pointer_widget.dart';
import 'catalog/primitive/align_widget.dart';
import 'catalog/custom/anchor_scope_widget.dart';
import 'catalog/custom/anchor_widget.dart';
import 'catalog/custom/chart_widget.dart';
import 'catalog/primitive/app_bar_widget.dart';
import 'catalog/primitive/aspect_ratio_widget.dart';
import 'catalog/custom/auto_scroll_widget.dart';
import 'catalog/primitive/backdrop_filter_widget.dart';
import 'catalog/primitive/baseline_widget.dart';
import 'catalog/primitive/badge_widget.dart';
import 'catalog/primitive/center_widget.dart';
import 'catalog/primitive/checkbox_widget.dart';
import 'catalog/primitive/circular_progress_indicator_widget.dart';
import 'catalog/primitive/clip_oval_widget.dart';
import 'catalog/primitive/clip_rect_widget.dart';
import 'catalog/primitive/clip_rrect_widget.dart';
import 'catalog/primitive/column_widget.dart';
import 'catalog/primitive/color_filtered_widget.dart';
import 'catalog/primitive/constrained_box_widget.dart';
import 'catalog/primitive/container_widget.dart';
import 'catalog/primitive/cupertino_switch_widget.dart';
import 'catalog/primitive/decorated_box_widget.dart';
import 'catalog/custom/skeleton_widget.dart';
import 'catalog/custom/speech_balloon_widget.dart';
import 'catalog/custom/serpentine_row_widget.dart';
import 'catalog/custom/scratch_card_widget.dart';
import 'catalog/custom/serpentine_widget.dart';
import 'catalog/custom/spin_grid_widget.dart';
import 'catalog/primitive/divider_widget.dart';
import 'catalog/primitive/custom_scroll_view_widget.dart';
import 'catalog/primitive/default_tab_controller_widget.dart';
import 'catalog/primitive/expanded_widget.dart';
import 'catalog/primitive/fitted_box_widget.dart';
import 'catalog/primitive/flex_widget.dart';
import 'catalog/primitive/flexible_widget.dart';
import 'catalog/primitive/fractionally_sized_box_widget.dart';
import 'catalog/primitive/grid_view_widget.dart';
import 'catalog/primitive/icon_widget.dart';
import 'catalog/primitive/image_widget.dart';
import 'catalog/primitive/image_filtered_widget.dart';
import 'catalog/primitive/ignore_pointer_widget.dart';
import 'catalog/primitive/indexed_stack_widget.dart';
import 'catalog/primitive/intrinsic_height_widget.dart';
import 'catalog/primitive/intrinsic_width_widget.dart';
import 'catalog/primitive/interactive_viewer_widget.dart';
import 'catalog/primitive/linear_progress_indicator_widget.dart';
import 'catalog/primitive/loading_indicator_widget.dart';
import 'catalog/primitive/limited_box_widget.dart';
import 'catalog/primitive/list_body_widget.dart';
import 'catalog/primitive/list_view_widget.dart';
import 'catalog/primitive/list_tile_widget.dart';
import 'catalog/primitive/nested_scroll_view_widget.dart';
import 'catalog/primitive/offstage_widget.dart';
import 'catalog/primitive/opacity_widget.dart';
import 'catalog/primitive/overflow_bar_widget.dart';
import 'catalog/primitive/overflow_box_widget.dart';
import 'catalog/primitive/padding_widget.dart';
import 'catalog/primitive/page_view_widget.dart';
import 'catalog/primitive/positioned_fill_widget.dart';
import 'catalog/primitive/positioned_widget.dart';
import 'catalog/primitive/physical_model_widget.dart';
import 'catalog/primitive/radio_widget.dart';
import 'catalog/primitive/refresh_indicator_widget.dart';
import 'catalog/primitive/dismissible_widget.dart';
import 'catalog/primitive/dropdown_widget.dart';
import 'catalog/primitive/rotated_box_widget.dart';
import 'catalog/primitive/row_widget.dart';
import 'catalog/primitive/rich_text_widget.dart';
import 'catalog/primitive/safe_area_widget.dart';
import 'catalog/primitive/shader_mask_widget.dart';
import 'catalog/primitive/scrollbar_widget.dart';
import 'catalog/primitive/single_child_scroll_view_widget.dart';
import 'catalog/primitive/sized_overflow_box_widget.dart';
import 'catalog/primitive/slider_widget.dart';
import 'catalog/primitive/sliver_app_bar_widget.dart';
import 'catalog/primitive/sliver_fill_remaining_widget.dart';
import 'catalog/primitive/sliver_grid_widget.dart';
import 'catalog/primitive/sliver_list_widget.dart';
import 'catalog/primitive/sliver_padding_widget.dart';
import 'catalog/primitive/sliver_persistent_header_widget.dart';
import 'catalog/primitive/sliver_to_box_adapter_widget.dart';
import 'catalog/primitive/tab_bar_view_widget.dart';
import 'catalog/primitive/tab_bar_widget.dart';
import 'catalog/primitive/tab_widget.dart';
import 'catalog/primitive/sizedbox_widget.dart';
import 'catalog/custom/collapsing_header_widget.dart';
import 'catalog/primitive/scaffold_widget.dart';
import 'catalog/primitive/spacer_widget.dart';
import 'catalog/primitive/stack_widget.dart';
import 'catalog/custom/swipe_indicator_widget.dart';
import 'catalog/custom/swipe_layout_widget.dart';
import 'catalog/custom/swipe_pane_widget.dart';
import 'catalog/primitive/text_field_widget.dart';
import 'catalog/primitive/toggle_widget.dart';
import 'catalog/primitive/text_widget.dart';
import 'catalog/primitive/transform_widget.dart';
import 'catalog/primitive/tooltip_widget.dart';
import 'catalog/primitive/unconstrained_box_widget.dart';
import 'catalog/primitive/vertical_divider_widget.dart';
import 'catalog/custom/video_widget.dart';
import 'catalog/primitive/visibility_widget.dart';
import 'catalog/primitive/wrap_widget.dart';

export 'contract/spec.dart';

/// Stores the process-wide mapping from engine type names to [WidgetSpec] values.
///
/// Registration may extend or replace built-ins during startup. Freezing the
/// registry prevents mounted templates from changing meaning at runtime.
final class WidgetFactory {
  const WidgetFactory._();

  static const Map<String, WidgetSpec> _builtins = {
    'anchor': EagerSpec(AnchorWidget.build),
    'anchor_scope': EagerSpec(AnchorScopeWidget.build),
    'text': EagerSpec(TextWidget.build),
    'rich_text': EagerSpec(RichTextWidget.build),
    'container': EagerSpec(ContainerWidget.build),
    'column': EagerSpec(ColumnWidget.build),
    'row': EagerSpec(RowWidget.build),
    'sizedbox': EagerSpec(SizedBoxWidget.build),
    'padding': EagerSpec(PaddingWidget.build),
    'center': EagerSpec(CenterWidget.build),
    'align': EagerSpec(AlignWidget.build),
    'stack': EagerSpec(StackWidget.build),
    'positioned': EagerSpec(PositionedWidget.build),
    'expanded': EagerSpec(ExpandedWidget.build),
    'flexible': EagerSpec(FlexibleWidget.build),
    'absorb_pointer': EagerSpec(AbsorbPointerWidget.build),
    'backdrop_filter': EagerSpec(BackdropFilterWidget.build),
    'badge': EagerSpec(BadgeWidget.build),
    'color_filtered': EagerSpec(ColorFilteredWidget.build),
    'image_filtered': EagerSpec(ImageFilteredWidget.build),
    'opacity': EagerSpec(OpacityWidget.build),
    'ignore_pointer': EagerSpec(IgnorePointerWidget.build),
    'physical_model': EagerSpec(PhysicalModelWidget.build),
    'tooltip': EagerSpec(TooltipWidget.build),
    'unconstrained_box': EagerSpec(UnconstrainedBoxWidget.build),
    'wrap': EagerSpec(WrapWidget.build),
    'spacer': EagerSpec(SpacerWidget.build),
    'aspect_ratio': EagerSpec(AspectRatioWidget.build),
    'clip_rrect': EagerSpec(ClipRRectWidget.build),
    'clip_rect': EagerSpec(ClipRectWidget.build),
    'clip_oval': EagerSpec(ClipOvalWidget.build),
    'decorated_box': EagerSpec(DecoratedBoxWidget.build),
    'speech_balloon': EagerSpec(SpeechBalloonWidget.build),
    'serpentine': EagerSpec(SerpentineWidget.build),
    'serpentine_row': EagerSpec(SerpentineRowWidget.build),
    'spin_grid': ActionSpec(SpinGridWidget.build),
    'scratch_card': ActionSpec(ScratchCardWidget.build),
    'chart': EagerSpec(ChartWidget.build),
    'skeleton': EagerSpec(SkeletonWidget.build),
    'rotated_box': EagerSpec(RotatedBoxWidget.build),
    'visibility': EagerSpec(VisibilityWidget.build),
    'positioned_fill': EagerSpec(PositionedFillWidget.build),
    'image': SlotSpec(ImageWidget.build),
    'icon': EagerSpec(IconWidget.build),
    'interactive_viewer': EagerSpec(InteractiveViewerWidget.build),
    'constrained_box': EagerSpec(ConstrainedBoxWidget.build),
    'fitted_box': EagerSpec(FittedBoxWidget.build),
    'fractionally_sized_box': EagerSpec(FractionallySizedBoxWidget.build),
    'intrinsic_height': EagerSpec(IntrinsicHeightWidget.build),
    'intrinsic_width': EagerSpec(IntrinsicWidthWidget.build),
    'limited_box': EagerSpec(LimitedBoxWidget.build),
    'offstage': EagerSpec(OffstageWidget.build),
    'overflow_box': EagerSpec(OverflowBoxWidget.build),
    'sized_overflow_box': EagerSpec(SizedOverflowBoxWidget.build),
    'transform': EagerSpec(TransformWidget.build),
    'baseline': EagerSpec(BaselineWidget.build),
    'indexed_stack': EagerSpec(IndexedStackWidget.build),
    'flex': EagerSpec(FlexWidget.build),
    'list_body': EagerSpec(ListBodyWidget.build),
    'overflow_bar': EagerSpec(OverflowBarWidget.build),
    'safe_area': EagerSpec(SafeAreaWidget.build),
    'shader_mask': EagerSpec(ShaderMaskWidget.build),
    'divider': EagerSpec(DividerWidget.build),
    'vertical_divider': EagerSpec(VerticalDividerWidget.build),
    'circular_progress_indicator': EagerSpec(
      CircularProgressIndicatorWidget.build,
    ),
    'linear_progress_indicator': EagerSpec(LinearProgressIndicatorWidget.build),
    'loading_indicator': EagerSpec(LoadingIndicatorWidget.build),
    'single_child_scroll_view': EagerSpec(SingleChildScrollViewWidget.build),
    'auto_scroll': EagerSpec(AutoScrollWidget.build),
    'list_view': EagerSpec(ListViewWidget.build),
    'grid_view': EagerSpec(GridViewWidget.build),
    'page_view': ActionSpec(PageViewWidget.build),
    'video': ActionSpec(VideoWidget.build),
    'scrollbar': EagerSpec(ScrollbarWidget.build),
    'refresh_indicator': ActionSpec(RefreshIndicatorWidget.build),
    'dismissible': ActionSpec(DismissibleWidget.build),
    'custom_scroll_view': EagerSpec(
      CustomScrollViewWidget.build,
      childProtocol: LayoutProtocol.sliver,
    ),
    'sliver_to_box_adapter': EagerSpec(
      SliverToBoxAdapterWidget.build,
      produces: LayoutProtocol.sliver,
    ),
    'sliver_list': EagerSpec(
      SliverListWidget.build,
      produces: LayoutProtocol.sliver,
    ),
    'sliver_grid': EagerSpec(
      SliverGridWidget.build,
      produces: LayoutProtocol.sliver,
    ),
    'sliver_padding': EagerSpec(
      SliverPaddingWidget.build,
      produces: LayoutProtocol.sliver,
      childProtocol: LayoutProtocol.sliver,
    ),
    'sliver_fill_remaining': EagerSpec(
      SliverFillRemainingWidget.build,
      produces: LayoutProtocol.sliver,
    ),
    'sliver_persistent_header': EagerSpec(
      SliverPersistentHeaderWidget.build,
      produces: LayoutProtocol.sliver,
    ),
    'sliver_app_bar': SlotSpec(
      SliverAppBarWidget.build,
      produces: LayoutProtocol.sliver,
    ),
    'app_bar': SlotSpec(AppBarWidget.build),
    'swipe_layout': ActionSpec(SwipeLayoutWidget.build),
    'swipe_pane': EagerSpec(SwipePaneWidget.build),
    'swipe_indicator': EagerSpec(SwipeIndicatorWidget.build),
    'default_tab_controller': EagerSpec(DefaultTabControllerWidget.build),
    'tab_bar': EagerSpec(TabBarWidget.build),
    'tab': SlotSpec(TabWidget.build),
    'tab_bar_view': EagerSpec(TabBarViewWidget.build),
    'nested_scroll_view': EagerSpec(
      NestedScrollViewWidget.build,
      childProtocol: null,
    ),
    'toggle': BoundSpec(ToggleWidget.build),
    'cupertino_switch': BoundSpec(CupertinoSwitchWidget.build),
    'checkbox': BoundSpec(CheckboxWidget.build),
    'dropdown': BoundSpec(DropdownWidget.build),
    'radio': BoundSpec(RadioWidget.build),
    'slider': BoundSpec(SliderWidget.build),
    'text_field': BoundSpec(TextFieldWidget.build),
    'scaffold': SlotSpec(ScaffoldWidget.build),
    'list_tile': SlotSpec(ListTileWidget.build),
    'collapsing_header': BuilderSpec(
      CollapsingHeaderWidget.build,
      produces: LayoutProtocol.sliver,
    ),
  };

  static final Map<String, WidgetSpec> _specs = _buildSpecs();

  static Map<String, WidgetSpec> _buildSpecs() {
    for (final entry in _builtins.entries) {
      WidgetSchemaRegistry.register(entry.key, _schemaOf(entry.value));
    }
    return {..._builtins};
  }

  static WidgetSchema _schemaOf(WidgetSpec spec) => WidgetSchema(
    kind: _kindOf(spec),
    produces: spec.produces,
    childProtocol: spec.childProtocol,
  );

  static WidgetKind _kindOf(WidgetSpec spec) => switch (spec) {
    EagerSpec() => WidgetKind.eager,
    SlotSpec() => WidgetKind.slot,
    BuilderSpec() => WidgetKind.builder,
    BoundSpec() => WidgetKind.bound,
    ActionSpec() => WidgetKind.action,
  };

  static bool _frozen = false;

  /// Prevents subsequent widget registration.
  static void freeze() {
    _specs;
    _frozen = true;
  }

  /// Seeds the compile-time [WidgetSchemaRegistry] from the built-in specs.
  ///
  /// The validator reads the schema registry without touching this factory, so
  /// a mount must trigger the factory's lazy init before validating (touching
  /// [_specs] runs `_buildSpecs`, which registers every built-in schema).
  static void ensureRegistered() {
    _specs;
  }

  /// Returns whether [type] has a registered specification.
  static bool knows(String type) => _specs.containsKey(type);

  /// Returns the specification registered for [type], if any.
  static WidgetSpec? specFor(String type) => _specs[type];

  static void _requireUnfrozen() {
    if (_frozen) {
      throw StateError('WidgetFactory is frozen — register before freeze().');
    }
  }

  /// Associates [type] with [spec], replacing an existing entry.
  ///
  /// Throws [StateError] after the registry has been frozen.
  static void register(String type, WidgetSpec spec) {
    _requireUnfrozen();
    _specs[type] = spec;
    WidgetSchemaRegistry.register(type, _schemaOf(spec));
  }

  /// Registers every entry in [specs], or throws [StateError] when frozen.
  static void registerAll(Map<String, WidgetSpec> specs) {
    _requireUnfrozen();
    for (final entry in specs.entries) {
      register(entry.key, entry.value);
    }
  }

  /// Restores the built-in specifications and unfreezes the registry.
  static void reset() {
    _frozen = false;
    WidgetSchemaRegistry.reset();
    _specs
      ..clear()
      ..addAll(_builtins);
    for (final entry in _builtins.entries) {
      WidgetSchemaRegistry.register(entry.key, _schemaOf(entry.value));
    }
  }

  /// Builds the eager widget registered as [type].
  ///
  /// Throws [StateError] when [type] is unknown or uses a non-eager contract.
  static Widget build(
    BuildContext context,
    String type,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final spec = _specs[type];
    if (spec is! EagerSpec) {
      throw StateError('Unknown or non-eager widget type: "$type".');
    }
    return spec.build(context, props, children);
  }
}
