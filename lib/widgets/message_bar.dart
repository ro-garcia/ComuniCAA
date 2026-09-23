import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../models/pictogram.dart';
import '../providers/communication_provider.dart';
import '../providers/settings_provider.dart';
import '../services/pictogram_audio_service.dart';
import 'bar_resize_handle.dart';
import 'message_pictogram.dart';

class MessageBar extends StatelessWidget {
  const MessageBar({super.key, this.forceVisible = false});

  final bool forceVisible;

  @override
  Widget build(BuildContext context) {
    final communication = context.watch<CommunicationProvider>();
    final settings = context.watch<SettingsProvider>();
    final colors = Theme.of(context).colorScheme;
    final sentence = communication.getSentence();
    final canSpeak = communication.hasMessage && sentence.trim().isNotEmpty;
    final messageParts = communication.messageParts
        .where(
          (part) =>
              part.pictogram == null || settings.showMessagePictograms,
        )
        .toList();
    final dense = settings.boardDensity == BoardDensity.dense;
    final barScale = settings.messageBarScale;
    final baseHeight = dense ? 94.0 : 116.0;
    final messageHeight = baseHeight * barScale;
    final actionButtonWidth = 92.0 * barScale;
    final isExpanded = barScale > SettingsProvider.defaultMessageBarScale;
    final isAtMaximum = barScale >= SettingsProvider.maxMessageBarScale - 0.01;

    if (!forceVisible && !settings.showMessageBar) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.outline, width: 1.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Semantics(
                label: canSpeak ? 'Reproducir frase' : 'Barra de mensaje',
                button: canSpeak,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: canSpeak
                      ? () => speakMessage(context, sentence)
                      : null,
                  child: SizedBox(
                    height: messageHeight,
                    child: messageParts.isNotEmpty
                        ? ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: messageParts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final part = messageParts[index];
                              if (part.pictogram == null) {
                                return _ManualMessageItem(
                                  text: part.text ?? '',
                                  onSpeak: () =>
                                      speakMessage(context, sentence),
                                );
                              }

                              return MessagePictogram(
                                pictogram: part.pictogram!,
                                scale: barScale,
                                onSpeak: () =>
                                    speakMessage(context, sentence),
                              );
                            },
                          )
                        : const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: messageHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MessageActionButton(
                    tooltip: 'Hablar mensaje',
                    semanticLabel: 'Hablar mensaje',
                    icon: Icons.volume_up_outlined,
                    width: actionButtonWidth,
                    height: messageHeight,
                    scale: barScale,
                    filled: true,
                    onPressed: canSpeak
                        ? () => speakMessage(context, sentence)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _MessageActionButton(
                    tooltip: 'Borrar ultima palabra',
                    semanticLabel: 'Borrar ultima palabra',
                    icon: Icons.backspace_outlined,
                    width: actionButtonWidth,
                    height: messageHeight,
                    scale: barScale,
                    onPressed: communication.hasMessage
                        ? () =>
                            context.read<CommunicationProvider>().removeLast()
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _MessageActionButton(
                    tooltip: 'Limpiar mensaje',
                    semanticLabel: 'Limpiar mensaje',
                    icon: Icons.delete_outline,
                    width: actionButtonWidth,
                    height: messageHeight,
                    scale: barScale,
                    onPressed: communication.hasMessage
                        ? () =>
                            context.read<CommunicationProvider>().clearMessage()
                        : null,
                  ),
                ],
              ),
            ),
            if (settings.isCaregiverMode) ...[
              const SizedBox(width: 8),
              BarResizeHandle(
                expandTooltip: 'Agrandar barra de comunicacion',
                resetTooltip: 'Restaurar barra de comunicacion',
                dragTooltip: 'Arrastrar para ajustar barra de comunicacion',
                expandIcon: Icons.keyboard_arrow_down,
                isExpanded: isExpanded,
                isAtMaximum: isAtMaximum,
                onExpand: () => context
                    .read<SettingsProvider>()
                    .setMessageBarScale(SettingsProvider.maxMessageBarScale),
                onReset: () =>
                    context.read<SettingsProvider>().setMessageBarScale(
                          SettingsProvider.defaultMessageBarScale,
                        ),
                onDragDelta: (delta) {
                  final provider = context.read<SettingsProvider>();
                  provider.setMessageBarScale(
                    provider.messageBarScale + delta / 180,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> speakMessage(
    BuildContext context,
    String sentence,
  ) async {
    if (sentence.trim().isEmpty) return;
    final view = View.of(context);
    final direction = Directionality.of(context);
    final parts = context.read<CommunicationProvider>().messageParts;
    final pictogramRun = <Pictogram>[];
    final failedText = <String>[];
    var playedAny = false;

    Future<void> playPictogramRun() async {
      if (pictogramRun.isEmpty) return;
      final result = await PictogramAudioService.playSequence(pictogramRun);
      playedAny = playedAny || result.playedAny;
      pictogramRun.clear();
    }

    for (final part in parts) {
      if (part.pictogram != null) {
        pictogramRun.add(part.pictogram!);
        continue;
      }

      await playPictogramRun();
      final text = part.text?.trim() ?? '';
      if (text.isEmpty) continue;
      final didPlay = await PictogramAudioService.playText(text);
      if (didPlay) {
        playedAny = true;
      } else {
        failedText.add(text);
      }
    }
    await playPictogramRun();

    if (failedText.isNotEmpty) {
      SemanticsService.sendAnnouncement(view, failedText.join(' '), direction);
    } else if (!playedAny) {
      SemanticsService.sendAnnouncement(view, sentence, direction);
    }
  }
}

class _ManualMessageItem extends StatelessWidget {
  const _ManualMessageItem({
    required this.text,
    required this.onSpeak,
  });

  final String text;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Reproducir texto escrito',
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onSpeak,
        child: Align(
          alignment: Alignment.centerLeft,
          child: IntrinsicWidth(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, maxWidth: 360),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.outline, width: 1.5),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageActionButton extends StatelessWidget {
  const _MessageActionButton({
    required this.tooltip,
    required this.semanticLabel,
    required this.icon,
    required this.width,
    required this.height,
    required this.scale,
    required this.onPressed,
    this.filled = false,
  });

  final String tooltip;
  final String semanticLabel;
  final IconData icon;
  final double width;
  final double height;
  final double scale;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final iconSize = 34.0 * scale.clamp(1.0, 1.35).toDouble();
    final backgroundColor =
        filled && enabled ? colors.primaryContainer : colors.surface;
    final iconColor = enabled
        ? filled
            ? colors.onPrimaryContainer
            : colors.onSurface
        : colors.onSurface.withValues(alpha: 0.38);

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: enabled
                  ? colors.outline
                  : colors.outline.withValues(alpha: 0.42),
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: width,
              height: height,
              child: Icon(icon, size: iconSize, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
