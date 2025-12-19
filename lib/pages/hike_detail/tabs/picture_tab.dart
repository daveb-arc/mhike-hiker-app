import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mhike/services/crud/m_hike_service.dart';
import 'package:mhike/services/crud/model/hike.dart';
import 'package:mhike/services/crud/model/picture.dart';

class PictureTab extends StatefulWidget {
  final Hike hike;

  const PictureTab({super.key, required this.hike});

  @override
  State<PictureTab> createState() => _PictureTabState();
}

class _PictureTabState extends State<PictureTab> {
  final MHikeService _mHikeService = MHikeService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _addPicture() async {
    final hikeId = widget.hike.id;
    if (hikeId == null) return;

    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final Uint8List bytes = await picked.readAsBytes();
    final String base64 = base64Encode(bytes);

    final Picture pic = Picture(
      id: '', // Firestore will assign this
      base64: base64,
      time: DateTime.now(),
    );

    await _mHikeService.addPicture(
      hikeId: hikeId,
      picture: pic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Picture>>(
            stream: _mHikeService.picturesForHike(widget.hike.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final pictures = snapshot.data ?? [];

              if (pictures.isEmpty) {
                return const Center(child: Text('No pictures yet'));
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: pictures.length,
                itemBuilder: (context, index) {
                  final pic = pictures[index];
                  return Image.memory(
                    base64Decode(pic.base64),
                    fit: BoxFit.cover,
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Picture'),
            onPressed: _addPicture,
          ),
        ),
      ],
    );
  }
}
