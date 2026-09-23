import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/mock_categories.dart';
import 'data/mock_pictograms.dart';
import 'data/mock_users.dart';
import 'providers/category_provider.dart';
import 'providers/communication_provider.dart';
import 'providers/pictogram_provider.dart';
import 'providers/settings_provider.dart';

void main() {
  runApp(
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
}
