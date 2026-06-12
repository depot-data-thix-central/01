// lib/presentation/chat/home_widgets/recent_conversation_widget.dart
// Widget iOS/Android pour afficher la dernière conversation
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class RecentConversationWidget {
  static const String widgetName = 'recent_conversation';
  
  static Future<void> update(String conversationId, String name, String lastMessage) async {
    await HomeWidget.saveWidgetData<String>('conversation_id', conversationId);
    await HomeWidget.saveWidgetData<String>('name', name);
    await HomeWidget.saveWidgetData<String>('last_message', lastMessage);
    await HomeWidget.updateWidget(name: widgetName);
  }
  
  static Widget buildPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            child: Icon(Icons.person, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aminata Diallo',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dernier message...',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFFD4AF37)),
        ],
      ),
    );
  }
}
