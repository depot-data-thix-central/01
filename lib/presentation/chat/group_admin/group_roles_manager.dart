// lib/presentation/chat/group_admin/group_roles_manager.dart
import 'package:flutter/material.dart';

class GroupRolesManager extends StatefulWidget {
  final String groupId;
  final String currentUserRole;
  final List<GroupMember> members;

  const GroupRolesManager({
    super.key,
    required this.groupId,
    required this.currentUserRole,
    required this.members,
  });

  @override
  State<GroupRolesManager> createState() => _GroupRolesManagerState();
}

class _GroupRolesManagerState extends State<GroupRolesManager> {
  late List<GroupMember> _members;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _roles = [
    {'name': 'Admin', 'value': 'admin', 'color': Color(0xFFD4AF37), 'icon': Icons.star},
    {'name': 'Modérateur', 'value': 'moderator', 'color': Colors.blue, 'icon': Icons.shield},
    {'name': 'Membre', 'value': 'member', 'color': Colors.grey, 'icon': Icons.person},
  ];

  @override
  void initState() {
    super.initState();
    _members = List.from(widget.members);
  }

  void _changeRole(String userId, String newRole) {
    setState(() {
      final index = _members.indexWhere((m) => m.id == userId);
      if (index != -1) {
        _members[index] = _members[index].copyWith(role: newRole);
      }
    });
  }

  void _removeMember(String userId) {
    setState(() {
      _members.removeWhere((m) => m.id == userId);
    });
  }

  List<GroupMember> get _filteredMembers {
    if (_searchQuery.isEmpty) return _members;
    return _members.where((m) =>
      m.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.currentUserRole == 'admin';
    final isModerator = widget.currentUserRole == 'moderator';

    if (!isAdmin && !isModerator) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Vous n\'avez pas les permissions nécessaires',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Seuls les admins et modérateurs peuvent gérer les rôles',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(18),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un membre...',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(Icons.search, size: 16),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
        
        // Roles legend
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: _roles.map((role) {
              return Expanded(
                child: Row(
                  children: [
                    Icon(role['icon'], size: 12, color: role['color']),
                    const SizedBox(width: 4),
                    Text(
                      role['name'],
                      style: TextStyle(fontSize: 9, color: role['color']),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Members list
        Expanded(
          child: ListView.builder(
            itemCount: _filteredMembers.length,
            itemBuilder: (context, index) {
              final member = _filteredMembers[index];
              final isSelf = member.isSelf;
              final canEdit = isAdmin || (isModerator && member.role != 'admin');
              
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
                          Row(
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (member.role == 'admin')
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
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
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
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
                          if (member.title != null)
                            Text(
                              member.title!,
                              style: const TextStyle(fontSize: 9, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                    if (canEdit && !isSelf)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 16),
                        onSelected: (value) {
                          if (value == 'remove') {
                            _removeMember(member.id);
                          } else {
                            _changeRole(member.id, value);
                          }
                        },
                        itemBuilder: (context) => [
                          if (member.role != 'admin')
                            const PopupMenuItem(
                              value: 'admin',
                              child: Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: Color(0xFFD4AF37)),
                                  SizedBox(width: 8),
                                  Text('Nommer admin', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          if (member.role != 'moderator' && member.role != 'admin')
                            const PopupMenuItem(
                              value: 'moderator',
                              child: Row(
                                children: [
                                  Icon(Icons.shield, size: 14, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Nommer modérateur', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          if (member.role != 'member')
                            const PopupMenuItem(
                              value: 'member',
                              child: Row(
                                children: [
                                  Icon(Icons.person, size: 14, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text('Rétrograder membre', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(Icons.remove_circle, size: 14, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Retirer du groupe', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class GroupMember {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? title;
  final String role;
  final bool isSelf;

  GroupMember({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.title,
    required this.role,
    this.isSelf = false,
  });

  GroupMember copyWith({String? role}) {
    return GroupMember(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      title: title,
      role: role ?? this.role,
      isSelf: isSelf,
    );
  }
}
