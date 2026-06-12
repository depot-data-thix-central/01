// lib/presentation/network/network_pro_home.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/models/network_post.dart';
import 'package:thix_id/providers/feed_provider.dart';
import 'widgets/create_post_dialog.dart';

class NetworkProHome extends StatefulWidget {
  const NetworkProHome({super.key});

  @override
  State<NetworkProHome> createState() => _NetworkProHomeState();
}

class _NetworkProHomeState extends State<NetworkProHome> with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  bool _loadingPosts = true;
  bool _isRefreshing = false;
  String _feedType = 'smart';
  int _selectedNavIndex = 0;
  final Map<String, AnimationController> _likeAnimations = {};

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
      // ✅ CORRIGÉ: Initialiser le realtime listening du FeedProvider
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      feedProvider.initRealtime();
    });

    _setupRealtimeSubscriptions();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    for (var controller in _likeAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// ✅ CORRIGÉ: Listener realtime Supabase pour les changements de publications
  void _setupRealtimeSubscriptions() {
    try {
      final supabase = Supabase.instance.client;
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);

      supabase.channel('public:posts')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'posts',
            callback: (payload) async {
              debugPrint('📬 [REALTIME] Nouvelle publication détectée en BDD!');
              if (mounted) {
                // Recharger le feed pour intégrer la nouvelle publication
                await feedProvider.loadFeed(feedType: _feedType);
                setState(() {});
              }
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'posts',
            callback: (payload) async {
              debugPrint('📝 [REALTIME] Publication mise à jour');
              if (mounted) {
                await feedProvider.loadFeed(feedType: _feedType);
                setState(() {});
              }
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'posts',
            callback: (payload) async {
              debugPrint('🗑️ [REALTIME] Publication supprimée');
              if (mounted) {
                await feedProvider.loadFeed(feedType: _feedType);
                setState(() {});
              }
            },
          )
          .subscribe((status, err) {
            if (err != null) {
              debugPrint('❌ Erreur Realtime: $err');
            } else if (status == RealtimeSubscriptionStatus.subscribed) {
              debugPrint('✅ Realtime connecté au feed');
            }
          });
    } catch (e) {
      debugPrint('❌ Erreur setup realtime: $e');
    }
  }

  Future<void> _loadAllData() async {
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    await feedProvider.loadFeed(feedType: _feedType);
    setState(() => _loadingPosts = false);
  }

  Future<void> _loadPosts() async {
    if (!mounted) return;
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    setState(() => _loadingPosts = true);

    try {
      await feedProvider.loadFeed(feedType: _feedType);
      if (mounted) setState(() => _loadingPosts = false);
    } catch (e) {
      debugPrint('❌ Erreur _loadPosts: $e');
      if (mounted) setState(() => _loadingPosts = false);
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    await feedProvider.loadFeed(feedType: _feedType);

    if (mounted) setState(() => _isRefreshing = false);
  }

  void _goToSearch() => context.push('/network/search');
  void _goToNotifications() => context.push('/network/notifications');
  void _goToMessages() => context.push('/network/messages');
  void _goToConnexions() => context.push('/network/connections');
  void _goToProfile() => context.push('/profile');

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    final posts = feedProvider.posts;
    final isLoading = feedProvider.isLoading;
    final auth = Provider.of<AuthController>(context);

    if (auth.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Connectez-vous pour accéder au Réseau Pro'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // Section Filtres
            SliverToBoxAdapter(
              child: _buildFilterChips(),
            ),
            // Section Posts
            if (isLoading)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (posts.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPostCard(posts[index]),
                  childCount: posts.length,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text('Réseau Pro', style: TextStyle(color: Color(0xFF0B1B3D), fontWeight: FontWeight.bold)),
      actions: [
        IconButton(icon: const Icon(Icons.search, color: Color(0xFF0B1B3D)), onPressed: _goToSearch),
        IconButton(icon: const Icon(Icons.notifications_none, color: Color(0xFF0B1B3D)), onPressed: _goToNotifications),
        IconButton(icon: const Icon(Icons.mail_outline, color: Color(0xFF0B1B3D)), onPressed: _goToMessages),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'icon': Icons.smart_toy_outlined, 'label': 'Smart Feed', 'value': 'smart'},
      {'icon': Icons.trending_up, 'label': 'Populaires', 'value': 'popular'},
    ];
    
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _feedType == filter['value'];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(filter['icon'] as IconData, size: 14, color: isSelected ? const Color(0xFFD4AF37) : Colors.white70),
                  const SizedBox(width: 4),
                  Text(filter['label'] as String, style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFFD4AF37) : Colors.white70)),
                ],
              ),
              onSelected: (selected) {
                setState(() => _feedType = filter['value'] as String);
                _loadPosts();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(NetworkPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Post
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(post.authorAvatar ?? ''), radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(post.authorTitle ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                PopupMenuButton(itemBuilder: (context) => []),
              ],
            ),
            const SizedBox(height: 12),
            // Contenu
            if (post.content != null) Text(post.content!),
            if (post.mediaUrl != null) ...[
              const SizedBox(height: 8),
              Image.network(post.mediaUrl!, height: 200, fit: BoxFit.cover),
            ],
            const SizedBox(height: 12),
            // Engagement Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${post.likesCount} J\'aime', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('${post.commentsCount} Commentaires', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('${post.sharesCount ?? 0} Partages', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const Divider(),
            // Boutons d'actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Provider.of<FeedProvider>(context, listen: false).toggleLike(post.id);
                  },
                  child: Icon(post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border, color: post.isLikedByCurrentUser ? Colors.red : Colors.grey[600]),
                ),
                GestureDetector(
                  onTap: () {
                    _showCommentDialog(post);
                  },
                  child: Icon(Icons.comment_outlined, color: Colors.grey[600]),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.bookmark_border, size: 18, color: Colors.grey[600]),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Icon(Icons.share_outlined, size: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentDialog(NetworkPost post) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un commentaire'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Écrivez votre commentaire...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final feedProvider = Provider.of<FeedProvider>(context, listen: false);
                await feedProvider.addComment(post.id, controller.text.trim());
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Publier'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const CreatePostDialog(),
        ).then((_) => _loadPosts());
      },
      label: const Text('Publier'),
      icon: const Icon(Icons.edit),
      backgroundColor: const Color(0xFFD4AF37),
      foregroundColor: const Color(0xFF0B1B3D),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) {
        setState(() => _selectedNavIndex = index);
        switch (index) {
          case 0:
            break;
          case 1:
            _goToSearch();
            break;
          case 2:
            _goToConnexions();
            break;
          case 3:
            _goToProfile();
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Connexions'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
              child: const Icon(Icons.post_add, size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text('Aucune publication', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
            const SizedBox(height: 8),
            const Text('Soyez le premier à publier!', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
