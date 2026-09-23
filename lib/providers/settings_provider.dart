import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/user_profile.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required UserProfile initialProfile})
      : _activeProfile = initialProfile,
        _manualGridColumns = null;

  static const double defaultMessageBarScale = 1.0;
  static const double maxMessageBarScale = 1.6;
  static const double defaultFolderStripScale = 1.0;
  static const double maxFolderStripScale = 1.65;

  ThemeMode _themeMode = ThemeMode.light;
  bool _caregiverMode = false;
  UserProfile _activeProfile;
  int? _manualGridColumns;
  double _textScale = 1.0;
  bool _showTextOnPictograms = true;
  bool _highContrast = false;
  bool _speakOnTap = true;
  bool _showMessageBar = true;
  bool _showMessagePictograms = true;
  bool _largeButtons = false;
  bool _reduceAnimations = false;
  bool _simplifiedMode = false;
  BoardDensity _boardDensity = BoardDensity.compact;
  FolderStripPlacement _folderStripPlacement = FolderStripPlacement.bottom;
  PictogramLabelPosition _pictogramLabelPosition = PictogramLabelPosition.top;
  bool _colorCodedCategories = true;
  bool _darkToolbar = true;
  double _cellCornerRadius = 8;
  double _pictogramScale = 1.0;
  double _messageBarScale = defaultMessageBarScale;
  double _folderStripScale = defaultFolderStripScale;

  ThemeMode get themeMode => _themeMode;
  bool get isCaregiverMode => _caregiverMode;
  UserProfile get activeProfile => _activeProfile;
  int? get manualGridColumns => _manualGridColumns;
  double get textScale => _textScale;
  bool get showTextOnPictograms => _showTextOnPictograms;
  bool get highContrast => _highContrast;
  bool get speakOnTap => _speakOnTap;
  bool get showMessageBar => _showMessageBar;
  bool get showMessagePictograms => _showMessagePictograms;
  bool get largeButtons => _largeButtons;
  bool get reduceAnimations => _reduceAnimations;
  bool get simplifiedMode => _simplifiedMode;
  BoardDensity get boardDensity => _boardDensity;
  FolderStripPlacement get folderStripPlacement => _folderStripPlacement;
  PictogramLabelPosition get pictogramLabelPosition => _pictogramLabelPosition;
  bool get colorCodedCategories => _colorCodedCategories;
  bool get darkToolbar => _darkToolbar;
  double get cellCornerRadius => _cellCornerRadius;
  double get pictogramScale => _pictogramScale;
  double get messageBarScale => _messageBarScale;
  double get folderStripScale => _folderStripScale;

  bool enterCaregiverMode(String pin) {
    if (pin.trim() != '1234') return false;
    _caregiverMode = true;
    notifyListeners();
    return true;
  }

  void enableCaregiverMode() {
    if (_caregiverMode) return;
    _caregiverMode = true;
    notifyListeners();
  }

  void exitCaregiverMode() {
    _caregiverMode = false;
    notifyListeners();
  }

  void applyProfile(UserProfile profile) {
    _activeProfile = profile;
    _manualGridColumns = profile.gridColumns;
    notifyListeners();
  }

  void setThemeMode(ThemeMode value) {
    _themeMode = value;
    notifyListeners();
  }

  void setManualGridColumns(int? value) {
    if (value != null) {
      _manualGridColumns = value.clamp(2, 12).toInt();
    } else {
      _manualGridColumns = null;
    }
    notifyListeners();
  }

  int gridColumnsForWidth(double width) {
    if (_manualGridColumns != null) return _manualGridColumns!;
    switch (_boardDensity) {
      case BoardDensity.comfortable:
        if (width >= 1200) return 7;
        if (width >= 900) return 6;
        if (width >= 600) return 4;
        return 3;
      case BoardDensity.compact:
        if (width >= 1200) return 9;
        if (width >= 900) return 7;
        if (width >= 600) return 5;
        return 4;
      case BoardDensity.dense:
        if (width >= 1200) return 12;
        if (width >= 900) return 10;
        if (width >= 600) return 7;
        return 5;
    }
  }

  double gridSpacing() {
    if (_largeButtons) return 8;
    switch (_boardDensity) {
      case BoardDensity.comfortable:
        return 10;
      case BoardDensity.compact:
        return 6;
      case BoardDensity.dense:
        return 4;
    }
  }

  double pictogramCardAspectRatio() {
    switch (_boardDensity) {
      case BoardDensity.comfortable:
        return _showTextOnPictograms ? 0.84 : 1;
      case BoardDensity.compact:
        return _showTextOnPictograms ? 0.92 : 1;
      case BoardDensity.dense:
        return _showTextOnPictograms ? 1.02 : 1.06;
    }
  }

  void setTextScale(double value) {
    _textScale = value.clamp(0.9, 1.4).toDouble();
    notifyListeners();
  }

  void setShowTextOnPictograms(bool value) {
    _showTextOnPictograms = value;
    notifyListeners();
  }

  void setHighContrast(bool value) {
    _highContrast = value;
    notifyListeners();
  }

  void setSpeakOnTap(bool value) {
    _speakOnTap = value;
    notifyListeners();
  }

  void setShowMessageBar(bool value) {
    _showMessageBar = value;
    notifyListeners();
  }

  void setShowMessagePictograms(bool value) {
    _showMessagePictograms = value;
    notifyListeners();
  }

  void setLargeButtons(bool value) {
    _largeButtons = value;
    notifyListeners();
  }

  void setReduceAnimations(bool value) {
    _reduceAnimations = value;
    notifyListeners();
  }

  void setSimplifiedMode(bool value) {
    _simplifiedMode = value;
    notifyListeners();
  }

  void setBoardDensity(BoardDensity value) {
    _boardDensity = value;
    notifyListeners();
  }

  void setFolderStripPlacement(FolderStripPlacement value) {
    _folderStripPlacement = value;
    notifyListeners();
  }

  void setPictogramLabelPosition(PictogramLabelPosition value) {
    _pictogramLabelPosition = value;
    notifyListeners();
  }

  void setColorCodedCategories(bool value) {
    _colorCodedCategories = value;
    notifyListeners();
  }

  void setDarkToolbar(bool value) {
    _darkToolbar = value;
    notifyListeners();
  }

  void setCellCornerRadius(double value) {
    _cellCornerRadius = value.clamp(4, 18).toDouble();
    notifyListeners();
  }

  void setPictogramScale(double value) {
    _pictogramScale = value.clamp(0.82, 1.16).toDouble();
    notifyListeners();
  }

  void setMessageBarScale(double value) {
    final next =
        value.clamp(defaultMessageBarScale, maxMessageBarScale).toDouble();
    if (next == _messageBarScale) return;
    _messageBarScale = next;
    notifyListeners();
  }

  void setFolderStripScale(double value) {
    final next =
        value.clamp(defaultFolderStripScale, maxFolderStripScale).toDouble();
    if (next == _folderStripScale) return;
    _folderStripScale = next;
    notifyListeners();
  }
}
