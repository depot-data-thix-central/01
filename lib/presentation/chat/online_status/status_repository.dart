// lib/presentation/chat/online_status/status_repository.dart
// Repository pour la gestion des statuts (appels Supabase)

import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/chat_models.dart';

class StatusRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Récupérer le statut d'un utilisateur spécifique
  Future<ChatUser> getUserStatus(String userId) async {
    final response = await _supabase
        .from('users')
        .select('id, display_name, avatar_url, status, last_seen')
        .eq('id', userId)
        .single();
    return ChatUser.fromJson(response);
  }

  // Récupérer la liste des contacts en ligne
  Future<List<ChatUser>> getOnlineContacts(String currentUserId) async {
    final response = await _supabase
        .from('users')
        .select('id, display_name, avatar_url, status, last_seen')
        .eq('status', 'online')
        .neq('id', currentUserId);
    return response.map<ChatUser>((json) => ChatUser.fromJson(json)).toList();
  }

  // Mettre à jour son propre statut
  Future<void> updateStatus(String userId, String status) async {
    await _supabase.from('users').update({
      'status': status,
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // Écouter les changements de statut en temps réel (WebSocket)
  Stream<ChatUser> listenToStatusChanges(String userId) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((event) => ChatUser.fromJson(event.first));
  }

  // Écouter tous les statuts des contacts (pour rafraîchir la liste)
  Stream<List<ChatUser>> listenToAllStatuses(List<String> contactIds) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .inFilter('id', contactIds)
        .map((events) => events.map((json) => ChatUser.fromJson(json)).toList());
  }
}
