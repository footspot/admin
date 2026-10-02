import 'package:flutter/material.dart';
import 'package:fs_sa/presentation/features/home/logs/log_view.dart';
import 'package:fs_sa/presentation/features/home/settings/settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    settingsCtrler.init(setState, context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // * Logs (moved here from the bottom navbar)
        ListTile(
          leading: const Icon(Icons.archive_outlined),
          title: const Text('Logs'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LogView()),
            );
          },
        ),
        const Divider(),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              await settingsCtrler.logOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Log out'),
          ),
        ),
      ],
    );
  }
}
