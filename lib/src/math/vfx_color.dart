/// RGBA color representation for VFX particles and color gradients (0.0 to 1.0 components).
class VfxColor {
  final double r;
  final double g;
  final double b;
  final double a;

  const VfxColor(this.r, this.g, this.b, [this.a = 1.0]);

  static const VfxColor white = VfxColor(1.0, 1.0, 1.0, 1.0);
  static const VfxColor black = VfxColor(0.0, 0.0, 0.0, 1.0);
  static const VfxColor transparent = VfxColor(0.0, 0.0, 0.0, 0.0);
  static const VfxColor red = VfxColor(1.0, 0.0, 0.0, 1.0);
  static const VfxColor green = VfxColor(0.0, 1.0, 0.0, 1.0);
  static const VfxColor blue = VfxColor(0.0, 0.0, 1.0, 1.0);
  static const VfxColor yellow = VfxColor(1.0, 1.0, 0.0, 1.0);
  static const VfxColor cyan = VfxColor(0.0, 1.0, 1.0, 1.0);
  static const VfxColor magenta = VfxColor(1.0, 0.0, 1.0, 1.0);
  static const VfxColor orange = VfxColor(1.0, 0.5, 0.0, 1.0);

  factory VfxColor.fromInts(int r, int g, int b, [int a = 255]) {
    return VfxColor(
      (r.clamp(0, 255)) / 255.0,
      (g.clamp(0, 255)) / 255.0,
      (b.clamp(0, 255)) / 255.0,
      (a.clamp(0, 255)) / 255.0,
    );
  }

  VfxColor withAlpha(double alpha) => VfxColor(r, g, b, alpha.clamp(0.0, 1.0));

  static VfxColor lerp(VfxColor c1, VfxColor c2, double t) {
    final clampedT = t.clamp(0.0, 1.0);
    return VfxColor(
      c1.r + (c2.r - c1.r) * clampedT,
      c1.g + (c2.g - c1.g) * clampedT,
      c1.b + (c2.b - c1.b) * clampedT,
      c1.a + (c2.a - c1.a) * clampedT,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VfxColor &&
          runtimeType == other.runtimeType &&
          r == other.r &&
          g == other.g &&
          b == other.b &&
          a == other.a;

  @override
  int get hashCode => Object.hash(r, g, b, a);

  @override
  String toString() =>
      'VfxColor(${r.toStringAsFixed(2)}, ${g.toStringAsFixed(2)}, ${b.toStringAsFixed(2)}, ${a.toStringAsFixed(2)})';
}
