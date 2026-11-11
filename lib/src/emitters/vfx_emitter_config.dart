import '../curves/vfx_color_gradient.dart';
import '../curves/vfx_curve.dart';
import '../math/vfx_color.dart';
import '../math/vfx_vec3.dart';
import 'vfx_emitter_shape.dart';

/// Instant burst of particles emitted at a specific elapsed time.
class VfxBurst {
  final double time;
  final int count;

  const VfxBurst({required this.time, required this.count});
}

/// Configuration settings controlling emission rates, lifetimes, sizes, colors, and shapes.
class VfxEmitterConfig {
  final double emissionRate;
  final List<VfxBurst> bursts;
  final VfxEmitterShape shape;
  final double lifetimeMin;
  final double lifetimeMax;
  final double speedMin;
  final double speedMax;
  final double sizeMin;
  final double sizeMax;
  final VfxCurve? sizeCurve;
  final VfxColorGradient? colorGradient;
  final double spinMin;
  final double spinMax;
  final double inheritEmitterVelocity;

  const VfxEmitterConfig({
    this.emissionRate = 50.0,
    this.bursts = const [],
    this.shape = const PointEmitterShape(),
    this.lifetimeMin = 1.0,
    this.lifetimeMax = 2.0,
    this.speedMin = 2.0,
    this.speedMax = 5.0,
    this.sizeMin = 0.2,
    this.sizeMax = 0.5,
    this.sizeCurve,
    this.colorGradient,
    this.spinMin = -2.0,
    this.spinMax = 2.0,
    this.inheritEmitterVelocity = 0.0,
  });

  /// Preset for a torch flame or bonfire.
  factory VfxEmitterConfig.fire() => VfxEmitterConfig(
        emissionRate: 80.0,
        shape: const ConeEmitterShape(radius: 0.2, angleRadians: 0.25),
        lifetimeMin: 0.6,
        lifetimeMax: 1.2,
        speedMin: 1.5,
        speedMax: 3.5,
        sizeMin: 0.2,
        sizeMax: 0.4,
        sizeCurve: VfxCurve.bell(min: 0.2, peak: 1.0),
        colorGradient: VfxColorGradient.fire(),
      );

  /// Preset for glowing spark showers or welding sparks.
  factory VfxEmitterConfig.sparks() => VfxEmitterConfig(
        emissionRate: 100.0,
        shape: const PointEmitterShape(direction: VfxVec3(0.0, 1.0, 0.0), spreadAngle: 0.8),
        lifetimeMin: 0.4,
        lifetimeMax: 0.8,
        speedMin: 5.0,
        speedMax: 12.0,
        sizeMin: 0.05,
        sizeMax: 0.1,
        colorGradient: VfxColorGradient.single(const VfxColor(1.0, 0.9, 0.4, 1.0)),
      );

  /// Preset for puff of smoke.
  factory VfxEmitterConfig.smoke() => VfxEmitterConfig(
        emissionRate: 25.0,
        shape: const SphereEmitterShape(radius: 0.2),
        lifetimeMin: 1.5,
        lifetimeMax: 3.0,
        speedMin: 0.5,
        speedMax: 1.5,
        sizeMin: 0.3,
        sizeMax: 0.6,
        sizeCurve: VfxCurve.linear(0.5, 2.5),
        colorGradient: VfxColorGradient.smoke(),
      );

  /// Preset for an explosive burst.
  factory VfxEmitterConfig.explosion({int particleCount = 150}) => VfxEmitterConfig(
        emissionRate: 0.0,
        bursts: [VfxBurst(time: 0.0, count: particleCount)],
        shape: const SphereEmitterShape(radius: 0.1),
        lifetimeMin: 0.5,
        lifetimeMax: 1.5,
        speedMin: 6.0,
        speedMax: 18.0,
        sizeMin: 0.1,
        sizeMax: 0.4,
        sizeCurve: VfxCurve.easeIn(start: 1.5, end: 0.0),
        colorGradient: VfxColorGradient.fire(),
      );
}
