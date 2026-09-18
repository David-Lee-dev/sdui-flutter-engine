import 'dart:math';

import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `speech_balloon` — Paints a rounded balloon with an integrated bezier nip.
///
/// Props:
/// - `text` (`String`, default `''`) — fallback content when no child is given.
/// - `style` (`textStyle`, default `TextStyle()`) — fallback text styling.
/// - `decoration` (`boxDecoration`, default `null`) — box fill/border/radius
///   (`color` | `gradient`, `border`, `border_radius`), same schema as `container`.
/// - `nip_height` (`size`, default `10`) — nip height.
/// - `nip_width` (`size`, default five times `nip_height`) — nip width.
/// - `nip_position` (`String`, default `bottom`) — `top` or `bottom`.
/// - `width` (`size`, default intrinsic) — body width.
/// - `height` (`size`, default intrinsic) — body height excluding the nip.
/// - `padding` (`edge`, default horizontal 10 and vertical 6) — content inset.
///
/// Child: the first child, falling back to `text`.
///
/// SDUI type: `speech_balloon`.
final class SpeechBalloonWidget {
  const SpeechBalloonWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final content = children.isNotEmpty
        ? children.first
        : Text(
            props['text'] is String ? props['text']! as String : '',
            style:
                PropsResolver.textStyle(context, props['style']) ??
                const TextStyle(),
          );
    final deco = PropsResolver.boxDecoration(context, props['decoration']);
    final color = deco?.color;
    final gradient = deco?.gradient;
    final side = deco?.border is Border ? (deco!.border as Border).top : null;
    final borderColor = (side != null && side.style != BorderStyle.none)
        ? side.color
        : null;
    final borderWidth = (side != null && side.style != BorderStyle.none)
        ? side.width
        : 0.0;
    final radiusGeom = deco?.borderRadius;
    final radius = radiusGeom is BorderRadius ? radiusGeom.topLeft.x : 999.0;
    final nipHeight = PropsResolver.size(context, props['nip_height']) ?? 10.0;
    final nipWidth =
        PropsResolver.size(context, props['nip_width']) ?? nipHeight * 5;
    final nipPosition = props['nip_position'] == 'top'
        ? _NipPosition.top
        : _NipPosition.bottom;

    return _SpeechBalloon(
      color: color,
      gradient: gradient,
      borderColor: borderColor,
      borderWidth: borderWidth,
      radius: radius,
      nipHeight: nipHeight,
      nipWidth: nipWidth,
      nipPosition: nipPosition,
      width: PropsResolver.size(context, props['width']),
      height: PropsResolver.size(context, props['height']),
      padding:
          PropsResolver.edge(context, props['padding']) ??
          const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: content,
    );
  }
}

enum _NipPosition { top, bottom }

class _SpeechBalloon extends StatelessWidget {
  const _SpeechBalloon({
    this.color,
    this.gradient,
    this.borderColor,
    required this.borderWidth,
    required this.radius,
    required this.nipHeight,
    required this.nipWidth,
    required this.nipPosition,
    this.width,
    this.height,
    required this.padding,
    required this.child,
  });

  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final double nipHeight;
  final double nipWidth;
  final _NipPosition nipPosition;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isTop = nipPosition == _NipPosition.top;
    final balloon = CustomPaint(
      painter: _BalloonPainter(
        color: color ?? Colors.transparent,
        gradient: gradient,
        borderColor: borderColor,
        borderWidth: borderWidth,
        radius: radius,
        nipHeight: nipHeight,
        nipWidth: nipWidth,
        nipPosition: nipPosition,
      ),
      child: SizedBox(
        width: width,
        height: height != null ? height! + nipHeight : null,
        child: Padding(
          padding:
              padding +
              EdgeInsets.only(
                top: isTop ? nipHeight : 0,
                bottom: isTop ? 0 : nipHeight,
              ),
          child: Center(child: child),
        ),
      ),
    );
    Widget result = balloon;
    if (width == null) result = IntrinsicWidth(child: result);
    if (height == null) result = IntrinsicHeight(child: result);
    return result;
  }
}

class _BalloonPainter extends CustomPainter {
  _BalloonPainter({
    required this.color,
    this.gradient,
    this.borderColor,
    required this.borderWidth,
    required this.radius,
    required this.nipHeight,
    required this.nipWidth,
    required this.nipPosition,
  });

  final Color color;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final double nipHeight;
  final double nipWidth;
  final _NipPosition nipPosition;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyHeight = size.height - nipHeight;
    if (bodyHeight <= 0) return;
    final r = min(radius, bodyHeight / 2);
    final cx = size.width / 2;
    final halfNip = nipWidth / 2;

    final path = nipPosition == _NipPosition.top
        ? _buildTopNipPath(size, bodyHeight, r, cx, halfNip)
        : _buildBottomNipPath(size, bodyHeight, r, cx, halfNip);

    final fillPaint = Paint()..style = PaintingStyle.fill;
    if (gradient != null) {
      fillPaint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    } else {
      fillPaint.color = color;
    }
    canvas.drawPath(path, fillPaint);

    if (borderColor != null && borderWidth > 0) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = borderColor!
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, strokePaint);
    }
  }

  Path _buildBottomNipPath(
    Size size,
    double bodyH,
    double r,
    double cx,
    double halfNip,
  ) {
    return Path()
      ..moveTo(r, 0)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
      ..lineTo(size.width, bodyH - r)
      ..arcToPoint(Offset(size.width - r, bodyH), radius: Radius.circular(r))
      ..lineTo(cx + halfNip, bodyH)
      ..quadraticBezierTo(cx + halfNip * 0.5, bodyH, cx, size.height)
      ..quadraticBezierTo(cx - halfNip * 0.5, bodyH, cx - halfNip, bodyH)
      ..lineTo(r, bodyH)
      ..arcToPoint(Offset(0, bodyH - r), radius: Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..close();
  }

  Path _buildTopNipPath(
    Size size,
    double bodyH,
    double r,
    double cx,
    double halfNip,
  ) {
    final top = nipHeight;
    return Path()
      ..moveTo(cx, 0)
      ..quadraticBezierTo(cx + halfNip * 0.5, top, cx + halfNip, top)
      ..lineTo(size.width - r, top)
      ..arcToPoint(Offset(size.width, top + r), radius: Radius.circular(r))
      ..lineTo(size.width, top + bodyH - r)
      ..arcToPoint(
        Offset(size.width - r, top + bodyH),
        radius: Radius.circular(r),
      )
      ..lineTo(r, top + bodyH)
      ..arcToPoint(Offset(0, top + bodyH - r), radius: Radius.circular(r))
      ..lineTo(0, top + r)
      ..arcToPoint(Offset(r, top), radius: Radius.circular(r))
      ..lineTo(cx - halfNip, top)
      ..quadraticBezierTo(cx - halfNip * 0.5, top, cx, 0)
      ..close();
  }

  @override
  bool shouldRepaint(_BalloonPainter old) =>
      color != old.color ||
      gradient != old.gradient ||
      borderColor != old.borderColor ||
      borderWidth != old.borderWidth ||
      radius != old.radius ||
      nipHeight != old.nipHeight ||
      nipWidth != old.nipWidth ||
      nipPosition != old.nipPosition;
}
