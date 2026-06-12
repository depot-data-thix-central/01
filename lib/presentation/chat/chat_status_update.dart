// lib/presentation/chat/chat_status_update.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';

class ChatStatusUpdatePage extends StatefulWidget {
  const ChatStatusUpdatePage({super.key});

  @override
  State<ChatStatusUpdatePage> createState() => _ChatStatusUpdatePageState();
}

class _ChatStatusUpdatePageState extends State<ChatStatusUpdatePage> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _postStatus() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    setState(() => _isUploading = true);

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    bool success = false;

    if (_selectedImage != null) {
      success = await chatProvider.postStoryImage(_selectedImage!);
    } else if (text.isNotEmpty) {
      success = await chatProvider.postStoryText(text);
    }

    setState(() => _isUploading = false);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ajouter un statut', style: TextStyle(fontSize: 16, color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _postStatus,
            child: Text(_isUploading ? 'Envoi...' : 'Partager', style: const TextStyle(fontSize: 13, color: Color(0xFFD4AF37))),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.contain)
                  : Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Que voulez-vous partager ?',
                          hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        maxLines: 5,
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(Icons.photo_library, 'Galerie', _pickImage),
                _actionButton(Icons.camera_alt, 'Appareil', _takePhoto),
                _actionButton(Icons.text_fields, 'Texte', () {
                  setState(() => _selectedImage = null);
                  FocusScope.of(context).requestFocus();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }
}
