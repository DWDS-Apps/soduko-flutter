import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/game_state.dart';
import '../models/player_stats.dart';
import '../models/settings_model.dart';

class StorageService {
  late Directory _appDir;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final docsDir = await getApplicationDocumentsDirectory();
    _appDir = Directory('${docsDir.path}/.sudoku_data');
    if (!await _appDir.exists()) {
      await _appDir.create(recursive: true);
    }
    _initialized = true;
  }

  String get _savePath => '${_appDir.path}/save.json';
  String get _statsPath => '${_appDir.path}/stats.json';
  String get _settingsPath => '${_appDir.path}/settings.json';
  String get _dailyPath => '${_appDir.path}/daily.json';

  Future<void> saveGame(GameState state) async {
    try {
      final data = state.toJson();
      await File(_savePath).writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving game: $e');
    }
  }

  Future<GameState?> loadGame() async {
    try {
      final file = File(_savePath);
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        return GameState.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error loading game: $e');
    }
    return null;
  }

  Future<void> deleteSave() async {
    final file = File(_savePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> hasSavedGame() async {
    if (!_initialized) return false;
    final file = File(_savePath);
    return await file.exists();
  }

  Future<void> saveStats(PlayerStats stats) async {
    try {
      final data = stats.toJson();
      await File(_statsPath).writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving stats: $e');
    }
  }

  Future<PlayerStats> loadStats() async {
    try {
      final file = File(_statsPath);
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        return PlayerStats.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
    return PlayerStats();
  }

  Future<void> saveSettings(SettingsModel settings) async {
    try {
      final data = settings.toJson();
      await File(_settingsPath).writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<SettingsModel> loadSettings() async {
    try {
      final file = File(_settingsPath);
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        return SettingsModel.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
    return SettingsModel();
  }

  Future<void> saveDailyChallenge(DailyChallenge challenge) async {
    try {
      final Map<String, dynamic> allData = {};
      final file = File(_dailyPath);
      if (await file.exists()) {
        allData.addAll(
            jsonDecode(await file.readAsString()) as Map<String, dynamic>);
      }
      allData[challenge.dateKey] = challenge.toJson();
      await file.writeAsString(jsonEncode(allData));
    } catch (e) {
      debugPrint('Error saving daily: $e');
    }
  }

  Future<DailyChallenge?> loadDailyChallenge(DateTime date) async {
    try {
      final file = File(_dailyPath);
      if (await file.exists()) {
        final allData =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        if (allData.containsKey(dateKey)) {
          return DailyChallenge.fromJson(
              allData[dateKey] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Error loading daily: $e');
    }
    return null;
  }
}
