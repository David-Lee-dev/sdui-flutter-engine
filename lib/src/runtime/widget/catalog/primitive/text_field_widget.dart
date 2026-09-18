import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../engine_registries.dart';
import '../../../util/props_resolver.dart';

/// `text_field` — Builds a controlled [TextField] synchronized with the bound engine value.
///
/// Its private controller mirrors external value changes without resetting the
/// selection unnecessarily, and forwards edits and submissions separately. A
/// non-empty `id` also registers its focus node with the mount's focus registry.
///
/// ```yaml
/// _type: text_field
/// input_type: text
/// bind: state_key
/// _on: { change: change_action, submit: submit_action }
/// ```
///
/// Props:
/// - `input_type` (`text`, default `text`) — keyboard type + input formatting. Values: text | number | phone | email | multiline | url.
/// - `decoration` (`inputDecoration`, default `empty decoration`) — paints the box or field decoration.
/// - `hint_text` (`text`, default `base.hintText`) — placeholder shown while the field is empty.
/// - `error_text` (`text`, default `base.errorText`) — error message shown by the field decoration.
/// - `id` (`text`, default `null`) — identifier used to register or connect the widget.
/// - `obscure_text` (`flag`, default `false`) — masks entered characters.
/// - `max_lines` (`integer`, default `null`) — maximum number of displayed or editable lines.
/// - `enabled` (`flag`, default `true`) — whether interaction is enabled.
/// - `read_only` (`flag`, default `false`) — allows selection without permitting edits.
/// - `semantics_label` (`text`, default `null`) — accessibility label.
/// - `max_length` (`integer`, default `null`) — maximum number of input characters.
/// - `text_input_action` (`textInputAction`, default `null`) — action button displayed by the software keyboard. Values: next | done | search | send | go | previous | newline | continue_action.
/// - `text_capitalization` (`textCapitalization`, default `none`) — capitalization behavior requested from the keyboard. Values: none | words | sentences | characters.
/// - `min_lines` (`integer`, default `null`) — minimum number of editable lines.
/// - `text_align` (`textAlign`, default `start`) — horizontal alignment of text within each line. Values: left | right | center | justify | start | end.
/// - `autofocus` (`flag`, default `false`) — requests focus when the field first appears.
/// - `style` (`textStyle`, default `null`) — text style of the entered text.
/// - `text_align_vertical` (`textAlignVertical`, default `null`) — vertical alignment of text within the field. Values: top | center | bottom.
/// - `cursor_color` (`color`, default `null`) — color of the text cursor.
/// - `cursor_width` (`size`, default `2.0`) — width of the text cursor.
/// - `cursor_height` (`size`, default `null`) — height of the text cursor.
/// - `cursor_radius` (`size`, default `null`) — corner radius of the text cursor.
/// - `keyboard_appearance` (`brightness`, default `null`) — keyboard brightness. Values: light | dark.
/// - `autocorrect` (`flag`, default `true`) — requests autocorrect from the keyboard.
/// - `enable_suggestions` (`flag`, default `true`) — requests input suggestions from the keyboard.
/// - `expands` (`flag`, default `false`) — fills the available vertical space; only takes effect when the effective `max_lines`/`min_lines` are both unset (e.g. `input_type: multiline` without them), since Flutter forbids combining `expands` with either.
///
/// Child: none.
final class TextFieldWidget {
  const TextFieldWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Object? value,
    ValueChanged<Object?>? onChanged,
    ValueChanged<Object?>? onSubmit,
  ) {
    final inputType = _TextFieldInputType.from(props['input_type']);
    final base =
        PropsResolver.inputDecoration(context, props['decoration']) ??
        const InputDecoration();
    final decoration = base.copyWith(
      hintText: PropsResolver.text(props['hint_text']) ?? base.hintText,
      errorText: PropsResolver.text(props['error_text']) ?? base.errorText,
    );
    final cursorRadiusValue = PropsResolver.size(
      context,
      props['cursor_radius'],
    );
    return _ControlledTextField(
      value: value,
      onChanged: onChanged,
      onSubmit: onSubmit,
      id: PropsResolver.text(props['id']),
      decoration: decoration,
      obscureText: PropsResolver.flag(props['obscure_text']) ?? false,
      maxLines: inputType == _TextFieldInputType.multiline
          ? PropsResolver.integer(props['max_lines'])
          : PropsResolver.integer(props['max_lines']) ?? 1,
      enabled: PropsResolver.flag(props['enabled']) ?? true,
      readOnly: PropsResolver.flag(props['read_only']) ?? false,
      semanticsLabel: PropsResolver.text(props['semantics_label']),
      inputType: inputType,
      maxLength: PropsResolver.integer(props['max_length']),
      textInputAction: PropsResolver.textInputAction(
        props['text_input_action'],
      ),
      textCapitalization:
          PropsResolver.textCapitalization(props['text_capitalization']) ??
          TextCapitalization.none,
      minLines: PropsResolver.integer(props['min_lines']),
      textAlign:
          PropsResolver.textAlign(props['text_align']) ?? TextAlign.start,
      autofocus: PropsResolver.flag(props['autofocus']) ?? false,
      style: PropsResolver.textStyle(context, props['style']),
      textAlignVertical: PropsResolver.textAlignVertical(
        props['text_align_vertical'],
      ),
      cursorColor: PropsResolver.color(props['cursor_color']),
      cursorWidth: PropsResolver.size(context, props['cursor_width']) ?? 2.0,
      cursorHeight: PropsResolver.size(context, props['cursor_height']),
      cursorRadius: cursorRadiusValue == null
          ? null
          : Radius.circular(cursorRadiusValue),
      keyboardAppearance: PropsResolver.brightness(
        props['keyboard_appearance'],
      ),
      autocorrect: PropsResolver.flag(props['autocorrect']) ?? true,
      enableSuggestions:
          PropsResolver.flag(props['enable_suggestions']) ?? true,
      expands: PropsResolver.flag(props['expands']) ?? false,
    );
  }
}

