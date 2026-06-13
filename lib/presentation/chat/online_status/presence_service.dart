// lib/presentation/chat/online_status/presence_service.dart
// Service central de présence (gère le statut en ligne, frappe, etc.)

import 'dart:async';
import 'package:flutter/material.dart';
import '../core/chat_repository.dart'; // pour avoir currentUserId
import 'status_repository.dart';

class PresenceService {
  final StatusRepository _statusRepository;
  final String currentUserId;
  Timer? _heartbeatTimer;
  bool _isActive = false;

  PresenceService({required this.currentUserId}) : _statusRepository = StatusRepository();

  // Démarrer le service (appeler au lancement de l'app)
  void start() {
    if (_isActive) return;
    _isActive = true;
    _setStatusOnline();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshPresence();
    });
  }

  // Arrêter le service (mettre en offline)
  void stop() async {
    _isActive = false;
    _heartbeatTimer?.cancel();
    await _statusRepository.updateStatus(currentUserId, 'offline');
  }

  Future<void> _setStatusOnline() async {
    await _statusRepository.updateStatus(currentUserId, 'online');
  }

  Future<void> _refreshPresence() async {
    if (_isActive) {
      await _statusRepository.updateStatus(currentUserId, 'online');
    }
  }

  // Envoyer un signal de frappe (dans une conversation)
  Future<void> sendTyping(String conversationId) async {
    // Optionnel : envoyer via WebSocket ou une table "typing_events"
    // Pour l'exemple, on peut simplement ignorer ou appeler une API
    // Ici, on peut émettre un événement dans le ChatBloc
  }

  // Arrêter le signal de frappe
  Future<void> stopTyping(String conversationId) async {
    // Idem
  }

  // Écouter les statuts des contacts
  Stream<List<ChatUser>> watchContactStatuses(List<String> contactIds) {
    return _statusRepository.listenToAllStatuses(contactIds);
  }

  // Récupérer le statut d'un utilisateur spécifique
  Future<ChatUser> getUserStatus(String userId) async {
    return await _statusRepository.getUserStatus(userId);
  }

  // Liste des contacts en ligne
  Future<List<ChatUser>> getOnlineContacts() async {
    return await _statusRepository.getOnlineContacts(currentUserId);
  }

  // Mise en veille (quand l'app passe en arrière-plan)
  void onAppPaused() {
    _statusRepository.updateStatus(currentUserId, 'away');
  }

  // Réveil (quand l'app revient au premier plan)
  void onAppResumed() {
    _statusRepository.updateStatus(currentUserId, 'online');
  }
}
