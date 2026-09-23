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
  bool _editingInline = false;
  int _viewResetToken = 0;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final screens = <Widget>[
      CommunicationScreen(
        isCreatingPictogram: _creatingPictogram,
        viewResetToken: _viewResetToken,
        onCreateSaved: () => _finishCreation(
          context,
          'Pictograma creado correctamente',
        ),
        onCreateCancel: _cancelCreation,
        onEditingChanged: _setInlineEditing,
      ),
      CategoriesScreen(
        isCreatingFolder: _creatingFolder,
        viewResetToken: _viewResetToken,
        onCreateSaved: () => _finishCreation(
          context,
          'Carpeta creada correctamente',
        ),
        onCreateCancel: _cancelCreation,
        onEditingChanged: _setInlineEditing,
      ),
      const SearchScreen(),
      const KeyboardScreen(),
      const SettingsScreen(),
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
            _resetOpenViews();
          });
        },
        onCustomizePressed: () => _enterEditorMode(context),
        onSettingsPressed: _openSettings,
      ),
      floatingActionButton: settings.isCaregiverMode && !_isCreatingOrEditing
          ? Padding(
              padding: EdgeInsets.only(
                bottom: _createButtonBottomOffset(settings),
              ),
              child: _CreateActions(
                onCreateFolder: _openFolderCreator,
                onCreatePictogram: _openPictogramCreator,
              ),
            )
          : null,
    );
  }

  double _createButtonBottomOffset(SettingsProvider settings) {
    if (_selectedIndex != 0 ||
        settings.folderStripPlacement != FolderStripPlacement.bottom) {
      return 0;
    }

    final dense = settings.boardDensity == BoardDensity.dense;
    final stripHeight = (dense ? 74.0 : 104.0) * settings.folderStripScale;
    final stripPadding = dense ? 8.0 : 16.0;
    return stripHeight + stripPadding + 8.0;
  }

  bool get _isCreating => _creatingPictogram || _creatingFolder;
  bool get _isCreatingOrEditing => _isCreating || _editingInline;

  void _openPictogramCreator() {
    setState(() {
      _resetOpenViews();
      _selectedIndex = 0;
      _creatingPictogram = true;
    });
  }

  void _openFolderCreator() {
    setState(() {
      _resetOpenViews();
      _selectedIndex = 1;
      _creatingFolder = true;
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

  void _resetOpenViews() {
    _clearCreation();
    _editingInline = false;
    _viewResetToken++;
  }

  void _setInlineEditing(bool editing) {
    if (_editingInline == editing) return;
    setState(() => _editingInline = editing);
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
      _resetOpenViews();
    });
  }

  void _openSettings() {
    setState(() {
      _selectedIndex = 4;
      _resetOpenViews();
    });
  }
}

class _CreateActions extends StatelessWidget {
  const _CreateActions({
    required this.onCreateFolder,
    required this.onCreatePictogram,
  });

  final VoidCallback onCreateFolder;
  final VoidCallback onCreatePictogram;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'create-folder',
          backgroundColor: colors.secondaryContainer,
          foregroundColor: colors.onSecondaryContainer,
          icon: const Icon(Icons.create_new_folder_outlined),
          label: const Text('Crear carpeta'),
          onPressed: onCreateFolder,
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: 'create-pictogram',
          icon: const Icon(Icons.add),
          label: const Text('Crear pictograma'),
          onPressed: onCreatePictogram,
        ),
      ],
    );
  }
}
