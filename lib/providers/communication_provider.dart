import 'package:flutter/foundation.dart';

import '../models/pictogram.dart';

class CommunicationPart {
  const CommunicationPart.pictogram(this.pictogram) : text = null;

  const CommunicationPart.text(this.text) : pictogram = null;

  final Pictogram? pictogram;
  final String? text;
}

class CommunicationProvider extends ChangeNotifier {
  final List<CommunicationPart> _messageParts = [];

  List<CommunicationPart> get messageParts => List.unmodifiable(_messageParts);

  List<Pictogram> get selectedPictograms => List.unmodifiable(
        _messageParts
            .where((part) => part.pictogram != null)
            .map((part) => part.pictogram!),
      );

  String? get manualSentence {
    final text = _messageParts
        .where((part) => part.text != null && part.text!.trim().isNotEmpty)
        .map((part) => part.text!.trim())
        .join(' ');
    return text.isEmpty ? null : text;
  }

  bool get hasMessage => _messageParts.any(
        (part) =>
            part.pictogram != null ||
            (part.text != null && part.text!.trim().isNotEmpty),
      );

  void addPictogram(Pictogram pictogram) {
    _messageParts.add(CommunicationPart.pictogram(pictogram));
    notifyListeners();
  }

  void addVariant(Pictogram base, String variant) {
    addPictogram(
      base.copyWith(
        id: '${base.id}_variant_${DateTime.now().microsecondsSinceEpoch}',
        label: variant,
        spokenText: variant.toLowerCase(),
      ),
    );
  }

  void removeLast() {
    if (_messageParts.isEmpty) return;
    _messageParts.removeLast();
    notifyListeners();
  }

  void removePictogram(Pictogram pictogram) {
    final index = _messageParts.indexWhere(
      (part) => part.pictogram == pictogram,
    );
    if (index == -1) return;
    _messageParts.removeAt(index);
    notifyListeners();
  }

  void clearMessage() {
    _messageParts.clear();
    notifyListeners();
  }

  void setManualSentence(String sentence) {
    final text = sentence.trim();
    if (text.isEmpty) return;

    final lastPartIsText =
        _messageParts.isNotEmpty && _messageParts.last.text != null;
    if (lastPartIsText) {
      _messageParts[_messageParts.length - 1] = CommunicationPart.text(text);
    } else {
      _messageParts.add(CommunicationPart.text(text));
    }
    notifyListeners();
  }

  String getSentence() {
    final raw = _messageParts
        .map(
          (part) => part.pictogram?.spokenText ?? part.text?.trim() ?? '',
        )
        .where((part) => part.isNotEmpty)
        .join(' ');

    return _sentenceCase(raw.trim().replaceAll(RegExp(r'\s+'), ' '));
  }

  String _sentenceCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
