// lib/services/read_receipt_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/read_receipt_models.dart';

class ReadReceiptService {
  final SupabaseClient _supabase;

  ReadReceiptService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  Future<List<ReadReceiptUser>> getReceipts(String messageId) async {
    try {
      final response = await _supabase
          .from('message_receipts')
          .select('*, users:user_id(display_name, photo_url)')
          .eq('message_id', messageId);

      return (response as List).map((e) {
        final userData = e['users'] as Map<String, dynamic>?;
        return ReadReceiptUser(
          id: e['user_id'],
          name: userData?['display_name'] ?? 'Utilisateur',
          avatarUrl: userData?['photo_url'],
          isDelivered: e['is_delivered'] ?? false,
          isRead: e['is_read'] ?? false,
          date: DateTime.parse(e['created_at']),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting receipts: $e');
      return [];
    }
  }

  Future<void> markAsRead(String messageId) async {
    try {
      await _supabase
          .from('message_receipts')
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('message_id', messageId)
          .eq('user_id', currentUserId);
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> sendPriorityMessage({
    required String conversationId,
    required String content,
    bool requireReadReceipt = true,
  }) async {
    final messageId = await _supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': currentUserId,
      'content': content,
      'type': 'text',
      'is_priority': true,
      'require_read_receipt': requireReadReceipt,
      'created_at': DateTime.now().toIso8601String(),
    }).select('id').then((res) => res[0]['id'] as String);

    final participants = await _supabase
        .from('conversation_participants')
        .select('user_id')
        .eq('conversation_id', conversationId);

    for (var p in participants as List) {
      if (p['user_id'] != currentUserId) {
        await _supabase.from('message_receipts').insert({
          'message_id': messageId,
          'user_id': p['user_id'],
          'is_delivered': false,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }
}
