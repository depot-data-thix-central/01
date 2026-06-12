// lib/services/theme_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ThemeService {
  static const String _themeKey = 'chat_theme';
  static const String _bubbleStyleKey = 'bubble_style';
  static const String _myBubbleColorKey = 'my_bubble_color';
  static const String _otherBubbleColorKey = 'other_bubble_color';
  static const String _borderRadiusKey = 'bubble_border_radius';
  static const String _showAvatarKey = 'show_avatar';
  static const String _showTimeKey = 'show_time';
  static const String _showReadReceiptKey = 'show_read_receipt';
  static const String _notificationSoundKey = 'notification_sound';
  static const String _notificationVolumeKey = 'notification_volume';
  static const String _notificationVibrateKey = 'notification_vibrate';
  static const String _chatWallpaperKey = 'chat_wallpaper';
  static const String _wallpaperOpacityKey = 'wallpaper_opacity';
  static const String _fontSizeKey = 'chat_font_size';

  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'light';
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  Future<String> getBubbleStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bubbleStyleKey) ?? 'rounded';
  }

  Future<void> setBubbleStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bubbleStyleKey, style);
  }

  Future<Color> getMyBubbleColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_myBubbleColorKey) ?? 0xFFD4AF37;
    return Color(colorValue);
  }

  Future<void> setMyBubbleColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_myBubbleColorKey, color.value);
  }

  Future<Color> getOtherBubbleColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_otherBubbleColorKey) ?? 0xFFFFFFFF;
    return Color(colorValue);
  }

  Future<void> setOtherBubbleColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_otherBubbleColorKey, color.value);
  }

  Future<double> getBorderRadius() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_borderRadiusKey) ?? 16;
  }

  Future<void> setBorderRadius(double radius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_borderRadiusKey, radius);
  }

  Future<bool> getShowAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showAvatarKey) ?? true;
  }

  Future<void> setShowAvatar(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showAvatarKey, show);
  }

  Future<bool> getShowTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showTimeKey) ?? true;
  }

  Future<void> setShowTime(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showTimeKey, show);
  }

  Future<bool> getShowReadReceipt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showReadReceiptKey) ?? true;
  }

  Future<void> setShowReadReceipt(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showReadReceiptKey, show);
  }

  Future<String> getNotificationSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_notificationSoundKey) ?? 'default';
  }

  Future<void> setNotificationSound(String sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationSoundKey, sound);
  }

  Future<double> getNotificationVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_notificationVolumeKey) ?? 0.8;
  }

  Future<void> setNotificationVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_notificationVolumeKey, volume);
  }

  Future<bool> getNotificationVibrate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationVibrateKey) ?? true;
  }

  Future<void> setNotificationVibrate(bool vibrate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationVibrateKey, vibrate);
  }

  Future<String> getChatWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chatWallpaperKey) ?? 'default';
  }

  Future<void> setChatWallpaper(String wallpaper) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chatWallpaperKey, wallpaper);
  }

  Future<double> getWallpaperOpacity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_wallpaperOpacityKey) ?? 0.3;
  }

  Future<void> setWallpaperOpacity(double opacity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_wallpaperOpacityKey, opacity);
  }

  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 14;
  }

  Future<void> setFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }
}
