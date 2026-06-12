// lib/presentation/chat/read_receipts/message_info_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/read_receipt_provider.dart';
import 'read_receipts_view.dart';

class MessageInfoPage extends StatefulWidget {
  final String messageId;
  final String messageContent;
  final DateTime sentAt;
  final bool isPriority;

  const MessageInfoPage({
    super.key,
    required this.messageId,
    required this.messageContent,
    required this.sentAt,
    this.isPriority = false,
  });

  @override
  State<MessageInfoPage> createState() => _MessageInfoPageState();
}

class _MessageInfoPageState extends State<MessageInfoPage> {
  @override
  Widget build(BuildContext context) {
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
          'Info message',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          // Message
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Message',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.messageContent,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy à HH:mm').format(widget.sentAt),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Statut prioritaire
          if (widget.isPriority)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.priority_high, size: 16, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Message prioritaire',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Accusé de lecture forcé • Notification spéciale',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Lectures
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.done_all, size: 20, color: Colors.green),
                  title: const Text('Lu par', style: TextStyle(fontSize: 13)),
                  trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  onTap: () => _showReadReceipts(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.done, size: 20, color: Colors.orange),
                  title: const Text('Livré à', style: TextStyle(fontSize: 13)),
                  trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  onTap: () => _showReadReceipts(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReadReceipts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, __) => ReadReceiptsView(
          messageId: widget.messageId,
          messageContent: widget.messageContent,
        ),
      ),
    );
  }
}
