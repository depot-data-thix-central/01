// lib/presentation/chat/audio_video/call_controls_advanced.dart
import 'package:flutter/material.dart';

class CallControlsAdvanced extends StatefulWidget {
  final bool isVideoCall;
  final Function(bool) onMuteToggle;
  final Function(bool) onVideoToggle;
  final Function(bool) onSpeakerToggle;
  final Function() onEndCall;
  final Function() onAddParticipant;

  const CallControlsAdvanced({
    super.key,
    required this.isVideoCall,
    required this.onMuteToggle,
    required this.onVideoToggle,
    required this.onSpeakerToggle,
    required this.onEndCall,
    required this.onAddParticipant,
  });

  @override
  State<CallControlsAdvanced> createState() => _CallControlsAdvancedState();
}

class _CallControlsAdvancedState extends State<CallControlsAdvanced> {
  bool _isMuted = false;
  bool _isVideoOn = true;
  bool _isSpeakerOn = true;
  bool _isRecording = false;
  bool _isScreenSharing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Main controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                label: _isMuted ? 'Micro off' : 'Micro',
                active: !_isMuted,
                onTap: () {
                  setState(() => _isMuted = !_isMuted);
                  widget.onMuteToggle(_isMuted);
                },
              ),
              _buildControlButton(
                icon: Icons.call_end,
                label: 'Raccrocher',
                active: false,
                color: Colors.red,
                onTap: widget.onEndCall,
              ),
              _buildControlButton(
                icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                label: _isSpeakerOn ? 'HP' : 'Écouteur',
                active: _isSpeakerOn,
                onTap: () {
                  setState(() => _isSpeakerOn = !_isSpeakerOn);
                  widget.onSpeakerToggle(_isSpeakerOn);
                },
              ),
              if (widget.isVideoCall)
                _buildControlButton(
                  icon: _isVideoOn ? Icons.videocam : Icons.videocam_off,
                  label: _isVideoOn ? 'Vidéo' : 'Caméra off',
                  active: _isVideoOn,
                  onTap: () {
                    setState(() => _isVideoOn = !_isVideoOn);
                    widget.onVideoToggle(_isVideoOn);
                  },
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Secondary controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSmallControlButton(
                icon: Icons.person_add,
                label: 'Ajouter',
                onTap: widget.onAddParticipant,
              ),
              _buildSmallControlButton(
                icon: _isRecording ? Icons.fiber_manual_record : Icons.fiber_manual_record,
                label: 'Enregistrer',
                color: _isRecording ? Colors.red : null,
                onTap: () => setState(() => _isRecording = !_isRecording),
              ),
              _buildSmallControlButton(
                icon: _isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                label: _isScreenSharing ? 'Arrêter' : 'Partager',
                onTap: () => setState(() => _isScreenSharing = !_isScreenSharing),
              ),
              _buildSmallControlButton(
                icon: Icons.message,
                label: 'Chat',
                onTap: () {},
              ),
              _buildSmallControlButton(
                icon: Icons.more_vert,
                label: 'Plus',
                onTap: () => _showMoreOptions(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color == Colors.red
                  ? Colors.red
                  : (active ? const Color(0xFFD4AF37) : Colors.grey[200]),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: color == Colors.red
                  ? Colors.white
                  : (active ? Colors.white : Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color == Colors.red ? Colors.red : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: color ?? Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 8, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.blur_on, size: 20),
              title: const Text('Flou d\'arrière-plan', style: TextStyle(fontSize: 13)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BackgroundBlurSettings()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.record_voice_over, size: 20),
              title: const Text('Enregistrer l\'appel', style: TextStyle(fontSize: 13)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.pip, size: 20),
              title: const Text('Mode image dans l\'image', style: TextStyle(fontSize: 13)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings, size: 20),
              title: const Text('Paramètres audio/vidéo', style: TextStyle(fontSize: 13)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
