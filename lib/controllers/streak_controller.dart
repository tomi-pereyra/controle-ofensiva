import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../models/reward_model.dart';
import '../services/storage_service.dart';

class StreakController extends ChangeNotifier {
  final StorageService _storage;

  int _streak = 0;
  DateTime? _lastCheckInDate;
  bool _isCompletedToday = false;
  List<RewardModel> _customRewards = [];
  Set<String> _unlockedBadgeIds = {};

  StreakController(this._storage);

  int get streak => _streak;
  bool get isCompletedToday => _isCompletedToday;
  DateTime? get lastCheckInDate => _lastCheckInDate;
  List<RewardModel> get customRewards => List.unmodifiable(_customRewards);
  Set<String> get unlockedBadgeIds => Set.unmodifiable(_unlockedBadgeIds);

  /// Inicializa o controlador carregando os dados e validando o estado da ofensiva
  Future<void> initialize() async {
    _streak = _storage.getStreak();
    _lastCheckInDate = _storage.getLastCheckInDate();
    _unlockedBadgeIds = _storage.getUnlockedBadges().toSet();
    _customRewards = _storage.getRewards();

    _validateStreakStatus();
    notifyListeners();
  }

  /// Normaliza uma data para o início do dia (00:00:00) no fuso local
  DateTime _normalizeDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Lógica de Reinício e Validação de Datas da Ofensiva
  void _validateStreakStatus() {
    final now = DateTime.now();
    final today = _normalizeDate(now);

    if (_lastCheckInDate == null) {
      _isCompletedToday = false;
      _streak = 0;
      _storage.saveStreak(0);
      return;
    }

    final last = _normalizeDate(_lastCheckInDate!);
    final differenceInDays = today.difference(last).inDays;

    if (differenceInDays == 0) {
      // Já registrado hoje
      _isCompletedToday = true;
    } else if (differenceInDays == 1) {
      // Registrado ontem: a ofensiva continua ativa aguardando o registro de hoje
      _isCompletedToday = false;
    } else if (differenceInDays > 1) {
      // Passou mais de 1 dia: quebra da sequência, reinicia para 0
      _streak = 0;
      _isCompletedToday = false;
      _storage.saveStreak(0);
    } else {
      // Relógio do dispositivo recuado
      _isCompletedToday = true;
    }
  }

  /// Executa o Check-in Diário
  /// Retorna a lista de insígnias recém-desbloqueadas para celebrar na UI
  Future<List<BadgeModel>> performCheckIn() async {
    _validateStreakStatus();

    if (_isCompletedToday) {
      return [];
    }

    final today = _normalizeDate(DateTime.now());
    _streak++;
    _lastCheckInDate = today;
    _isCompletedToday = true;

    // Salvar estado principal
    await _storage.saveStreak(_streak);
    await _storage.saveLastCheckInDate(today);

    // Verificar desbloqueio de insígnias predefinidas
    final newlyUnlocked = <BadgeModel>[];
    for (final badge in BadgeModel.defaultBadges) {
      if (_streak >= badge.requiredDays && !_unlockedBadgeIds.contains(badge.id)) {
        _unlockedBadgeIds.add(badge.id);
        newlyUnlocked.add(badge);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await _storage.saveUnlockedBadges(_unlockedBadgeIds.toList());
    }

    notifyListeners();
    return newlyUnlocked;
  }

  /// Adicionar nova recompensa personalizada
  Future<void> addCustomReward({
    required String title,
    required int targetDays,
    required IconData icon,
  }) async {
    final newReward = RewardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      targetDays: targetDays,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily,
      iconFontPackage: icon.fontPackage,
    );

    _customRewards.add(newReward);
    // Ordena do menor alvo para o maior
    _customRewards.sort((a, b) => a.targetDays.compareTo(b.targetDays));

    await _storage.saveRewards(_customRewards);
    notifyListeners();
  }

  /// Remover uma recompensa personalizada
  Future<void> removeCustomReward(String id) async {
    _customRewards.removeWhere((r) => r.id == id);
    await _storage.saveRewards(_customRewards);
    notifyListeners();
  }

  /// Força revalidação (por exemplo, quando o app volta do background)
  void refreshStatus() {
    _validateStreakStatus();
    notifyListeners();
  }

  /// Desfaz o check-in realizado hoje (caso tenha clicado sem querer)
  Future<void> undoTodayCheckIn() async {
    if (!_isCompletedToday) return;

    _streak = (_streak - 1).clamp(0, 999999);
    _isCompletedToday = false;

    if (_streak > 0) {
      // Volta o último registro para ontem para que a ofensiva continue viva
      final yesterday = _normalizeDate(DateTime.now().subtract(const Duration(days: 1)));
      _lastCheckInDate = yesterday;
      await _storage.saveLastCheckInDate(yesterday);
    } else {
      _lastCheckInDate = null;
      await _storage.saveLastCheckInDate(DateTime.fromMillisecondsSinceEpoch(0));
    }

    await _storage.saveStreak(_streak);
    notifyListeners();
  }

  /// Reinicia a ofensiva manualmente para 0
  Future<void> resetStreak() async {
    _streak = 0;
    _lastCheckInDate = null;
    _isCompletedToday = false;

    await _storage.saveStreak(0);
    await _storage.saveLastCheckInDate(DateTime.fromMillisecondsSinceEpoch(0));
    notifyListeners();
  }
}
