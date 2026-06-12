// lib/presentation/chat/group_admin/group_info_page.dart
import 'package:flutter/material.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? groupAvatar;
  final String groupDescription;
  final int memberCount;
  final List<GroupMemberInfo> members;
  final String currentUserRole;

  const GroupInfoPage({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupAvatar,
    required this.groupDescription,
    required this.memberCount,
    required this.members,
    required this.currentUserRole,
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.currentUserRole == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Info groupe',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditDialog(),
            ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, size: 20),
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Partager le lien', style: TextStyle(fontSize: 13))),
              if (isAdmin)
                const PopupMenuItem(child: Text('Paramètres', style: TextStyle(fontSize: 13))),
              const PopupMenuItem(child: Text('Signaler', style: TextStyle(fontSize: 13))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: widget.groupAvatar != null
                      ? NetworkImage(widget.groupAvatar!)
                      : null,
                  child: widget.groupAvatar == null
                      ? const Icon(Icons.group, size: 50)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.groupName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.memberCount} membres',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (widget.groupDescription.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.groupDescription,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFD4AF37),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFD4AF37),
            tabs: const [
              Tab(text: 'Membres', icon: Icon(Icons.people, size: 18)),
              Tab(text: 'Médias', icon: Icon(Icons.image, size: 18)),
            ],
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMembersTab(),
                _buildMediaTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddMembersSheet(),
              backgroundColor: const Color(0xFFD4AF37),
              child: const Icon(Icons.add, size: 20, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildMembersTab() {
    final admins = widget.members.where((m) => m.role == 'admin').toList();
    final moderators = widget.members.where((m) => m.role == 'moderator').toList();
    final members = widget.members.where((m) => m.role == 'member').toList();

    return ListView(
      children: [
        if (admins.isNotEmpty) ...[
          _buildSectionHeader('Admins ${admins.length}'),
          ...admins.map((m) => _buildMemberTile(m)),
        ],
        if (moderators.isNotEmpty) ...[
          _buildSectionHeader('Modérateurs ${moderators.length}'),
          ...moderators.map((m) => _buildMemberTile(m)),
        ],
        if (members.isNotEmpty) ...[
          _buildSectionHeader('Membres ${members.length}'),
          ...members.map((m) => _buildMemberTile(m)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
      ),
    );
  }

  Widget _buildMemberTile(GroupMemberInfo member) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                if (member.title != null)
                  Text(
                    member.title!,
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
              ],
            ),
          ),
          if (member.role == 'admin')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Admin',
                style: TextStyle(fontSize: 8, color: Color(0xFFD4AF37)),
              ),
            ),
          if (member.role == 'moderator')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Modo',
                style: TextStyle(fontSize: 8, color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.image, size: 24, color: Colors.grey),
        ),
      ),
    );
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: widget.groupName);
    final descController = TextEditingController(text: widget.groupDescription);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le groupe', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Nom du groupe'),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: 'Description'),
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('Enregistrer', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showAddMembersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMembersSheet(
        groupId: widget.groupId,
        currentMemberIds: widget.members.map((m) => m.id).toList(),
        onAdd: (userIds) {
          // Ajouter les membres
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${userIds.length} membres ajoutés')),
          );
        },
      ),
    );
  }
}

class GroupMemberInfo {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? title;
  final String role;

  GroupMemberInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.title,
    required this.role,
  });
}
