// lib/presentation/chat/chat_spaces_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/chat_provider.dart';

class ChatSpacesPage extends StatefulWidget {
  const ChatSpacesPage({super.key});

  @override
  State<ChatSpacesPage> createState() => _ChatSpacesPageState();
}

class _ChatSpacesPageState extends State<ChatSpacesPage> with AutomaticKeepAliveClientMixin {
  int _selectedNavIndex = 2; // Spaces sélectionné

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  void _loadSpaces() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.loadSpaces();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final chatProvider = Provider.of<ChatProvider>(context);
    final spaces = chatProvider.spaces;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: spaces.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: spaces.length,
              itemBuilder: (context, index) => _buildSpaceTile(spaces[index]),
            ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createSpace(),
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(Icons.add, size: 20, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Spaces',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B1B3D)),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, size: 20, color: Color(0xFF0B1B3D)),
          onPressed: () => _searchSpaces(),
        ),
      ],
    );
  }

  Widget _buildSpaceTile(Space space) {
    return GestureDetector(
      onTap: () => _openSpace(space),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: space.avatarUrl != null ? NetworkImage(space.avatarUrl!) : null,
              child: space.avatarUrl == null ? const Icon(Icons.grid_view, size: 24) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(space.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('${space.memberCount} membres', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: space.unreadCount > 0 ? const Color(0xFFD4AF37) : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                space.unreadCount.toString(),
                style: TextStyle(fontSize: 10, color: space.unreadCount > 0 ? Colors.white : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_view, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Aucun espace', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text('Créez un espace pour collaborer en équipe', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _createSpace,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('Créer un espace', style: TextStyle(fontSize: 12)),
          ),
        ],
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
        onTap: (index) {
          HapticFeedback.lightImpact();
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/chat'); break;
            case 2: break;
            case 3: context.push('/chat/status'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 20), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline, size: 20), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view, size: 20), label: 'Spaces'),
          BottomNavigationBarItem(icon: Icon(Icons.circle, size: 20), label: 'Statut'),
        ],
      ),
    );
  }

  void _createSpace() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un espace', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Nom de l\'espace', hintStyle: TextStyle(fontSize: 12)),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(hintText: 'Description (optionnel)', hintStyle: TextStyle(fontSize: 12)),
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(fontSize: 12))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('Créer', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _openSpace(Space space) {
    context.push('/chat/space/${space.id}', extra: space);
  }

  void _searchSpaces() {
    showSearch(
      context: context,
      delegate: SpaceSearchDelegate(),
    );
  }
}

class SpaceSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Rechercher un espace...';
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: () => query = '')];
  }
  
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back, size: 20), onPressed: () => close(context, null));
  }
  
  @override
  Widget buildResults(BuildContext context) {
    return _buildResults();
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResults();
  }
  
  Widget _buildResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_view, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Aucun résultat pour "$query"', style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}
