import 'dart:developer';

import 'package:fs_sa/data/models/objectbox/log.dart';
import 'package:fs_sa/data/services/local/log_local.dart';
import 'package:fs_sa/data/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final clubService = ClubService();

class ClubService {
  ClubService._privateConstructor();
  factory ClubService() => _singleton;
  static final ClubService _singleton = ClubService._privateConstructor();

  final _supabase = api.supabase;

  final perPage = 20;

  getClub(int page) async {
    try {
      final start = (page - 1) * perPage;
      final end = start + (perPage - 1);

      //TODO GET FROM LOCAL HERE

      log('page: $page \ns: $start \ne: $end ');

      final res =
          await _supabase
              .from('right_subscription')
              .select('*, club:club_id!inner(*)')
              .order('id', ascending: false)
              .range(start, end)
              .count();

      return res;
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'clubService.getClub(page: $page)',
        ),
      );
      log('GETCLUB: ${e.toString()}');
      return [];
    }
  }

  addClub(Map<String, dynamic> body) async {
    try {
      final res = await api.supabase.functions.invoke(
        'get-more-money',
        method: HttpMethod.post,
        body: body,
      );

      return res.data;
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'clubService.addClub(body: ${body.toString()})',
        ),
      );
      log('ADDCLUB: ${e.toString()}');
      return null;
    }
  }

  // * New club flow: the FFF data is fetched client-side (Cronet, to pass the
  // * WAF) and passed in here; this edge function only persists it. The legacy
  // * addClub()/get-more-money path is kept intact above.
  addNewClub(Map<String, dynamic> body) async {
    try {
      final res = await api.supabase.functions.invoke(
        'add-new-club',
        method: HttpMethod.post,
        body: body,
      );

      return res.data;
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          // * Body carries the full FFF payload + base64 logo — log keys only.
          source: 'clubService.addNewClub(keys: ${body.keys.toList()})',
        ),
      );
      log('ADDNEWCLUB: ${e.toString()}');
      return null;
    }
  }

  searchClub(String query) async {
    try {
      return await api.supabase
          .from('right_subscription')
          .select('*, club:club_id!inner(*)')
          .ilike('club.name', '%$query%');
    } catch (e) {
      log(e.toString());

      return [];
    }
  }

  rightSub(int id, Map<String, String> body) async {
    try {
      await api.supabase.from('right_subscription').update(body).eq('id', id);

      logLocal.addLog(
        LogEntity(
          message: 'rs $id edited',
          level: 'info',
          source: 'clubService.rightSub(body: ${body.toString()})',
        ),
      );

      return true;
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'clubService.rightSub(body: ${body.toString()})',
        ),
      );
      return false;
    }
  }

  getDirectorsByClub(int clubId) async {
    try {
      final res = await api.supabase
          .from('user')
          .select(
            'name, lastname, phone, email_contact, user_role!inner(role_id), user_club!inner(club_id)',
          )
          .eq('user_role.role_id', 1)
          .eq('user_club.club_id', clubId);

      return res;
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'clubService.getDirectorsByClub(clubId: $clubId)',
        ),
      );
      return [];
    }
  }

  String getClubLogoUrl(String logoPath) {
    try {
      return _supabase.storage.from('club-docs').getPublicUrl(logoPath);
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'clubService.getClubLogoUrl(logoPath: $logoPath)',
        ),
      );
      log('GETCLUBLOGOURL: ${e.toString()}');
      return '';
    }
  }
}
