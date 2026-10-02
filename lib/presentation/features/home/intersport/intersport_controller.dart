import 'dart:async';

import 'package:fs_sa/data/models/legacy/intersport_partner.dart';
import 'package:fs_sa/data/models/legacy/intersport_pending_request.dart';
import 'package:fs_sa/data/services/intersport_service.dart';

final intersportCtrler = IntersportController();

/// Holds partner + pending-request state for the Intersport tab.
/// Stream-based so each sub-view re-renders independently on refresh.
class IntersportController {
  IntersportController._privateConstructor();
  factory IntersportController() => _singleton;
  static final IntersportController _singleton =
      IntersportController._privateConstructor();

  final _partnersCtrl =
      StreamController<List<IntersportPartner>>.broadcast();
  final _requestsCtrl =
      StreamController<List<IntersportPendingRequest>>.broadcast();
  final _historyCtrl =
      StreamController<List<IntersportPendingRequest>>.broadcast();

  Stream<List<IntersportPartner>> get partnersStream => _partnersCtrl.stream;
  Stream<List<IntersportPendingRequest>> get requestsStream =>
      _requestsCtrl.stream;
  // * Processed (accepted + rejected) requests — read-only History tab.
  Stream<List<IntersportPendingRequest>> get historyStream =>
      _historyCtrl.stream;

  List<IntersportPartner> partners = [];
  List<IntersportPendingRequest> requests = [];
  List<IntersportPendingRequest> history = [];

  bool loadingPartners = false;
  bool loadingRequests = false;
  bool loadingHistory = false;

  Future<void> refreshPartners() async {
    loadingPartners = true;
    final res = await intersportService.listPartners();
    partners = res;
    loadingPartners = false;
    _partnersCtrl.add(partners);
  }

  Future<void> refreshRequests() async {
    loadingRequests = true;
    final res = await intersportService.listPendingRequests();
    requests = res;
    loadingRequests = false;
    _requestsCtrl.add(requests);
  }

  Future<void> refreshHistory() async {
    loadingHistory = true;
    final res = await intersportService.listProcessedRequests();
    history = res;
    loadingHistory = false;
    _historyCtrl.add(history);
  }

  /// Optimistic remove on accept/reject — the next refreshRequests refetches
  /// the canonical state.
  void removeRequestLocally(int requestId) {
    requests = requests.where((r) => r.id != requestId).toList();
    _requestsCtrl.add(requests);
  }

  /// Optimistic add on create — the next refreshPartners refetches the
  /// canonical state with the linked_clubs_count fresh from the server.
  void addPartnerLocally(IntersportPartner p) {
    partners = [p, ...partners];
    _partnersCtrl.add(partners);
  }
}
