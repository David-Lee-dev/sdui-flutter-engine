import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'engine_metrics.dart';
import 'styled_border.dart';
import '../widget/util/icon_catalog.dart';

/// Decodes loosely typed template properties into Flutter values.
///
/// Decoders return `null` for absent, unknown, or malformed input so individual
/// properties can fall back without taking down a node. Pixel dimensions consume
/// [EngineMetrics]; ratios, enums, colors, transforms, and durations do not.
final class PropsResolver {
  const PropsResolver._();

  /// Whether [raw] requests a size-adaptive corner radius.
  static bool isAutoRadius(Object? raw) => raw == 'auto';

  static double scaleOf(BuildContext context) => EngineMetrics.scaleOf(context);

  /// Returns a scaled non-negative finite dimension, or `null`.
  static double? size(BuildContext context, Object? raw) {
    final value = _finite(raw);
    if (value == null || value < 0) return null;
    return value * scaleOf(context);
  }

  /// Returns a scaled signed finite offset, or `null`.
  static double? offset(BuildContext context, Object? raw) =>
      _scaledSigned(context, raw);

  /// Coerces a number or numeric string to a finite unscaled value.
  static double? number(Object? raw) => _finite(raw);

  static double? ratio01(Object? raw) =>
      _finite(raw)?.clamp(0.0, 1.0).toDouble();

  /// Decodes an ARGB integer or a `#RGB`, `#RRGGBB`, or `#AARRGGBB` string.
  static Color? color(Object? raw) {
    if (raw is int) return Color(raw);
    if (raw is! String) return null;
    final hex = raw.trim();
    if (!hex.startsWith('#')) return null;

    var digits = hex.substring(1);
    if (digits.length == 3) {
      digits = digits.split('').map((c) => '$c$c').join();
    }
    if (digits.length == 6) digits = 'ff$digits';
    if (digits.length != 8) return null;

    final value = int.tryParse(digits, radix: 16);
    return value == null ? null : Color(value);
  }

  static Alignment? alignment(Object? raw) =>
      raw is String ? _alignments[raw] : null;

  static AlignmentDirectional? alignmentDirectional(Object? raw) =>
      enumOf(raw, _alignmentDirectionals);

  /// Decodes one, two, or four scaled inset components.
  static EdgeInsets? edge(BuildContext context, Object? raw) {
    if (raw is List) {
      if (raw.length == 2) {
        final h = size(context, raw[0]);
        final v = size(context, raw[1]);
        if (h == null || v == null) return null;
        return EdgeInsets.symmetric(horizontal: h, vertical: v);
      }
      if (raw.length == 4) {
        final l = size(context, raw[0]);
        final t = size(context, raw[1]);
        final r = size(context, raw[2]);
        final b = size(context, raw[3]);
        if (l == null || t == null || r == null || b == null) return null;
        return EdgeInsets.fromLTRB(l, t, r, b);
      }
      return null;
    }
    final all = size(context, raw);
    return all == null ? null : EdgeInsets.all(all);
  }

  static BorderRadius? radius(BuildContext context, Object? raw) {
    if (raw is List) {
      if (raw.length != 4) return null;
      final values = [for (final v in raw) size(context, v)];
      if (values.any((v) => v == null)) return null;
      return BorderRadius.only(
        topLeft: Radius.circular(values[0]!),
        topRight: Radius.circular(values[1]!),
        bottomRight: Radius.circular(values[2]!),
        bottomLeft: Radius.circular(values[3]!),
      );
    }
    final all = size(context, raw);
    return all == null ? null : BorderRadius.circular(all);
  }

  static BoxConstraints? constraints(BuildContext context, Object? raw) {
    if (raw is! Map) return null;
    return BoxConstraints(
      minWidth: size(context, raw['min_width']) ?? 0,
      maxWidth: size(context, raw['max_width']) ?? double.infinity,
      minHeight: size(context, raw['min_height']) ?? 0,
      maxHeight: size(context, raw['max_height']) ?? double.infinity,
    );
  }

