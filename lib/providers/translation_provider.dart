// lib/providers/translation_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/translation_service.dart';

class TranslationProvider extends ChangeNotifier {
  late TranslationService _service;
  
  String _targetLanguage = 'fr';
  bool _autoTranslate = true;
  bool _autoDetectLanguage = true;
  bool _translateOutgoing = false;
  final Map<String, String> _translations = {};
  
  TranslationProvider() {
    _service = TranslationService(Supabase.instance.client);
    _loadSettings();
  }
  
  // ============================================================
  // GETTERS
  // ============================================================
  
  String get targetLanguage => _targetLanguage;
  bool get autoTranslate => _autoTranslate;
  bool get autoDetectLanguage => _autoDetectLanguage;
  bool get translateOutgoing => _translateOutgoing;
  Map<String, String> get translations => _translations;
  
  // ============================================================
  // MÉTHODES
  // ============================================================
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _targetLanguage = prefs.getString('translation_target') ?? 'fr';
      _autoTranslate = prefs.getBool('auto_translate') ?? true;
      _autoDetectLanguage = prefs.getBool('auto_detect_language') ?? true;
      _translateOutgoing = prefs.getBool('translate_outgoing') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading translation settings: $e');
    }
  }
  
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('translation_target', _targetLanguage);
    await prefs.setBool('auto_translate', _autoTranslate);
    await prefs.setBool('auto_detect_language', _autoDetectLanguage);
    await prefs.setBool('translate_outgoing', _translateOutgoing);
  }
  
  void setTargetLanguage(String lang) {
    _targetLanguage = lang;
    saveSettings();
    notifyListeners();
  }
  
  void setAutoTranslate(bool value) {
    _autoTranslate = value;
    saveSettings();
    notifyListeners();
  }
  
  void setAutoDetectLanguage(bool value) {
    _autoDetectLanguage = value;
    saveSettings();
    notifyListeners();
  }
  
  void setTranslateOutgoing(bool value) {
    _translateOutgoing = value;
    saveSettings();
    notifyListeners();
  }
  
  bool isTranslated(String messageId) => _translations.containsKey(messageId);
  
  String? getTranslation(String messageId) => _translations[messageId];
  
  Future<String?> translateMessage({
    required String messageId,
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (sourceLang == targetLang) return null;
    
    try {
      final translated = await _service.translate(
        text: text,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
      
      if (translated != null) {
        _translations[messageId] = translated;
        notifyListeners();
        return translated;
      }
      return null;
    } catch (e) {
      debugPrint('Translation error: $e');
      return null;
    }
  }
  
  void removeTranslation(String messageId) {
    _translations.remove(messageId);
    notifyListeners();
  }
}
