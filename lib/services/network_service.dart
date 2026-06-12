// lib/services/network_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import '../models/network_post.dart';
import '../models/network_connection.dart';
import '../models/network_community.dart';
import '../models/network_message.dart';
import '../models/network_notification.dart';
import '../models/network_story.dart';
import 'dart:io';

// ============================================================
// CLASSE POSTSCORE
// ============================================================
class PostScore {
  final NetworkPost post;
  double score;
  PostScore(this.post, this.score);
}

class NetworkService {
  final SupabaseClient _supabase;

  NetworkService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  // ============================================================
  // SECTION 1: POSTS - GET FEED
  // ============================================================

  Future<List<NetworkPost>> getFeedPosts({int limit = 20}) async {
    try {
      final currentUserId = this.currentUserId;
      if (currentUserId.isEmpty) return [];
      
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            users:user_id (
              display_name,
              photo_url,
              profession
            )
          ''')
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .limit(limit);
      
      final posts = <NetworkPost>[];
      for (var e in response as List) {
        final likesData = await _supabase
            .from('post_likes')
            .select('id')
            .eq('post_id', e['id']);
        
        final commentsData = await _supabase
            .from('comments')
            .select('id')
            .eq('post_id', e['id']);
        
        final likedData = await _supabase
            .from('post_likes')
            .select('id')
            .eq('post_id', e['id'])
            .eq('user_id', currentUserId);
        
        posts.add(NetworkPost.fromJson({
          ...e,
          'author_name': e['users']?['display_name'] ?? 'Utilisateur',
          'author_avatar': e['users']?['photo_url'],
          'author_title': e['users']?['profession'],
          'likes_count': (likesData as List).length,
          'comments_count': (commentsData as List).length,
          'is_liked_by_current_user': (likedData as List).isNotEmpty,
        }));
      }
      
      return posts;
    } catch (e) {
      debugPrint('❌ Error getFeedPosts: $e');
      return [];
    }
  }

  // ============================================================
  // SECTION 2: FEED INTELLIGENT (IA & ALGORITHME)
  // ============================================================

  Future<List<NetworkPost>> getSmartFeed({int limit = 20}) async {
    try {
      final currentUserId = this.currentUserId;
      if (currentUserId.isEmpty) return [];
      
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            users:user_id (
              display_name,
              photo_url,
              profession
            )
          ''')
          .eq('is_public', true)
          .limit(100);
      
      final connections = await _supabase
          .from('connections')
          .select('connection_id')
          .eq('user_id', currentUserId)
          .eq('status', 'accepted');
      
      final connectedUserIds = (connections as List)
          .map((c) => c['connection_id'] as String)
          .toSet();
      
      final postsWithScores = <PostScore>[];
      
      for (var e in response as List) {
        final likesData = await _supabase
            .from('post_likes')
            .select('id')
            .eq('post_id', e['id']);
        
        final commentsData = await _supabase
            .from('comments')
            .select('id')
            .eq('post_id', e['id']);
        
        final userLikedData = await _supabase
            .from('post_likes')
            .select('id')
            .eq('post_id', e['id'])
            .eq('user_id', currentUserId);
        
        final userData = e['users'] as Map<String, dynamic>?;
        
        final post = NetworkPost.fromJson({
          ...e,
          'author_name': userData?['display_name'] ?? 'Utilisateur',
          'author_avatar': userData?['photo_url'],
          'author_title': userData?['profession'],
          'likes_count': (likesData as List).length,
          'comments_count': (commentsData as List).length,
          'is_liked_by_current_user': (userLikedData as List).isNotEmpty,
        });
        
        double score = 0;
        
        // Score basé sur l'engagement
        score += post.likesCount * 1.0;
        score += post.commentsCount * 3.0;
        
        // Score basé sur la récence
        final ageInMinutes = DateTime.now().difference(post.createdAt).inMinutes;
        final recencyScore = 100.0 / (ageInMinutes + 10);
        score += recencyScore;
        
        // Bonus pour les posts des connexions
        if (connectedUserIds.contains(post.userId)) {
          score += 50;
        }
        
        // Malus pour les vieux posts
        if (ageInMinutes > 60 * 24) { // Plus de 24h
          score *= 0.5;
        }
        
        postsWithScores.add(PostScore(post, score));
      }
      
      // Trier par score décroissant
      postsWithScores.sort((a, b) => b.score.compareTo(a.score));
      
      return postsWithScores.take(limit).map((ps) => ps.post).toList();
    } catch (e) {
      debugPrint('❌ Error getSmartFeed: $e');
      return [];
    }
  }

  // ============================================================
  // SECTION 3: POSTS - CREATE / UPDATE / DELETE
  // ============================================================

  Future<String> createPost(String content, List<String> images) async {
    try {
      final userId = currentUserId;
      if (userId.isEmpty) return '';
      
      final newPost = {
        'user_id': userId,
        'content': content,
        'images': images,
        'is_public': true,
        'created_at': DateTime.now().toIso8601String(),
        'likes_count': 0,
        'comments_count': 0,
        'shares_count': 0,
      };
      
      final response = await _supabase
          .from('posts')
          .insert(newPost)
          .select()
          .single();
      
      return response['id'] as String;
    } catch (e) {
      debugPrint('❌ Error createPost: $e');
      return '';
    }
  }

  Future<bool> updatePost(String postId, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('posts')
          .update(data)
          .eq('id', postId)
          .eq('user_id', currentUserId);
      return true;
    } catch (e) {
      debugPrint('❌ Error updatePost: $e');
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _supabase
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', currentUserId);
      return true;
    } catch (e) {
      debugPrint('❌ Error deletePost: $e');
      return false;
    }
  }

  // ============================================================
  // SECTION 4: INTERACTIONS (LIKES & COMMENTAIRES)
  // ============================================================

  Future<bool> likePost(String postId) async {
    try {
      final userId = currentUserId;
      if (userId.isEmpty) return false;
      
      // Vérifier si déjà liké
      final existing = await _supabase
          .from('post_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId);
      
      if ((existing as List).isNotEmpty) return true;
      
      // Ajouter le like
      await _supabase.from('post_likes').insert({
        'post_id': postId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Incrémenter le compteur
      await _supabase.rpc('increment_post_likes', params: {'post_id': postId});
      
      return true;
    } catch (e) {
      debugPrint('❌ Error likePost: $e');
      return false;
    }
  }

  Future<bool> unlikePost(String postId) async {
    try {
      final userId = currentUserId;
      if (userId.isEmpty) return false;
      
      await _supabase
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      
      // Décrémenter le compteur
      await _supabase.rpc('decrement_post_likes', params: {'post_id': postId});
      
      return true;
    } catch (e) {
      debugPrint('❌ Error unlikePost: $e');
      return false;
    }
  }

  /// ✅ CORRIGÉ: Méthode pour ajouter un commentaire
  Future<bool> addCommentToPost(String postId, String comment) async {
    try {
      final userId = currentUserId;
      if (userId.isEmpty || comment.trim().isEmpty) return false;
      
      final newComment = {
        'post_id': postId,
        'user_id': userId,
        'content': comment.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase.from('comments').insert(newComment);
      
      // Incrémenter le compteur de commentaires
      await _supabase.rpc('increment_post_comments', params: {'post_id': postId});
      
      return true;
    } catch (e) {
      debugPrint('❌ Error addCommentToPost: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('*, users:user_id(display_name, photo_url)')
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      
      return (response as List).map((e) {
        final userData = e['users'] as Map<String, dynamic>?;
        return {
          'id': e['id'],
          'content': e['content'],
          'user_name': userData?['display_name'] ?? 'Utilisateur',
          'user_avatar': userData?['photo_url'],
          'created_at': e['created_at'],
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getComments: $e');
      return [];
    }
  }

  // ============================================================
  // SECTION 5: SHARE
  // ============================================================

  Future<void> sharePost(BuildContext context, NetworkPost post) async {
    try {
      await Share.share(
        '${post.content}\n\nPartagé depuis THIX ID - Réseau Pro',
        subject: 'Publication de ${post.authorName}',
      );
      
      // Incrémenter le compteur de partages
      await _supabase.rpc('increment_post_shares', params: {'post_id': post.id});
    } catch (e) {
      debugPrint('❌ Error sharePost: $e');
    }
  }

  // ============================================================
  // SECTION 6: FOLLOW / CONNECTIONS
  // ============================================================

  Future<bool> followUser(String userId) async {
    try {
      final currentId = currentUserId;
      if (currentId.isEmpty || currentId == userId) return false;
      
      await _supabase.from('follows').insert({
        'follower_id': currentId,
        'following_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      debugPrint('❌ Error followUser: $e');
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      final currentId = currentUserId;
      if (currentId.isEmpty) return false;
      
      await _supabase
          .from('follows')
          .delete()
          .eq('follower_id', currentId)
          .eq('following_id', userId);
      
      return true;
    } catch (e) {
      debugPrint('❌ Error unfollowUser: $e');
      return false;
    }
  }

  Future<bool> isFollowing(String userId) async {
    try {
      final currentId = currentUserId;
      if (currentId.isEmpty) return false;
      
      final response = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', currentId)
          .eq('following_id', userId);
      
      return (response as List).isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error isFollowing: $e');
      return false;
    }
  }

  // ============================================================
  // SECTION 7: STORIES
  // ============================================================

  Future<List<NetworkStory>> getStories() async {
    try {
      final response = await _supabase
          .from('stories')
          .select('*, users:user_id(display_name, photo_url)')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return (response as List).map((e) {
        final userData = e['users'] as Map<String, dynamic>?;
        return NetworkStory(
          id: e['id'],
          userId: e['user_id'],
          userName: userData?['display_name'] ?? 'Utilisateur',
          userAvatar: userData?['photo_url'],
          mediaUrl: e['media_url'],
          createdAt: DateTime.parse(e['created_at']),
          isViewed: false,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getStories: $e');
      return [];
    }
  }

  // ============================================================
  // SECTION 8: NOTIFICATIONS
  // ============================================================

  Future<List<NetworkNotification>> getNotifications() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('*, actor:actor_id(display_name, photo_url)')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false)
          .limit(50);
      
      return (response as List).map((e) {
        final actorData = e['actor'] as Map<String, dynamic>?;
        return NetworkNotification(
          id: e['id'],
          type: e['type'],
          actorId: e['actor_id'],
          actorName: actorData?['display_name'] ?? 'Quelqu\'un',
          actorAvatar: actorData?['photo_url'],
          content: e['content'],
          postId: e['post_id'],
          isRead: e['is_read'] ?? false,
          createdAt: DateTime.parse(e['created_at']),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getNotifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('❌ Error markNotificationAsRead: $e');
    }
  }

  // ============================================================
  // SECTION 9: MESSAGES
  // ============================================================

  Future<List<NetworkMessage>> getConversations() async {
    try {
      final response = await _supabase
          .from('conversations')
          .select('''
            *,
            participants:conversation_participants(user_id),
            last_message:messages(
              content,
              created_at,
              sender_id
            )
          ''')
          .eq('participants.user_id', currentUserId);
      
      return (response as List).map((e) {
        final lastMsg = e['last_message'] as List?;
        final lastMessage = lastMsg != null && lastMsg.isNotEmpty 
            ? lastMsg[0] as Map<String, dynamic>
            : null;
        
        return NetworkMessage(
          id: e['id'],
          conversationId: e['id'],
          senderId: lastMessage?['sender_id'] ?? '',
          receiverId: '',
          content: lastMessage?['content'] ?? '',
          createdAt: lastMessage != null 
              ? DateTime.parse(lastMessage['created_at'])
              : DateTime.now(),
          isRead: true,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getConversations: $e');
      return [];
    }
  }

  // ============================================================
  // SECTION 10: UPLOAD
  // ============================================================

  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'posts/$fileName';
      
      await _supabase.storage.from('network').upload(path, imageFile);
      
      final publicUrl = _supabase.storage.from('network').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error uploadImage: $e');
      return null;
    }
  }

  // ============================================================
  // SECTION 11: HELPERS
  // ============================================================

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, display_name, photo_url, profession, bio, location')
          .eq('id', userId)
          .single();
      
      return response as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('❌ Error getUserProfile: $e');
      return null;
    }
  }

  Future<int> getUserPostsCount(String userId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('id', count: CountOption.exact)
          .eq('user_id', userId);
      
      return response.count ?? 0;
    } catch (e) {
      debugPrint('❌ Error getUserPostsCount: $e');
      return 0;
    }
  }

  Future<int> getUserFollowersCount(String userId) async {
    try {
      final response = await _supabase
          .from('follows')
          .select('id', count: CountOption.exact)
          .eq('following_id', userId);
      
      return response.count ?? 0;
    } catch (e) {
      debugPrint('❌ Error getUserFollowersCount: $e');
      return 0;
    }
  }

  Future<int> getUserFollowingCount(String userId) async {
    try {
      final response = await _supabase
          .from('follows')
          .select('id', count: CountOption.exact)
          .eq('follower_id', userId);
      
      return response.count ?? 0;
    } catch (e) {
      debugPrint('❌ Error getUserFollowingCount: $e');
      return 0;
    }
  }
}
