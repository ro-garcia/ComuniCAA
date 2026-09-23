enum PictogramImageType {
  assetSvg,
  assetRaster,
  localFile,
}

class Pictogram {
  const Pictogram({
    required this.id,
    required this.label,
    required this.spokenText,
    required this.categoryId,
    required this.imagePath,
    required this.imageType,
    this.audioPath,
    this.favorite = false,
    this.visible = true,
    this.isCustom = false,
    this.isFolder = false,
    this.onBoard = false,
    this.position = 0,
    this.parentCategoryId,
    this.parentFolderId,
  });

  final String id;
  final String label;
  final String spokenText;
  final String categoryId;
  final String imagePath;
  final PictogramImageType imageType;
  final String? audioPath;
  final bool favorite;
  final bool visible;
  final bool isCustom;
  final bool isFolder;
  final bool onBoard;
  final int position;
  final String? parentCategoryId;
  final String? parentFolderId;

  Pictogram copyWith({
    String? id,
    String? label,
    String? spokenText,
    String? categoryId,
    String? imagePath,
    PictogramImageType? imageType,
    String? audioPath,
    bool clearAudioPath = false,
    bool? favorite,
    bool? visible,
    bool? isCustom,
    bool? isFolder,
    bool? onBoard,
    int? position,
    String? parentCategoryId,
    bool clearParentCategoryId = false,
    String? parentFolderId,
    bool clearParentFolderId = false,
  }) {
    return Pictogram(
      id: id ?? this.id,
      label: label ?? this.label,
      spokenText: spokenText ?? this.spokenText,
      categoryId: categoryId ?? this.categoryId,
      imagePath: imagePath ?? this.imagePath,
      imageType: imageType ?? this.imageType,
      audioPath: clearAudioPath ? null : audioPath ?? this.audioPath,
      favorite: favorite ?? this.favorite,
      visible: visible ?? this.visible,
      isCustom: isCustom ?? this.isCustom,
      isFolder: isFolder ?? this.isFolder,
      onBoard: onBoard ?? this.onBoard,
      position: position ?? this.position,
      parentCategoryId: clearParentCategoryId
          ? null
          : parentCategoryId ?? this.parentCategoryId,
      parentFolderId:
          clearParentFolderId ? null : parentFolderId ?? this.parentFolderId,
    );
  }
}
