import 'package:thix_id/models/thix_money/nfc_card_model.dart';

class CardService {
  /// Get the user's NFC card information
  Future<NfcCardModel?> getCard() async {
    // TODO: Implement real card fetching from Supabase
    await Future.delayed(const Duration(milliseconds: 500));
    return null;
  }

  /// Activate a card with PIN
  Future<bool> activateCard(String pin) async {
    // TODO: Implement real card activation
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }

  /// Block the user's card
  Future<bool> blockCard() async {
    // TODO: Implement real card blocking
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }

  /// Change the card PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    // TODO: Implement real PIN change
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }

  /// Set spending limit without PIN
  Future<bool> setLimitWithoutPin(double limit) async {
    // TODO: Implement real limit setting
    await Future.delayed(const Duration(milliseconds: 500));
    return false;
  }
}
