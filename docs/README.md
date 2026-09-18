# SDUI template-language reference

This reference documents the template language implemented by the engine, from syntax and state through commands, motion, media, and every widget catalog entry.

## Suggested reading order

1. [Concepts](concepts.md) — node anatomy, compilation, validation, and layout protocols.
2. [Expressions](expressions.md) — `${…}` syntax, operators, and built-in functions.
3. [State](state.md) — scopes, reactive reads, binding writes, and root data.
4. [Actions](actions.md) and [commands](commands/net.md) — flows, handlers, and drivers.
5. [Control flow](control-flow.md), [loops](loops.md), and [lifecycle](lifecycle.md).
6. [Interaction](interaction.md), [motion](motion.md), and [media](media.md).
7. [Widget catalog](widgets/README.md) — all 103 registered widget types and the internal catalog helper.

## Language guides

- [Concepts](concepts.md) — parsing, directive wrappers, catalog guarantees, reserved keys, and box/sliver safety.
- [Expressions](expressions.md) — complete expression grammar and all built-in functions.
- [State](state.md) — `_scope._state`, reactivity, shadowing, `bind`, and root data.
- [Actions](actions.md) — `_action`, sequential/concurrent flows, guards, handlers, and errors.
- [Lifecycle](lifecycle.md) — `mount`, `render`, `remount`, `interval`, and `dispose` hooks.
- [Interaction](interaction.md) — all `_on` events, payloads, timing, and press feedback.
- [Control flow](control-flow.md) — `cond`, `switch`, node `_if`, and `_morph`.
- [Loops](loops.md) — `_loop`, stable keys, all 14 wrappers, lazy/eager behavior, and mutation.
- [Motion](motion.md) — nine atoms, every composite preset, curves, and scheduling parameters.
- [Media](media.md) — image/video source policies, placeholders, cross-fades, and controls.
- [Widget catalog](widgets/README.md) — categorized widget index with protocol and loop-wrapper status.

## Built-in commands

- [`net`](commands/net.md) — send application-defined request fields through a selected `NetworkClient`.
- [`navigate`](commands/navigate.md) — push, replace via `go`, or pop a route.
- [`modal`](commands/modal.md) — open and close engine-rendered modal templates.
- [`toast`](commands/toast.md) — show a host toast.
- [`scroll`](commands/scroll.md) — reveal a registered anchor.
- [`anchoring`](commands/anchoring.md) — animate registered content between anchors.
- [`set`](commands/set.md) — commit values to the defining scope.
- [`app_storage`](commands/app-storage.md) — get/set values and calendar-day throttling stamps.
- [`secure_storage`](commands/secure-storage.md) — read/write/delete secure strings.
- [`sys_haptic`](commands/sys-haptic.md) — platform haptic impulses and semantic patterns.
- [External commands](commands/external.md) — app-owned commands registered through `SduiService`.
