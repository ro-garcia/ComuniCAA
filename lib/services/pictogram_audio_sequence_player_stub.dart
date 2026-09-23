import 'package:audioplayers/audioplayers.dart';

Future<void> primePictogramAudioPlayback() async {}

void stopPictogramAudioSequence() {}

Future<void> playPictogramAudioSequence(List<String> audioPaths) async {
  for (final audioPath in audioPaths) {
    final player = AudioPlayer();
    try {
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource(audioPath));
      await _waitForClip(player);
    } finally {
      await player.dispose();
    }
  }
}

Future<void> _waitForClip(AudioPlayer player) async {
  final duration = await _durationForClip(player);
  final fallbackDelay = duration == null
      ? const Duration(seconds: 2)
      : duration + const Duration(milliseconds: 300);

  await Future.any([
    player.onPlayerComplete.first,
    Future<void>.delayed(_capDelay(fallbackDelay)),
  ]);
}

Future<Duration?> _durationForClip(AudioPlayer player) async {
  final currentDuration = await player.getDuration();
  if (currentDuration != null && currentDuration > Duration.zero) {
    return currentDuration;
  }

  try {
    return await player.onDurationChanged.first.timeout(
      const Duration(seconds: 1),
    );
  } catch (_) {
    return null;
  }
}

Duration _capDelay(Duration duration) {
  const minDelay = Duration(milliseconds: 450);
  const maxDelay = Duration(seconds: 10);
  if (duration < minDelay) return minDelay;
  if (duration > maxDelay) return maxDelay;
  return duration;
}