  static BoxBorder? border(BuildContext context, Object? raw) {
    if (raw is! Map) return null;
    if (const {'top', 'bottom', 'left', 'right'}.any(raw.containsKey)) {
      return Border(
        top: _side(context, raw['top']),
        bottom: _side(context, raw['bottom']),
        left: _side(context, raw['left']),
        right: _side(context, raw['right']),
      );
    }
    final style =
        enumOf(raw['style'], const {
          'solid': BorderLineStyle.solid,
          'dashed': BorderLineStyle.dashed,
          'dotted': BorderLineStyle.dotted,
        }) ??
        BorderLineStyle.solid;
    final grad = gradient(raw['gradient']);
    final resolvedColor = color(raw['color']);
    final width = size(context, raw['width']) ?? 1.0;
    if (style == BorderLineStyle.solid && grad == null) {
      return Border.all(
        color: resolvedColor ?? const Color(0xFF000000),
        width: width,
      );
    }
    return StyledBoxBorder(
      width: width,
      color: resolvedColor,
      gradient: grad,
      style: style,
      dash: size(context, raw['dash']) ?? 4.0,
      gap: size(context, raw['gap']) ?? 4.0,
    );
  }

  static BorderSide _side(BuildContext context, Object? raw) {
    if (raw is! Map) return BorderSide.none;
    return BorderSide(
      color: color(raw['color']) ?? const Color(0xFF000000),
      width: size(context, raw['width']) ?? 1.0,
    );
  }

  static List<BoxShadow>? boxShadow(BuildContext context, Object? raw) {
    if (raw is Map) {
      final shadow = _boxShadowOf(context, raw);
      return [shadow];
    }
    if (raw is List) {
      final shadows = [
        for (final item in raw)
          if (item is Map) _boxShadowOf(context, item),
      ];
      return shadows.isEmpty ? null : shadows;
    }
    return null;
  }

  static double? _scaledSigned(BuildContext context, Object? raw) {
    final value = _finite(raw);
    return value == null ? null : value * scaleOf(context);
  }

  static BoxShadow _boxShadowOf(
    BuildContext context,
    Map<Object?, Object?> raw,
  ) {
    final offsetRaw = raw['offset'];
    final dx = offsetRaw is List && offsetRaw.length == 2
        ? _scaledSigned(context, offsetRaw[0])
        : null;
    final dy = offsetRaw is List && offsetRaw.length == 2
        ? _scaledSigned(context, offsetRaw[1])
        : null;
    return BoxShadow(
      color: color(raw['color']) ?? const Color(0xFF000000),
      blurRadius: size(context, raw['blur_radius']) ?? 0.0,
      spreadRadius: size(context, raw['spread_radius']) ?? 0.0,
      offset: Offset(dx ?? 0.0, dy ?? 0.0),
    );
  }

  static List<ui.Shadow>? textShadows(BuildContext context, Object? raw) {
    if (raw is Map) return [_textShadowOf(context, raw)];
    if (raw is List) {
      final shadows = [
        for (final item in raw)
          if (item is Map) _textShadowOf(context, item),
      ];
      return shadows.isEmpty ? null : shadows;
    }
    return null;
  }

  static ui.Shadow _textShadowOf(
    BuildContext context,
    Map<Object?, Object?> raw,
  ) {
    final offsetRaw = raw['offset'];
    final dx = offsetRaw is List && offsetRaw.length == 2
        ? _scaledSigned(context, offsetRaw[0])
        : null;
    final dy = offsetRaw is List && offsetRaw.length == 2
        ? _scaledSigned(context, offsetRaw[1])
        : null;
    return ui.Shadow(
      color: color(raw['color']) ?? const Color(0xFF000000),
      blurRadius: size(context, raw['blur_radius']) ?? 0.0,
      offset: Offset(dx ?? 0.0, dy ?? 0.0),
    );
  }

  static BoxDecoration? boxDecoration(
    BuildContext context,
    Object? raw, {
    BorderRadius? borderRadius,
  }) {
    if (raw is! Map) return null;
    final resolvedGradient = gradient(raw['gradient']);
    return BoxDecoration(
      color: resolvedGradient == null ? color(raw['color']) : null,
      gradient: resolvedGradient,
      border: border(context, raw['border']),
      borderRadius: borderRadius ?? radius(context, raw['border_radius']),
      boxShadow: boxShadow(context, raw['box_shadow']),
      shape: boxShape(raw['shape']) ?? BoxShape.rectangle,
      backgroundBlendMode: blendMode(raw['background_blend_mode']),
    );
  }

