// lib/presentation/chat/ephemeral/ephemeral_timer_widget.dart
import 'package:flutter/material.dart';

class EphemeralTimerWidget extends StatefulWidget {
  final int durationSeconds;
  final DateTime? expiresAt;
  final VoidCallback? onExpired;

  const EphemeralTimerWidget({
    super.key,
    required this.durationSeconds,
    this.expiresAt,
    this.onExpired,
  });

  @override
  State<EphemeralTimerWidget> createState() => _EphemeralTimerWidgetState();
}

class _EphemeralTimerWidgetState extends State<EphemeralTimerWidget> {
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _isExpired = true;
            _timer.cancel();
            widget.onExpired?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isExpired) {
      return const SizedBox.shrink();
    }

    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final progress = 1 - (_remainingSeconds / widget.durationSeconds);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              color: const Color(0xFFD4AF37),
              backgroundColor: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}
