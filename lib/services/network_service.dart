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
          'is_liked': (likedData as List).isNotEmpty,
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
          'is_liked': (userLikedData as List).isNotEmpty,
        });
        
        double score = 0;
        score += post.likesCount * 1.0;
        score += post.commentsCount * 3.0;
        
        final ageInMinutes = DateTime.now().difference(post.createdAt).inMinutes;
        final recencyScore = 100.0 / (ageInMinutes + 10);

