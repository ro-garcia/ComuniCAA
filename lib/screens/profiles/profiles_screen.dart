import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_users.dart';
import '../../providers/settings_provider.dart';

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfiles')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockUsers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final profile = mockUsers[index];
          final selected = profile.id == settings.activeProfile.id;
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                child: Text(profile.name.characters.first),
              ),
              title: Text(
                profile.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('${profile.gridColumns} columnas'),
              trailing: selected
                  ? const Icon(Icons.check_circle)
                  : const Icon(Icons.chevron_right),
              onTap: () {
                context.read<SettingsProvider>().applyProfile(profile);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Perfil ${profile.name} activo')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
