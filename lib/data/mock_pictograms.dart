import '../models/pictogram.dart';
import 'mock_categories.dart';

const _coreNames = <String>[
  'comunicacion aumentativa',
  'yo quiero',
  'necesito ayuda',
  'ayuda',
  'hola',
  'adiós',
  'sí',
  'no',
  'no quiero',
  'no te entiendo',
  'por favor',
  'gracias',
  'ahora',
  'hoy',
  'mañana',
  'después',
  'más',
  'qué',
  'quién',
  'cuándo',
  'por qué',
  'otro',
  'me gusta eso',
  'bien',
  'bueno',
  'malo',
  'yo no sé',
];

const _peopleNames = <String>[
  'yo',
  'tú',
  'él',
  'ella',
  'mamá',
  'papá',
  'abuela',
  'amiga',
  'amigo',
  'hermana',
  'hermano',
  'familia',
  'profesor',
  'profesora',
  'médico',
];

const _foodNames = <String>[
  'agua',
  'beber',
  'comer',
  'comida',
  'hambre',
  'sed',
  'tomar',
  'preparado para comer',
];

const _emotionNames = <String>[
  'aburrido',
  'amor',
  'abrazo',
  'asustado',
  'cansado',
  'feliz',
  'nervioso',
  'sorprendido',
  'tranquilo',
  'triste',
  'dolor',
  'enfermo',
  'calor',
  'caliente',
  'frío',
  'no gustar',
];

const _placeNames = <String>[
  'aquí',
  'allí',
  'casa',
  'colegio',
  'escuela',
  'hospital',
  'parque',
  'tienda',
  'baño',
  'dentro',
  'fuera',
  'en',
];

const _activityNames = <String>[
  'abrir',
  'aprender',
  'caminar',
  'cerrar',
  'dar',
  'dormir',
  'dibujar',
  'escuchar',
  'grande',
  'guardar',
  'hablar',
  'hacer',
  'hacer pipí',
  'ir',
  'jugar',
  'mirar',
  'pequeño',
  'poder',
  'poner',
  'pintar',
  'pintar con los dedos',
  'querer',
  'quitar',
  'no gritar',
  'no patear',
  'sentar',
  'tener',
  'terminar',
  'venir',
  'trabajo en grupo',
];

const _initialBoardNames = <String>[
  'hola',
  'no patear',
  'abrazo',
  'dibujar',
  'pintar',
  'no gritar',
  'hacer pipí',
  'comer',
];

Pictogram _imported({
  required String name,
  required String categoryId,
  required int position,
}) {
  return Pictogram(
    id: name.replaceAll(' ', '_'),
    label: _labelFromName(name),
    spokenText: name,
    categoryId: categoryId,
    imagePath: 'assets/pictograms/imported/${_assetNameFromName(name)}.png',
    imageType: PictogramImageType.assetRaster,
    audioPath: 'audio/pictograms/${_assetNameFromName(name)}.mp3',
    onBoard: _initialBoardNames.contains(name),
    position: position,
  );
}

String _assetNameFromName(String name) {
  return name
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(' ', '_');
}

String _labelFromName(String name) {
  if (name.isEmpty) return name;
  return name[0].toUpperCase() + name.substring(1);
}

List<Pictogram> _buildImported({
  required String categoryId,
  required int positionBase,
  required List<String> names,
}) {
  final pictograms = <Pictogram>[];
  for (var index = 0; index < names.length; index++) {
    pictograms.add(
      _imported(
        name: names[index],
        categoryId: categoryId,
        position: positionBase + index,
      ),
    );
  }
  return pictograms;
}

final mockPictograms = <Pictogram>[
  ..._buildImported(
    categoryId: categoryCore,
    positionBase: 1,
    names: _coreNames,
  ),
  ..._buildImported(
    categoryId: categoryPeople,
    positionBase: 101,
    names: _peopleNames,
  ),
  ..._buildImported(
    categoryId: categoryFood,
    positionBase: 201,
    names: _foodNames,
  ),
  ..._buildImported(
    categoryId: categoryEmotions,
    positionBase: 301,
    names: _emotionNames,
  ),
  ..._buildImported(
    categoryId: categoryPlaces,
    positionBase: 401,
    names: _placeNames,
  ),
  ..._buildImported(
    categoryId: categoryActivities,
    positionBase: 501,
    names: _activityNames,
  ),
];
