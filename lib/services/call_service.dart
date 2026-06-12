// lib/services/call_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/call_models.dart';

class CallService {
  final SupabaseClient _supabase;

  CallService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  Future<List<Call>> getCallHistory() async {
    try {
      final response = await _supabase
          .from('calls')
          .select('*, caller:caller_id(display_name, photo_url), receiver:receiver_id(display_name, photo_url)')
          .or('caller_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .order('started_at', ascending: false)
          .limit(50);

      return (response as List).map((e) {
        final callerData = e['caller'] as Map<String, dynamic>?;
        final receiverData = e['receiver'] as Map<String, dynamic>?;
        final isCaller = e['caller_id'] == currentUserId;
        return Call(
          id: e['id'],
          callerId: e['caller_id'],
          callerName: callerData?['display_name'] ?? 'Inconnu',
          callerAvatar: callerData?['photo_url'],
          receiverId: e['receiver_id'],
          receiverName: receiverData?['display_name'] ?? 'Inconnu',
          receiverAvatar: receiverData?['photo_url'],
          type: e['type'],
          status: e['status'],
          duration: e['duration'] ?? 0,
          startedAt: DateTime.parse(e['started_at']),
          endedAt: e['ended_at'] != null ? DateTime.parse(e['ended_at']) : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting call history: $e');
      return [];
    }
  }

  Future<Call> startCall(String conversationId, String type) async {
    final response = await _supabase.from('calls').insert({
      'caller_id': currentUserId,
      'conversation_id': conversationId,
      'type': type,
      'status': 'ongoing',
      'started_at': DateTime.now().toIso8601String(),
    }).select().single();

    return Call(
      id: response['id'],
      callerId: response['caller_id'],
      callerName: 'Moi',
      receiverId: '',
      receiverName: '',
      type: response['type'],
      status: response['status'],
      duration: 0,
      startedAt: DateTime.parse(response['started_at']),
    );
  }

  Future<void> acceptCall(String callId) async {
    await _supabase
        .from('calls')
        .update({'status': 'ongoing'})
        .eq('id', callId);
  }

  Future<void> rejectCall(String callId) async {
    await _supabase
        .from('calls')
        .update({'status': 'rejected', 'ended_at': DateTime.now().toIso8601String()})
        .eq('id', callId);
  }

  Future<void> endCall(String callId) async {
    final call = await _supabase
        .from('calls')
        .select('started_at')
        .eq('id', callId)
        .single();
    
    final startedAt = DateTime.parse(call['started_at']);
    final duration = DateTime.now().difference(startedAt).inSeconds;
    
    await _supabase
        .from('calls')
        .update({
          'status': 'ended',
          'duration': duration,
          'ended_at': DateTime.now().toIso8601String(),
        })
        .eq('id', callId);
  }

  Future<void> toggleMute(String callId, bool muted) async {
    // Logique pour mute/unmute
  }

  Future<void> toggleSpeaker(String callId, bool speakerOn) async {
    // Logique pour speaker
  }

  Future<void> toggleVideo(String callId, bool videoOn) async {
    // Logique pour vidéo
  }
}
