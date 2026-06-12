// lib/providers/voice_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import '../services/voice_service.dart';

class VoiceProvider extends ChangeNotifier {
  late VoiceService _service;
  
  final Map<String, String> _transcripts = {};
  final Map<String, bool> _transcribing = {};
  
  VoiceProvider() {
    _service = VoiceService(Supabase.instance.client);
  }
  
  // ============================================================
  // GETTERS
  // ============================================================
  
  bool isTranscribing(String messageId) => _transcribing[messageId] ?? false;
  String? getTranscript(String messageId) => _transcripts[messageId];
  
  // ============================================================
  // MÉTHODES
  // ============================================================
  
  Future<void> transcribeAudio(String messageId, String audioUrl) async {
    if (_transcribing[messageId] == true) return;
    
    _transcribing[messageId] = true;
    notifyListeners();
    
    try {
      final transcript = await _service.transcribeAudio(audioUrl);
      if (transcript != null && transcript.isNotEmpty) {
        _transcripts[messageId] = transcript;
        await _service.saveTranscript(messageId, transcript);
      }
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
    } finally {
      _transcribing[messageId] = false;
      notifyListeners();
    }
  }
  
  Future<String?> uploadAudio(File audioFile) async {
    return await _service.uploadAudio(audioFile);
  }
}
