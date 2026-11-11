import 'dart:math' as math;
import '../math/vfx_vec3.dart';

/// Sampled spawn data from an emitter shape.
class VfxSpawnData {
  final VfxVec3 positionOffset;
  final VfxVec3 direction;

  const VfxSpawnData(this.positionOffset, this.direction);
}

/// Base class for spatial emitter shapes.
abstract class VfxEmitterShape {
  const VfxEmitterShape();

  /// Samples a spawn position offset and launch direction vector.
  VfxSpawnData sample(math.Random random);
}

/// Emits particles from a single point.
class PointEmitterShape extends VfxEmitterShape {
  final VfxVec3 direction;
  final double spreadAngle;

  const PointEmitterShape({
    this.direction = const VfxVec3(0.0, 1.0, 0.0),
    this.spreadAngle = 0.0,
  });

  @override
  VfxSpawnData sample(math.Random random) {
    if (spreadAngle <= 1e-4) {
      return VfxSpawnData(VfxVec3.zero, direction.normalized);
    }
    // Random perturbation within spreadAngle
    final u1 = random.nextDouble();
    final u2 = random.nextDouble();
    final z = math.cos(spreadAngle * u1);
    final phi = 2.0 * math.pi * u2;
    final sinTheta = math.sqrt(math.max(0.0, 1.0 - z * z));
    final localDir = VfxVec3(sinTheta * math.cos(phi), z, sinTheta * math.sin(phi));
    return VfxSpawnData(VfxVec3.zero, localDir.normalized);
  }
}

/// Emits particles inside or on the surface of a 3D sphere.
class SphereEmitterShape extends VfxEmitterShape {
  final double radius;
  final bool surfaceOnly;

  const SphereEmitterShape({
    this.radius = 1.0,
    this.surfaceOnly = false,
  });

  @override
  VfxSpawnData sample(math.Random random) {
    final u = random.nextDouble() * 2.0 - 1.0;
    final phi = random.nextDouble() * 2.0 * math.pi;
    final sinTheta = math.sqrt(math.max(0.0, 1.0 - u * u));
    final dir = VfxVec3(sinTheta * math.cos(phi), u, sinTheta * math.sin(phi)).normalized;

    final r = surfaceOnly ? radius : radius * math.pow(random.nextDouble(), 1.0 / 3.0);
    return VfxSpawnData(dir * r, dir);
  }
}

/// Emits particles from a cone base directed along the cone axis.
class ConeEmitterShape extends VfxEmitterShape {
  final double radius;
  final double angleRadians;
  final double length;

  const ConeEmitterShape({
    this.radius = 0.5,
    this.angleRadians = 0.4, // ~23 degrees
    this.length = 1.0,
  });

  @override
  VfxSpawnData sample(math.Random random) {
    final r = radius * math.sqrt(random.nextDouble());
    final phi = random.nextDouble() * 2.0 * math.pi;
    final pos = VfxVec3(r * math.cos(phi), 0.0, r * math.sin(phi));

    // Cone spread angle
    final spread = angleRadians * random.nextDouble();
    final spreadPhi = random.nextDouble() * 2.0 * math.pi;
    final dir = VfxVec3(
      math.sin(spread) * math.cos(spreadPhi),
      math.cos(spread),
      math.sin(spread) * math.sin(spreadPhi),
    ).normalized;

    return VfxSpawnData(pos, dir);
  }
}

/// Emits particles inside or on the surface of an axis-aligned box.
class BoxEmitterShape extends VfxEmitterShape {
  final VfxVec3 halfExtents;
  final bool surfaceOnly;

  const BoxEmitterShape({
    this.halfExtents = const VfxVec3(1.0, 1.0, 1.0),
    this.surfaceOnly = false,
  });

  @override
  VfxSpawnData sample(math.Random random) {
    double rx = (random.nextDouble() * 2.0 - 1.0) * halfExtents.x;
    double ry = (random.nextDouble() * 2.0 - 1.0) * halfExtents.y;
    double rz = (random.nextDouble() * 2.0 - 1.0) * halfExtents.z;

    if (surfaceOnly) {
      final face = random.nextInt(6);
      switch (face) {
        case 0: rx = halfExtents.x; break;
        case 1: rx = -halfExtents.x; break;
        case 2: ry = halfExtents.y; break;
        case 3: ry = -halfExtents.y; break;
        case 4: rz = halfExtents.z; break;
        case 5: rz = -halfExtents.z; break;
      }
    }

    final pos = VfxVec3(rx, ry, rz);
    final dir = pos.lengthSquared > 1e-6 ? pos.normalized : const VfxVec3(0.0, 1.0, 0.0);
    return VfxSpawnData(pos, dir);
  }
}

/// Emits particles on a 2D planar circle / ring.
class Circle2DEmitterShape extends VfxEmitterShape {
  final double radius;
  final bool edgeOnly;

  const Circle2DEmitterShape({
    this.radius = 1.0,
    this.edgeOnly = false,
  });

  @override
  VfxSpawnData sample(math.Random random) {
    final theta = random.nextDouble() * 2.0 * math.pi;
    final r = edgeOnly ? radius : radius * math.sqrt(random.nextDouble());
    final pos = VfxVec3(r * math.cos(theta), r * math.sin(theta), 0.0);
    final dir = pos.lengthSquared > 1e-6 ? pos.normalized : const VfxVec3(0.0, 1.0, 0.0);
    return VfxSpawnData(pos, dir);
  }
}
