import 'package:flutter/foundation.dart';
import '../models/player_stats.dart';
import '../models/game_state.dart';
import '../services/storage_service.dart';
import '../core/constants.dart';

class StatsProvider extends ChangeNotifier {
  final StorageService _storage;

  PlayerStats _stats = PlayerStats();
  PlayerStats get stats => _stats;

  StatsProvider(this._storage);

  Future<void> load() async {
    _stats = await _storage.loadStats();
    notifyListeners();
  }

  Future<void> recordGame(
      Difficulty difficulty, int timeSeconds, bool won,
      {int hintsUsed = 0}) async {
    _stats.recordGame(difficulty, timeSeconds, won, hintsUsed: hintsUsed);
    await _storage.saveStats(_stats);
    notifyListeners();
  }
}
