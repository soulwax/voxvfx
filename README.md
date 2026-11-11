# voxvfx

High-performance, pure Dart visual effects particle simulation library. Designed for real-time 2D and 3D games with zero platform dependencies.

## Features

- **Pre-Allocated Particle Pool:** High-throughput zero-garbage simulation loop.
- **Physical Force Fields:**
  - `GravityForce`: Directional acceleration.
  - `LinearDragForce`: Air / fluid resistance opposing velocity.
  - `AttractorForce`: Gravitational / magnetic attraction and repulsion fields.
  - `VortexForce`: Spinning vortex fields around arbitrary 3D axes with inward pull.
  - `TurbulenceForce`: Fast divergence-free spatial curl turbulence noise.
- **Emitter Shapes:** Point, Sphere (volume / surface), Cone (axis / spread), Box (volume / surface), Circle2D.
- **Curves & Color Gradients:** Size curves (linear, bell, ease) and multi-stop color / alpha gradients (presets for fire, smoke, plasma, sparks).
- **Bursts & Continuous Streams:** Flexible emitter configurations and instant programmatic bursts.
