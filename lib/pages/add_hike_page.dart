import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mhike/constants/routes.dart';
import 'package:mhike/services/auth/auth_service.dart';
import 'package:mhike/services/crud/m_hike_service.dart';
import 'package:mhike/services/crud/model/hike.dart';

class AddHikePage extends StatefulWidget {
  const AddHikePage({super.key});

  @override
  State<AddHikePage> createState() => _AddHikePageState();
}

class _AddHikePageState extends State<AddHikePage> {
  final MHikeService _mHikeService = MHikeService();

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _lengthController = TextEditingController();
  final _estimatedTimeController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _parking = false;
  String? _difficulty;
  DateTime? _date;

  String? _coverBase64;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _lengthController.dispose();
    _estimatedTimeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _coverBase64 = base64Encode(bytes);
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _saveHike() async {
    final user = AuthService.firebase().currentUser;
    if (user == null) {
      _toast('You must be logged in.');
      return;
    }

    final length = double.tryParse(_lengthController.text.trim()) ?? 0.0;
    if (length <= 0) {
      _toast('Enter a valid length');
      return;
    }
    if (_difficulty == null || _difficulty!.isEmpty) {
      _toast('Select difficulty');
      return;
    }
    if (_date == null) {
      _toast('Pick a date');
      return;
    }
    if (_coverBase64 == null || _coverBase64!.isEmpty) {
      _toast('Pick a cover image');
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      _toast('Enter title');
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      _toast('Enter location');
      return;
    }

    setState(() => _saving = true);

    try {
      final hike = Hike(
        userId: user.id,
        userEmail: user.email ?? '',
        coverImage: _coverBase64!,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        length: length,
        estimatedTime: _estimatedTimeController.text.trim(),
        description: _descriptionController.text.trim(),
        parking: _parking,
        difficulty: _difficulty!,
        date: _date!,
        popularityIndex: 0,
      );

      await _mHikeService.createHike(hike);

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        homeRoute,
        (route) => false,
      );
    } catch (e) {
      _toast('Failed to save hike: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? previewBytes;
    if (_coverBase64 != null && _coverBase64!.isNotEmpty) {
      previewBytes = base64Decode(_coverBase64!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Hike'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickCoverImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white12,
                ),
                child: previewBytes == null
                    ? const Center(child: Text('Tap to select cover image'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(previewBytes, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _lengthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Length'),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _estimatedTimeController,
              decoration: const InputDecoration(labelText: 'Estimated Time'),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Parking'),
              value: _parking,
              onChanged: (v) => setState(() => _parking = v),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _difficulty,
              items: const [
                DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
                DropdownMenuItem(value: 'Hard', child: Text('Hard')),
              ],
              onChanged: (v) => setState(() => _difficulty = v),
              decoration: const InputDecoration(labelText: 'Difficulty'),
            ),
            const SizedBox(height: 12),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(
                _date == null
                    ? 'Tap to pick a date'
                    : DateFormat('y-MM-dd').format(_date!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: _saving ? null : _saveHike,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Hike'),
            ),
          ],
        ),
      ),
    );
  }
}
