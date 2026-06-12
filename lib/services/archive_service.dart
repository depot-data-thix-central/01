// lib/services/archive_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/archive_models.dart';

class ArchiveService {
  final SupabaseClient _supabase;

  ArchiveService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  Future<List<ArchivedConversation>> getArchivedConversations() async {
    try {
      final response = await _supabase
          .from('conversations')
          .select('*, participants:conversation_participants(user_id)')
          .eq('is_archived', true)
          .eq('participants.user_id', currentUserId)
          .order('updated_at', ascending: false);

      return (response as List).map((e) => ArchivedConversation(
        id: e['id'],
        name: e['name'] ?? 'Chat',
        avatarUrl: e['avatar_url'],
        lastMessage: e['last_message'] ?? '',
        lastMessageAt: DateTime.parse(e['updated_at']),
        unreadCount: e['unread_count'] ?? 0,
      )).toList();
    } catch (e) {
      debugPrint('Error getting archived conversations: $e');
      return [];
    }
  }

  Future<List<ArchivedMedia>> getArchivedMedia() async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*')
          .eq('is_archived', true)
          .eq('sender_id', currentUserId)
          .inFilter('type', ['image', 'video'])
          .order('created_at', ascending: false);

      return (response as List).map((e) => ArchivedMedia(
        id: e['id'],
        type: e['type'],
        url: e['media_url'],
        thumbnailUrl: e['thumbnail_url'],
        archivedAt: DateTime.parse(e['created_at']),
      )).toList();
    } catch (e) {
      debugPrint('Error getting archived media: $e');
      return [];
    }
  }

  Future<List<ArchivedFile>> getArchivedFiles() async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*')
          .eq('is_archived', true)
          .eq('sender_id', currentUserId)
          .eq('type', 'file')
          .order('created_at', ascending: false);

      return (response as List).map((e) => ArchivedFile(
        id: e['id'],
        name: e['file_name'] ?? 'Fichier',
        type: _getFileType(e['file_name'] ?? ''),
        size: e['file_size'] ?? 0,
        archivedAt: DateTime.parse(e['created_at']),
      )).toList();
    } catch (e) {
      debugPrint('Error getting archived files: $e');
      return [];
    }
  }

  Future<List<ArchivedLink>> getArchivedLinks() async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*')
          .eq('is_archived', true)
          .eq('sender_id', currentUserId)
          .eq('type', 'link')
          .order('created_at', ascending: false);

      return (response as List).map((e) => ArchivedLink(
        id: e['id'],
        title: e['link_title'] ?? e['content'],
        url: e['content'],
        previewImage: e['link_preview'],
        archivedAt: DateTime.parse(e['created_at']),
      )).toList();
    } catch (e) {
      debugPrint('Error getting archived links: $e');
      return [];
    }
  }

  Future<void> unarchiveConversation(String id) async {
    await _supabase
        .from('conversations')
        .update({'is_archived': false})
        .eq('id', id);
  }

  Future<void> unarchiveMedia(String id) async {
    await _supabase
        .from('messages')
        .update({'is_archived': false})
        .eq('id', id);
  }

  Future<void> unarchiveFile(String id) async {
    await _supabase
        .from('messages')
        .update({'is_archived': false})
        .eq('id', id);
  }

  Future<void> unarchiveLink(String id) async {
    await _supabase
        .from('messages')
        .update({'is_archived': false})
        .eq('id', id);
  }

  Future<void> deleteArchiveItem(String id) async {
    await _supabase.from('messages').delete().eq('id', id);
  }

  Future<List<dynamic>> search({
    String? query,
    String? type,
    String? dateRange,
    String? sender,
    String? chat,
    bool? hasMedia,
  }) async {
    try {
      var request = _supabase
          .from('messages')
          .select('*, conversation:conversation_id(name)')
          .eq('sender_id', currentUserId)
          .eq('is_archived', true);

      if (query != null && query.isNotEmpty) {
        request = request.ilike('content', '%$query%');
      }
      if (type != null && type != 'all') {
        request = request.eq('type', type);
      }
      if (sender != null && sender != 'anyone') {
        // Filtrer par expéditeur
      }

      final response = await request.order('created_at', ascending: false).limit(100);
      return response as List;
    } catch (e) {
      debugPrint('Error searching archives: $e');
      return [];
    }
  }

  String _getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return 'pdf';
      case 'doc': return 'doc';
      case 'docx': return 'doc';
      case 'xls': return 'xls';
      case 'xlsx': return 'xls';
      case 'ppt': return 'ppt';
      case 'pptx': return 'ppt';
      default: return 'other';
    }
  }
}
