// lib/presentation/chat/ephemeral/screenshot_detector.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:supabase_flutter/supabase_flutter.dart';

class ScreenshotDetector extends StatefulWidget {
  final Widget child;
  final String conversationId;
  final String messageId;
  final VoidCallback? onScreenshotDetected;

  const ScreenshotDetector({
    super.key,
    required this.child,
    required this.conversationId,
    required this.messageId,
    this.onScreenshotDetected,
  });

  @override
  State<ScreenshotDetector> createState() => _ScreenshotDetectorState();
}

class _ScreenshotDetectorState extends State<ScreenshotDetector> with WidgetsBindingObserver {
  Timer? _checkTimer;
  ui.Image? _lastScreenshot;
  bool _hasNotified = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startDetection();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _checkTimer?.cancel();
    super.dispose();
  }

  void _startDetection() {
    _checkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      await _checkForScreenshot();
    });
  }

  Future<void> _checkForScreenshot() async {
    try {
      final screenshot = await _captureScreen();
      if (_lastScreenshot != null && screenshot != null) {
        final isSame = await _compareImages(_lastScreenshot!, screenshot);
        if (!isSame) {
          _onScreenshotDetected();
        }
      }
      _lastScreenshot = screenshot;
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  Future<ui.Image?> _captureScreen() async {
    try {
      final RenderRepaintBoundary boundary = RenderRepaintBoundary();
      final image = await boundary.toImage();
      return image;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _compareImages(ui.Image img1, ui.Image img2) async {
    // Comparaison simplifiée
    return img1.width == img2.width && img1.height == img2.height;
  }

  Future<void> _onScreenshotDetected() async {
    if (_hasNotified) return;
    _hasNotified = true;

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser != null) {
        await supabase.from('screenshot_alerts').insert({
          'message_id': widget.messageId,
          'user_id': currentUser.id,
          'captured_by': currentUser.id,
          'captured_at': DateTime.now().toIso8601String(),
        });
      }

      widget.onScreenshotDetected?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Capture d\'écran détectée !'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error reporting screenshot: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _onScreenshotDetected();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
