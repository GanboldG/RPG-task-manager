import 'dart:math';
import 'package:flutter/material.dart';

/// Call this to launch flying reward particles from [origin] toward [target].
/// [type] is 'gold' or 'xp'. [count] is number of particles.
void launchRewardParticles({
  required BuildContext context,
  required Offset origin,
  required Offset target,
  required String type, // 'gold' or 'xp'
  int count = 6,
  VoidCallback? onComplete,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _RewardParticlesLayer(
      origin: origin,
      target: target,
      type: type,
      count: count,
      onComplete: () {
        entry.remove();
        onComplete?.call();
      },
    ),
  );

  overlay.insert(entry);
}

class _RewardParticlesLayer extends StatefulWidget {
  final Offset origin;
  final Offset target;
  final String type;
  final int count;
  final VoidCallback onComplete;

  const _RewardParticlesLayer({
    required this.origin,
    required this.target,
    required this.type,
    required this.count,
    required this.onComplete,
  });

  @override
  State<_RewardParticlesLayer> createState() => _RewardParticlesLayerState();
}

class _RewardParticlesLayerState extends State<_RewardParticlesLayer>
    with TickerProviderStateMixin {
  final List<_Particle> _particles = [];
  int _completed = 0;

  @override
  void initState() {
    super.initState();
    final rng = Random();

    for (int i = 0; i < widget.count; i++) {
      final delay = Duration(milliseconds: i * 80 + rng.nextInt(60));
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 700 + rng.nextInt(300)),
      );

      final spreadX = (rng.nextDouble() - 0.5) * 60;
      final spreadY = (rng.nextDouble() - 0.5) * 60;
      final midpoint = Offset(
        (widget.origin.dx + widget.target.dx) / 2 + spreadX,
        min(widget.origin.dy, widget.target.dy) - 80 - rng.nextDouble() * 60,
      );

      final particle = _Particle(
        controller: ctrl,
        origin: widget.origin,
        midpoint: midpoint,
        target: widget.target,
        type: widget.type,
        size: 14.0 + rng.nextDouble() * 8,
        rotationSpeed: (rng.nextDouble() - 0.5) * 4,
      );

      _particles.add(particle);

      Future.delayed(delay, () {
        if (mounted) {
          ctrl.forward().then((_) {
            _completed++;
            if (_completed == widget.count) {
              widget.onComplete();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (final p in _particles) {
      p.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _particles.map((p) => _ParticleWidget(p: p)).toList(),
    );
  }
}

class _Particle {
  final AnimationController controller;
  final Offset origin;
  final Offset midpoint;
  final Offset target;
  final String type;
  final double size;
  final double rotationSpeed;

  _Particle({
    required this.controller,
    required this.origin,
    required this.midpoint,
    required this.target,
    required this.type,
    required this.size,
    required this.rotationSpeed,
  });
}

class _ParticleWidget extends StatelessWidget {
  final _Particle p;

  const _ParticleWidget({required this.p});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: p.controller,
      builder: (_, __) {
        final t = p.controller.value;
        // Quadratic bezier: origin -> midpoint -> target
        final pos = _bezier(p.origin, p.midpoint, p.target, t);
        final opacity = t < 0.8 ? 1.0 : (1.0 - t) / 0.2;
        final scale = t < 0.1
            ? t / 0.1
            : t > 0.85
                ? 1.0 - (t - 0.85) / 0.15 * 0.5
                : 1.0;

        return Positioned(
          left: pos.dx - p.size / 2,
          top: pos.dy - p.size / 2,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: t * p.rotationSpeed * pi,
                child: _buildIcon(p.type, p.size),
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _bezier(Offset a, Offset b, Offset c, double t) {
    final ab = Offset.lerp(a, b, t)!;
    final bc = Offset.lerp(b, c, t)!;
    return Offset.lerp(ab, bc, t)!;
  }

  Widget _buildIcon(String type, double size) {
    if (type == 'gold') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(colors: [
            Color(0xFFFFE566),
            Color(0xFFFFB300),
            Color(0xFF996600),
          ]),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB300).withOpacity(0.8),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.monetization_on,
          color: Colors.white.withOpacity(0.9),
          size: size * 0.75,
        ),
      );
    } else {
      // XP orb — glowing purple/blue
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(colors: [
            Color(0xFFB388FF),
            Color(0xFF7C4DFF),
            Color(0xFF311B92),
          ]),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C4DFF).withOpacity(0.8),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          Icons.auto_awesome,
          color: Colors.white.withOpacity(0.9),
          size: size * 0.65,
        ),
      );
    }
  }
}