// lib/presentation/chat/translation/auto_translate_settings.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/translation_provider.dart';
import 'language_selector_sheet.dart';

class AutoTranslateSettings extends StatelessWidget {
  const AutoTranslateSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);

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
          'Traduction automatique',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
              title: const Text('Traduction automatique', style: TextStyle(fontSize: 13)),
              subtitle: const Text('Traduire automatiquement les messages reçus', style: TextStyle(fontSize: 10)),
              value: provider.autoTranslate,
              onChanged: (value) => provider.setAutoTranslate(value),
              activeColor: const Color(0xFFD4AF37),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          // Langue cible
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: const Text('Langue de traduction', style: TextStyle(fontSize: 13)),
              subtitle: Text(
                _getLanguageName(provider.targetLanguage),
                style: const TextStyle(fontSize: 11, color: Color(0xFFD4AF37)),
              ),
              trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const LanguageSelectorSheet(),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Langue source automatique
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Détection automatique', style: TextStyle(fontSize: 13)),
              subtitle: const Text('Détecter automatiquement la langue source', style: TextStyle(fontSize: 10)),
              value: provider.autoDetectLanguage,
              onChanged: (value) => provider.setAutoDetectLanguage(value),
              activeColor: const Color(0xFFD4AF37),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          // Traduction des messages sortants
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Traduire mes messages', style: TextStyle(fontSize: 13)),
              subtitle: const Text('Envoyer automatiquement une traduction de vos messages', style: TextStyle(fontSize: 10)),
              value: provider.translateOutgoing,
              onChanged: (value) => provider.setTranslateOutgoing(value),
              activeColor: const Color(0xFFD4AF37),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    const languages = {
      'fr': 'Français',
      'en': 'Anglais',
      'ar': 'Arabe',
      'es': 'Espagnol',
      'de': 'Allemand',
      'it': 'Italien',
      'pt': 'Portugais',
      'ru': 'Russe',
      'zh': 'Chinois',
      'ja': 'Japonais',
      'ko': 'Coréen',
      'nl': 'Néerlandais',
      'pl': 'Polonais',
      'tr': 'Turc',
      'vi': 'Vietnamien',
      'th': 'Thaï',
    };
    return languages[code] ?? code;
  }
}
