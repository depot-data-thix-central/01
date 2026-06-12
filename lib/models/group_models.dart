// lib/models/group_models.dart
class Group {
  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final int memberCount;
  final String role; // 'admin', 'moderator', 'member'
  final bool isMuted;

  Group({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.memberCount,
    required this.role,
    this.isMuted = false,
  });
}

class GroupMember {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? title;
  final String role; // 'admin', 'moderator', 'member'
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
