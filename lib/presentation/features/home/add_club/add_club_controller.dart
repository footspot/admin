import 'package:flutter/widgets.dart';
import 'package:fs_sa/data/models/objectbox/log.dart';
import 'package:fs_sa/data/services/club_service.dart';
import 'package:fs_sa/data/services/fff_service.dart';
import 'package:fs_sa/data/services/local/log_local.dart';
import 'package:fs_sa/presentation/utils/local_authentication.dart';

final addClubCtrler = AddClubController();

class AddClubController with LocalAuth {
  static final AddClubController _singleton =
      AddClubController._privateConstructor();
  factory AddClubController() => _singleton;
  AddClubController._privateConstructor();

  late BuildContext context;
  late Function setState;

  init(initSetState, initContext) {
    setState = initSetState;
    context = initContext;
  }

  // * New flow — fetch the FFF club client-side (Cronet bypasses the WAF) then
  // * hand it to the 'add-new-club' edge function to persist. Returns null on
  // * auth failure or if the FFF fetch fails, so the view shows "add failed".
  addNewClub(String demoEmail, int clubNbr, int maxMembers, double price) async {
    try {
      if (await authenticate() == false) return null;

      final fff = await fffService.fetchClub(clubNbr);

      if (fff == null) {
        logLocal.addLog(
          LogEntity(
            source: 'addClubController.addNewClub(clubNbr: $clubNbr)',
            message: 'FFF fetch returned null (WAF block or unknown club)',
          ),
        );
        return null;
      }

      return await clubService.addNewClub({
        'clubNbr': clubNbr,
        'maxMembers': maxMembers,
        'price': price,
        'email': demoEmail,
        'fffClub': fff['fffClub'],
        'logoBase64': fff['logoBase64'],
        'logoContentType': fff['logoContentType'],
      });
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          source: 'addClubController.addNewClub($demoEmail, $clubNbr, '
              '$maxMembers, $price)',
          message: e.toString(),
        ),
      );

      return null;
    }
  }

  addClub(String demoEmail, int clubNbr, int maxMembers, double price) async {
    try {
      return await authenticate() == false
          ? null
          : await clubService.addClub({
            'clubNbr': clubNbr,
            'maxMembers': maxMembers,
            'price': price,
            'email': demoEmail,
          });
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          source:
              'addClubController.addClub($demoEmail, $clubNbr, $maxMembers, $price)',
          message: e.toString(),
        ),
      );

      return null;
    }
  }
}
