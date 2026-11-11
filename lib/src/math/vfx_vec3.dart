import 'dart:math' as math;

/// 3D vector for VFX particles, positions, velocities, and force fields.
class VfxVec3 {
  final double x;
  final double y;
  final double z;

  const VfxVec3(this.x, this.y, this.z);

  static const VfxVec3 zero = VfxVec3(0.0, 0.0, 0.0);
  static const VfxVec3 up = VfxVec3(0.0, 1.0, 0.0);
  static const VfxVec3 forward = VfxVec3(0.0, 0.0, -1.0);
  static const VfxVec3 right = VfxVec3(1.0, 0.0, 0.0);

  VfxVec3 operator +(VfxVec3 other) => VfxVec3(x + other.x, y + other.y, z + other.z);
  VfxVec3 operator -(VfxVec3 other) => VfxVec3(x - other.x, y - other.y, z - other.z);
  VfxVec3 operator -() => VfxVec3(-x, -y, -z);
  VfxVec3 operator *(double scalar) => VfxVec3(x * scalar, y * scalar, z * scalar);
  VfxVec3 operator /(double scalar) => VfxVec3(x / scalar, y / scalar, z / scalar);

  double dot(VfxVec3 other) => x * other.x + y * other.y + z * other.z;

  VfxVec3 cross(VfxVec3 other) {
    return VfxVec3(
      y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x,
    );
  }

  double get lengthSquared => x * x + y * y + z * z;
  double get length => math.sqrt(lengthSquared);

  VfxVec3 get normalized {
    final len = length;
    if (len < 1e-12) return VfxVec3.zero;
    return this / len;
  }

  static VfxVec3 lerp(VfxVec3 a, VfxVec3 b, double t) {
    return VfxVec3(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
      a.z + (b.z - a.z) * t,
    );
  }

  @override
  String toString() => 'VfxVec3(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}, ${z.toStringAsFixed(2)})';
}
