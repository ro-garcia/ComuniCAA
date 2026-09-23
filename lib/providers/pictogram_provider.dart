import 'package:flutter/foundation.dart';

import '../data/mock_categories.dart';
import '../models/pictogram.dart';

class PictogramProvider extends ChangeNotifier {
  PictogramProvider({required List<Pictogram> initialPictograms})
      : _pictograms = List<Pictogram>.from(initialPictograms);

  final List<Pictogram> _pictograms;

  List<Pictogram> get pictograms => List.unmodifiable(_pictograms);

  void addPictogram(Pictogram pictogram) {
    _pictograms.add(pictogram);
    _sort();
    notifyListeners();
  }

  void updatePictogram(Pictogram updated) {
    final index = _pictograms.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;
    _pictograms[index] = updated;
    _sort();
    notifyListeners();
  }

  void deletePictogram(String id) {
    final targetIndex = _pictograms.indexWhere((item) => item.id == id);
    if (targetIndex == -1 || !_pictograms[targetIndex].isCustom) return;
    final target = _pictograms[targetIndex];

    if (target.isFolder) {
      // Reubica sus contenidos en el tablero al borrar la carpeta.
      for (var index = 0; index < _pictograms.length; index += 1) {
        final item = _pictograms[index];
        if (item.parentFolderId != id) continue;
        _pictograms[index] = item.copyWith(
          clearParentFolderId: true,
          onBoard: true,
        );
      }
    }

    _pictograms.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _pictograms.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _pictograms[index] = _pictograms[index].copyWith(
      favorite: !_pictograms[index].favorite,
    );
    _sort();
    notifyListeners();
  }

  void addToBoard(String id) {
    final index = _pictograms.indexWhere((item) => item.id == id);
    if (index == -1 || _pictograms[index].onBoard) return;
    _pictograms[index] = _pictograms[index].copyWith(onBoard: true);
    _sort();
    notifyListeners();
  }

  void removeFromBoard(String id) {
    final index = _pictograms.indexWhere((item) => item.id == id);
    if (index == -1 || !_pictograms[index].onBoard) return;
    _pictograms[index] = _pictograms[index].copyWith(onBoard: false);
    notifyListeners();
  }

  bool isOnBoard(String id) {
    final index = _pictograms.indexWhere((item) => item.id == id);
    return index != -1 && _pictograms[index].onBoard;
  }

  void convertToFolder(String id) {
    final index = _pictograms.indexWhere((item) => item.id == id);
    if (index == -1 || _pictograms[index].isFolder) return;

    final source = _pictograms[index];
    final folderId = 'folder_${DateTime.now().microsecondsSinceEpoch}';
    final folder = Pictogram(
      id: folderId,
      label: source.label,
      spokenText: source.spokenText,
      categoryId: source.categoryId,
      imagePath: source.imagePath,
      imageType: source.imageType,
      audioPath: source.audioPath,
      favorite: source.favorite,
      visible: source.visible,
      isCustom: true,
      isFolder: true,
      onBoard: source.onBoard,
      position: source.position,
      parentCategoryId: source.parentCategoryId,
      parentFolderId: source.parentFolderId,
    );

    // Conserva el pictograma original como primer contenido de la carpeta.
    _pictograms[index] = source.copyWith(
      isFolder: false,
      onBoard: false,
      parentFolderId: folderId,
    );
    _pictograms.add(folder);
    _sort();
    notifyListeners();
  }

  void addToFolder(String pictogramId, String folderId) {
    final createsCycle = _wouldCreateFolderCycle(
      pictogramId: pictogramId,
      targetFolderId: folderId,
    );
    if (pictogramId == folderId || createsCycle) {
      return;
    }

    final pictogramIndex =
        _pictograms.indexWhere((item) => item.id == pictogramId);
    final folderIndex = _pictograms.indexWhere(
      (item) => item.id == folderId && item.isFolder,
    );
    if (pictogramIndex == -1 || folderIndex == -1) return;

    _pictograms[pictogramIndex] = _pictograms[pictogramIndex].copyWith(
      parentFolderId: folderId,
      onBoard: false,
    );
    _sort();
    notifyListeners();
  }

  void removeFromFolder(String pictogramId) {
    final index = _pictograms.indexWhere((item) => item.id == pictogramId);
    if (index == -1 || _pictograms[index].parentFolderId == null) return;
    _pictograms[index] = _pictograms[index].copyWith(
      clearParentFolderId: true,
      onBoard: true,
    );
    notifyListeners();
  }

  List<Pictogram> getBoardPictograms() {
    return _visibleAndSorted(
      _pictograms.where(
        (item) => item.onBoard && item.parentFolderId == null,
      ),
    );
  }

  List<Pictogram> getFolderChildren(String folderId) {
    return _visibleAndSorted(
      _pictograms.where((item) => item.parentFolderId == folderId),
    );
  }

  List<Pictogram> getFolderPictograms({String? excludingId}) {
    return _visibleAndSorted(
      _pictograms.where(
        (item) =>
            item.isFolder &&
            item.visible &&
            item.id != excludingId &&
            !_wouldCreateFolderCycle(
              pictogramId: excludingId,
              targetFolderId: item.id,
            ),
      ),
    );
  }

  List<Pictogram> getRootFolderPictograms({bool onBoardOnly = true}) {
    return _visibleAndSorted(
      _pictograms.where(
        (item) =>
            item.isFolder &&
            item.parentFolderId == null &&
            (!onBoardOnly || item.onBoard),
      ),
    );
  }

  List<Pictogram> getByCategory(String categoryId) {
    final items = categoryId == categoryFavorites
        ? _pictograms.where(
            (item) => item.favorite && item.parentFolderId == null,
          )
        : _pictograms.where(
            (item) =>
                item.categoryId == categoryId && item.parentFolderId == null,
          );

    return _visibleAndSorted(items);
  }

  List<Pictogram> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return [];

    final results = _pictograms.where((item) {
      return item.visible &&
          item.parentFolderId == null &&
          (item.label.toLowerCase().contains(normalized) ||
              item.spokenText.toLowerCase().contains(normalized));
    });

    return _visibleAndSorted(results);
  }

  List<Pictogram> getCustomPictograms() {
    final custom = _pictograms.where((item) => item.isCustom).toList();
    custom.sort((a, b) => a.position.compareTo(b.position));
    return custom;
  }

  int nextPositionForCategory(String categoryId) {
    final categoryItems =
        _pictograms.where((item) => item.categoryId == categoryId);
    if (categoryItems.isEmpty) return 900;
    return categoryItems
            .map((item) => item.position)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  List<Pictogram> _visibleAndSorted(Iterable<Pictogram> items) {
    final result = items.where((item) => item.visible).toList();
    result.sort(_comparePictograms);
    return result;
  }

  void _sort() {
    _pictograms.sort(_comparePictograms);
  }

  static int _comparePictograms(Pictogram a, Pictogram b) {
    if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
    return a.position.compareTo(b.position);
  }

  bool _wouldCreateFolderCycle({
    required String? pictogramId,
    required String targetFolderId,
  }) {
    if (pictogramId == null) return false;
    if (pictogramId == targetFolderId) return true;

    var currentId = targetFolderId;
    final seen = <String>{};
    while (seen.add(currentId)) {
      if (currentId == pictogramId) return true;

      final current = _pictograms.where((item) => item.id == currentId);
      if (current.isEmpty) return false;

      final parentId = current.first.parentFolderId;
      if (parentId == null) return false;
      currentId = parentId;
    }

    return true;
  }
}
