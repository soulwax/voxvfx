import 'dart:math' as math;
import '../emitters/vfx_emitter_config.dart';
import '../forces/vfx_force.dart';
import '../math/vfx_color.dart';
import '../math/vfx_vec3.dart';
import 'vfx_particle.dart';

/// Core particle simulation managing a fixed-size pool of particles, forces, and emitters.
class VfxSimulation {
  final int maxParticles;
  late final List<VfxParticle> _pool;
  final math.Random _random;

  VfxEmitterConfig config;
  final List<VfxForce> forces = [];

  VfxVec3 emitterPosition = VfxVec3.zero;
  VfxVec3 emitterVelocity = VfxVec3.zero;

  bool isEmitting = true;
  bool isLooping = true;
  double elapsedTime = 0.0;

  double _emissionAccumulator = 0.0;
  final Set<int> _triggeredBursts = {};

  VfxSimulation({
    this.maxParticles = 1000,
    VfxEmitterConfig? config,
    math.Random? random,
  })  : config = config ?? const VfxEmitterConfig(),
        _random = random ?? math.Random() {
    _pool = List.generate(maxParticles, (_) => VfxParticle(), growable: false);
  }

  /// Number of currently active particles in the simulation.
  int get activeParticleCount {
    int count = 0;
    for (int i = 0; i < maxParticles; i++) {
      if (_pool[i].isAlive) count++;
    }
    return count;
  }

  /// Active particles currently rendering or simulating.
  Iterable<VfxParticle> get activeParticles sync* {
    for (int i = 0; i < maxParticles; i++) {
      if (_pool[i].isAlive) {
        yield _pool[i];
      }
    }
  }

  /// Instantly spawns a burst of [count] particles.
  void burst(int count) {
    for (int i = 0; i < count; i++) {
      _spawnSingleParticle();
    }
  }

  /// Steps the particle simulation forward by [dt] seconds.
  void update(double dt) {
    if (dt <= 0.0) return;

    elapsedTime += dt;

    // Check scheduled bursts
    for (int i = 0; i < config.bursts.length; i++) {
      final b = config.bursts[i];
      if (elapsedTime >= b.time && !_triggeredBursts.contains(i)) {
        _triggeredBursts.add(i);
        burst(b.count);
      }
    }

    // Continuous emission
    if (isEmitting && config.emissionRate > 0.0) {
      _emissionAccumulator += config.emissionRate * dt;
      final int toSpawn = _emissionAccumulator.floor();
      if (toSpawn > 0) {
        _emissionAccumulator -= toSpawn;
        for (int i = 0; i < toSpawn; i++) {
          _spawnSingleParticle();
        }
      }
    }

    // Step active particles
    final sizeCurve = config.sizeCurve;
    final colorGrad = config.colorGradient;

    for (int i = 0; i < maxParticles; i++) {
      final p = _pool[i];
      if (!p.isAlive) continue;

      p.age += dt;
      if (p.age >= p.lifetime) {
        p.kill();
        continue;
      }

      // Sum applied forces
      VfxVec3 netForce = VfxVec3.zero;
      for (int f = 0; f < forces.length; f++) {
        netForce = netForce + forces[f].calculateForce(p, dt);
      }

      // Integrate motion
      p.velocity = p.velocity + netForce * dt;
      p.position = p.position + p.velocity * dt;
      p.rotation += p.angularVelocity * dt;

      // Update appearance over lifetime progress
      final progress = p.progress;

      if (sizeCurve != null) {
        p.currentSize = p.startSize * sizeCurve.evaluate(progress);
      }

      if (colorGrad != null) {
        p.currentColor = colorGrad.evaluate(progress);
      }
    }
  }

  /// Attempts to acquire an inactive particle from the pool and spawn it.
  VfxParticle? _spawnSingleParticle() {
    for (int i = 0; i < maxParticles; i++) {
      final p = _pool[i];
      if (!p.isAlive) {
        _initParticle(p);
        return p;
      }
    }
    return null; // Pool full
  }

  void _initParticle(VfxParticle p) {
    final sample = config.shape.sample(_random);
    final spawnPos = emitterPosition + sample.positionOffset;

    final speed = _lerpDouble(config.speedMin, config.speedMax, _random.nextDouble());
    final vel = sample.direction * speed + emitterVelocity * config.inheritEmitterVelocity;

    final lifetime = _lerpDouble(config.lifetimeMin, config.lifetimeMax, _random.nextDouble());
    final size = _lerpDouble(config.sizeMin, config.sizeMax, _random.nextDouble());
    final spin = _lerpDouble(config.spinMin, config.spinMax, _random.nextDouble());
    final rot = _random.nextDouble() * 2.0 * math.pi;

    final startColor = config.colorGradient?.evaluate(0.0) ?? VfxColor.white;

    p.spawn(
      spawnPosition: spawnPos,
      initialVelocity: vel,
      totalLifetime: lifetime,
      size: size,
      color: startColor,
      initialRotation: rot,
      spin: spin,
    );
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  /// Kills all active particles and resets the simulation clock.
  void clear() {
    for (int i = 0; i < maxParticles; i++) {
      _pool[i].kill();
    }
    elapsedTime = 0.0;
    _emissionAccumulator = 0.0;
    _triggeredBursts.clear();
  }
}
