// lib/presentation/chat/thix_chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/chat_provider.dart';
import '../../providers/auth_controller.dart';
import 'chat_conversation_page.dart';
import 'chat_status_page.dart';
import 'chat_spaces_page.dart';
import 'chat_call_page.dart';

class ThixChatPage extends StatefulWidget {
  const ThixChatPage({super.key});

  @override
  State<ThixChatPage> createState() => _ThixChatPageState();
}

class _ThixChatPageState extends State<ThixChatPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int _selectedNavIndex = 1; // Chats est sélectionné par défaut
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
    _setupRealtime();
  }

  void _loadData() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadConversations();
    await chatProvider.loadStats();
    await chatProvider.loadStories();
  }

  void _setupRealtime() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.initRealtime();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _selectedNavIndex = index);
    HapticFeedback.lightImpact();
    
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        // Déjà sur chat
        break;
      case 2:
        context.push('/chat/spaces');
        break;
      case 3:
        context.push('/chat/status');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final chatProvider = Provider.of<ChatProvider>(context);
    final auth = Provider.of<AuthController>(context);
    
    if (auth.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Connectez-vous pour accéder au chat', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                child: const Text('Se connecter', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsRow(chatProvider.stats),
          _buildStoriesRow(chatProvider.stories),
          _buildFilters(),
          Expanded(child: _buildConversationsList(chatProvider)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'THIX CHAT',
        style: TextStyle(
          color: Color(0xFF0B1B3D),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add_alt_rounded, size: 20, color: Color(0xFF0B1B3D)),
          onPressed: () => _showNewChatDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF0B1B3D)),
          onPressed: () => _showMenu(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
        ),
        child: TextField(
          controller: _searchController,
          onTap: () {
            setState(() => _isSearching = true);
          },
          onSubmitted: (value) => _searchChats(value),
          decoration: InputDecoration(
            hintText: 'Rechercher un chat, contact, groupe...',
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey[500]),
            suffixIcon: _isSearching
                ? IconButton(
                    icon: Icon(Icons.close, size: 14, color: Colors.grey[500]),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _isSearching = false;
                      });
                      _loadData();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(ChatStats stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(count: stats.onlineCount.toString(), label: 'En ligne', icon: Icons.circle, color: Colors.green, size: 8),
          _StatItem(count: stats.newMessagesCount.toString(), label: 'Nouveaux messages', icon: Icons.mark_email_unread, color: const Color(0xFFD4AF37), size: 12),
          _StatItem(count: stats.activeCallsCount.toString(), label: 'Réunions actives', icon: Icons.videocam, color: Colors.blue, size: 12),
          _StatItem(count: stats.securityAlertsCount.toString(), label: 'Alertes sécurité', icon: Icons.warning, color: Colors.red, size: 12),
        ],
      ),
    );
  }

  Widget _buildStoriesRow(List<Story> stories) {
    if (stories.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('En ligne', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
              GestureDetector(
                onTap: () => context.push('/chat/stories'),
                child: Text('Voir tout', style: TextStyle(fontSize: 10, color: const Color(0xFFD4AF37))),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stories.length,
            itemBuilder: (context, index) => _buildStoryItem(stories[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryItem(Story story) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: story.isViewed
                      ? null
                      : const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFAA7C11)]),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: story.userAvatar != null ? NetworkImage(story.userAvatar!) : null,
                    child: story.userAvatar == null ? const Icon(Icons.person, size: 20) : null,
                  ),
                ),
              ),
              if (story.type == 'video')
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            story.userName.length > 8 ? '${story.userName.substring(0, 8)}...' : story.userName,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _tabController.index == index;
          return GestureDetector(
            onTap: () {
              _tabController.animateTo(index);
              if (filter['value'] != null) {
                Provider.of<ChatProvider>(context, listen: false).filterConversations(filter['value']);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(filter['icon'] as IconData, size: 12, color: isSelected ? Colors.white : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    filter['name'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationsList(ChatProvider chatProvider) {
    final conversations = chatProvider.filteredConversations;
    
    if (chatProvider.isLoading && conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('Aucune conversation', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showNewChatDialog(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              child: const Text('Nouveau message', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) => _buildConversationTile(conversations[index]),
    );
  }

  Widget _buildConversationTile(Conversation conv) {
    return GestureDetector(
      onTap: () {
        context.push('/chat/conversation/${conv.id}', extra: conv);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: conv.avatarUrl != null ? NetworkImage(conv.avatarUrl!) : null,
                  child: conv.avatarUrl == null ? const Icon(Icons.person, size: 24) : null,
                ),
                if (conv.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(conv.lastMessageTime, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (conv.type == 'group')
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.group, size: 10, color: Colors.grey),
                        ),
                      Expanded(
                        child: Text(
                          conv.lastMessage,
                          style: TextStyle(
                            fontSize: 11,
                            color: conv.unreadCount > 0 ? Colors.black : Colors.grey,
                            fontWeight: conv.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conv.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            '${conv.unreadCount}',
                            style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        currentIndex: _selectedNavIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 20), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline, size: 20), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view, size: 20), label: 'Spaces'),
          BottomNavigationBarItem(icon: Icon(Icons.circle, size: 20), label: 'Statut'),
        ],
      ),
    );
  }

  void _showNewChatDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Nouvelle conversation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nom, email ou numéro',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(Icons.search, size: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), minimumSize: const Size(double.infinity, 40)),
              child: const Text('Commencer', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            _menuItem(Icons.qr_code_scanner, 'Scanner un QR code'),
            _menuItem(Icons.group_add, 'Créer un groupe'),
            _menuItem(Icons.call, 'Appel vocal'),
            _menuItem(Icons.videocam, 'Appel vidéo'),
            _menuItem(Icons.settings, 'Paramètres du chat'),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontSize: 13)),
      onTap: () => Navigator.pop(context),
    );
  }

  Future<void> _searchChats(String query) async {
    if (query.isEmpty) {
      _loadData();
      return;
    }
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.searchConversations(query);
  }

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Tous', 'icon': Icons.forum, 'value': null},
    {'name': 'Équipes', 'icon': Icons.group, 'value': 'group'},
    {'name': 'Appels', 'icon': Icons.call, 'value': 'call'},
    {'name': 'Favoris', 'icon': Icons.star, 'value': 'favorite'},
    {'name': 'Rendez-vous', 'icon': Icons.calendar_today, 'value': 'meeting'},
  ];
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;
  final Color color;
  final double size;

  const _StatItem({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: size, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(count, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }
}
