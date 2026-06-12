// lib/presentation/chat/group_admin/do_not_disturb_settings.dart
import 'package:flutter/material.dart';

class DoNotDisturbSettings extends StatefulWidget {
  final bool isEnabled;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final List<int> selectedDays;

  const DoNotDisturbSettings({
    super.key,
    required this.isEnabled,
    this.startTime,
    this.endTime,
    this.selectedDays = const [],
  });

  @override
  State<DoNotDisturbSettings> createState() => _DoNotDisturbSettingsState();
}

class _DoNotDisturbSettingsState extends State<DoNotDisturbSettings> {
  late bool _isEnabled;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late List<bool> _selectedDays;

  final List<String> _weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.isEnabled;
    _startTime = widget.startTime ?? const TimeOfDay(hour: 22, minute: 0);
    _endTime = widget.endTime ?? const TimeOfDay(hour: 8, minute: 0);
    _selectedDays = List.generate(7, (i) => widget.selectedDays.contains(i));
  }

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
          'Ne pas déranger',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Enregistrer',
              style: TextStyle(fontSize: 12, color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Activation
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Activer Ne pas déranger', style: TextStyle(fontSize: 13)),
              subtitle: const Text('Désactiver les notifications pendant la période définie', style: TextStyle(fontSize: 10)),
              value: _isEnabled,
              onChanged: (value) => setState(() => _isEnabled = value),
              activeColor: const Color(0xFFD4AF37),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          
          if (_isEnabled) ...[
            // Heure de début
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.bedtime, size: 20, color: Color(0xFFD4AF37)),
                title: const Text('Heure de début', style: TextStyle(fontSize: 13)),
                subtitle: Text(
                  _startTime.format(context),
                  style: const TextStyle(fontSize: 11, color: Color(0xFFD4AF37)),
                ),
                trailing: const Icon(Icons.chevron_right, size: 16),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                  );
                  if (time != null) setState(() => _startTime = time);
                },
              ),
            ),
            
            // Heure de fin
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.wb_sunny, size: 20, color: Color(0xFFD4AF37)),
                title: const Text('Heure de fin', style: TextStyle(fontSize: 13)),
                subtitle: Text(
                  _endTime.format(context),
                  style: const TextStyle(fontSize: 11, color: Color(0xFFD4AF37)),
                ),
                trailing: const Icon(Icons.chevron_right, size: 16),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime,
                  );
                  if (time != null) setState(() => _endTime = time);
                },
              ),
            ),
            
            // Jours de la semaine
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
                    'Répéter',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDays[index] = !_selectedDays[index];
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _selectedDays[index]
                                ? const Color(0xFFD4AF37)
                                : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _weekDays[index],
                              style: TextStyle(
                                fontSize: 12,
                                color: _selectedDays[index] ? Colors.white : Colors.grey,
                                fontWeight: _selectedDays[index] ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            
            // Exceptions
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, size: 20, color: Color(0xFFD4AF37)),
                title: const Text('Exceptions', style: TextStyle(fontSize: 13)),
                subtitle: const Text('Ajouter des exceptions spécifiques', style: TextStyle(fontSize: 10)),
                trailing: const Icon(Icons.chevron_right, size: 16),
                onTap: () => _showExceptionsDialog(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showExceptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exceptions', style: TextStyle(fontSize: 16)),
        content: const Text(
          'Ajouter des dates où Ne pas déranger ne s\'applique pas',
          style: TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
