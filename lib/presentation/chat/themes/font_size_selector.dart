// lib/presentation/chat/themes/font_size_selector.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeSelector extends StatefulWidget {
  const FontSizeSelector({super.key});

  @override
  State<FontSizeSelector> createState() => _FontSizeSelectorState();
}

class _FontSizeSelectorState extends State<FontSizeSelector> {
  double _fontSize = 14;
  
  final List<Map<String, dynamic>> _fontSizes = [
    {'label': 'Très petit', 'value': 11, 'preview': 'A'},
    {'label': 'Petit', 'value': 12, 'preview': 'A'},
    {'label': 'Normal', 'value': 14, 'preview': 'A'},
    {'label': 'Grand', 'value': 16, 'preview': 'A'},
    {'label': 'Très grand', 'value': 18, 'preview': 'A'},
  ];

  @override
  void initState() {
    super.initState();
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('chat_font_size') ?? 14;
    });
  }

  Future<void> _saveFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('chat_font_size', value);
    setState(() => _fontSize = value);
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
          'Taille de police',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          // Preview
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
                  'Aperçu',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message exemple',
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ceci est un exemple de texte à la taille sélectionnée.',
                        style: TextStyle(fontSize: _fontSize - 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Slider
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.text_fields, size: 16, color: Colors.grey),
                    Expanded(
                      child: Slider(
                        value: _fontSize,
                        min: 11,
                        max: 20,
                        divisions: 9,
                        onChanged: (value) {
                          _saveFontSize(value);
                        },
                        activeColor: const Color(0xFFD4AF37),
                      ),
                    ),
                    const Icon(Icons.text_fields, size: 20, color: Color(0xFFD4AF37)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Taille actuelle: ${_fontSize.toStringAsFixed(0)}px',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFD4AF37)),
                ),
              ],
            ),
          ),
          
          // Presets
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
                  'Préréglages',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: _fontSizes.map((size) {
                    final isSelected = _fontSize == size['value'];
                    return GestureDetector(
                      onTap: () => _saveFontSize(size['value']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              size['preview'],
                              style: TextStyle(
                                fontSize: size['value'],
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              size['label'],
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
