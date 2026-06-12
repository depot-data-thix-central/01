// lib/services/chat_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/chat_models.dart';

class ChatService {
  final SupabaseClient _supabase;

  ChatService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  // ============================================================
  // CONVERSATIONS
  // ============================================================

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _supabase
          .from('conversations')
          .select('''
            *,
            participants:conversation_participants(user_id),
            last_message:messages(content, created_at, sender_id)
          ''')
          .eq('participants.user_id', currentUserId)
          .order('updated_at', ascending: false);

      final conversations = <Conversation>[];
      for (var e in response as List) {
        final lastMsg = e['last_message'] as List?;
        final lastMessage = lastMsg != null && lastMsg.isNotEmpty
            ? lastMsg[0] as Map<String, dynamic>
            : null;
        
        conversations.add(Conversation(
          id: e['id'],
          type: e['type'] ?? 'private',
          name: e['name'] ?? 'Chat',
          avatarUrl: e['avatar_url'],
          lastMessage: lastMessage?['content'] ?? 'Nouvelle conversation',
          lastMessageTime: _formatTimeAgo(lastMessage != null
              ? DateTime.parse(lastMessage['created_at'])
              : DateTime.parse(e['created_at'])),
          unreadCount: e['unread_count'] ?? 0,
          isOnline: false,
        ));
      }
      return conversations;
    } catch (e) {
      debugPrint('Error getting conversations: $e');
      return [];
    }
  }

  Future<ChatStats> getStats() async {
    try {
      final online = await _supabase
          .from('user_status')
          .select('id')
          .eq('status', 'online');
      
      final unread = await _supabase
          .from('conversation_participants')
          .select('id')
          .eq('user_id', currentUserId)
          .gt('unread_count', 0);
      
      return ChatStats(
        onlineCount: (online as List).length,
        newMessagesCount: (unread as List).length,
        activeCallsCount: 0,
        securityAlertsCount: 0,
      );
    } catch (e) {
      debugPrint('Error getting stats: $e');
      return ChatStats.empty();
    }
  }

  Future<List<Story>> getStories() async {
    try {
      final response = await _supabase
          .from('stories')
          .select('*, users:user_id(display_name, photo_url)')
          .eq('is_active', true)
          .gte('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      return (response as List).map((e) {
        final userData = e['users'] as Map<String, dynamic>?;
        return Story(
          id: e['id'],
          userId: e['user_id'],
          userName: userData?['display_name'] ?? 'Utilisateur',
          userAvatar: userData?['photo_url'],
          mediaUrl: e['media_url'],
          type: e['type'] ?? 'image',
          isViewed: false,
          createdAt: DateTime.parse(e['created_at']),
          expiresAt: DateTime.parse(e['expires_at']),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting stories: $e');
      return [];
    }
  }

  Future<List<Story>> getMyStories() async {
    try {
      final response = await _supabase
          .from('stories')
          .select('*')
          .eq('user_id', currentUserId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List).map((e) => Story(
        id: e['id'],
        userId: e['user_id'],
        userName: '',
        mediaUrl: e['media_url'],
        type: e['type'] ?? 'image',
        isViewed: false,
        createdAt: DateTime.parse(e['created_at']),
        expiresAt: DateTime.parse(e['expires_at']),
      )).toList();
    } catch (e) {
      debugPrint('Error getting my stories: $e');
      return [];
    }
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*, users:sender_id(display_name, photo_url)')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List).map((e) {
        final userData = e['users'] as Map<String, dynamic>?;
        final isFromMe = e['sender_id'] == currentUserId;
        return ChatMessage(
          id: e['id'],
          senderId: e['sender_id'],
          senderName: userData?['display_name'] ?? 'Utilisateur',
          senderAvatar: userData?['photo_url'],
          type: e['type'] ?? 'text',
          content: e['content'] ?? '',
          mediaUrl: e['media_url'],
          mediaDuration: e['media_duration'],
          fileName: e['file_name'],
          fileSize: e['file_size'],
          isFromMe: isFromMe,
          isRead: e['is_read'] ?? false,
          isDelivered: e['is_delivered'] ?? false,
          isPinned: e['is_pinned'] ?? false,
          reactions: (e['reactions'] as Map?)?.cast<String, List<String>>() ?? {},
          createdAt: DateTime.parse(e['created_at']),
          formattedTime: _formatTime(DateTime.parse(e['created_at'])),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return [];
    }
  }

  Future<ChatMessage> sendMessage(String conversationId, String content) async {
    final response = await _supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': currentUserId,
      'content': content,
      'type': 'text',
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();

    return ChatMessage(
      id: response['id'],
      senderId: currentUserId,
      senderName: 'Moi',
      type: 'text',
      content: content,
      isFromMe: true,
      isRead: false,
      isDelivered: false,
      reactions: {},
      createdAt: DateTime.now(),
      formattedTime: _formatTime(DateTime.now()),
    );
  }

  Future<ChatMessage> sendMedia(String conversationId, String filePath, String type) async {
    final url = await _uploadFile(filePath, type);
    
    final response = await _supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': currentUserId,
      'media_url': url,
      'type': type,
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();

    return ChatMessage(
      id: response['id'],
      senderId: currentUserId,
      senderName: 'Moi',
      type: type,
      content: '',
      mediaUrl: url,
      isFromMe: true,
      isRead: false,
      isDelivered: false,
      reactions: {},
      createdAt: DateTime.now(),
      formattedTime: _formatTime(DateTime.now()),
    );
  }

  Future<void> toggleLike(String messageId) async {
    final existing = await _supabase
        .from('message_likes')
        .select('id')
        .eq('message_id', messageId)
        .eq('user_id', currentUserId)
        .maybeSingle();

    if (existing == null) {
      await _supabase.from('message_likes').insert({
        'message_id': messageId,
        'user_id': currentUserId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await _supabase
          .from('message_likes')
          .delete()
          .eq('message_id', messageId)
          .eq('user_id', currentUserId);
    }
  }

  Future<void> addReaction(String messageId, String emoji) async {
    final reactions = await _supabase
        .from('message_reactions')
        .select('reactions')
        .eq('message_id', messageId)
        .maybeSingle();

    Map<String, dynamic> currentReactions = {};
    if (reactions != null) {
      currentReactions = reactions['reactions'] as Map<String, dynamic>? ?? {};
    }

    final users = currentReactions[emoji] as List? ?? [];
    if (!users.contains(currentUserId)) {
      users.add(currentUserId);
      currentReactions[emoji] = users;
    }

    await _supabase.from('message_reactions').upsert({
      'message_id': messageId,
      'reactions': currentReactions,
    });
  }

  Future<void> pinMessage(String messageId) async {
    await _supabase
        .from('messages')
        .update({'is_pinned': true})
        .eq('id', messageId);
  }

  Future<void> markMessagesAsRead(String conversationId) async {
    await _supabase
        .from('conversation_participants')
        .update({'unread_count': 0, 'last_read_at': DateTime.now().toIso8601String()})
        .eq('conversation_id', conversationId)
        .eq('user_id', currentUserId);
  }

  // ============================================================
  // STORIES
  // ============================================================

  Future<void> createStory(File mediaFile, String type) async {
    final url = await _uploadFile(mediaFile.path, type);
    await _supabase.from('stories').insert({
      'user_id': currentUserId,
      'media_url': url,
      'type': type,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    });
  }

  Future<void> createStoryText(String text) async {
    await _supabase.from('stories').insert({
      'user_id': currentUserId,
      'text': text,
      'type': 'text',
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    });
  }

  Future<void> markStoryAsViewed(String storyId) async {
    final viewedBy = await _supabase
        .from('stories')
        .select('viewed_by')
        .eq('id', storyId)
        .maybeSingle();

    List<dynamic> viewers = [];
    if (viewedBy != null && viewedBy['viewed_by'] != null) {
      viewers = viewedBy['viewed_by'] as List;
    }
    
    if (!viewers.contains(currentUserId)) {
      viewers.add(currentUserId);
      await _supabase
          .from('stories')
          .update({'viewed_by': viewers})
          .eq('id', storyId);
    }
  }

  // ============================================================
  // SPACES
  // ============================================================

  Future<List<Space>> getSpaces() async {
    try {
      final response = await _supabase
          .from('spaces')
          .select('*')
          .eq('is_active', true)
          .limit(10);

      return (response as List).map((e) => Space(
        id: e['id'],
        name: e['name'],
        description: e['description'],
        avatarUrl: e['avatar_url'],
        memberCount: e['member_count'] ?? 1,
      )).toList();
    } catch (e) {
      debugPrint('Error getting spaces: $e');
      return [];
    }
  }

  // ============================================================
  // UTILITAIRES
  // ============================================================

  Future<String> _uploadFile(String filePath, String type) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final extension = filePath.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final storagePath = 'chat_media/$currentUserId/$fileName';
      
      await _supabase.storage.from('chat').uploadBinary(storagePath, bytes);
      return _supabase.storage.from('chat').getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return '';
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    return '${date.day}/${date.month}';
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'maintenant';
    if (diff.inHours < 1) return '${diff.inMinutes}min';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'hier';
    return '${diff.inDays}j';
  }
}
