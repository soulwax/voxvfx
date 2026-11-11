import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:voxvfx/voxvfx.dart';

void main() {
  group('VfxVec3', () {
    test('vector arithmetic and operations', () {
      final a = const VfxVec3(1.0, 2.0, 3.0);
      final b = const VfxVec3(4.0, 5.0, 6.0);

      expect((a + b).x, closeTo(5.0, 1e-4));
      expect((b - a).y, closeTo(3.0, 1e-4));
      expect((-a).z, closeTo(-3.0, 1e-4));
      expect((a * 2.0).x, closeTo(2.0, 1e-4));
      expect((b / 2.0).y, closeTo(2.5, 1e-4));

      expect(a.dot(b), closeTo(1 * 4 + 2 * 5 + 3 * 6, 1e-4));

      final cross = const VfxVec3(1.0, 0.0, 0.0).cross(const VfxVec3(0.0, 1.0, 0.0));
      expect(cross.z, closeTo(1.0, 1e-4));

      final normalized = const VfxVec3(0.0, 5.0, 0.0).normalized;
      expect(normalized.y, closeTo(1.0, 1e-4));
      expect(normalized.length, closeTo(1.0, 1e-4));
    });
  });

  group('VfxColor & Gradients', () {
    test('color lerp and presets', () {
      final c1 = const VfxColor(1.0, 0.0, 0.0, 1.0);
      final c2 = const VfxColor(0.0, 1.0, 0.0, 0.0);
      final mid = VfxColor.lerp(c1, c2, 0.5);

      expect(mid.r, closeTo(0.5, 1e-4));
      expect(mid.g, closeTo(0.5, 1e-4));
      expect(mid.b, closeTo(0.0, 1e-4));
      expect(mid.a, closeTo(0.5, 1e-4));
    });

    test('gradient evaluation across multiple stops', () {
      final grad = VfxColorGradient.fire();
      final start = grad.evaluate(0.0);
      final mid = grad.evaluate(0.5);
      final end = grad.evaluate(1.0);

      expect(start.r, closeTo(1.0, 1e-3));
      expect(mid.g, closeTo(0.4, 1e-3));
      expect(end.a, closeTo(0.0, 1e-3));
    });
  });

  group('VfxCurve', () {
    test('interpolates between keyframes', () {
      final curve = VfxCurve.bell(min: 0.1, peak: 1.0);
      expect(curve.evaluate(0.0), closeTo(0.1, 1e-4));
      expect(curve.evaluate(0.5), closeTo(1.0, 1e-4));
      expect(curve.evaluate(1.0), closeTo(0.1, 1e-4));
    });
  });

  group('VfxForces', () {
    test('GravityForce applies constant acceleration', () {
      const gravity = GravityForce(VfxVec3(0.0, -9.81, 0.0));
      final particle = VfxParticle()
        ..spawn(
          spawnPosition: VfxVec3.zero,
          initialVelocity: VfxVec3.zero,
          totalLifetime: 1.0,
          size: 1.0,
          color: VfxColor.white,
        );

      final f = gravity.calculateForce(particle, 0.1);
      expect(f.y, closeTo(-9.81, 1e-4));
    });

    test('LinearDragForce opposes velocity', () {
      const drag = LinearDragForce(0.5);
      final particle = VfxParticle()
        ..spawn(
          spawnPosition: VfxVec3.zero,
          initialVelocity: const VfxVec3(10.0, 0.0, 0.0),
          totalLifetime: 1.0,
          size: 1.0,
          color: VfxColor.white,
        );

      final f = drag.calculateForce(particle, 0.1);
      expect(f.x, closeTo(-5.0, 1e-4));
    });

    test('AttractorForce pulls toward target', () {
      const attractor = AttractorForce(target: VfxVec3(0.0, 10.0, 0.0), strength: 20.0);
      final particle = VfxParticle()
        ..spawn(
          spawnPosition: VfxVec3.zero,
          initialVelocity: VfxVec3.zero,
          totalLifetime: 1.0,
          size: 1.0,
          color: VfxColor.white,
        );

      final f = attractor.calculateForce(particle, 0.1);
      expect(f.y, greaterThan(0.0));
      expect(f.x, closeTo(0.0, 1e-4));
    });

    test('VortexForce applies tangential spin and inward pull', () {
      const vortex = VortexForce(center: VfxVec3.zero, radialSpeed: 4.0, inwardSpeed: 2.0);
      final particle = VfxParticle()
        ..spawn(
          spawnPosition: const VfxVec3(5.0, 0.0, 0.0),
          initialVelocity: VfxVec3.zero,
          totalLifetime: 1.0,
          size: 1.0,
          color: VfxColor.white,
        );

      final f = vortex.calculateForce(particle, 0.1);
      // Inward pull should have negative x
      expect(f.x, lessThan(0.0));
      // Tangent around Y axis should affect Z
      expect(f.z.abs(), greaterThan(0.0));
    });
  });

  group('VfxEmitterShapes', () {
    final rng = math.Random(42);

    test('SphereEmitterShape respects radius constraint', () {
      const shape = SphereEmitterShape(radius: 5.0);
      for (int i = 0; i < 20; i++) {
        final sample = shape.sample(rng);
        expect(sample.positionOffset.length, lessThanOrEqualTo(5.001));
      }
    });

    test('BoxEmitterShape respects half extents', () {
      const shape = BoxEmitterShape(halfExtents: VfxVec3(2.0, 3.0, 4.0));
      for (int i = 0; i < 20; i++) {
        final sample = shape.sample(rng);
        expect(sample.positionOffset.x.abs(), lessThanOrEqualTo(2.001));
        expect(sample.positionOffset.y.abs(), lessThanOrEqualTo(3.001));
        expect(sample.positionOffset.z.abs(), lessThanOrEqualTo(4.001));
      }
    });
  });

  group('VfxSimulation', () {
    test('burst instantly spawns particles up to pool limit', () {
      final sim = VfxSimulation(maxParticles: 50, config: const VfxEmitterConfig(emissionRate: 0.0));
      expect(sim.activeParticleCount, 0);

      sim.burst(25);
      expect(sim.activeParticleCount, 25);

      sim.burst(50); // should clamp at maxParticles (50)
      expect(sim.activeParticleCount, 50);
    });

    test('continuous emission spawns particles and updates kinematics', () {
      final sim = VfxSimulation(
        maxParticles: 100,
        config: const VfxEmitterConfig(
          emissionRate: 50.0,
          lifetimeMin: 1.0,
          lifetimeMax: 1.0,
          speedMin: 10.0,
          speedMax: 10.0,
          shape: PointEmitterShape(direction: VfxVec3(0.0, 1.0, 0.0)),
        ),
      );

      sim.forces.add(const GravityForce(VfxVec3(0.0, -10.0, 0.0)));

      // Step forward by 0.5s -> spawns ~25 particles
      sim.update(0.5);
      expect(sim.activeParticleCount, closeTo(25, 2));

      for (final p in sim.activeParticles) {
        expect(p.isAlive, isTrue);
        expect(p.age, greaterThan(0.0));
      }

      // Step forward until particles expire
      sim.isEmitting = false;
      sim.update(1.2);
      expect(sim.activeParticleCount, 0);
    });

    test('updates size and color along curves', () {
      final sim = VfxSimulation(
        maxParticles: 10,
        config: VfxEmitterConfig(
          emissionRate: 0.0,
          sizeMin: 1.0,
          sizeMax: 1.0,
          sizeCurve: VfxCurve.linear(1.0, 0.0),
          colorGradient: VfxColorGradient.fade(const VfxColor(1.0, 0.0, 0.0, 1.0)),
          lifetimeMin: 1.0,
          lifetimeMax: 1.0,
        ),
      );

      sim.burst(1);
      final p = sim.activeParticles.first;
      expect(p.currentSize, closeTo(1.0, 1e-3));
      expect(p.currentColor.a, closeTo(1.0, 1e-3));

      sim.update(0.5);
      expect(p.currentSize, closeTo(0.5, 1e-3));
      expect(p.currentColor.a, closeTo(0.5, 1e-3));

      sim.update(0.6);
      expect(p.isAlive, isFalse);
      expect(sim.activeParticleCount, 0);
    });

    test('clear kills all active particles', () {
      final sim = VfxSimulation(maxParticles: 30);
      sim.burst(20);
      expect(sim.activeParticleCount, 20);

      sim.clear();
      expect(sim.activeParticleCount, 0);
    });
  });
}
