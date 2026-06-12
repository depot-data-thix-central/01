// lib/services/status_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusService {
  final SupabaseClient _supabase;

  StatusService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  Future<void> updateStatus(String status, {String? customStatus}) async {
    try {
      await _supabase.from('user_status').upsert({
        'user_id': currentUserId,
        'status': status,
        'custom_status': customStatus,
        'last_seen': DateTime.now().toIso8601String(),
      });
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_status', status);
      if (customStatus != null) {
        await prefs.setString('custom_status', customStatus);
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserStatus(String userId) async {
    try {
      final response = await _supabase
          .from('user_status')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();
      return response as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting user status: $e');
      return null;
    }
  }

  Future<void> updateLastSeen() async {
    await _supabase
        .from('user_status')
        .update({'last_seen': DateTime.now().toIso8601String()})
        .eq('user_id', currentUserId);
  }

  Future<List<Map<String, dynamic>>> getOnlineUsers() async {
    try {
      final response = await _supabase
          .from('user_status')
          .select('*, users:user_id(display_name, photo_url)')
          .eq('status', 'online')
          .neq('user_id', currentUserId);

      return (response as List).map((e) => {
        'user_id': e['user_id'],
        'status': e['status'],
        'custom_status': e['custom_status'],
        'last_seen': e['last_seen'],
        'display_name': e['users']['display_name'],
        'photo_url': e['users']['photo_url'],
      }).toList();
    } catch (e) {
      debugPrint('Error getting online users: $e');
      return [];
    }
  }
}
