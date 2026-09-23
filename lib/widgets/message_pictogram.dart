import 'package:flutter/material.dart';

import '../models/pictogram.dart';
import 'pictogram_image.dart';

class MessagePictogram extends StatefulWidget {
  const MessagePictogram({
    super.key,
    required this.pictogram,
    required this.onSpeak,
    this.scale = 1.0,
    this.isPlaying = false,
  });

  final Pictogram pictogram;
  final VoidCallback onSpeak;
  final double scale;
  final bool isPlaying;

  @override
  State<MessagePictogram> createState() => _MessagePictogramState();
}

class _MessagePictogramState extends State<MessagePictogram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant MessagePictogram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      _syncPulse();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _syncPulse() {
    if (widget.isPlaying) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController
        ..stop()
        ..value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final paddingScale = widget.scale.clamp(1.0, 1.25).toDouble();

    return Semantics(
      label: 'Reproducir mensaje desde ${widget.pictogram.label}',
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onSpeak,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulse = widget.isPlaying ? _pulseController.value : 0.0;
            final glowColor = Color.lerp(
              colors.primary,
              colors.tertiary,
              pulse,
            )!;
            final activeBackground = Color.lerp(
              colors.surface,
              colors.primaryContainer,
              0.32 + (pulse * 0.12),
            )!;

            return AnimatedScale(
              scale: widget.isPlaying ? 1.04 : 1,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 92.0 * widget.scale,
                padding: EdgeInsets.all(5.0 * paddingScale),
                decoration: BoxDecoration(
                  color: widget.isPlaying ? activeBackground : colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isPlaying ? glowColor : colors.outline,
                    width: widget.isPlaying ? 2.4 : 1.5,
                  ),
                  boxShadow: widget.isPlaying
                      ? [
                          BoxShadow(
                            color: glowColor.withValues(alpha: 0.38),
                            blurRadius: 12 + (pulse * 8),
                            spreadRadius: 1.5,
                          ),
                        ]
                      : null,
                ),
                child: child,
              ),
            );
          },
          child: Column(
            children: [
              Expanded(child: PictogramImage(pictogram: widget.pictogram)),
              const SizedBox(height: 4),
              Text(
                widget.pictogram.label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
