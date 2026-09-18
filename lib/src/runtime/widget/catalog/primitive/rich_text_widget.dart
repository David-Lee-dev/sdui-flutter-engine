import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `rich_text` — Builds [RichText] from a list of inline-span descriptions.
///
/// Malformed span entries are ignored so one invalid fragment does not prevent
/// the remaining text from rendering.
///
/// ```yaml
/// _type: rich_text
/// spans: example
/// ```
///
/// Props:
/// - `spans` (`list`, default `null`) — inline span maps containing `value` and optional `style`.
/// - `text_align` (`textAlign`, default `null`) — horizontal alignment of text within each line. Values: left | right | center | justify | start | end.
/// - `max_lines` (`integer`, default `null`) — maximum number of displayed or editable lines.
/// - `overflow` (`textOverflow`, default `null`) — handling used when text exceeds its bounds. Values: clip | fade | ellipsis | visible.
/// - `soft_wrap` (`flag`, default `null`) — allows text to wrap at soft line breaks.
/// - `style` (`textStyle`, default `null`) — text style applied to the content.
///
/// Child: none.
final class RichTextWidget {
  const RichTextWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final spansRaw = props['spans'];
    final spans = spansRaw is List
        ? <InlineSpan>[
            for (final span in spansRaw)
              if (span is Map)
                TextSpan(
                  text: (span['value'] ?? '').toString(),
                  style: PropsResolver.textStyle(context, span['style']),
                ),
          ]
        : const <InlineSpan>[];
    return Text.rich(
      TextSpan(children: spans),
      textAlign: PropsResolver.textAlign(props['text_align']),
      maxLines: PropsResolver.integer(props['max_lines']),
      overflow: PropsResolver.textOverflow(props['overflow']),
      softWrap: PropsResolver.flag(props['soft_wrap']),
      style: PropsResolver.textStyle(context, props['style']),
    );
  }
}
