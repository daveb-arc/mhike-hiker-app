import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mhike/constants/routes.dart';
import 'package:mhike/pages/home/hike_list_view.dart';
import 'package:mhike/services/auth/auth_service.dart';
import 'package:mhike/services/crud/m_hike_service.dart';
import 'package:mhike/services/crud/model/hike.dart';
import 'package:mhike/services/crud/model/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MHikeService _mHikeService = MHikeService();
  late final PageController pageController;

  int currentPage = 0;

  @override
  void initState() {
    pageController = PageController(viewportFraction: 0.73);
    pageController.addListener(() {
      final page = pageController.page?.round() ?? 0;
      if (page != currentPage) {
        setState(() => currentPage = page);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = AuthService.firebase().currentUser;
    final email = authUser?.email ?? '';
    final uid = authUser?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xff282b41),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff282b41),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(searchRoute);
              },
              icon: Image.asset(
                'assets/search.png',
                color: Colors.white,
                width: 21,
              ),
            ),
          ),
        ],
      ),
      drawer: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(50)),
        child: Drawer(
          backgroundColor: const Color.fromARGB(255, 55, 59, 87),
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xff282b41),
                ),
                child: Center(
                  child: Text(
                    'mhike',
                    style: GoogleFonts.dancingScript(
                      fontSize: 82.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: FutureBuilder<User?>(
                  future: _mHikeService.getUserByUid(uid).then((u) async {
                    // fallback (older flow) if user doc was created by email query
                    return u ?? await _mHikeService.getUser(null, email);
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SizedBox(height: 70);
                    }
                    final user = snapshot.data;
                    if (user == null) {
                      return const Text(
                        'No profile found',
                        style: TextStyle(color: Colors.white),
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundImage:
                              AssetImage('assets/images/pexels3.jpg'),
                        ),
                        const VerticalDivider(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '@${user.username}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              ListTile(
                title: const Text('Add Hike', style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.add, color: Colors.white),
                onTap: () {
                  Navigator.of(context).pushNamed(addHikeRoute);
                },
              ),
              ListTile(
                title: const Text('Logout', style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.logout, color: Colors.white),
                onTap: () async {
                  await AuthService.firebase().logout();
                  if (!mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Popular',
              style: GoogleFonts.montserrat(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // POPULAR CAROUSEL
            SizedBox(
              height: 400,
              child: StreamBuilder<List<Hike>>(
                stream: _mHikeService.allHikes,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allHikes = snapshot.data!;
                  final popularHikes = allHikes
                      .where((h) => (h.popularityIndex ?? 999999) < 10)
                      .toList();

                  if (popularHikes.isEmpty) {
                    return const Center(
                      child: Text('No popular hikes yet',
                          style: TextStyle(color: Colors.white70)),
                    );
                  }

                  return PageView.builder(
                    padEnds: false,
                    controller: pageController,
                    itemCount: popularHikes.length,
                    itemBuilder: (context, index) {
                      final active = index == currentPage;
                      // Your existing card widget expects Hike; keep as-is
                      return _PopularCardWrapper(
                        active: active,
                        hike: popularHikes[index],
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'All Hikes',
              style: GoogleFonts.montserrat(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // ALL HIKES LIST
            StreamBuilder<List<Hike>>(
              stream: _mHikeService.allHikes,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final hikes = snapshot.data!;
                return HikeListView(
                  hikes: hikes,
                  onDeleteHike: (hike) async {
                    final id = hike.id;
                    if (id == null) return;
                    await _mHikeService.deleteHike(id: id);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Minimal wrapper so you don’t have to refactor your existing popular card widget.
// Replace this with your existing widget if you already have one.
class _PopularCardWrapper extends StatelessWidget {
  final bool active;
  final Hike hike;

  const _PopularCardWrapper({
    required this.active,
    required this.hike,
  });

  @override
  Widget build(BuildContext context) {
    // If you already had a popular card widget, use it here.
    // For now, reuse HikeListView card patterns elsewhere, or keep your existing.
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Opacity(
        opacity: active ? 1.0 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color.fromARGB(255, 55, 59, 87),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hike.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(hike.location,
                  style: const TextStyle(color: Colors.white70)),
              const Spacer(),
              const Text('Tap a hike card in All Hikes for details',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
