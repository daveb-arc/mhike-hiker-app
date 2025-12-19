import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mhike/services/crud/m_hike_service.dart';
import 'package:mhike/services/crud/model/hike.dart';
import 'package:mhike/services/crud/model/observation.dart';

class ObservationTab extends StatefulWidget {
  final Hike hike;
  const ObservationTab({super.key, required this.hike});

  @override
  State<ObservationTab> createState() => _ObservationTabState();
}

class _ObservationTabState extends State<ObservationTab> {
  final MHikeService _mHikeService = MHikeService();

  final _title = TextEditingController();
  final _category = TextEditingController();
  final _detail = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _category.dispose();
    _detail.dispose();
    super.dispose();
  }

  Future<void> _addObservation() async {
    final hikeId = widget.hike.id;
    if (hikeId == null || hikeId.isEmpty) return;

    final title = _title.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);

    try {
      final obs = Observation(
        hikeId: hikeId,
        title: title,
        category: _category.text.trim(),
        detail: _detail.text.trim(),
        dateTime: DateTime.now(),
      );

      await _mHikeService.addObservation(
        hikeId: hikeId,
        observation: obs,
      );

      if (!mounted) return;
      _title.clear();
      _category.clear();
      _detail.clear();
      FocusScope.of(context).unfocus();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hikeId = widget.hike.id;
    if (hikeId == null) {
      return const Center(child: Text('Missing hike id'));
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Observation>>(
            stream: _mHikeService.observationsForHike(hikeId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final observations = snapshot.data!;
              if (observations.isEmpty) {
                return const Center(child: Text('No observations yet'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: observations.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final o = observations[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 55, 59, 87),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                o.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('y-MM-dd').format(o.dateTime),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        if (o.category.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            o.category,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                        if (o.detail.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(o.detail),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xff282b41),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(
                  hintText: 'Title (required)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _category,
                decoration: const InputDecoration(
                  hintText: 'Category (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _detail,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Detail (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _saving ? null : _addObservation,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Observation'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