  /// Decodes linear, radial, or sweep gradient data with at least two colors.
  static Gradient? gradient(Object? raw) {
    if (raw is! Map) return null;
    final colorsRaw = raw['colors'];
    if (colorsRaw is! List) return null;
    final colors = [
      for (final item in colorsRaw)
        if (color(item) case final resolved?) resolved,
    ];
    if (colors.length < 2) return null;

    List<double>? stops;
    final stopsRaw = raw['stops'];
    if (stopsRaw is List) {
      final resolved = [for (final item in stopsRaw) number(item)];
      final valid =
          resolved.length == colors.length &&
          resolved.every(
            (value) => value != null && value >= 0 && value <= 1,
          ) &&
          resolved.indexed.every(
            (entry) => entry.$1 == 0 || resolved[entry.$1 - 1]! <= entry.$2!,
          );
      if (valid) stops = [for (final value in resolved) value!];
    }

    final mode = enumOf(raw['tile_mode'], _tileModes) ?? TileMode.clamp;
    final radius = number(raw['radius']);
    final resolvedRadius = radius != null && radius >= 0 ? radius : 0.5;
    final startAngle = number(raw['start_angle']) ?? 0.0;
    final candidateEndAngle = number(raw['end_angle']) ?? 6.283185307179586;
    final endAngle = candidateEndAngle >= startAngle
        ? candidateEndAngle
        : startAngle + 6.283185307179586;
    return switch (raw['type']) {
      'radial' => RadialGradient(
        center: alignment(raw['center']) ?? Alignment.center,
        radius: resolvedRadius,
        colors: colors,
        stops: stops,
        tileMode: mode,
      ),
      'sweep' => SweepGradient(
        center: alignment(raw['center']) ?? Alignment.center,
        startAngle: startAngle,
        endAngle: endAngle,
        colors: colors,
        stops: stops,
        tileMode: mode,
      ),
      _ => LinearGradient(
        begin: alignment(raw['begin']) ?? Alignment.centerLeft,
        end: alignment(raw['end']) ?? Alignment.centerRight,
        colors: colors,
        stops: stops,
        tileMode: mode,
      ),
    };
  }

  /// Applies translation, rotation, then scale from a transform property map.
  static Matrix4? matrix4(Object? raw) {
    if (raw is! Map) return null;
    final matrix = Matrix4.identity();

    final translate = raw['translate'];
    if (translate is List && translate.length == 2) {
      final dx = number(translate[0]);
      final dy = number(translate[1]);
      if (dx != null && dy != null) {
        matrix.translateByDouble(dx, dy, 0, 1);
      }
    }

    final rotate = number(raw['rotate']);
    if (rotate != null) matrix.rotateZ(rotate);

    final scale = raw['scale'];
    if (scale is List && scale.length == 2) {
      final sx = number(scale[0]);
      final sy = number(scale[1]);
      if (sx != null && sy != null) matrix.scaleByDouble(sx, sy, 1, 1);
    } else {
      final uniform = number(scale);
      if (uniform != null) matrix.scaleByDouble(uniform, uniform, 1, 1);
    }
    return matrix;
  }

  static TextStyle? textStyle(BuildContext context, Object? raw) {
    if (raw is! Map) return null;
    return TextStyle(
      fontSize: size(context, raw['font_size']),
      color: color(raw['color']),
      fontWeight: fontWeight(raw['font_weight']),
      fontStyle: fontStyle(raw['font_style']),
      letterSpacing: _scaledSigned(context, raw['letter_spacing']),
      height: number(raw['height']),
      decoration: textDecorationLine(raw['decoration']),
      decorationColor: color(raw['decoration_color']),
      decorationStyle: textDecorationStyle(raw['decoration_style']),
      decorationThickness: number(raw['decoration_thickness']),
      leadingDistribution: leadingDistribution(raw['leading_distribution']),
      wordSpacing: _scaledSigned(context, raw['word_spacing']),
      backgroundColor: color(raw['background_color']),
      shadows: textShadows(context, raw['shadows']),
      fontFamily: text(raw['font_family']),
    );
  }

