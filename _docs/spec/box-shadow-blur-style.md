# box_shadow blur_style (inner shadow)

User decision 2026-11-08: templates need an inner shadow on containers (e.g. a raised/bevelled pill card). Flutter's BoxShadow supports BlurStyle (normal, solid, outer, inner) but the engine's box_shadow decoding ignores it. Add it without breaking anything.

## Requirements
- B1 `box_shadow` entries (single map or list, wherever box_shadow is decoded today: decoration, and any other widget that reuses the same decoder) accept `blur_style: normal | solid | outer | inner`, mapped to Flutter BlurStyle. Absent → normal (today's behavior). Expression-bindable like other values.
- B2 An invalid value falls back to normal, following the engine's existing malformed-value policy (no throw), unless the existing convention for enums in that decoder is different — follow the existing convention.
- B3 Non-breaking: templates without blur_style render exactly as before. Decide, following existing engine conventions for new property values, whether a `_requires` capability is needed (older engines ignore unknown keys inside box_shadow → they would draw a normal outer shadow); document the decision and the behavior on older engines.
- B4 Tests at the public boundary (decoding + a widget/golden-free render check that the BoxDecoration carries the BlurStyle), docs (props reference where box_shadow is documented, motion/visual docs if relevant), CHANGELOG entry, version bump to 0.23.0. Do not publish (main publishes after review).

## Amendment 2026-11-08 (user decision after review)
Review found that Flutter BlurStyle.inner is not a CSS-style inset shadow (it fills the shape with the shadow color and softens only the inner edge). The user chose to add a real inset shadow and keep blur_style.
- B1a Docs/CHANGELOG must describe blur_style values by Flutter's actual semantics (normal, solid, outer glow, inner = fuzzy inside/nothing outside) and must not call `inner` an inset shadow or recommend it in foreground for an inset look.
- B5 `box_shadow` entries accept `inset: true` (default false). An inset entry draws a CSS-like inner shadow: the shadow appears inside the box's shape (respecting border_radius and shape circle), offset/blur_radius/spread_radius behave like CSS inset (positive spread shrinks the hole / thickens the shadow inward), clipped to the box, painted above the box background color/gradient and below the child (like CSS). Non-inset entries keep today's behavior and order. Mixed lists work (outer entries painted outside as today, inset entries inside).
- B6 Works wherever box_shadow is decoded (container decoration, decorated_box, speech_balloon if it uses the same decoration path); if a consumer cannot support inset, document it.
- B7 Tests: inset painting is verified at a public boundary (e.g. golden-free pixel/paint checks or painter calls) for rounded rect and circle, offset direction, and that non-inset rendering is unchanged. Docs with an example of a raised pill (top light inset + bottom dark inset). Same declare-only capability or a new one per existing convention; version stays 0.23.0.
