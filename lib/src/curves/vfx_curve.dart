/// Keyframe representing a value at a normalized time [0.0, 1.0].
class VfxKeyframe {
  final double time;
  final double value;

  const VfxKeyframe(this.time, this.value);
}

/// Curve evaluating scalar properties (size, speed modifier, alpha) over particle lifetime.
class VfxCurve {
  final List<VfxKeyframe> keyframes;

  VfxCurve(List<VfxKeyframe> frames) : keyframes = List.unmodifiable([...frames]..sort((a, b) => a.time.compareTo(b.time))) {
    if (keyframes.isEmpty) {
      throw ArgumentError('VfxCurve must have at least one keyframe');
    }
  }

  /// Constant value curve.
  factory VfxCurve.constant(double value) => VfxCurve([VfxKeyframe(0.0, value), VfxKeyframe(1.0, value)]);

  /// Linear ramp between start and end.
  factory VfxCurve.linear(double start, double end) => VfxCurve([VfxKeyframe(0.0, start), VfxKeyframe(1.0, end)]);

  /// Bell curve starting at min, peaking at mid (time 0.5), returning to min at 1.0.
  factory VfxCurve.bell({double min = 0.0, double peak = 1.0}) => VfxCurve([
        VfxKeyframe(0.0, min),
        VfxKeyframe(0.5, peak),
        VfxKeyframe(1.0, min),
      ]);

  /// Ease in curve.
  factory VfxCurve.easeIn({double start = 0.0, double end = 1.0}) => VfxCurve([
        VfxKeyframe(0.0, start),
        VfxKeyframe(0.5, start + (end - start) * 0.25),
        VfxKeyframe(1.0, end),
      ]);

  /// Ease out curve.
  factory VfxCurve.easeOut({double start = 0.0, double end = 1.0}) => VfxCurve([
        VfxKeyframe(0.0, start),
        VfxKeyframe(0.5, start + (end - start) * 0.75),
        VfxKeyframe(1.0, end),
      ]);

  /// Evaluates the curve at normalized progress [t] in [0.0, 1.0].
  double evaluate(double t) {
    if (keyframes.isEmpty) return 0.0;
    if (keyframes.length == 1) return keyframes.first.value;

    final clampedT = t.clamp(0.0, 1.0);
    if (clampedT <= keyframes.first.time) return keyframes.first.value;
    if (clampedT >= keyframes.last.time) return keyframes.last.value;

    for (int i = 0; i < keyframes.length - 1; i++) {
      final k0 = keyframes[i];
      final k1 = keyframes[i + 1];
      if (clampedT >= k0.time && clampedT <= k1.time) {
        final span = k1.time - k0.time;
        if (span <= 1e-12) return k1.value;
        final localT = (clampedT - k0.time) / span;
        return k0.value + (k1.value - k0.value) * localT;
      }
    }

    return keyframes.last.value;
  }
}
