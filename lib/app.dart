import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_settings.dart';
import 'providers/settings_provider.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/communication/communication_screen.dart';
import 'screens/editor/pictogram_editor_screen.dart';
import 'screens/keyboard/keyboard_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_bottom_navigation.dart';

class ComuniCaaApp extends StatelessWidget {
  const ComuniCaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'ComuniCAA',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(highContrast: settings.highContrast),
          darkTheme: AppTheme.dark(highContrast: settings.highContrast),
          themeMode: settings.themeMode,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(settings.textScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const MainShell(),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final screens = <Widget>[
      const CommunicationScreen(),
      const CategoriesScreen(),
      const SearchScreen(),
      const KeyboardScreen(),
      if (settings.isCaregiverMode) const SettingsScreen(),
    ];

    if (_selectedIndex >= screens.length) {
      _selectedIndex = screens.length - 1;
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        editorMode: settings.isCaregiverMode,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        onCustomizePressed: () => _enterEditorMode(context),
        onSettingsPressed: () => _openSettingsInCaregiverMode(context),
      ),
      floatingActionButton: settings.isCaregiverMode
          ? Padding(
              padding: EdgeInsets.only(
                bottom: _createButtonBottomOffset(settings),
              ),
              child: FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: Text(_selectedIndex == 1 ? 'Crear carpeta' : 'Crear'),
                onPressed: () => _openEditor(context),
              ),
            )
          : null,
    );
  }

  double _createButtonBottomOffset(SettingsProvider settings) {
    if (settings.folderStripPlacement != FolderStripPlacement.bottom) {
      return 0;
    }

    final dense = settings.boardDensity == BoardDensity.dense;
    final stripHeight = (dense ? 74.0 : 104.0) * settings.folderStripScale;
    final stripPadding = dense ? 8.0 : 16.0;
    return stripHeight + stripPadding + 8.0;
  }

  Future<void> _openEditor(BuildContext context) async {
    final creatingFolder = _selectedIndex == 1;
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PictogramEditorScreen(folderMode: creatingFolder),
      ),
    );

    if (!context.mounted || created != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          creatingFolder
              ? 'Carpeta creada correctamente'
              : 'Pictograma creado correctamente',
        ),
      ),
    );
  }

  void _enterEditorMode(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    if (settings.isCaregiverMode) {
      settings.exitCaregiverMode();
    } else {
      settings.enableCaregiverMode();
    }
    setState(() => _selectedIndex = 0);
  }

  void _openSettingsInCaregiverMode(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    settings.enableCaregiverMode();
    setState(() => _selectedIndex = 4);
  }
}
