import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_settings.dart';
import 'providers/settings_provider.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/communication/communication_screen.dart';
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
  bool _creatingPictogram = false;
  bool _creatingFolder = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final screens = <Widget>[
      CommunicationScreen(
        isCreatingPictogram: _creatingPictogram,
        onCreateSaved: () => _finishCreation(
          context,
          'Pictograma creado correctamente',
        ),
        onCreateCancel: _cancelCreation,
      ),
      CategoriesScreen(
        isCreatingFolder: _creatingFolder,
        onCreateSaved: () => _finishCreation(
          context,
          'Carpeta creada correctamente',
        ),
        onCreateCancel: _cancelCreation,
      ),
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
          setState(() {
            _selectedIndex = index;
            _clearCreation();
          });
        },
        onCustomizePressed: () => _enterEditorMode(context),
        onSettingsPressed: () => _openSettingsInCaregiverMode(context),
      ),
      floatingActionButton: settings.isCaregiverMode && !_isCreating
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

  bool get _isCreating => _creatingPictogram || _creatingFolder;

  void _openEditor(BuildContext context) {
    final creatingFolder = _selectedIndex == 1;
    setState(() {
      _clearCreation();
      if (creatingFolder) {
        _creatingFolder = true;
      } else {
        _selectedIndex = 0;
        _creatingPictogram = true;
      }
    });
  }

  void _finishCreation(BuildContext context, String message) {
    setState(_clearCreation);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _cancelCreation() {
    setState(_clearCreation);
  }

  void _clearCreation() {
    _creatingPictogram = false;
    _creatingFolder = false;
  }

  void _enterEditorMode(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    if (settings.isCaregiverMode) {
      settings.exitCaregiverMode();
    } else {
      settings.enableCaregiverMode();
    }
    setState(() {
      _selectedIndex = 0;
      _clearCreation();
    });
  }

  void _openSettingsInCaregiverMode(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    settings.enableCaregiverMode();
    setState(() {
      _selectedIndex = 4;
      _clearCreation();
    });
  }
}
