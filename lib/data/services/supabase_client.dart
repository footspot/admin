import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final api = API();

class API {
  API._privateConstructor();
  factory API() => _singleton;
  static final API _singleton = API._privateConstructor();

  late SupabaseClient supabase;

  init() async {
    await dotenv.load(fileName: '.env');

    supabase = await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_KEY']!,
    ).then((s) => s.client);
  }
}
