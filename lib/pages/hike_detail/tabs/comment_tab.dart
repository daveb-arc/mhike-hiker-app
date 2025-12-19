import 'package:flutter/material.dart';

import 'package:mhike/services/auth/auth_service.dart';
import 'package:mhike/services/crud/m_hike_service.dart';
import 'package:mhike/services/crud/model/comment.dart';
import 'package:mhike/services/crud/model/hike.dart';

class CommentTab extends StatefulWidget {
  final Hike hike;
  const CommentTab({super.key, required this.hike});

  @override
  State<CommentTab> createState() => _CommentTabState();
}

class _CommentTabState extends State<CommentTab> {
  final MHikeService _mHikeService = MHikeService();

  final TextEditingController _commentController = TextEditingController();
  double _rating = 3.0;
  bool _saving = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _addComment() async {
    final hikeId = widget.hike.id;
    if (hikeId == null || hikeId.isEmpty) {
      _toast('Missing hike id');
      return;
    }

    final user = AuthService.firebase().currentUser;
    if (user == null) {
      _toast('Please log in to comment.');
      return;
    }

    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _saving = true);

    try {
      final newComment = Comment(
        hikeId: hikeId,
        userId: user.id,
        userEmail: user.email ?? '',
        rating: _rating,
        text: text,
        dateTime: DateTime.now(),
      );

      await _mHikeService.addComment(
        hikeId: hikeId,
        comment: newComment,
      );

      _commentController.clear();
      setState(() => _rating = 3.0);
    } catch (e) {
      _toast('Failed to add comment: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hikeId = widget.hike.id;

    if (hikeId == null || hikeId.isEmpty) {
      return const Center(child: Text('No hike id available.'));
    }

    return Column(
      children: [
        // Add comment UI
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _commentController,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Add a comment',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Rating'),
                  Expanded(
                    child: Slider(
                      value: _rating,
                      min: 1,
                      max: 5,
                      divisions: 8,
                      label: _rating.toStringAsFixed(1),
                      onChanged: (v) => setState(() => _rating = v),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(_rating.toStringAsFixed(1)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _saving ? null : _addComment,
                child: _saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post Comment'),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Existing comments list
        Expanded(
          child: StreamBuilder<List<Comment>>(
            stream: _mHikeService.commentsForHike(hikeId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final comments = snapshot.data!;
              if (comments.isEmpty) {
                return const Center(child: Text('No comments yet.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: comments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final c = comments[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.userEmail,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text('Rating: ${c.rating.toStringAsFixed(1)}'),
                        const SizedBox(height: 6),
                        Text(c.text),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