  static InputBorder? inputBorder(BuildContext context, Object? raw) {
    if (raw is! Map) return null;
    if (raw['type'] == 'none') return InputBorder.none;
    final side = BorderSide(
      color: color(raw['color']) ?? const BorderSide().color,
      width: size(context, raw['width']) ?? const BorderSide().width,
    );
    if (raw['type'] == 'outline') {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(size(context, raw['radius']) ?? 4),
        borderSide: side,
      );
    }
    return UnderlineInputBorder(borderSide: side);
  }

  static InputDecoration? inputDecoration(BuildContext context, Object? raw) {
    if (raw is! Map) return null;
    return InputDecoration(
      labelText: text(raw['label_text']),
      hintText: text(raw['hint_text']),
      helperText: text(raw['helper_text']),
      errorText: text(raw['error_text']),
      counterText: text(raw['counter_text']),
      prefixText: text(raw['prefix_text']),
      suffixText: text(raw['suffix_text']),
      prefixIcon: _icon(raw['prefix_icon']),
      suffixIcon: _icon(raw['suffix_icon']),
      filled: flag(raw['filled']),
      fillColor: color(raw['fill_color']),
      contentPadding: edge(context, raw['content_padding']),
      // isDense opts a field out of InputDecorator's 48px kMinInteractiveDimension
      // floor; left null (Flutter default false) so existing templates that size
      // their field off that floor are unaffected.
      isDense: flag(raw['is_dense']),
      isCollapsed: flag(raw['is_collapsed']) ?? false,
      border: inputBorder(context, raw['border']),
      enabledBorder: inputBorder(context, raw['enabled_border']),
      focusedBorder: inputBorder(context, raw['focused_border']),
      errorBorder: inputBorder(context, raw['error_border']),
      focusedErrorBorder: inputBorder(context, raw['focused_error_border']),
      disabledBorder: inputBorder(context, raw['disabled_border']),
      hintStyle: textStyle(context, raw['hint_style']),
      labelStyle: textStyle(context, raw['label_style']),
      errorStyle: textStyle(context, raw['error_style']),
      helperStyle: textStyle(context, raw['helper_style']),
      counterStyle: textStyle(context, raw['counter_style']),
      prefixStyle: textStyle(context, raw['prefix_style']),
      suffixStyle: textStyle(context, raw['suffix_style']),
      errorMaxLines: integer(raw['error_max_lines']),
      prefixIconColor: color(raw['prefix_icon_color']),
      suffixIconColor: color(raw['suffix_icon_color']),
      constraints: constraints(context, raw['constraints']),
      alignLabelWithHint: flag(raw['align_label_with_hint']),
      floatingLabelBehavior: floatingLabelBehavior(
        raw['floating_label_behavior'],
      ),
    );
  }

  static Icon? _icon(Object? raw) {
    final codePoint = IconCatalog.codePoint(raw);
    return codePoint == null
        ? null
        : Icon(IconData(codePoint, fontFamily: 'MaterialIcons'));
  }

  static OutlinedBorder? outlinedBorder(BuildContext context, Object? raw) {
    if (raw is! Map) return null;
    final sideRaw = raw['side'];
    final side = sideRaw is Map
        ? BorderSide(
            color: color(sideRaw['color']) ?? const BorderSide().color,
            width: size(context, sideRaw['width']) ?? const BorderSide().width,
          )
        : BorderSide.none;
    return switch (raw['type']) {
      'circle' => CircleBorder(side: side),
      'stadium' => StadiumBorder(side: side),
      _ => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size(context, raw['radius']) ?? 4),
        side: side,
      ),
    };
  }

  /// Coerces integral numbers and integer strings without truncating fractions.
  static int? integer(Object? raw) {
    if (raw is int) return raw;
    if (raw is num && raw.isFinite) return raw.toInt();
    if (raw is String) return int.tryParse(raw.trim());
    return null;
  }

  /// Returns [raw] only when it is already a boolean.
  static bool? flag(Object? raw) => raw is bool ? raw : null;

  /// Interprets common boolean-like values used by toggle properties.
  static bool truthy(Object? raw) {
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      return const {'true', '1', 'yes', 'on'}.contains(raw.toLowerCase());
    }
    return false;
  }

  static String? text(Object? raw) => raw is String ? raw : null;

  static Duration? duration(Object? raw) {
    final ms = _finite(raw);
    if (ms == null || ms < 0) return null;
    return Duration(milliseconds: ms.round());
  }

  /// Looks up a string property in [table], returning `null` when unknown.
  static T? enumOf<T>(Object? raw, Map<String, T> table) =>
      raw is String ? table[raw] : null;

  static MainAxisAlignment? mainAxisAlignment(Object? raw) =>
      enumOf(raw, _mainAxisAlignments);
  static CrossAxisAlignment? crossAxisAlignment(Object? raw) =>
      enumOf(raw, _crossAxisAlignments);
  static MainAxisSize? mainAxisSize(Object? raw) => enumOf(raw, _mainAxisSizes);
  static TextAlign? textAlign(Object? raw) => enumOf(raw, _textAligns);
  static TextAlignVertical? textAlignVertical(Object? raw) =>
      enumOf(raw, _textAlignVerticals);
  static TextOverflow? textOverflow(Object? raw) => enumOf(raw, _textOverflows);

  static FontWeight? fontWeight(Object? raw) {
    if (raw is num) return _fontWeightsByValue[raw.toInt()];
    return enumOf(raw, _fontWeights);
  }

  static FontStyle? fontStyle(Object? raw) => enumOf(raw, _fontStyles);

  static TextDecoration? textDecorationLine(Object? raw) =>
      enumOf(raw, _textDecorationLines);
  static TextDecorationStyle? textDecorationStyle(Object? raw) =>
      enumOf(raw, _textDecorationStyles);
  static TextLeadingDistribution? leadingDistribution(Object? raw) =>
      enumOf(raw, _leadingDistributions);
  static BoxFit? boxFit(Object? raw) => enumOf(raw, _boxFits);
  static TextInputAction? textInputAction(Object? raw) =>
      enumOf(raw, _textInputActions);
  static TextCapitalization? textCapitalization(Object? raw) =>
      enumOf(raw, _textCapitalizations);
  static FloatingLabelBehavior? floatingLabelBehavior(Object? raw) =>
      enumOf(raw, _floatingLabelBehaviors);
  static Brightness? brightness(Object? raw) => enumOf(raw, _brightnesses);
  static ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior(
    Object? raw,
  ) => enumOf(raw, _keyboardDismissBehaviors);
  static TabAlignment? tabAlignment(Object? raw) => enumOf(raw, _tabAlignments);
  static TabBarIndicatorSize? tabBarIndicatorSize(Object? raw) =>
      enumOf(raw, _tabBarIndicatorSizes);
  static ImageRepeat? imageRepeat(Object? raw) => enumOf(raw, _imageRepeats);
  static FilterQuality? filterQuality(Object? raw) =>
      enumOf(raw, _filterQualities);

  static FloatingActionButtonLocation? fabLocation(Object? raw) =>
      enumOf(raw, _fabLocations);
  static Axis? axis(Object? raw) => enumOf(raw, _axes);
  static VerticalDirection? verticalDirection(Object? raw) =>
      enumOf(raw, _verticalDirections);
  static TextDirection? textDirection(Object? raw) =>
      enumOf(raw, _textDirections);
  static TextBaseline? textBaseline(Object? raw) => enumOf(raw, _textBaselines);
  static WrapAlignment? wrapAlignment(Object? raw) =>
      enumOf(raw, _wrapAlignments);
  static WrapCrossAlignment? wrapCrossAlignment(Object? raw) =>
      enumOf(raw, _wrapCrossAlignments);
  static StackFit? stackFit(Object? raw) => enumOf(raw, _stackFits);
  static Clip? clip(Object? raw) => enumOf(raw, _clips);
  static FlexFit? flexFit(Object? raw) => enumOf(raw, _flexFits);
  static BoxShape? boxShape(Object? raw) => enumOf(raw, _boxShapes);

  static BlendMode? blendMode(Object? raw) => enumOf(raw, _blendModes);

  static DecorationPosition? decorationPosition(Object? raw) =>
      enumOf(raw, _decorationPositions);
  static OverflowBarAlignment? overflowBarAlignment(Object? raw) =>
      enumOf(raw, _overflowBarAlignments);
  static DismissDirection? dismissDirection(Object? raw) =>
      enumOf(raw, _dismissDirections);

  static ScrollPhysics? scrollPhysics(Object? raw) => switch (raw) {
    'never' => const NeverScrollableScrollPhysics(),
    'bouncing' => const BouncingScrollPhysics(),
    'clamping' => const ClampingScrollPhysics(),
    'always' => const AlwaysScrollableScrollPhysics(),
    _ => null,
  };

  static const Map<String, MainAxisAlignment> _mainAxisAlignments = {
    'start': MainAxisAlignment.start,
    'end': MainAxisAlignment.end,
    'center': MainAxisAlignment.center,
    'space_between': MainAxisAlignment.spaceBetween,
    'space_around': MainAxisAlignment.spaceAround,
    'space_evenly': MainAxisAlignment.spaceEvenly,
  };

  static const Map<String, CrossAxisAlignment> _crossAxisAlignments = {
    'start': CrossAxisAlignment.start,
    'end': CrossAxisAlignment.end,
    'center': CrossAxisAlignment.center,
    'stretch': CrossAxisAlignment.stretch,
    'baseline': CrossAxisAlignment.baseline,
  };

  static const Map<String, MainAxisSize> _mainAxisSizes = {
    'min': MainAxisSize.min,
    'max': MainAxisSize.max,
  };

  static const Map<String, TextAlign> _textAligns = {
    'left': TextAlign.left,
    'right': TextAlign.right,
    'center': TextAlign.center,
    'justify': TextAlign.justify,
    'start': TextAlign.start,
    'end': TextAlign.end,
  };

  static const Map<String, TextAlignVertical> _textAlignVerticals = {
    'top': TextAlignVertical.top,
    'center': TextAlignVertical.center,
    'bottom': TextAlignVertical.bottom,
  };

  static const Map<String, TextOverflow> _textOverflows = {
    'clip': TextOverflow.clip,
    'fade': TextOverflow.fade,
    'ellipsis': TextOverflow.ellipsis,
    'visible': TextOverflow.visible,
  };

  static const Map<String, FontWeight> _fontWeights = {
    'normal': FontWeight.normal,
    'bold': FontWeight.bold,
    'w100': FontWeight.w100,
    'w200': FontWeight.w200,
    'w300': FontWeight.w300,
    'w400': FontWeight.w400,
    'w500': FontWeight.w500,
    'w600': FontWeight.w600,
    'w700': FontWeight.w700,
    'w800': FontWeight.w800,
    'w900': FontWeight.w900,
  };

  static const Map<int, FontWeight> _fontWeightsByValue = {
    100: FontWeight.w100,
    200: FontWeight.w200,
    300: FontWeight.w300,
    400: FontWeight.w400,
    500: FontWeight.w500,
    600: FontWeight.w600,
    700: FontWeight.w700,
    800: FontWeight.w800,
    900: FontWeight.w900,
  };

  static const Map<String, FontStyle> _fontStyles = {
    'normal': FontStyle.normal,
    'italic': FontStyle.italic,
  };

  static const Map<String, TextDecoration> _textDecorationLines = {
    'none': TextDecoration.none,
    'underline': TextDecoration.underline,
    'overline': TextDecoration.overline,
    'line_through': TextDecoration.lineThrough,
  };

  static const Map<String, TextDecorationStyle> _textDecorationStyles = {
    'solid': TextDecorationStyle.solid,
    'double': TextDecorationStyle.double,
    'dotted': TextDecorationStyle.dotted,
    'dashed': TextDecorationStyle.dashed,
    'wavy': TextDecorationStyle.wavy,
  };

  static const Map<String, TextLeadingDistribution> _leadingDistributions = {
    'even': TextLeadingDistribution.even,
    'proportional': TextLeadingDistribution.proportional,
  };

  static const Map<String, TextInputAction> _textInputActions = {
    'next': TextInputAction.next,
    'done': TextInputAction.done,
    'search': TextInputAction.search,
    'send': TextInputAction.send,
    'go': TextInputAction.go,
    'previous': TextInputAction.previous,
    'newline': TextInputAction.newline,
    'continue_action': TextInputAction.continueAction,
  };

  static const Map<String, TextCapitalization> _textCapitalizations = {
    'none': TextCapitalization.none,
    'words': TextCapitalization.words,
    'sentences': TextCapitalization.sentences,
    'characters': TextCapitalization.characters,
  };

  static const Map<String, FloatingLabelBehavior> _floatingLabelBehaviors = {
    'auto': FloatingLabelBehavior.auto,
    'always': FloatingLabelBehavior.always,
    'never': FloatingLabelBehavior.never,
  };

  static const Map<String, Brightness> _brightnesses = {
    'light': Brightness.light,
    'dark': Brightness.dark,
  };

  static const Map<String, ScrollViewKeyboardDismissBehavior>
  _keyboardDismissBehaviors = {
    'manual': ScrollViewKeyboardDismissBehavior.manual,
    'on_drag': ScrollViewKeyboardDismissBehavior.onDrag,
  };

  static const Map<String, TabAlignment> _tabAlignments = {
    'start': TabAlignment.start,
    'start_offset': TabAlignment.startOffset,
    'fill': TabAlignment.fill,
    'center': TabAlignment.center,
  };

  static const Map<String, TabBarIndicatorSize> _tabBarIndicatorSizes = {
    'tab': TabBarIndicatorSize.tab,
    'label': TabBarIndicatorSize.label,
  };

  static const Map<String, ImageRepeat> _imageRepeats = {
    'no_repeat': ImageRepeat.noRepeat,
    'repeat': ImageRepeat.repeat,
    'repeat_x': ImageRepeat.repeatX,
    'repeat_y': ImageRepeat.repeatY,
  };

  static const Map<String, FilterQuality> _filterQualities = {
    'none': FilterQuality.none,
    'low': FilterQuality.low,
    'medium': FilterQuality.medium,
    'high': FilterQuality.high,
  };

  static const Map<String, FloatingActionButtonLocation> _fabLocations = {
    'start_float': FloatingActionButtonLocation.startFloat,
    'center_float': FloatingActionButtonLocation.centerFloat,
    'end_float': FloatingActionButtonLocation.endFloat,
    'start_top': FloatingActionButtonLocation.startTop,
    'center_top': FloatingActionButtonLocation.centerTop,
    'end_top': FloatingActionButtonLocation.endTop,
    'start_docked': FloatingActionButtonLocation.startDocked,
    'center_docked': FloatingActionButtonLocation.centerDocked,
    'end_docked': FloatingActionButtonLocation.endDocked,
    'mini_start_float': FloatingActionButtonLocation.miniStartFloat,
    'mini_center_float': FloatingActionButtonLocation.miniCenterFloat,
    'mini_end_float': FloatingActionButtonLocation.miniEndFloat,
  };

  static const Map<String, BoxFit> _boxFits = {
    'fill': BoxFit.fill,
    'contain': BoxFit.contain,
    'cover': BoxFit.cover,
    'fit_width': BoxFit.fitWidth,
    'fit_height': BoxFit.fitHeight,
    'none': BoxFit.none,
    'scale_down': BoxFit.scaleDown,
  };

  static const Map<String, Axis> _axes = {
    'horizontal': Axis.horizontal,
    'vertical': Axis.vertical,
  };

  static const Map<String, VerticalDirection> _verticalDirections = {
    'up': VerticalDirection.up,
    'down': VerticalDirection.down,
  };

  static const Map<String, TextDirection> _textDirections = {
    'ltr': TextDirection.ltr,
    'rtl': TextDirection.rtl,
  };

  static const Map<String, TextBaseline> _textBaselines = {
    'alphabetic': TextBaseline.alphabetic,
    'ideographic': TextBaseline.ideographic,
  };

  static const Map<String, WrapAlignment> _wrapAlignments = {
    'start': WrapAlignment.start,
    'end': WrapAlignment.end,
    'center': WrapAlignment.center,
    'space_between': WrapAlignment.spaceBetween,
    'space_around': WrapAlignment.spaceAround,
    'space_evenly': WrapAlignment.spaceEvenly,
  };

  static const Map<String, WrapCrossAlignment> _wrapCrossAlignments = {
    'start': WrapCrossAlignment.start,
    'end': WrapCrossAlignment.end,
    'center': WrapCrossAlignment.center,
  };

  static const Map<String, StackFit> _stackFits = {
    'loose': StackFit.loose,
    'expand': StackFit.expand,
    'passthrough': StackFit.passthrough,
  };

  static const Map<String, Clip> _clips = {
    'none': Clip.none,
    'hard_edge': Clip.hardEdge,
    'anti_alias': Clip.antiAlias,
    'anti_alias_with_save_layer': Clip.antiAliasWithSaveLayer,
  };

  static const Map<String, FlexFit> _flexFits = {
    'tight': FlexFit.tight,
    'loose': FlexFit.loose,
  };

  static const Map<String, BoxShape> _boxShapes = {
    'rectangle': BoxShape.rectangle,
    'circle': BoxShape.circle,
  };

  static const Map<String, TileMode> _tileModes = {
    'clamp': TileMode.clamp,
    'repeated': TileMode.repeated,
    'mirror': TileMode.mirror,
    'decal': TileMode.decal,
  };

  static const Map<String, BlendMode> _blendModes = {
    'src_over': BlendMode.srcOver,
    'src_atop': BlendMode.srcATop,
    'src_in': BlendMode.srcIn,
    'dst_in': BlendMode.dstIn,
    'modulate': BlendMode.modulate,
    'multiply': BlendMode.multiply,
    'screen': BlendMode.screen,
    'overlay': BlendMode.overlay,
    'darken': BlendMode.darken,
    'lighten': BlendMode.lighten,
    'color': BlendMode.color,
    'hue': BlendMode.hue,
    'saturation': BlendMode.saturation,
    'luminosity': BlendMode.luminosity,
    'difference': BlendMode.difference,
    'exclusion': BlendMode.exclusion,
    'plus': BlendMode.plus,
    'clear': BlendMode.clear,
  };

  static const Map<String, DecorationPosition> _decorationPositions = {
    'background': DecorationPosition.background,
    'foreground': DecorationPosition.foreground,
  };

  static const Map<String, OverflowBarAlignment> _overflowBarAlignments = {
    'start': OverflowBarAlignment.start,
    'center': OverflowBarAlignment.center,
    'end': OverflowBarAlignment.end,
  };

  static const Map<String, DismissDirection> _dismissDirections = {
    'horizontal': DismissDirection.horizontal,
    'vertical': DismissDirection.vertical,
    'end_to_start': DismissDirection.endToStart,
    'start_to_end': DismissDirection.startToEnd,
    'up': DismissDirection.up,
    'down': DismissDirection.down,
    'none': DismissDirection.none,
  };

  static double? _finite(Object? raw) {
    final value = switch (raw) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s.trim()),
      _ => null,
    };
    return value != null && value.isFinite ? value : null;
  }

  static const Map<String, Alignment> _alignments = {
    'top_left': Alignment.topLeft,
    'top_center': Alignment.topCenter,
    'top_right': Alignment.topRight,
    'center_left': Alignment.centerLeft,
    'center': Alignment.center,
    'center_right': Alignment.centerRight,
    'bottom_left': Alignment.bottomLeft,
    'bottom_center': Alignment.bottomCenter,
    'bottom_right': Alignment.bottomRight,
  };

  static const Map<String, AlignmentDirectional> _alignmentDirectionals = {
    'top_start': AlignmentDirectional.topStart,
    'top_center': AlignmentDirectional.topCenter,
    'top_end': AlignmentDirectional.topEnd,
    'center_start': AlignmentDirectional.centerStart,
    'center': AlignmentDirectional.center,
    'center_end': AlignmentDirectional.centerEnd,
    'bottom_start': AlignmentDirectional.bottomStart,
    'bottom_center': AlignmentDirectional.bottomCenter,
    'bottom_end': AlignmentDirectional.bottomEnd,
  };
}
