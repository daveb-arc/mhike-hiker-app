import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mhike/constants/routes.dart';
import 'package:mhike/pages/home/hike_list_view.dart';
import 'package:mhike/services/auth/auth_service.dart';
import 'package:mhike/services/crud/m_hike_service.dart';
import 'package:mhike/services/crud/model/hike.dart';
import 'package:mhike/services/crud/model/user.dart' as mhike_user;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MHikeService _mHikeService = MHikeService();

  @override
  Widget build(BuildContext context) {
    final authUser = AuthService.firebase().currentUser;
    final uid = authUser?.id;
    final email = authUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xff282b41),
      appBar: AppBar(
        backgroundColor: const Color(0xff282b41),
        elevation: 0,
        title: Text(
          'M Hike',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(searchRoute);
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(addHikeRoute);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),

      // =========================
      // Drawer
      // =========================
      drawer: Drawer(
        backgroundColor: const Color(0xff282b41),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Account',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // User card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xff343852),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: FutureBuilder<mhike_user.User?>(
                    future: () async {
                      if (uid != null && uid.isNotEmpty) {
                        final byUid = await _mHikeService.getUserByUid(uid);
                        if (byUid != null) return byUid;
                      }
                      if (email.isNotEmpty) {
                        return await _mHikeService.getUser(null, email);
                      }
                      return null;
                    }(),
                    builder: (context, snap) {
                      final u = snap.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u?.fullName ?? 'Signed in',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            u?.email ?? email,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if ((u?.username ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '@${u!.username}',
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Divider(color: Colors.white24),

              // =========================
              // Add hike (RESTORED)
              // =========================
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add hike'),
                onTap: () {
                  Navigator.of(context).pop(); // close drawer
                  Navigator.of(context).pushNamed(addHikeRoute);
                },
              ),

              // Logout
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log out'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await AuthService.firebase().logout();
                  if (!mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // =========================
      // Body
      // =========================
      body: StreamBuilder<List<Hike>>(
        stream: _mHikeService.allHikes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading hikes:\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final hikes = snapshot.data ?? [];

          final popular = hikes
              .where((h) => (h.popularityIndex ?? 999999) < 10)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Popular'),
                const SizedBox(height: 10),

                if (popular.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No popular hikes yet',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                else
                  _popularCard(context, popular.first),

                const SizedBox(height: 28),
                _sectionTitle('All Hikes'),
                const SizedBox(height: 10),

                HikeListView(
                  hikes: hikes,
                  onDeleteHike: (hike) async {
                    final id = hike.id;
                    if (id == null) return;
                    await _mHikeService.deleteHike(id: id);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 34,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _popularCard(BuildContext context, Hike hike) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          hikeDetailRoute,
          arguments: hike,
        );
      },
      child: Container(
        height: 180,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff343852),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hike.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hike.location,
              style: const TextStyle(color: Colors.white70),
            ),
            const Spacer(),
            const Text(
              'Tap to view details',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
