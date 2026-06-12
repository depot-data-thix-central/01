// lib/providers/feed_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../services/network_service.dart';
import '../models/network_post.dart';

class FeedProvider extends ChangeNotifier {
  final NetworkService _networkService;
  final SupabaseClient? _supabase;
  
  List<NetworkPost> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String _currentFeedType = 'smart';
  String? _error;
  
  // ✅ AJOUT: Real-time listening
  RealtimeChannel? _realtimeChannel;
  Timer? _autoRefreshTimer;
  DateTime? _lastRefresh;
  
  FeedProvider(this._networkService, {SupabaseClient? supabase}) : _supabase = supabase;
  
  // Getters
  List<NetworkPost> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get currentFeedType => _currentFeedType;
  String? get error => _error;
  
  // ============================================================
  // INITIALISATION REALTIME
  // ============================================================
  
  /// ✅ CORRIGÉ: Démarre l'écoute realtime et le polling
  void initRealtime() {
    debugPrint('🎙️ FeedProvider: Initialisation realtime...');
    
    _setupRealtimeListener();
    _setupAutoRefresh();
  }
  
  /// ✅ Configuration du listener Realtime Supabase
  void _setupRealtimeListener() {
    try {
      if (_supabase == null) {
        debugPrint('❌ FeedProvider: Supabase client manquant');
        return;
      }
      
      _realtimeChannel = _supabase!
          .channel('public:posts')
          .onInsert((payload) {
            debugPrint('📬 [REALTIME] Nouvelle publication détectée!');
            _onPostInserted(payload.newRecord);
          })
          .onUpdate((payload) {
            debugPrint('📝 [REALTIME] Publication mise à jour');
            _onPostUpdated(payload.newRecord);
          })
          .onDelete((payload) {
            debugPrint('🗑️ [REALTIME] Publication supprimée');
            _onPostDeleted(payload.oldRecord);
          });
      
      _realtimeChannel!.subscribe((status, err) {
        if (err != null) {
          debugPrint('❌ FeedProvider Realtime error: $err');
        } else if (status == RealtimeSubscriptionStatus.subscribed) {
          debugPrint('✅ FeedProvider: Realtime connecté');
        }
      });
    } catch (e) {
      debugPrint('❌ FeedProvider _setupRealtimeListener error: $e');
    }
  }
  
  /// ✅ Configuration du polling automatique (refresh toutes les 5 secondes)
  void _setupAutoRefresh() {
    _autoRefreshTimer?.cancel();
    
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      // Ne recharger que si pas de chargement en cours
      if (!_isLoading) {
        await _autoRefresh();
      }
    });
    
    debugPrint('✅ FeedProvider: Auto-refresh activé (5s)');
  }
  
  /// ✅ Refresh automatique silencieux
  Future<void> _autoRefresh() async {
    try {
      final now = DateTime.now();
      if (_lastRefresh != null && 
          now.difference(_lastRefresh!).inSeconds < 3) {
        return; // Éviter les refresh trop fréquents
      }
      
      _lastRefresh = now;
      await loadFeed(feedType: _currentFeedType);
    } catch (e) {
      debugPrint('❌ FeedProvider _autoRefresh error: $e');
    }
  }
  
  /// ✅ Callback: Nouvelle publication insérée
  void _onPostInserted(dynamic newRecord) {
    try {
      final post = NetworkPost.fromJson(newRecord as Map<String, dynamic>);
      _posts.insert(0, post);
      notifyListeners();
      debugPrint('✅ FeedProvider: Post inséré en début de liste');
    } catch (e) {
      debugPrint('❌ FeedProvider _onPostInserted error: $e');
    }
  }
  
  /// ✅ Callback: Publication mise à jour
  void _onPostUpdated(dynamic updatedRecord) {
    try {
      final updated = NetworkPost.fromJson(updatedRecord as Map<String, dynamic>);
      final index = _posts.indexWhere((p) => p.id == updated.id);
      if (index != -1) {
        _posts[index] = updated;
        notifyListeners();
        debugPrint('✅ FeedProvider: Post ${updated.id} mis à jour');
      }
    } catch (e) {
      debugPrint('❌ FeedProvider _onPostUpdated error: $e');
    }
  }
  
  /// ✅ Callback: Publication supprimée
  void _onPostDeleted(dynamic deletedRecord) {
    try {
      final deleted = NetworkPost.fromJson(deletedRecord as Map<String, dynamic>);
      _posts.removeWhere((p) => p.id == deleted.id);
      notifyListeners();
      debugPrint('✅ FeedProvider: Post ${deleted.id} supprimé');
    } catch (e) {
      debugPrint('❌ FeedProvider _onPostDeleted error: $e');
    }
  }

  // ============================================================
  // CHARGEMENT DU FEED
  // ============================================================

  Future<void> loadFeed({String? feedType, int limit = 20}) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      if (feedType != null) _currentFeedType = feedType;
      
      late List<NetworkPost> newPosts;
      
      switch (_currentFeedType) {
        case 'smart':
          newPosts = await _networkService.getSmartFeed(limit: limit);
          break;
        case 'popular':
          final allPosts = await _networkService.getFeedPosts(limit: 50);
          allPosts.sort((a, b) => b.likesCount.compareTo(a.likesCount));
          newPosts = allPosts.take(limit).toList();
          break;
        default:
          newPosts = await _networkService.getFeedPosts(limit: limit);
      }
      
      _posts = newPosts;
      _hasMore = newPosts.length >= limit;
      _lastRefresh = DateTime.now();
      
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ FeedProvider loadFeed error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ============================================================
  // CRÉATION DE POST
  // ============================================================
  
  Future<bool> createPost(String content, List<String> images) async {
    try {
      debugPrint('📝 FeedProvider: création du post...');
      
      final postId = await _networkService.createPost(content, images);
      
      if (postId.isEmpty) {
        debugPrint('❌ FeedProvider: pas d\'ID retourné');
        return false;
      }
      
      debugPrint('✅ FeedProvider: post créé avec ID: $postId');
      
      // Recharger tout le feed
      await loadFeed(feedType: _currentFeedType);
      debugPrint('🔄 FeedProvider: feed rechargé, ${_posts.length} posts');
      
      return true;
    } catch (e) {
      debugPrint('❌ FeedProvider createPost error: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // ============================================================
  // INTERACTIONS (LIKE, COMMENTAIRE)
  // ============================================================
  
  // ⭐ CORRIGÉ - Version simplifiée sans utiliser les paramètres manquants
  Future<void> toggleLike(String postId) async {
    try {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index == -1) return;
      
      final post = _posts[index];
      
      if (post.isLikedByCurrentUser) {
        await _networkService.unlikePost(postId);
        _posts[index] = post.copyWith(
          likesCount: post.likesCount - 1,
          isLikedByCurrentUser: false,
        );
      } else {
        await _networkService.likePost(postId);
        _posts[index] = post.copyWith(
          likesCount: post.likesCount + 1,
          isLikedByCurrentUser: true,
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ FeedProvider toggleLike error: $e');
    }
  }
  
  Future<void> addComment(String postId, String comment) async {
    try {
      await _networkService.commentOnPost(postId, comment);
      
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = post.copyWith(
          commentsCount: post.commentsCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ FeedProvider addComment error: $e');
    }
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
