import 'package:flutter/foundation.dart';
import '../models/settings_model.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  SettingsModel _settings = SettingsModel();
  SettingsModel get settings => _settings;

  SettingsProvider(this._storage);

  Future<void> load() async {
    _settings = await _storage.loadSettings();
    notifyListeners();
  }

  Future<void> update(SettingsModel newSettings) async {
    _settings = newSettings;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _settings.darkMode = value;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _settings.soundEnabled = value;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _settings.vibrationEnabled = value;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setHighlightDuplicates(bool value) async {
    _settings.highlightDuplicates = value;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setAutoCheckMistakes(bool value) async {
    _settings.autoCheckMistakes = value;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setShowTimer(bool value) async {
    _settings.showTimer = value;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setLeftHandedMode(bool value) async {
    _settings.leftHandedMode = value;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }
}
