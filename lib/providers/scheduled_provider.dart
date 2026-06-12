// lib/providers/scheduled_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/scheduled_service.dart';
import '../models/scheduled_models.dart';

class ScheduledProvider extends ChangeNotifier {
  late ScheduledService _service;
  
  List<ScheduledMessage> _scheduledMessages = [];
  bool _isLoading = false;
  
  ScheduledProvider() {
    _service = ScheduledService(Supabase.instance.client);
  }
  
  // ============================================================
  // GETTERS
  // ============================================================
  
  List<ScheduledMessage> get scheduledMessages => _scheduledMessages;
  bool get isLoading => _isLoading;
  
  // ============================================================
  // MÉTHODES
  // ============================================================
  
  Future<void> loadScheduledMessages(String conversationId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _scheduledMessages = await _service.getScheduledMessages(conversationId);
    } catch (e) {
      debugPrint('Error loading scheduled messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> scheduleMessage({
    required String conversationId,
    required String content,
    required DateTime scheduledAt,
    bool isRecurring = false,
    String? recurringPattern,
  }) async {
    try {
      await _service.scheduleMessage(
        conversationId: conversationId,
        content: content,
        scheduledAt: scheduledAt,
        isRecurring: isRecurring,
        recurringPattern: recurringPattern,
      );
      await loadScheduledMessages(conversationId);
      return true;
    } catch (e) {
      debugPrint('Error scheduling message: $e');
      return false;
    }
  }
  
  Future<bool> cancelScheduledMessage(String id) async {
    try {
      await _service.cancelScheduledMessage(id);
      return true;
    } catch (e) {
      debugPrint('Error cancelling message: $e');
      return false;
    }
  }
}
