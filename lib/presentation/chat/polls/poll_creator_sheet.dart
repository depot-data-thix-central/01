// lib/presentation/chat/polls/poll_creator_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/poll_provider.dart';

class PollCreatorSheet extends StatefulWidget {
  final String conversationId;

  const PollCreatorSheet({
    super.key,
    required this.conversationId,
  });

  @override
  State<PollCreatorSheet> createState() => _PollCreatorSheetState();
}

class _PollCreatorSheetState extends State<PollCreatorSheet> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isAnonymous = false;
  bool _isMultiple = false;
  DateTime? _expirationDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers.removeAt(index);
      });
    }
  }

  Future<void> _selectExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _expirationDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _createPoll() async {
    final question = _questionController.text.trim();
    final options = _optionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une question')),
      );
      return;
    }

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins 2 options')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final pollProvider = Provider.of<PollProvider>(context, listen: false);
    final success = await pollProvider.createPoll(
      conversationId: widget.conversationId,
      question: question,
      options: options,
      isAnonymous: _isAnonymous,
      isMultiple: _isMultiple,
      expiresAt: _expirationDate,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sondage créé avec succès')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Créer un sondage',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Question
          TextField(
            controller: _questionController,
            decoration: InputDecoration(
              hintText: 'Votre question...',
              hintStyle: const TextStyle(fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          // Options
          const Text(
            'Options',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ..._optionControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Option ${index + 1}',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (_optionControllers.length > 2)
                    IconButton(
                      icon: const Icon(Icons.remove_circle, size: 18, color: Colors.red),
                      onPressed: () => _removeOption(index),
                    ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: _addOption,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Ajouter une option', style: TextStyle(fontSize: 11)),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFD4AF37)),
          ),
          const SizedBox(height: 16),
          // Options avancées
          SwitchListTile(
            title: const Text('Votes anonymes', style: TextStyle(fontSize: 12)),
            value: _isAnonymous,
            onChanged: (value) => setState(() => _isAnonymous = value),
            activeColor: const Color(0xFFD4AF37),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Votes multiples', style: TextStyle(fontSize: 12)),
            value: _isMultiple,
            onChanged: (value) => setState(() => _isMultiple = value),
            activeColor: const Color(0xFFD4AF37),
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            title: const Text('Date d\'expiration', style: TextStyle(fontSize: 12)),
            subtitle: _expirationDate != null
                ? Text(_formatDate(_expirationDate!), style: const TextStyle(fontSize: 10))
                : const Text('Optionnel', style: TextStyle(fontSize: 10)),
            trailing: const Icon(Icons.calendar_today, size: 16),
            onTap: _selectExpirationDate,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _createPoll,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B1B3D),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Créer', style: TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
