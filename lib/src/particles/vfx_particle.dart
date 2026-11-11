import '../math/vfx_color.dart';
import '../math/vfx_vec3.dart';

/// Single particle instance held in a pre-allocated simulation pool.
class VfxParticle {
  VfxVec3 position = VfxVec3.zero;
  VfxVec3 velocity = VfxVec3.zero;
  VfxVec3 acceleration = VfxVec3.zero;

  double age = 0.0;
  double lifetime = 1.0;

  double startSize = 1.0;
  double currentSize = 1.0;

  VfxColor currentColor = VfxColor.white;

  double rotation = 0.0;
  double angularVelocity = 0.0;

  bool isAlive = false;

  /// Progress through life in [0.0, 1.0].
  double get progress => lifetime > 1e-12 ? (age / lifetime).clamp(0.0, 1.0) : 1.0;

  /// Resets and activates this particle from pool.
  void spawn({
    required VfxVec3 spawnPosition,
    required VfxVec3 initialVelocity,
    required double totalLifetime,
    required double size,
    required VfxColor color,
    double initialRotation = 0.0,
    double spin = 0.0,
  }) {
    position = spawnPosition;
    velocity = initialVelocity;
    acceleration = VfxVec3.zero;
    age = 0.0;
    lifetime = totalLifetime;
    startSize = size;
    currentSize = size;
    currentColor = color;
    rotation = initialRotation;
    angularVelocity = spin;
    isAlive = true;
  }

  /// Deactivates this particle.
  void kill() {
    isAlive = false;
  }
}
