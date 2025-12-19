import 'package:flutter/material.dart';
import 'package:mhike/constants/routes.dart';
import 'package:mhike/services/crud/model/hike.dart';

typedef DeleteHikeCallback = void Function(Hike hike);

class HikeListView extends StatelessWidget {
  final List<Hike> hikes;
  final DeleteHikeCallback onDeleteHike;

  const HikeListView({
    super.key,
    required this.hikes,
    required this.onDeleteHike,
  });

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete hike?'),
        content: const Text('This will delete the hike document in Firestore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (hikes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No hikes yet',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: hikes.length,
      itemBuilder: (context, index) {
        final hike = hikes[index];

        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              hikeDetailRoute,
              arguments: hike,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xff343852),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hike.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hike.location,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip('${hike.length.toStringAsFixed(1)} mi'),
                          _chip(hike.estimatedTime),
                          _chip(hike.difficulty),
                          if (hike.parking) _chip('Parking'),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final shouldDelete = await _confirmDelete(context);
                    if (shouldDelete) {
                      onDeleteHike(hike);
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xff282b41),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white70),
      ),
    );
  }
}
