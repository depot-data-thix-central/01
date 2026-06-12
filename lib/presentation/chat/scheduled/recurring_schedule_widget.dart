// lib/presentation/chat/scheduled/recurring_schedule_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecurringScheduleWidget extends StatefulWidget {
  final Function(DateTime, String) onSchedule;
  final VoidCallback onCancel;

  const RecurringScheduleWidget({
    super.key,
    required this.onSchedule,
    required this.onCancel,
  });

  @override
  State<RecurringScheduleWidget> createState() => _RecurringScheduleWidgetState();
}

class _RecurringScheduleWidgetState extends State<RecurringScheduleWidget> {
  final TextEditingController _messageController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedPattern = 'daily';
  List<int> _selectedWeekDays = [1]; // Lundi par défaut
  int _selectedMonthDay = 1;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, dynamic>> _patterns = [
    {'label': 'Quotidien', 'value': 'daily', 'icon': Icons.today},
    {'label': 'Hebdomadaire', 'value': 'weekly', 'icon': Icons.weekend},
    {'label': 'Mensuel', 'value': 'monthly', 'icon': Icons.calendar_month},
  ];

  final List<String> _weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null && mounted) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date != null && mounted) {
      setState(() => _endDate = date);
    }
  }

  void _schedule() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un message')),
      );
      return;
    }

    final firstSchedule = DateTime(
      (_startDate ?? DateTime.now()).year,
      (_startDate ?? DateTime.now()).month,
      (_startDate ?? DateTime.now()).day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    widget.onSchedule(firstSchedule, _selectedPattern);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répéter le message',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Message
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Message à répéter...',
              hintStyle: const TextStyle(fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          // Motif
          const Text('Fréquence', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _patterns.map((pattern) {
              final isSelected = _selectedPattern == pattern['value'];
              return FilterChip(
                label: Text(pattern['label'], style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedPattern = pattern['value']),
                avatar: Icon(pattern['icon'], size: 14),
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFFD4AF37).withOpacity(0.15),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Heure
          GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('À ${_selectedTime.format(context)}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Jours (si hebdomadaire)
          if (_selectedPattern == 'weekly') ...[
            const Text('Jours de la semaine', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(_weekDays.length, (index) {
                final isSelected = _selectedWeekDays.contains(index);
                return FilterChip(
                  label: Text(_weekDays[index], style: const TextStyle(fontSize: 11)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedWeekDays.add(index);
                      } else {
                        _selectedWeekDays.remove(index);
                      }
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFFD4AF37).withOpacity(0.15),
                );
              }),
            ),
          ],
          // Jour du mois (si mensuel)
          if (_selectedPattern == 'monthly') ...[
            const Text('Jour du mois', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonthDay,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: List.generate(28, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}', style: const TextStyle(fontSize: 12)))),
                    onChanged: (value) => setState(() => _selectedMonthDay = value ?? 1),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Période
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _selectStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _startDate != null
                              ? DateFormat('dd/MM/yy').format(_startDate!)
                              : 'Début',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _selectEndDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stop, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _endDate != null
                              ? DateFormat('dd/MM/yy').format(_endDate!)
                              : 'Fin',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Annuler', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _schedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0B1B3D),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Programmer', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
