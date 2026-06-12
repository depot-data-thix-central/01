// lib/presentation/chat/read_receipts/read_by_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/read_receipt_models.dart';

class ReadByList extends StatelessWidget {
  final List<ReadReceiptUser> users;
  final String type; // 'delivered' or 'read'

  const ReadByList({
    super.key,
    required this.users,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'delivered' ? Icons.done_all : Icons.remove_red_eye,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text(
              type == 'delivered'
                  ? 'Message non encore livré'
                  : 'Personne n\'a encore lu ce message',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            _formatTime(user.date),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          trailing: Icon(
            type == 'delivered' ? Icons.done : Icons.remove_red_eye,
            size: 16,
            color: type == 'delivered' ? Colors.orange : Colors.green,
          ),
        );
      },
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return DateFormat('HH:mm').format(date);
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
