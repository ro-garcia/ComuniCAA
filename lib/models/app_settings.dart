enum BoardDensity {
  comfortable,
  compact,
  dense,
}

enum FolderStripPlacement {
  top,
  bottom,
  hidden,
}

enum PictogramLabelPosition {
  top,
  bottom,
}

String boardDensityLabel(BoardDensity density) {
  switch (density) {
    case BoardDensity.comfortable:
      return 'Amplio';
    case BoardDensity.compact:
      return 'Compacto';
    case BoardDensity.dense:
      return 'Denso';
  }
}

String folderStripPlacementLabel(FolderStripPlacement placement) {
  switch (placement) {
    case FolderStripPlacement.top:
      return 'Arriba';
    case FolderStripPlacement.bottom:
      return 'Abajo';
    case FolderStripPlacement.hidden:
      return 'Ocultas';
  }
}

String pictogramLabelPositionLabel(PictogramLabelPosition position) {
  switch (position) {
    case PictogramLabelPosition.top:
      return 'Arriba';
    case PictogramLabelPosition.bottom:
      return 'Abajo';
  }
}
