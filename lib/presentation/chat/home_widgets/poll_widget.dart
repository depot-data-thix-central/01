// lib/presentation/chat/home_widgets/poll_widget.dart
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class PollWidget {
  static const String widgetName = 'chat_poll';
  
  static Future<void> update(String question, List<String> options, int totalVotes) async {
    await HomeWidget.saveWidgetData<String>('poll_question', question);
    await HomeWidget.saveWidgetData<List<String>>('poll_options', options);
    await HomeWidget.saveWidgetData<int>('poll_total_votes', totalVotes);
    await HomeWidget.updateWidget(name: widgetName);
  }
  
  static Widget buildPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sondage en cours',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          const Text(
            'Quel est votre avis ?',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _pollOption('Option 1', 65),
          const SizedBox(height: 4),
          _pollOption('Option 2', 35),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '12 votes',
                style: TextStyle(fontSize: 9, color: Colors.grey),
              ),
              const Text(
                'Voter',
                style: TextStyle(fontSize: 9, color: Color(0xFFD4AF37)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  static Widget _pollOption(String label, int percentage) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 10)),
            ),
            Text('$percentage%', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          color: const Color(0xFFD4AF37),
          minHeight: 3,
        ),
      ],
    );
  }
}
