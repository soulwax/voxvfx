import 'dart:math' as math;
import '../math/vfx_vec3.dart';
import '../particles/vfx_particle.dart';

/// Base class for all physical forces acting on VFX particles.
abstract class VfxForce {
  const VfxForce();

  /// Calculates acceleration or force vector to apply to [particle] during [dt].
  VfxVec3 calculateForce(VfxParticle particle, double dt);
}

/// Constant directional gravitational acceleration (e.g. earth gravity: VfxVec3(0, -9.81, 0)).
class GravityForce extends VfxForce {
  final VfxVec3 gravity;

  const GravityForce([this.gravity = const VfxVec3(0.0, -9.81, 0.0)]);

  @override
  VfxVec3 calculateForce(VfxParticle particle, double dt) => gravity;
}

/// Drag force resisting velocity proportionally to velocity.
class LinearDragForce extends VfxForce {
  final double dragCoefficient;

  const LinearDragForce(this.dragCoefficient);

  @override
  VfxVec3 calculateForce(VfxParticle particle, double dt) {
    return particle.velocity * (-dragCoefficient);
  }
}

/// Point attractor or repeller pulling or pushing particles toward a central target.
class AttractorForce extends VfxForce {
  final VfxVec3 target;
  final double strength;
  final double minDistance;
  final double maxDistance;

  const AttractorForce({
    required this.target,
    this.strength = 10.0,
    this.minDistance = 0.1,
    this.maxDistance = 100.0,
  });

  @override
  VfxVec3 calculateForce(VfxParticle particle, double dt) {
    final diff = target - particle.position;
    final distSq = diff.lengthSquared;
    if (distSq < minDistance * minDistance) return VfxVec3.zero;
    if (distSq > maxDistance * maxDistance) return VfxVec3.zero;

    final dist = math.sqrt(distSq);
    final dir = diff / dist;
    // F = strength / distSq (or linear falloff)
    final mag = strength / (dist * 0.5 + 1.0);
    return dir * mag;
  }
}

/// Vortex spinning force rotating particles around an axis while drawing them inward.
class VortexForce extends VfxForce {
  final VfxVec3 center;
  final VfxVec3 axis;
  final double radialSpeed;
  final double inwardSpeed;

  const VortexForce({
    required this.center,
    this.axis = const VfxVec3(0.0, 1.0, 0.0),
    this.radialSpeed = 5.0,
    this.inwardSpeed = 1.0,
  });

  @override
  VfxVec3 calculateForce(VfxParticle particle, double dt) {
    final r = particle.position - center;
    final normalizedAxis = axis.normalized;
    // Project r onto axis plane
    final parallel = normalizedAxis * r.dot(normalizedAxis);
    final radial = r - parallel;
    final dist = radial.length;
    if (dist < 1e-4) return VfxVec3.zero;

    final radialDir = radial / dist;
    // Tangent perpendicular to both axis and radialDir
    final tangent = normalizedAxis.cross(radialDir);

    final spinForce = tangent * radialSpeed;
    final pullForce = radialDir * (-inwardSpeed);
    return spinForce + pullForce;
  }
}

/// Pseudo-random continuous spatial turbulence force.
class TurbulenceForce extends VfxForce {
  final double strength;
  final double frequency;

  const TurbulenceForce({
    this.strength = 2.0,
    this.frequency = 1.0,
  });

  @override
  VfxVec3 calculateForce(VfxParticle particle, double dt) {
    final p = particle.position * frequency;
    // Fast analytical divergence-free curl approximation
    final fx = math.sin(p.y * 2.1 + particle.age) + math.cos(p.z * 1.7);
    final fy = math.sin(p.z * 2.3 + particle.age) + math.cos(p.x * 1.9);
    final fz = math.sin(p.x * 2.5 + particle.age) + math.cos(p.y * 1.3);
    return VfxVec3(fx, fy, fz) * strength;
  }
}
