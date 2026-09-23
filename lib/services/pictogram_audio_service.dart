import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/pictogram.dart';
import 'pictogram_audio_sequence_player_stub.dart'
    if (dart.library.html) 'pictogram_audio_sequence_player_web.dart';

typedef PictogramPlaybackCallback = void Function(
  int index,
  Pictogram pictogram,
);

class PictogramAudioResult {
  const PictogramAudioResult({
    required this.total,
    required this.played,
    this.missingLabels = const [],
  });

  final int total;
  final int played;
  final List<String> missingLabels;

  bool get playedAny => played > 0;
  bool get playedAll => total > 0 && played == total && missingLabels.isEmpty;
}

class PictogramAudioService {
  PictogramAudioService._();

  static final AudioPlayer _player = AudioPlayer();
  static final FlutterTts _tts = FlutterTts();
  static int _playbackRunId = 0;
  static bool _ttsConfigured = false;

  static Future<bool> play(Pictogram pictogram) async {
    final runId = ++_playbackRunId;
    final audioPath = _normalizedAudioPath(pictogram);

    try {
      stopPictogramAudioSequence();
      await _stopSpeech();

      if (audioPath != null &&
          audioPath.isNotEmpty &&
          await _assetExists(audioPath)) {
        return await _playAsset(audioPath);
      }

      return await _speakText(_spokenText(pictogram), runId);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> playText(String text) async {
    final runId = ++_playbackRunId;

    try {
      stopPictogramAudioSequence();
      await _stopSpeech();
      return await _speakText(text, runId);
    } catch (_) {
      return false;
    }
  }

  static Future<PictogramAudioResult> playSequence(
    List<Pictogram> pictograms, {
    PictogramPlaybackCallback? onPictogramStarted,
    PictogramPlaybackCallback? onPictogramFinished,
  }) async {
    if (pictograms.isEmpty) {
      return const PictogramAudioResult(total: 0, played: 0);
    }

    final runId = ++_playbackRunId;
    stopPictogramAudioSequence();
    await _stopSpeech();

    var played = 0;
    final missingLabels = <String>[];

    for (var index = 0; index < pictograms.length; index++) {
      final pictogram = pictograms[index];
      if (runId != _playbackRunId) break;

      onPictogramStarted?.call(index, pictogram);
      final audioPath = _normalizedAudioPath(pictogram);
      var didPlay = false;
      if (audioPath != null &&
          audioPath.isNotEmpty &&
          await _assetExists(audioPath)) {
        didPlay = await _playAssetInSequence(audioPath);
      }

      if (!didPlay) {
        didPlay = await _speakText(_spokenText(pictogram), runId);
      }

      if (didPlay) {
        played += 1;
      } else {
        missingLabels.add(pictogram.label);
      }

      onPictogramFinished?.call(index, pictogram);
    }

    return PictogramAudioResult(
      total: pictograms.length,
      played: played,
      missingLabels: missingLabels,
    );
  }

  static Future<bool> _playAsset(String audioPath) async {
    try {
      if (kIsWeb) {
        await primePictogramAudioPlayback();
        await playPictogramAudioSequence([audioPath]);
        return true;
      }

      await _player.stop();
      await _player.play(AssetSource(audioPath));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _playAssetInSequence(String audioPath) async {
    try {
      await primePictogramAudioPlayback();
      await playPictogramAudioSequence([audioPath]);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _speakText(String text, int runId) async {
    final spokenText = text.trim();
    if (spokenText.isEmpty || runId != _playbackRunId) return false;

    try {
      await _configureTts();
      if (runId != _playbackRunId) return false;
      final result = await _tts.speak(spokenText);
      return result == null || result == 1 || result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _configureTts() async {
    if (_ttsConfigured) return;

    try {
      await _tts.setLanguage('es-MX');
    } catch (_) {
      try {
        await _tts.setLanguage('es-ES');
      } catch (_) {}
    }

    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _ttsConfigured = true;
  }

  static Future<void> _stopSpeech() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  static String _spokenText(Pictogram pictogram) {
    final spokenText = pictogram.spokenText.trim();
    return spokenText.isEmpty ? pictogram.label : spokenText;
  }

  static String? _normalizedAudioPath(Pictogram pictogram) {
    final audioPath = pictogram.audioPath?.trim().replaceAll('\\', '/');
    if (audioPath == null || audioPath.isEmpty) return null;
    return audioPath.startsWith('assets/')
        ? audioPath.substring('assets/'.length)
        : audioPath;
  }

  static Future<bool> _assetExists(String audioPath) async {
    try {
      await rootBundle.load('assets/$audioPath');
      return true;
    } catch (_) {
      return false;
    }
  }
}
