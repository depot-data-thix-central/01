// lib/providers/data_saver_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataSaverProvider extends ChangeNotifier {
  bool _isLowDataMode = false;
  bool _blockImages = false;
  bool _blockVideos = false;
  bool _blockStickers = false;
  bool _reduceQuality = true;
  String _downloadOnMobile = 'wifi_only';
  String _videoQuality = 'auto';
  String _imageQuality = 'high';
  bool _autoPlayVideos = true;
  bool _autoPlayGifs = true;
  String _photosOnMobile = 'wifi';
  String _videosOnMobile = 'never';
  String _documentsOnMobile = 'wifi';
  int _maxFileSize = 50;
  
  DataSaverProvider() {
    _loadSettings();
  }
  
  // ============================================================
  // GETTERS
  // ============================================================
  
  bool get isLowDataMode => _isLowDataMode;
  bool get blockImages => _blockImages;
  bool get blockVideos => _blockVideos;
  bool get blockStickers => _blockStickers;
  bool get reduceQuality => _reduceQuality;
  String get downloadOnMobile => _downloadOnMobile;
  String get videoQuality => _videoQuality;
  String get imageQuality => _imageQuality;
  bool get autoPlayVideos => _autoPlayVideos;
  bool get autoPlayGifs => _autoPlayGifs;
  String get photosOnMobile => _photosOnMobile;
  String get videosOnMobile => _videosOnMobile;
  String get documentsOnMobile => _documentsOnMobile;
  int get maxFileSize => _maxFileSize;
  
  // ============================================================
  // MÉTHODES
  // ============================================================
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLowDataMode = prefs.getBool('low_data_mode') ?? false;
      _blockImages = prefs.getBool('block_images') ?? false;
      _blockVideos = prefs.getBool('block_videos') ?? false;
      _blockStickers = prefs.getBool('block_stickers') ?? false;
      _reduceQuality = prefs.getBool('reduce_quality') ?? true;
      _downloadOnMobile = prefs.getString('download_on_mobile') ?? 'wifi_only';
      _videoQuality = prefs.getString('video_quality') ?? 'auto';
      _imageQuality = prefs.getString('image_quality') ?? 'high';
      _autoPlayVideos = prefs.getBool('auto_play_videos') ?? true;
      _autoPlayGifs = prefs.getBool('auto_play_gifs') ?? true;
      _photosOnMobile = prefs.getString('auto_download_photos_mobile') ?? 'wifi';
      _videosOnMobile = prefs.getString('auto_download_videos_mobile') ?? 'never';
      _documentsOnMobile = prefs.getString('auto_download_documents_mobile') ?? 'wifi';
      _maxFileSize = prefs.getInt('max_auto_download_size') ?? 50;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data saver settings: $e');
    }
  }
  
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else {
      await prefs.setString(key, value);
    }
  }
  
  void toggleLowDataMode(bool value) {
    _isLowDataMode = value;
    if (value) {
      _blockImages = true;
      _blockVideos = true;
      _reduceQuality = true;
      _saveSetting('block_images', true);
      _saveSetting('block_videos', true);
      _saveSetting('reduce_quality', true);
    }
    _saveSetting('low_data_mode', value);
    notifyListeners();
  }
  
  void setBlockImages(bool value) {
    _blockImages = value;
    _saveSetting('block_images', value);
    notifyListeners();
  }
  
  void setBlockVideos(bool value) {
    _blockVideos = value;
    _saveSetting('block_videos', value);
    notifyListeners();
  }
  
  void setBlockStickers(bool value) {
    _blockStickers = value;
    _saveSetting('block_stickers', value);
    notifyListeners();
  }
  
  void setReduceQuality(bool value) {
    _reduceQuality = value;
    _saveSetting('reduce_quality', value);
    notifyListeners();
  }
  
  void setDownloadOnMobile(String value) {
    _downloadOnMobile = value;
    _saveSetting('download_on_mobile', value);
    notifyListeners();
  }
  
  void setVideoQuality(String value) {
    _videoQuality = value;
    _saveSetting('video_quality', value);
    notifyListeners();
  }
  
  void setImageQuality(String value) {
    _imageQuality = value;
    _saveSetting('image_quality', value);
    notifyListeners();
  }
  
  void setAutoPlayVideos(bool value) {
    _autoPlayVideos = value;
    _saveSetting('auto_play_videos', value);
    notifyListeners();
  }
  
  void setAutoPlayGifs(bool value) {
    _autoPlayGifs = value;
    _saveSetting('auto_play_gifs', value);
    notifyListeners();
  }
  
  void setPhotosOnMobile(String value) {
    _photosOnMobile = value;
    _saveSetting('auto_download_photos_mobile', value);
    notifyListeners();
  }
  
  void setVideosOnMobile(String value) {
    _videosOnMobile = value;
    _saveSetting('auto_download_videos_mobile', value);
    notifyListeners();
  }
  
  void setDocumentsOnMobile(String value) {
    _documentsOnMobile = value;
    _saveSetting('auto_download_documents_mobile', value);
    notifyListeners();
  }
  
  void setMaxFileSize(int size) {
    _maxFileSize = size;
    _saveSetting('max_auto_download_size', size);
    notifyListeners();
  }
}