class _ControlledTextField extends StatefulWidget {
  const _ControlledTextField({
    required this.value,
    required this.onChanged,
    required this.onSubmit,
    required this.id,
    required this.decoration,
    required this.obscureText,
    required this.maxLines,
    required this.enabled,
    required this.readOnly,
    required this.semanticsLabel,
    required this.inputType,
    required this.maxLength,
    required this.textInputAction,
    required this.textCapitalization,
    required this.minLines,
    required this.textAlign,
    required this.autofocus,
    required this.style,
    required this.textAlignVertical,
    required this.cursorColor,
    required this.cursorWidth,
    required this.cursorHeight,
    required this.cursorRadius,
    required this.keyboardAppearance,
    required this.autocorrect,
    required this.enableSuggestions,
    required this.expands,
  });

  final Object? value;
  final ValueChanged<Object?>? onChanged;
  final ValueChanged<Object?>? onSubmit;

  final String? id;
  final InputDecoration decoration;
  final bool obscureText;
  final int? maxLines;
  final bool enabled;
  final bool readOnly;
  final String? semanticsLabel;
  final _TextFieldInputType inputType;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int? minLines;
  final TextAlign textAlign;
  final bool autofocus;
  final TextStyle? style;
  final TextAlignVertical? textAlignVertical;
  final Color? cursorColor;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Brightness? keyboardAppearance;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool expands;

  @override
  State<_ControlledTextField> createState() => _ControlledTextFieldState();
}

class _ControlledTextFieldState extends State<_ControlledTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  FocusRegistry? _focusRegistry;
  String? _registeredId;

  void _syncFocusRegistration() {
    final registry = EngineRegistryScope.of(context)?.focus;
    final id = (widget.id != null && widget.id!.isNotEmpty) ? widget.id : null;
    if (identical(registry, _focusRegistry) && id == _registeredId) return;
    if (_focusRegistry != null && _registeredId != null) {
      _focusRegistry!.unregister(_registeredId!, _focusNode);
    }
    _focusRegistry = registry;
    _registeredId = id;
    if (registry != null && id != null) registry.register(id, _focusNode);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFocusRegistration();
    _syncFromValue();
  }

  @override
  void didUpdateWidget(_ControlledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) _syncFocusRegistration();
    if (oldWidget.value != widget.value) _syncFromValue();
  }

  void _syncFromValue() {
    final text = widget.value?.toString() ?? '';
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    if (_focusRegistry != null && _registeredId != null) {
      _focusRegistry!.unregister(_registeredId!, _focusNode);
    }
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onChanged = widget.onChanged;
    final maxLines = widget.obscureText ? 1 : widget.maxLines;
    final minLines = widget.obscureText ? null : widget.minLines;
    // TextField asserts !expands || (maxLines == null && minLines == null); only
    // honor the prop once obscureText's own override has had the final say.
    final expands = widget.expands && maxLines == null && minLines == null;
    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: widget.obscureText,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      textAlign: widget.textAlign,
      autofocus: widget.autofocus,
      decoration: widget.decoration,
      keyboardType: widget.inputType.keyboardType,
      inputFormatters: widget.inputType.inputFormatters,
      style: widget.style,
      textAlignVertical: widget.textAlignVertical,
      cursorColor: widget.cursorColor,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      keyboardAppearance: widget.keyboardAppearance,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      expands: expands,
      onChanged: !widget.enabled || onChanged == null
          ? null
          : (text) => onChanged(widget.inputType.encode(text)),
      onSubmitted: !widget.enabled || widget.onSubmit == null
          ? null
          : (text) => widget.onSubmit!(widget.inputType.encode(text)),
    );
    return widget.semanticsLabel == null
        ? field
        : Semantics(
            label: widget.semanticsLabel,
            textField: true,
            child: field,
          );
  }
}

enum _TextFieldInputType {
  text(TextInputType.text),
  number(TextInputType.number),
  phone(TextInputType.phone),
  email(TextInputType.emailAddress),
  multiline(TextInputType.multiline),
  url(TextInputType.url);

  const _TextFieldInputType(this.keyboardType);

  factory _TextFieldInputType.from(Object? raw) {
    final name = PropsResolver.text(raw);
    return _TextFieldInputType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => _TextFieldInputType.text,
    );
  }

  final TextInputType keyboardType;

  List<TextInputFormatter>? get inputFormatters => this == number
      ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))]
      : null;

  Object? encode(String text) {
    if (this != number) return text;
    if (text.isEmpty) return null;
    if (text == '-' || text.endsWith('.')) return text;
    return num.tryParse(text) ?? text;
  }
}
