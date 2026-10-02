import 'package:flutter/material.dart';
import 'package:fs_sa/data/services/object_box_service.dart';
import 'package:fs_sa/data/services/supabase_client.dart';
import 'package:fs_sa/presentation/core/routes.dart';
import 'package:fs_sa/presentation/core/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ObjectBoxService.instance.initialize();

  await api.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PATRON',
      routerConfig: router,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.dark,
    );
  }
}
