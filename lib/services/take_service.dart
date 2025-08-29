// lib/services/take_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class TakeService {
  // key: taken:YYYY-MM-DD:medId:alarmIso
  static String _keyFor({
    required int medicineId,
    required String date, // yyyy-MM-dd
    required String alarmIso, // alarmTime.toIso8601String()
  }) =>
      'taken:$date:$medicineId:$alarmIso';

  /// 로컬에 저장된 복용 여부 확인
  static Future<bool> isTakenLocal({
    required int medicineId,
    required String date,
    required String alarmIso,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(medicineId: medicineId, date: date, alarmIso: alarmIso);
    return prefs.getBool(key) ?? false;
  }

  /// 로컬에 복용 완료로 표시
  static Future<void> markTakenLocal({
    required int medicineId,
    required String date,
    required String alarmIso,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(medicineId: medicineId, date: date, alarmIso: alarmIso);
    await prefs.setBool(key, true);
  }

  /// 로컬에서 복용 완료 기록 삭제 (필요시)
  static Future<void> clearTakenLocal({
    required int medicineId,
    required String date,
    required String alarmIso,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(medicineId: medicineId, date: date, alarmIso: alarmIso);
    await prefs.remove(key);
  }
}
