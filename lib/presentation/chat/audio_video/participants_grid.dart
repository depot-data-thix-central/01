// lib/presentation/chat/audio_video/participants_grid.dart
import 'package:flutter/material.dart';

class ParticipantsGrid extends StatelessWidget {
  final List<CallParticipant> participants;

  const ParticipantsGrid({
    super.key,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    final count = participants.length;
    
    if (count == 0) {
      return const Center(
        child: Text(
          'En attente de participants...',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    
    if (count == 1) {
      return _buildSingleParticipant(participants[0]);
    }
    
    if (count == 2) {
      return Row(
        children: [
          Expanded(child: _buildParticipantTile(participants[0])),
          Expanded(child: _buildParticipantTile(participants[1])),
        ],
      );
    }
    
    // 3+ participants - grille
    int crossAxisCount = count <= 4 ? 2 : 3;
    
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        return _buildParticipantTile(participants[index]);
      },
    );
  }

  Widget _buildSingleParticipant(CallParticipant participant) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          shape: BoxShape.circle,
        ),
        child: _buildParticipantContent(participant),
      ),
    );
  }

  Widget _buildParticipantTile(CallParticipant participant) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildParticipantContent(participant),
    );
  }

  Widget _buildParticipantContent(CallParticipant participant) {
    return Stack(
      children: [
        // Video or avatar
        Center(
          child: participant.isVideoOn
              ? Container(
                  color: Colors.grey[700],
                  child: const Center(
                    child: Icon(Icons.videocam, size: 40, color: Colors.white38),
                  ),
                )
              : CircleAvatar(
                  radius: 40,
                  backgroundImage: participant.avatarUrl != null
                      ? NetworkImage(participant.avatarUrl!)
                      : null,
                  child: participant.avatarUrl == null
                      ? Text(
                          participant.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
        ),
        
        // Name and status
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    participant.name,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (participant.isSpeaking) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
                ],
                if (participant.isMuted) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.mic_off, size: 10, color: Colors.red),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
