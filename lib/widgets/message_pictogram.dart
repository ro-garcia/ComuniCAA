import 'package:flutter/material.dart';

import '../models/pictogram.dart';
import 'pictogram_image.dart';

class MessagePictogram extends StatelessWidget {
  const MessagePictogram({
    super.key,
    required this.pictogram,
    required this.onSpeak,
    this.scale = 1.0,
  });

  final Pictogram pictogram;
  final VoidCallback onSpeak;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final paddingScale = scale.clamp(1.0, 1.25).toDouble();

    return Semantics(
      label: 'Reproducir mensaje desde ${pictogram.label}',
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onSpeak,
        child: Container(
          width: 92.0 * scale,
          padding: EdgeInsets.all(5.0 * paddingScale),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.outline, width: 1.5),
          ),
          child: Column(
            children: [
              Expanded(child: PictogramImage(pictogram: pictogram)),
              const SizedBox(height: 4),
              Text(
                pictogram.label.toUpperCase(),
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
