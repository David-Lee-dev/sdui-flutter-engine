import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `text` — Builds Flutter's [Text], stringifying non-null dynamic values leniently.
///
/// ```yaml
/// _type: text
/// value: example
/// ```
///
/// Props:
/// - `value` (`dynamic`, default `null`) — displayed text value.
/// - `style` (`textStyle`, default `null`) — text style applied to the content.
/// - `text_align` (`textAlign`, default `null`) — horizontal alignment of text within each line. Values: left | right | center | justify | start | end.
/// - `max_lines` (`integer`, default `null`) — maximum number of displayed or editable lines.
/// - `overflow` (`textOverflow`, default `null`) — handling used when text exceeds its bounds. Values: clip | fade | ellipsis | visible.
/// - `soft_wrap` (`flag`, default `null`) — allows text to wrap at soft line breaks.
/// - `text_direction` (`textDirection`, default `null`) — resolves start/end ordering and alignment. Values: ltr | rtl.
/// - `semantics_label` (`text`, default `null`) — accessibility label.
///
/// Child: none.
final class TextWidget {
  const TextWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final value = props['value'];
    return Text(
      value == null ? '' : value.toString(),
      style: PropsResolver.textStyle(context, props['style']),
      textAlign: PropsResolver.textAlign(props['text_align']),
      maxLines: PropsResolver.integer(props['max_lines']),
      overflow: PropsResolver.textOverflow(props['overflow']),
      softWrap: PropsResolver.flag(props['soft_wrap']),
      textDirection: PropsResolver.textDirection(props['text_direction']),
      semanticsLabel: PropsResolver.text(props['semantics_label']),
    );
  }
}
