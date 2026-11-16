import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reward_model.dart';

class StorageService {
  static const String _keyStreak = 'streak_count';
  static const String _keyLastDate = 'last_checkin_date';
  static const String _keyRewards = 'custom_rewards_json';
  static const String _keyUnlockedBadges = 'unlocked_badge_ids';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int getStreak() {
    return _prefs.getInt(_keyStreak) ?? 0;
  }

  Future<void> saveStreak(int streak) async {
    await _prefs.setInt(_keyStreak, streak);
  }

  DateTime? getLastCheckInDate() {
    final dateStr = _prefs.getString(_keyLastDate);
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastCheckInDate(DateTime date) async {
    // Salva apenas a data (YYYY-MM-DD) para evitar ruído de fuso ou horas
    final formatted =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    await _prefs.setString(_keyLastDate, formatted);
  }

  List<String> getUnlockedBadges() {
    return _prefs.getStringList(_keyUnlockedBadges) ?? [];
  }

  Future<void> saveUnlockedBadges(List<String> badgeIds) async {
    await _prefs.setStringList(_keyUnlockedBadges, badgeIds);
  }

  List<RewardModel> getRewards() {
    final rawList = _prefs.getStringList(_keyRewards) ?? [];
    return rawList.map((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      return RewardModel.fromMap(decoded);
    }).toList();
  }

  Future<void> saveRewards(List<RewardModel> rewards) async {
    final rawList = rewards.map((r) => jsonEncode(r.toMap())).toList();
    await _prefs.setStringList(_keyRewards, rawList);
  }
}
