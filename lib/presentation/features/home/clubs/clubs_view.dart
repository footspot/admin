import 'package:flutter/material.dart';
import 'package:fs_sa/data/models/objectbox/club_sub_entity.dart';
import 'package:fs_sa/presentation/features/home/clubs/clubs_controller.dart';
import 'package:fs_sa/presentation/features/home/clubs/widgets/club_item.dart';
import 'package:fs_sa/presentation/widgets/search_bar/search_bar.dart';

class ClubsView extends StatefulWidget {
  const ClubsView({super.key});

  @override
  State<ClubsView> createState() => _ClubsViewState();
}

class _ClubsViewState extends State<ClubsView> {
  bool isSearching = false;

  @override
  void initState() {
    clubsCtrler.init(setState, context);
    super.initState();
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GenericSearchBar<ClubSubscriptionEntity>(
      mainScrollController: clubsCtrler.scrollController,
      onSearch: clubsCtrler.onSearch,
      mainItemBuilder: (context, club, index) {
        return ClubItem(data: club, index: index);
      },
      mainPagingController: clubsCtrler.paginationController,
      hintText: 'Search by name... ',
      searchItemBuilder: (context, club, index) {
        return ClubItem(data: club, index: index);
      },
    );
  }
}
