import 'dart:developer';

import 'package:fs_sa/data/models/objectbox/log.dart';
import 'package:fs_sa/data/models/objectbox/user_entity.dart';
import 'package:fs_sa/data/services/local/log_local.dart';
import 'package:fs_sa/data/services/local/user_local.dart';
import 'package:fs_sa/data/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userService = UserService();

class UserService {
  UserService._privateConstructor();
  factory UserService() => _singleton;
  static final UserService _singleton = UserService._privateConstructor();

  final _supabase = api.supabase;

  /// BODY: { int clubId, String email, String licenseNbr, int role }
  Future<bool> addMember(Map<String, dynamic> body) async {
    try {
      final res = await _supabase.functions.invoke(
        'aam',
        method: HttpMethod.post,
        body: body,
      );

      userLocal.addUser(
        UserEntity.fromJson({...res.data['user'], 'role': body['role']}),
      );

      return true;
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'userService.addMember(body: ${body.toString()})',
        ),
      );

      log(e.toString());

      return false;
    }
  }
}
