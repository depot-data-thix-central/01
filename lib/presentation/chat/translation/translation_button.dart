// lib/presentation/chat/translation/translation_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/translation_provider.dart';

class TranslationButton extends StatelessWidget {
  final String messageId;
  final String originalText;
  final String originalLanguage;
  final VoidCallback onTranslated;

  const TranslationButton({
    super.key,
    required this.messageId,
    required this.originalText,
    required this.originalLanguage,
    required this.onTranslated,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final isTranslated = provider.isTranslated(messageId);
    final translatedText = provider.getTranslation(messageId);

    if (isTranslated && translatedText != null) {
      return GestureDetector(
        onTap: () {
          provider.removeTranslation(messageId);
          onTranslated();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.translate, size: 10, color: Colors.grey),
              const SizedBox(width: 2),
              const Text('Traduit', style: TextStyle(fontSize: 9, color: Colors.grey)),
              const SizedBox(width: 2),
              Icon(Icons.close, size: 8, color: Colors.grey),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
        final targetLang = provider.targetLanguage;
        final translated = await provider.translateMessage(
          messageId: messageId,
          text: originalText,
          sourceLang: originalLanguage,
          targetLang: targetLang,
        );
        if (translated != null) {
          onTranslated();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 10, color: Color(0xFFD4AF37)),
            const SizedBox(width: 2),
            Text(
              'Traduire en ${_getLanguageName(provider.targetLanguage)}',
              style: const TextStyle(fontSize: 9, color: Color(0xFFD4AF37)),
            ),
          ],
        ),
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
    };
    return languages[code] ?? code;
  }
}
