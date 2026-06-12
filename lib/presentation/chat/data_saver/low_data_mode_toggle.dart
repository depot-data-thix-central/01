// lib/presentation/chat/data_saver/low_data_mode_toggle.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LowDataModeToggle extends StatefulWidget {
  const LowDataModeToggle({super.key});

  @override
  State<LowDataModeToggle> createState() => _LowDataModeToggleState();
}

class _LowDataModeToggleState extends State<LowDataModeToggle> {
  bool _isLowDataMode = false;
  bool _blockImages = false;
  bool _blockVideos = false;
  bool _blockStickers = false;
  bool _reduceQuality = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLowDataMode = prefs.getBool('low_data_mode') ?? false;
      _blockImages = prefs.getBool('block_images') ?? false;
      _blockVideos = prefs.getBool('block_videos') ?? false;
      _blockStickers = prefs.getBool('block_stickers') ?? false;
      _reduceQuality = prefs.getBool('reduce_quality') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _toggleLowDataMode(bool value) {
    setState(() {
      _isLowDataMode = value;
      if (value) {
        _blockImages = true;
        _blockVideos = true;
        _reduceQuality = true;
        _saveSetting('block_images', true);
        _saveSetting('block_videos', true);
        _saveSetting('reduce_quality', true);
      }
    });
    _saveSetting('low_data_mode', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mode économie de données',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          // Main toggle
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Mode économie de données', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Réduire la consommation de données', style: TextStyle(fontSize: 10)),
              value: _isLowDataMode,
              onChanged: _toggleLowDataMode,
              activeColor: const Color(0xFFD4AF37),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          
          if (_isLowDataMode) ...[
            // Info card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.data_saver_on, size: 20, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Économie active',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Les médias ne seront pas chargés automatiquement',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Block images
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('Bloquer les images', style: TextStyle(fontSize: 13)),
                subtitle: const Text('Ne pas charger les images automatiquement', style: TextStyle(fontSize: 10)),
                value: _blockImages,
                onChanged: (value) {
                  setState(() => _blockImages = value);
                  _saveSetting('block_images', value);
                },
                activeColor: const Color(0xFFD4AF37),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            
            // Block videos
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('Bloquer les vidéos', style: TextStyle(fontSize: 13)),
                subtitle: const Text('Ne pas charger les vidéos automatiquement', style: TextStyle(fontSize: 10)),
                value: _blockVideos,
                onChanged: (value) {
                  setState(() => _blockVideos = value);
                  _saveSetting('block_videos', value);
                },
                activeColor: const Color(0xFFD4AF37),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            
            // Block stickers
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('Bloquer les stickers', style: TextStyle(fontSize: 13)),
                subtitle: const Text('Ne pas charger les stickers animés', style: TextStyle(fontSize: 10)),
                value: _blockStickers,
                onChanged: (value) {
                  setState(() => _blockStickers = value);
                  _saveSetting('block_stickers', value);
                },
                activeColor: const Color(0xFFD4AF37),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            
            // Reduce quality
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('Réduire la qualité', style: TextStyle(fontSize: 13)),
                subtitle: const Text('Charger les médias en basse qualité', style: TextStyle(fontSize: 10)),
                value: _reduceQuality,
                onChanged: (value) {
                  setState(() => _reduceQuality = value);
                  _saveSetting('reduce_quality', value);
                },
                activeColor: const Color(0xFFD4AF37),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            
            // Estimated savings
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Économies estimées',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _savingItem(Icons.image, 'Images', '-70%'),
                      _savingItem(Icons.videocam, 'Vidéos', '-85%'),
                      _savingItem(Icons.data_usage, 'Total', '-75%'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _savingItem(IconData icon, String label, String saving) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: const Color(0xFFD4AF37)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
        Text(
          saving,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ],
    );
  }
}
