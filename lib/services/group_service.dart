// lib/services/group_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/group_models.dart';

class GroupService {
  final SupabaseClient _supabase;

  GroupService(this._supabase);

  String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  Future<List<Group>> getGroups() async {
    try {
      final response = await _supabase
          .from('groups')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List).map((e) => Group(
        id: e['id'],
        name: e['name'],
        description: e['description'],
        avatarUrl: e['avatar_url'],
        memberCount: e['member_count'] ?? 1,
        role: e['user_role'] ?? 'member',
      )).toList();
    } catch (e) {
      debugPrint('Error getting groups: $e');
      return [];
    }
  }

  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    try {
      final response = await _supabase
          .from('group_members')
          .select('*, users:user_id(display_name, photo_url, profession)')
          .eq('group_id', groupId);

      return (response as List).map((e) {
        final userData = e['users'] as Map<String, dynamic>?;
        return GroupMember(
          id: e['user_id'],
          name: userData?['display_name'] ?? 'Utilisateur',
          avatarUrl: userData?['photo_url'],
          title: userData?['profession'],
          role: e['role'] ?? 'member',
          isSelf: e['user_id'] == currentUserId,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting group members: $e');
      return [];
    }
  }

  Future<Group> createGroup(String name, String? avatarUrl) async {
    final response = await _supabase.from('groups').insert({
      'name': name,
      'avatar_url': avatarUrl,
      'created_by': currentUserId,
      'member_count': 1,
    }).select().single();

    await _supabase.from('group_members').insert({
      'group_id': response['id'],
      'user_id': currentUserId,
      'role': 'admin',
    });

    return Group(
      id: response['id'],
      name: response['name'],
      avatarUrl: response['avatar_url'],
      memberCount: 1,
      role: 'admin',
    );
  }

  Future<void> updateRole(String groupId, String userId, String role) async {
    await _supabase
        .from('group_members')
        .update({'role': role})
        .eq('group_id', groupId)
        .eq('user_id', userId);
  }

  Future<void> removeMember(String groupId, String userId) async {
    await _supabase
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', userId);
  }

  Future<void> addMembers(String groupId, List<String> userIds) async {
    for (var userId in userIds) {
      await _supabase.from('group_members').insert({
        'group_id': groupId,
        'user_id': userId,
        'role': 'member',
      });
    }
    await _supabase
        .from('groups')
        .update({'member_count': userIds.length + (await getGroupMembers(groupId)).length})
        .eq('id', groupId);
  }

  Future<void> updateSettings(String groupId, Map<String, dynamic> settings) async {
    await _supabase
        .from('groups')
        .update(settings)
        .eq('id', groupId);
  }

  Future<void> leaveGroup(String groupId) async {
    await _supabase
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', currentUserId);
  }

  Future<void> deleteGroup(String groupId) async {
    await _supabase.from('groups').delete().eq('id', groupId);
  }
}
