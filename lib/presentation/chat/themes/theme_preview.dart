// lib/presentation/chat/themes/theme_preview.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreview extends StatelessWidget {
  const ThemePreview({super.key});

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
          'Aperçu du thème',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          _buildThemeCard(
            'Thème clair',
            'Colors.white, texte sombre',
            Icons.light_mode,
            Colors.white,
            () => _applyTheme('light'),
          ),
          _buildThemeCard(
            'Thème sombre',
            'Colors.black, texte clair',
            Icons.dark_mode,
            const Color(0xFF1A1A1A),
            () => _applyTheme('dark'),
          ),
          _buildThemeCard(
            'THIX Or',
            'Couleur signature THIX',
            Icons.star,
            const Color(0xFF0B1B3D),
            () => _applyTheme('thix'),
          ),
          _buildThemeCard(
            'Bleu',
            'Apaisant et professionnel',
            Icons.water_drop,
            Colors.blue.shade50,
            () => _applyTheme('blue'),
          ),
          _buildThemeCard(
            'Vert',
            'Naturel et reposant',
            Icons.eco,
            Colors.green.shade50,
            () => _applyTheme('green'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(String name, String description, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _applyTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_theme', theme);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thème $theme appliqué'), duration: const Duration(seconds: 1)),
      );
    }
  }
}
