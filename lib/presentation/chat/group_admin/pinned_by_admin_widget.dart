// lib/presentation/chat/group_admin/pinned_by_admin_widget.dart
import 'package:flutter/material.dart';

class PinnedByAdminWidget extends StatelessWidget {
  final String message;
  final String adminName;
  final DateTime pinnedAt;
  final VoidCallback onTap;
  final VoidCallback onUnpin;

  const PinnedByAdminWidget({
    super.key,
    required this.message,
    required this.adminName,
    required this.pinnedAt,
    required this.onTap,
    required this.onUnpin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: Color(0xFFD4AF37), width: 3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.push_pin, size: 14, color: Color(0xFFD4AF37)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Épinglé par l\'admin',
                        style: TextStyle(fontSize: 9, color: Color(0xFFD4AF37)),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        adminName,
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(pinnedAt),
                        style: const TextStyle(fontSize: 8, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onUnpin,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays >= 1) return 'il y a ${diff.inDays}j';
    if (diff.inHours >= 1) return 'il y a ${diff.inHours}h';
    if (diff.inMinutes >= 1) return 'il y a ${diff.inMinutes}min';
    return 'maintenant';
  }
}
