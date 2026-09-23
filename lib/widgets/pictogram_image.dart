import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/pictogram.dart';

class PictogramImage extends StatelessWidget {
  const PictogramImage({
    super.key,
    required this.pictogram,
    this.fit = BoxFit.contain,
  });

  final Pictogram pictogram;
  final BoxFit fit;

  static const placeholderAsset =
      'assets/placeholders/pictogram_placeholder.svg';

  @override
  Widget build(BuildContext context) {
    switch (pictogram.imageType) {
      case PictogramImageType.assetSvg:
        return SvgPicture.asset(
          pictogram.imagePath,
          fit: fit,
          placeholderBuilder: (_) => const _PlaceholderImage(),
        );
      case PictogramImageType.assetRaster:
        return Image.asset(
          pictogram.imagePath,
          fit: fit,
          errorBuilder: (_, __, ___) => const _PlaceholderImage(),
        );
      case PictogramImageType.localFile:
        if (pictogram.imagePath.isEmpty) return const _PlaceholderImage();
        if (kIsWeb) {
          return Image.network(
            pictogram.imagePath,
            fit: fit,
            errorBuilder: (_, __, ___) => const _PlaceholderImage(),
          );
        }
        return Image.file(
          File(pictogram.imagePath),
          fit: fit,
          errorBuilder: (_, __, ___) => const _PlaceholderImage(),
        );
    }
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pictograma no disponible',
      child: SvgPicture.asset(
        PictogramImage.placeholderAsset,
        fit: BoxFit.contain,
      ),
    );
  }
}
