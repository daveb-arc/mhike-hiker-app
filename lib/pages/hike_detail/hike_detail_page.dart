import 'package:flutter/material.dart';
import 'package:mhike/constants/routes.dart';
import 'package:mhike/enums/menu_actions.dart';
import 'package:mhike/services/auth/auth_service.dart';
import 'package:mhike/services/crud/model/hike.dart';
import 'package:mhike/utilities/generics/get_arguments.dart';

// Tab widgets (aliased to avoid collisions / name mismatch)
import 'package:mhike/pages/hike_detail/tabs/comment_tab.dart' as comment_tab;
import 'package:mhike/pages/hike_detail/tabs/observation_tab.dart'
    as observation_tab;
import 'package:mhike/pages/hike_detail/tabs/picture_tab.dart' as picture_tab;

class HikeDetailPage extends StatefulWidget {
  const HikeDetailPage({super.key});

  @override
  State<HikeDetailPage> createState() => _HikeDetailPageState();
}

class _HikeDetailPageState extends State<HikeDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Hike _hike;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Hike?> _getHikeDetail(BuildContext context) async {
    final hike = context.getArgument<Hike>();
    if (hike != null) {
      _hike = hike;
      return hike;
    }
    return null;
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Log out'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff282b41),
      body: FutureBuilder<Hike?>(
        future: _getHikeDetail(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final hike = snapshot.data;
          if (hike == null) {
            return const Center(child: Text('No hike found'));
          }

          return Scaffold(
            backgroundColor: const Color(0xff282b41),
            appBar: AppBar(
              backgroundColor: const Color(0xff282b41),
              title: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hike.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                PopupMenuButton<MenuAction>(
                  onSelected: (value) async {
                    switch (value) {
                      case MenuAction.logout:
                        final shouldLogout = await _showLogoutDialog(context);
                        if (!shouldLogout) return;

                        await AuthService.firebase().logout();

                        if (!mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute,
                          (_) => false,
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Comments'),
                  Tab(text: 'Observations'),
                  Tab(text: 'Pictures'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                comment_tab.CommentTab(hike: hike),
                observation_tab.ObservationTab(hike: hike),
                picture_tab.PictureTab(hike: hike),
              ],
            ),
          );
        },
      ),
    );
  }
}
