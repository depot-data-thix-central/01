// lib/presentation/chat/audio_video/group_call_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/call_provider.dart';

class GroupCallPage extends StatefulWidget {
  final String callId;
  final String callName;
  final List<CallParticipant> participants;
  final bool isVideoCall;

  const GroupCallPage({
    super.key,
    required this.callId,
    required this.callName,
    required this.participants,
    this.isVideoCall = true,
  });

  @override
  State<GroupCallPage> createState() => _GroupCallPageState();
}

class _GroupCallPageState extends State<GroupCallPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isVideoOn = true;
  bool _isRecording = false;
  bool _isScreenSharing = false;
  Duration _callDuration = Duration.zero;
  int _activeSpeakers = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
        });
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1B3D),
      body: Stack(
        children: [
          // Video grid background
          Positioned.fill(
            child: _isVideoOn
                ? ParticipantsGrid(participants: widget.participants)
                : Container(color: Colors.black),
          ),
          
          // Top bar
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatDuration(_callDuration),
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_activeSpeakers participants actifs',
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.swap_calls, size: 20, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Call controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Tabs
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFFD4AF37),
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: const Color(0xFFD4AF37),
                    tabs: const [
                      Tab(text: 'Participants', icon: Icon(Icons.people, size: 16)),
                      Tab(text: 'Chat', icon: Icon(Icons.chat, size: 16)),
                    ],
                  ),
                ),
                
                // Tab content
                Container(
                  height: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildParticipantsTab(),
                      _buildChatTab(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Call controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CallControlButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      label: _isMuted ? 'Micro off' : 'Micro',
                      active: !_isMuted,
                      onTap: () => setState(() => _isMuted = !_isMuted),
                    ),
                    CallControlButton(
                      icon: Icons.call_end,
                      label: 'Raccrocher',
                      active: false,
                      color: Colors.red,
                      onTap: () => Navigator.pop(context),
                    ),
                    CallControlButton(
                      icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      label: _isSpeakerOn ? 'HP' : 'Écouteur',
                      active: _isSpeakerOn,
                      onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                    ),
                    if (widget.isVideoCall)
                      CallControlButton(
                        icon: _isVideoOn ? Icons.videocam : Icons.videocam_off,
                        label: _isVideoOn ? 'Vidéo' : 'Caméra off',
                        active: _isVideoOn,
                        onTap: () => setState(() => _isVideoOn = !_isVideoOn),
                      ),
                    CallControlButton(
                      icon: _isRecording ? Icons.fiber_manual_record : Icons.fiber_manual_record,
                      label: _isRecording ? 'Enreg.' : 'Enregistrer',
                      active: _isRecording,
                      color: _isRecording ? Colors.red : Colors.white,
                      onTap: () => setState(() => _isRecording = !_isRecording),
                    ),
                    CallControlButton(
                      icon: Icons.more_vert,
                      label: 'Plus',
                      active: false,
                      onTap: () => _showMoreOptions(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsTab() {
    return ListView.builder(
      itemCount: widget.participants.length,
      itemBuilder: (context, index) {
        final participant = widget.participants[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 16,
            backgroundImage: participant.avatarUrl != null
                ? NetworkImage(participant.avatarUrl!)
                : null,
            child: participant.avatarUrl == null
                ? const Icon(Icons.person, size: 16)
                : null,
          ),
          title: Text(
            participant.name,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (participant.isSpeaking)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
              const SizedBox(width: 8),
              if (participant.isMuted)
                const Icon(Icons.mic_off, size: 14, color: Colors.red),
              if (participant.isVideoOn)
                const Icon(Icons.videocam, size: 14, color: Colors.white70),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatTab() {
    return ListView(
      children: [
        _chatMessage('Jean Dupont', 'Super, j\'arrive !', DateTime.now()),
        _chatMessage('Marie Koné', '✅', DateTime.now().subtract(const Duration(minutes: 1))),
        _chatMessage('Paul Yao', 'Merci pour l\'invitation', DateTime.now().subtract(const Duration(minutes: 2))),
      ],
    );
  }

  Widget _chatMessage(String name, String message, DateTime time) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            child: Text(name[0], style: const TextStyle(fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ],
            ),
          ),
          Text(
            '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 8, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share, size: 20),
              title: const Text('Partager l\'appel', style: TextStyle(fontSize: 13)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.record_voice_over, size: 20),
              title: const Text('Enregistrer l\'appel', style: TextStyle(fontSize: 13)),
              onTap: () => setState(() => _isRecording = !_isRecording),
            ),
            ListTile(
              leading: const Icon(Icons.blur_on, size: 20),
              title: const Text('Flou d\'arrière-plan', style: TextStyle(fontSize: 13)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackgroundBlurSettings())),
            ),
            ListTile(
              leading: const Icon(Icons.screen_share, size: 20),
              title: const Text('Partager l\'écran', style: TextStyle(fontSize: 13)),
              onTap: () => setState(() => _isScreenSharing = true),
            ),
          ],
        ),
      ),
    );
  }
}

class CallParticipant {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isSpeaking;
  final bool isMuted;
  final bool isVideoOn;

  CallParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isSpeaking = false,
    this.isMuted = false,
    this.isVideoOn = true,
  });
}

class CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? color;

  const CallControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (color == Colors.red)
                  ? Colors.red
                  : (active ? const Color(0xFFD4AF37) : Colors.white24),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: (color == Colors.red)
                  ? Colors.white
                  : (active ? Colors.white : Colors.white70),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
