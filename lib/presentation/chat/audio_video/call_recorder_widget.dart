// lib/presentation/chat/audio_video/call_recorder_widget.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CallRecorderWidget extends StatefulWidget {
  final Function(File recordingFile) onRecordingComplete;

  const CallRecorderWidget({
    super.key,
    required this.onRecordingComplete,
  });

  @override
  State<CallRecorderWidget> createState() => _CallRecorderWidgetState();
}

class _CallRecorderWidgetState extends State<CallRecorderWidget> {
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordingDuration = Duration.zero;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isRecording && !_isPaused) {
        setState(() {
          _recordingDuration = Duration(seconds: _recordingDuration.inSeconds + 1);
        });
      }
    });
  }

  void _pauseRecording() {
    setState(() => _isPaused = true);
  }

  void _resumeRecording() {
    setState(() => _isPaused = false);
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() => _isRecording = false);
    // Simuler un fichier enregistré
    widget.onRecordingComplete(File('path/to/recording.m4a'));
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRecording) {
      return GestureDetector(
        onTap: _startRecording,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              const Text(
                'Enregistrer l\'appel',
                style: TextStyle(fontSize: 11, color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: AlwaysStoppedAnimation(0),
            builder: (context, child) {
              return Text(
                _formatDuration(_recordingDuration),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              );
            },
          ),
          const SizedBox(width: 12),
          if (_isPaused)
            IconButton(
              icon: const Icon(Icons.play_arrow, size: 18),
              onPressed: _resumeRecording,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: Colors.white,
            )
          else
            IconButton(
              icon: const Icon(Icons.pause, size: 18),
              onPressed: _pauseRecording,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: Colors.white,
            ),
          IconButton(
            icon: const Icon(Icons.stop, size: 18),
            onPressed: _stopRecording,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
