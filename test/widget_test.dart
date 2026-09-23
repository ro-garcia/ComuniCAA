import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:comunicaa/app.dart';
import 'package:comunicaa/data/mock_categories.dart';
import 'package:comunicaa/data/mock_pictograms.dart';
import 'package:comunicaa/data/mock_users.dart';
import 'package:comunicaa/providers/category_provider.dart';
import 'package:comunicaa/providers/communication_provider.dart';
import 'package:comunicaa/providers/pictogram_provider.dart';
import 'package:comunicaa/providers/settings_provider.dart';

void main() {
  testWidgets('ComuniCAA muestra la pantalla de comunicacion', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => SettingsProvider(initialProfile: mockUsers.first),
          ),
          ChangeNotifierProvider(
            create: (_) => PictogramProvider(initialPictograms: mockPictograms),
          ),
          ChangeNotifierProvider(
            create: (_) => CategoryProvider(initialCategories: mockCategories),
          ),
          ChangeNotifierProvider(create: (_) => CommunicationProvider()),
        ],
        child: const ComuniCaaApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ComuniCAA'), findsNothing);
    expect(find.text('Construye tu mensaje'), findsNothing);
    expect(find.text('Tablero en blanco'), findsOneWidget);
    expect(find.text('Esenciales'), findsOneWidget);
    expect(find.text('Sin palabras seleccionadas'), findsNothing);
    expect(find.text('Yo'), findsNothing);
  });
}
