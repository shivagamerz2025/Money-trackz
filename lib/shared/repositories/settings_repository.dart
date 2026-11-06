import 'package:riverpod/riverpod.dart';
import 'package:hive/hive.dart';
import '../models/currency.dart';

/// Settings repository for app preferences
class SettingsRepository {
  final Box _box;

  SettingsRepository(this._box);

  static const _currencyKey = 'currency';
  static const _themeModeKey = 'themeMode';
  static const _firstRunKey = 'firstRun';

  /// Get selected currency
  Currency getCurrency() {
    final code = _box.get(_currencyKey) as String?;
    return Currency.fromCode(code ?? 'USD');
  }

  /// Set selected currency
  Future<void> setCurrency(Currency currency) async {
    await _box.put(_currencyKey, currency.code);
  }

  /// Get theme mode (0=system, 1=light, 2=dark)
  int getThemeMode() {
    return _box.get(_themeModeKey, defaultValue: 0) as int;
  }

  /// Set theme mode
  Future<void> setThemeMode(int mode) async {
    await _box.put(_themeModeKey, mode);
  }

  /// Check if first run
  bool isFirstRun() {
    return _box.get(_firstRunKey, defaultValue: true) as bool;
  }

  /// Mark first run complete
  Future<void> setFirstRunComplete() async {
    await _box.put(_firstRunKey, false);
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _box.clear();
  }
}

/// Provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final box = Hive.box('settings');
  return SettingsRepository(box);
});