import '../math/vfx_color.dart';

/// Single color stop on a color gradient timeline [0.0, 1.0].
class VfxColorStop {
  final double time;
  final VfxColor color;

  const VfxColorStop(this.time, this.color);
}

/// Gradient evaluating colors and alpha over normalized particle lifetime.
class VfxColorGradient {
  final List<VfxColorStop> stops;

  VfxColorGradient(List<VfxColorStop> stopList)
      : stops = List.unmodifiable([...stopList]..sort((a, b) => a.time.compareTo(b.time))) {
    if (stops.isEmpty) {
      throw ArgumentError('VfxColorGradient must have at least one stop');
    }
  }

  /// Constant single color throughout lifetime.
  factory VfxColorGradient.single(VfxColor color) =>
      VfxColorGradient([VfxColorStop(0.0, color), VfxColorStop(1.0, color)]);

  /// Single color that fades to transparent over lifetime.
  factory VfxColorGradient.fade(VfxColor color) => VfxColorGradient([
        VfxColorStop(0.0, color),
        VfxColorStop(1.0, color.withAlpha(0.0)),
      ]);

  /// Fire gradient: white/yellow core -> orange -> red -> dark smoky ember.
  factory VfxColorGradient.fire() => VfxColorGradient([
        const VfxColorStop(0.0, VfxColor(1.0, 1.0, 0.8, 1.0)),
        const VfxColorStop(0.2, VfxColor(1.0, 0.9, 0.1, 1.0)),
        const VfxColorStop(0.5, VfxColor(1.0, 0.4, 0.0, 0.9)),
        const VfxColorStop(0.8, VfxColor(0.8, 0.1, 0.0, 0.5)),
        const VfxColorStop(1.0, VfxColor(0.2, 0.2, 0.2, 0.0)),
      ]);

  /// Smoke gradient: light gray fading to transparent dark charcoal.
  factory VfxColorGradient.smoke() => VfxColorGradient([
        const VfxColorStop(0.0, VfxColor(0.7, 0.7, 0.7, 0.6)),
        const VfxColorStop(0.5, VfxColor(0.5, 0.5, 0.5, 0.4)),
        const VfxColorStop(1.0, VfxColor(0.2, 0.2, 0.2, 0.0)),
      ]);

  /// Plasma gradient: cyan -> magenta -> deep violet.
  factory VfxColorGradient.plasma() => VfxColorGradient([
        const VfxColorStop(0.0, VfxColor(0.2, 0.9, 1.0, 1.0)),
        const VfxColorStop(0.5, VfxColor(0.9, 0.1, 0.9, 0.8)),
        const VfxColorStop(1.0, VfxColor(0.3, 0.0, 0.7, 0.0)),
      ]);

  /// Evaluates color at normalized time [t] in [0.0, 1.0].
  VfxColor evaluate(double t) {
    if (stops.isEmpty) return VfxColor.white;
    if (stops.length == 1) return stops.first.color;

    final clampedT = t.clamp(0.0, 1.0);
    if (clampedT <= stops.first.time) return stops.first.color;
    if (clampedT >= stops.last.time) return stops.last.color;

    for (int i = 0; i < stops.length - 1; i++) {
      final s0 = stops[i];
      final s1 = stops[i + 1];
      if (clampedT >= s0.time && clampedT <= s1.time) {
        final span = s1.time - s0.time;
        if (span <= 1e-12) return s1.color;
        final localT = (clampedT - s0.time) / span;
        return VfxColor.lerp(s0.color, s1.color, localT);
      }
    }

    return stops.last.color;
  }
}
