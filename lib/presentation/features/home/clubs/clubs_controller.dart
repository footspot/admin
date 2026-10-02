import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fs_sa/data/models/objectbox/club_sub_entity.dart';
import 'package:fs_sa/data/models/objectbox/log.dart';
import 'package:fs_sa/data/models/objectbox/user_entity.dart';

import 'package:fs_sa/data/services/club_service.dart';
import 'package:fs_sa/data/services/local/log_local.dart';
import 'package:fs_sa/data/services/user_service.dart';
import 'package:fs_sa/presentation/widgets/notification_banner.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

final clubsCtrler = ClubsController();

class ClubsController {
  static final ClubsController _singleton =
      ClubsController._privateConstructor();
  factory ClubsController() => _singleton;
  ClubsController._privateConstructor() {
    paginationController = PagingController(
      getNextPageKey:
          (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: fetchClubs,
    );
  }

  int totalItem = -1;

  late final PagingController<int, ClubSubscriptionEntity> paginationController;
  final ScrollController scrollController = ScrollController();

  late BuildContext context;
  late Function setState;

  init(initSetState, initContext) {
    setState = initSetState;
    context = initContext;
  }

  // Your API service method
  Future<List<ClubSubscriptionEntity>> fetchClubs(int pageKey) async {
    try {
      if (!paginationController.value.hasNextPage) return [];

      if (totalItem == paginationController.items?.length) return [];

      final page = paginationController.value.keys?.last ?? 1;

      final res = await clubService.getClub(page);

      if (res != null) {
        totalItem = res?.count ?? 0;

        return ClubSubscriptionEntity.fromJsonList(res.data);
      }

      return [];
    } catch (e) {
      logLocal.addLog(
        LogEntity(message: e.toString(), source: 'ClubsController.fetchClubs'),
      );
      log('FETCHCLUB: ${e.toString()}');
      return [];
    }
  }

  Future<bool> addDirector(
    int clubId,
    String email,
    int role,
    String licenseNbr,
  ) async {
    try {
      return await userService.addMember({
        'clubId': clubId,
        'email': email,
        'role': role,
        'license_number': licenseNbr,
      });
    } catch (e) {
      logLocal.addLog(LogEntity(message: e.toString()));
      log('ADD DIRECTOR: ${e.toString()}');
      return false;
    }
  }

  Future<List<ClubSubscriptionEntity>> onSearch(String query) async {
    try {
      final res = await clubService.searchClub(query);

      return ClubSubscriptionEntity.fromJsonList(res);
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<bool> editClub(int id, String price, String limit) async {
    try {
      final res = await clubService.rightSub(id, {
        'price_member': price,
        'members_limit': limit,
      });

      if (res)
        for (var item in paginationController.items!) {
          if (item.id == id) {
            item.membersLimit = int.parse(limit);
            item.priceMember = double.parse(price);
          }
        }

      return res;
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'clubController.editClub(price: $price, maxMembers: $limit)',
        ),
      );
      return false;
    }
  }

  Future<List<UserEntity>> getDirectors(int clubId) async {
    try {
      final user = await clubService.getDirectorsByClub(clubId);

      final userFomatted =
          user
              .map(
                (u) => {
                  ...Map<String, dynamic>.from(u),
                  'club_id': u['user_club']['club_id'],
                  'role': 1,
                },
              )
              .toList();

      final list = UserEntity.fromJsonList(userFomatted);

      return list;
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'clubController.getDirectors(clubId: $clubId)',
        ),
      );

      context.showErrorNotification(
        'Fail to load directors, show logs',
        title: 'Get Directors',
      );

      return [];
    }
  }

  String getClubLogoUrl(String logoPath) {
    return clubService.getClubLogoUrl(logoPath);
  }

  void dispose() {
    paginationController.dispose();
  }
}
