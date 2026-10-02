import 'package:flutter/material.dart';
import 'package:fs_sa/data/models/legacy/intersport_partner.dart';
import 'package:fs_sa/data/models/legacy/intersport_pending_request.dart';
import 'package:fs_sa/presentation/features/home/intersport/intersport_controller.dart';
import 'package:fs_sa/presentation/features/home/intersport/widgets/add_partner_dialog.dart';
import 'package:fs_sa/presentation/features/home/intersport/widgets/partner_card.dart';
import 'package:fs_sa/presentation/features/home/intersport/widgets/pending_request_card.dart';
import 'package:fs_sa/presentation/features/home/intersport/widgets/processed_request_card.dart';

class IntersportView extends StatefulWidget {
  const IntersportView({super.key});

  @override
  State<IntersportView> createState() => _IntersportViewState();
}

class _IntersportViewState extends State<IntersportView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    // * Initial fetch for all sub-views; refreshing one tab doesn't block
    // * the others.
    intersportCtrler.refreshPartners();
    intersportCtrler.refreshRequests();
    intersportCtrler.refreshHistory();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intersport'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(icon: Icon(Icons.store_outlined), text: 'Partners'),
            Tab(icon: Icon(Icons.inbox_outlined), text: 'Requests'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [_PartnersTab(), _RequestsTab(), _HistoryTab()],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabCtrl,
        builder: (_, __) {
          // * FAB only on the Partners tab.
          if (_tabCtrl.index != 0) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => AddPartnerDialog.show(context),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

class _PartnersTab extends StatelessWidget {
  const _PartnersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<IntersportPartner>>(
      stream: intersportCtrler.partnersStream,
      initialData: intersportCtrler.partners,
      builder: (context, snap) {
        final partners = snap.data ?? const [];
        return RefreshIndicator(
          onRefresh: intersportCtrler.refreshPartners,
          child:
              partners.isEmpty
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Icon(
                        Icons.storefront_outlined,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'No partner yet',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Tap + to add the first Intersport region.',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  )
                  : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 6, bottom: 80),
                    itemCount: partners.length,
                    itemBuilder:
                        (_, i) => PartnerCard(partner: partners[i]),
                  ),
        );
      },
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<IntersportPendingRequest>>(
      stream: intersportCtrler.requestsStream,
      initialData: intersportCtrler.requests,
      builder: (context, snap) {
        final requests = snap.data ?? const [];
        return RefreshIndicator(
          onRefresh: intersportCtrler.refreshRequests,
          child:
              requests.isEmpty
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'No pending request',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'New requests from directors will appear here.',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  )
                  : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 6, bottom: 80),
                    itemCount: requests.length,
                    itemBuilder:
                        (_, i) => PendingRequestCard(request: requests[i]),
                  ),
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<IntersportPendingRequest>>(
      stream: intersportCtrler.historyStream,
      initialData: intersportCtrler.history,
      builder: (context, snap) {
        final history = snap.data ?? const [];
        return RefreshIndicator(
          onRefresh: intersportCtrler.refreshHistory,
          child:
              history.isEmpty
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'No processed request yet',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Accepted and rejected requests will appear here.',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  )
                  : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 6, bottom: 80),
                    itemCount: history.length,
                    itemBuilder:
                        (_, i) => ProcessedRequestCard(request: history[i]),
                  ),
        );
      },
    );
  }
}
