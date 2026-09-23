import 'dart:js_interop';

@JS('comunicaaPrimeAudio')
external JSPromise<JSAny?> _primePictogramAudioPlayback();

@JS('comunicaaStopAudioSequence')
external void _stopPictogramAudioSequence();

@JS('comunicaaPlayAudioSequence')
external JSPromise<JSAny?> _playPictogramAudioSequence(
  JSArray<JSString> audioPaths,
);

Future<void> primePictogramAudioPlayback() async {
  await _primePictogramAudioPlayback().toDart;
}

void stopPictogramAudioSequence() {
  _stopPictogramAudioSequence();
}

Future<void> playPictogramAudioSequence(List<String> audioPaths) async {
  await _playPictogramAudioSequence(
    audioPaths.map((audioPath) => audioPath.toJS).toList().toJS,
  ).toDart;
}
