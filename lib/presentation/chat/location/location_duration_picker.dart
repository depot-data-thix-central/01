// lib/presentation/chat/location/location_duration_picker.dart
import 'package:flutter/material.dart';

class LocationDurationPicker extends StatefulWidget {
  final int selectedDuration;
  final Function(int) onDurationChanged;

  const LocationDurationPicker({
    super.key,
    required this.selectedDuration,
    required this.onDurationChanged,
  });

  @override
  State<LocationDurationPicker> createState() => _LocationDurationPickerState();
}

class _LocationDurationPickerState extends State<LocationDurationPicker> {
  final List<Map<String, dynamic>> _durations = [
    {'label': '15 min', 'value': 15},
    {'label': '30 min', 'value': 30},
    {'label': '1 heure', 'value': 60},
    {'label': '2 heures', 'value': 120},
    {'label': '6 heures', 'value': 360},
    {'label': 'Jusqu\'à annulation', 'value': -1},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durée de partage',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _durations.map((duration) {
            final isSelected = duration['value'] == widget.selectedDuration;
            return GestureDetector(
              onTap: () => widget.onDurationChanged(duration['value']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  duration['label'],
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
