// lib/models/voice_models.dart
class VoiceMessage {
  final String id;
  final String messageId;
  final String audioUrl;
  final int duration;
  final String? transcript;
  final DateTime createdAt;

  VoiceMessage({
    required this.id,
    required this.messageId,
    required this.audioUrl,
    required this.duration,
    this.transcript,
    required this.createdAt,
  });

  factory VoiceMessage.fromJson(Map<String, dynamic> json) {
    return VoiceMessage(
      id: json['id'],
      messageId: json['message_id'],
      audioUrl: json['audio_url'],
      duration: json['duration'],
      transcript: json['audio_transcript'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'audio_url': audioUrl,
      'duration': duration,
      'audio_transcript': transcript,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
