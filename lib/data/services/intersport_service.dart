import 'dart:developer';

import 'package:fs_sa/data/models/legacy/intersport_partner.dart';
import 'package:fs_sa/data/models/legacy/intersport_pending_request.dart';
import 'package:fs_sa/data/models/objectbox/log.dart';
import 'package:fs_sa/data/services/local/log_local.dart';
import 'package:fs_sa/data/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final intersportService = IntersportService();

/// All PDG-side calls to the Intersport edge functions.
/// Mirrors the pattern from `club_service.dart`: singleton, edge functions
/// via `api.supabase.functions.invoke(...)`, errors logged to `logLocal`.
class IntersportService {
  IntersportService._privateConstructor();
  factory IntersportService() => _singleton;
  static final IntersportService _singleton =
      IntersportService._privateConstructor();

  /// One-time-shown secrets returned by createPartner. Never persisted.
  Future<List<IntersportPartner>> listPartners() async {
    try {
      final res = await api.supabase.functions.invoke(
        'intersport-pdg-list-partners',
        method: HttpMethod.post,
        body: {},
      );

      final data = res.data as Map<String, dynamic>?;
      final list = (data?['partners'] as List?) ?? const [];
      return list
          .map((j) => IntersportPartner.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'intersportService.listPartners()',
        ),
      );
      log('LIST_PARTNERS: ${e.toString()}');
      return [];
    }
  }

  /// Returns null on failure. On success returns the row + the raw secrets
  /// (caller is responsible for showing them once and dropping the values).
  Future<({IntersportPartner partner, String hmacSecret, String shopToken})?>
  createPartner({
    required String name,
    required String region,
    required String baseUrl,
    required String shopUrlPrefix,
  }) async {
    try {
      final res = await api.supabase.functions.invoke(
        'intersport-pdg-create-partner',
        method: HttpMethod.post,
        body: {
          'name': name,
          'region': region,
          'base_url': baseUrl,
          'shop_url_prefix': shopUrlPrefix,
        },
      );

      final data = res.data as Map<String, dynamic>?;
      if (data == null || data['partner'] == null) return null;

      // * If the edge function returned an error body the data shape is
      // * { error, code } rather than { partner, hmac_secret, shop_token }.
      if (data['error'] != null) {
        throw Exception(data['error']);
      }

      return (
        partner: IntersportPartner.fromJson(
          data['partner'] as Map<String, dynamic>,
        ),
        hmacSecret: data['hmac_secret'] as String,
        shopToken: data['shop_token'] as String,
      );
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source:
              'intersportService.createPartner(name: $name, region: $region)',
        ),
      );
      log('CREATE_PARTNER: ${e.toString()}');
      return null;
    }
  }

  Future<List<IntersportPendingRequest>> listPendingRequests() async {
    try {
      final res = await api.supabase.functions.invoke(
        'intersport-pdg-list-pending-requests',
        method: HttpMethod.post,
        body: {},
      );

      final data = res.data as Map<String, dynamic>?;
      final list = (data?['requests'] as List?) ?? const [];
      return list
          .map(
            (j) =>
                IntersportPendingRequest.fromJson(j as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'intersportService.listPendingRequests()',
        ),
      );
      log('LIST_PENDING: ${e.toString()}');
      return [];
    }
  }

  /// Processed (accepted + rejected) requests for the History tab — read-only
  /// audit of past decisions. Same shape as listPendingRequests, plus the
  /// status / processed_at / rejected_reason fields.
  Future<List<IntersportPendingRequest>> listProcessedRequests() async {
    try {
      final res = await api.supabase.functions.invoke(
        'intersport-pdg-list-history',
        method: HttpMethod.post,
        body: {},
      );

      final data = res.data as Map<String, dynamic>?;
      final list = (data?['requests'] as List?) ?? const [];
      return list
          .map(
            (j) =>
                IntersportPendingRequest.fromJson(j as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'intersportService.listProcessedRequests()',
        ),
      );
      log('LIST_HISTORY: ${e.toString()}');
      return [];
    }
  }

  /// Accept or reject a request. Returns true on success.
  Future<bool> decideRequest({
    required int requestId,
    required String decision,
    String? rejectedReason,
  }) async {
    try {
      final body = <String, dynamic>{
        'request_id': requestId,
        'decision': decision,
      };
      if (rejectedReason != null && rejectedReason.isNotEmpty) {
        body['rejected_reason'] = rejectedReason;
      }

      final res = await api.supabase.functions.invoke(
        'intersport-pdg-decide',
        method: HttpMethod.post,
        body: body,
      );

      final data = res.data as Map<String, dynamic>?;
      if (data == null) return false;
      if (data['error'] != null) {
        throw Exception(data['error']);
      }
      return data['ok'] == true;
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source:
              'intersportService.decideRequest(id: $requestId, decision: $decision)',
        ),
      );
      log('DECIDE: ${e.toString()}');
      return false;
    }
  }

  /// Flow 2 — link a freshly-created Footspot club to an Intersport club.
  /// The PDG got `intersportClubId` + the partner from the Intersport admin's
  /// email. Returns `ok` plus the edge function's error key on failure so the
  /// UI can surface the specific reason (CLUB_ALREADY_LINKED, …).
  Future<({bool ok, String? error})> createClubFromEmail({
    required int clubId,
    required String intersportClubId,
    required String intersportPartnerId,
  }) async {
    try {
      final res = await api.supabase.functions.invoke(
        'intersport-pdg-create-club-from-email',
        method: HttpMethod.post,
        body: {
          'club_id': clubId,
          'intersport_club_id': intersportClubId,
          'intersport_partner_id': intersportPartnerId,
        },
      );

      final data = res.data as Map<String, dynamic>?;
      if (data != null && data['error'] != null) {
        return (ok: false, error: data['error'].toString());
      }
      return (ok: data?['ok'] == true, error: null);
    } on FunctionException catch (e) {
      // * Edge function returned a non-2xx — body carries { error, code }.
      final detail = e.details;
      final msg = detail is Map ? detail['error']?.toString() : null;
      logLocal.addLog(
        LogEntity(
          message: 'FunctionException(${e.status}): ${msg ?? detail}',
          source: 'intersportService.createClubFromEmail(clubId: $clubId)',
        ),
      );
      log('CREATE_CLUB_FROM_EMAIL: ${msg ?? detail}');
      return (ok: false, error: msg ?? 'edge_function_error');
    } catch (e) {
      logLocal.addLog(
        LogEntity(
          message: e.toString(),
          source: 'intersportService.createClubFromEmail(clubId: $clubId)',
        ),
      );
      log('CREATE_CLUB_FROM_EMAIL: ${e.toString()}');
      return (ok: false, error: e.toString());
    }
  }
}
