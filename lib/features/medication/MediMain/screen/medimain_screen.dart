// medimain_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medife/features/calendar/calendar.dart' hide Medicine, Alarm;
import 'package:medife/routes/route_observer.dart';
import '../model/medimain_medicine.dart';
import '../model/medimain_alarm.dart';
import '../component/medimain_app_bar.dart';
import '../component/medimain_medication_card.dart';
import '../repository/medimain_medicine_repository.dart';
import 'package:medife/components/custom_primary_button.dart';
import 'package:medife/features/medication/MediStart/screen/medistart_screen.dart';

class MediMainScreen extends StatefulWidget {
  const MediMainScreen({Key? key}) : super(key: key);

  @override
  _MediMainScreenState createState() => _MediMainScreenState();
}

class _MediMainScreenState extends State<MediMainScreen> with RouteAware {
  final MedicineRepository _repo = MedicineRepository();
  List<Medicine> _medicines = [];
  bool _isLoading = true;
  String? _token;
  String? _favoriteMedName;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadAll();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('accessToken');
    });
    await _fetchMedicines();
  }

  /// 약 리스트 fetch 후 로컬 즐겨찾기 로드
  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('accessToken');
    if (_token == null) {
      setState(() {
        _isLoading = false;
        _medicines = [];
        _favoriteMedName = null;
      });
      return;
    }

    setState(() { _isLoading = true; });

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<Medicine> meds;
    try {
      meds = await _repo.fetchMedicines(_token!, today);
    } catch (_) {
      meds = [];
    }

    final favName = prefs.getString('favoriteMedicine');
    for (var med in meds) {
      med.isFavorite = med.medicineName == favName;
    }

    setState(() {
      _medicines = meds;
      _favoriteMedName = favName;
      _isLoading = false;
    });
  }

  Future<void> _fetchMedicines() async {
    if (_token == null) {
      setState(() {
        _isLoading = false;
        _medicines = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      final meds = await _repo.fetchMedicines(_token!, today);
      setState(() {
        _medicines = meds;
      });
    } catch (e) {
      setState(() {
        _medicines = [];
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  /// 로컬에서 favoriteMedicine 키 읽어서
  Future<void> _loadFavoriteMedicine() async {
    final prefs = await SharedPreferences.getInstance();
    final favName = prefs.getString('favoriteMedicine');
    setState(() {
      _favoriteMedName = favName;
      for (var med in _medicines) {
        med.isFavorite = med.medicineName == favName;
      }
    });
  }

  /// 즐겨찾기 토글 로직 - 로컬 prefs에 favoriteMedicine, favoriteAlarmIso, favoriteMedicineId 저장
  Future<void> _toggleFavorite(Medicine med) async {
    for (var other in _medicines) {
      other.isFavorite = false;
    }

    med.isFavorite = !med.isFavorite;

    final prefs = await SharedPreferences.getInstance();
    if (med.isFavorite) {
      await prefs.setString('favoriteMedicine', med.medicineName);
      await prefs.setInt('favoriteMedicineId', med.medicineId);

      // 가장 가까운 알람(현재 이후 알람, 없으면 첫 알람) 찾아서 저장
      final now = DateTime.now();
      Alarm? nextAlarm;
      final futureAlarms = med.alarms.where((a) => a.alarmTime.isAfter(now)).toList();
      if (futureAlarms.isNotEmpty) {
        nextAlarm = futureAlarms.first;
      } else if (med.alarms.isNotEmpty) {
        nextAlarm = med.alarms.first;
      } else {
        nextAlarm = null;
      }

      if (nextAlarm != null) {
        await prefs.setString('favoriteAlarmIso', nextAlarm.alarmTime.toIso8601String());
      } else {
        await prefs.remove('favoriteAlarmIso');
      }

      // 서버에도 즐겨찾기 반영(선택사항) - 토큰이 있으면 호출
      final token = prefs.getString('accessToken');
      if (token != null) {
        try {
          await _repo.toggleFavorite(token, med);
        } catch (_) {
          // 실패해도 로컬은 반영
        }
      }
    } else {
      await prefs.remove('favoriteMedicine');
      await prefs.remove('favoriteMedicineId');
      await prefs.remove('favoriteAlarmIso');
      // 서버 remove favorite could be called here
    }

    setState(() {});
  }

  /// 알람 '복용' 토글: 서버로 patch 요청 후 로컬 반영
  Future<void> _toggleTaking(Medicine med, Alarm alarm) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    final date = DateFormat('yyyy-MM-dd').format(alarm.alarmTime);
    try {
      await _repo.patchTaking(
        token: token,
        medicineId: med.medicineId,
        alarmIso: alarm.alarmTime.toIso8601String(),
        date: date,
        taking: !alarm.taking,
      );

      // 서버 반영 성공 시 로컬도 토글
      setState(() {
        alarm.taking = !alarm.taking;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('서버 저장 실패: $e')));
    }
  }

  void _askConfirm(BuildContext ctx, Medicine med, Alarm alarm) {
    final label = DateFormat('a hh:mm', 'ko_KR').format(alarm.alarmTime);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(med.medicineName),
        content: Text('$label 에 약을 드셨나요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('아니요')),
          ElevatedButton(onPressed: () {
            Navigator.pop(ctx);
            _toggleTaking(med, alarm);
          }, child: const Text('네')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ✅ MediMain에서 "뒤로가기" 누르면 항상 랜딩으로
        onWillPop: () async {
          Navigator.of(context).pushNamedAndRemoveUntil('/landing', (route) => false);
          return false;
        },
        child: Scaffold(
          appBar: MediMainAppBar(
            // ✅ 상단 뒤로가기 버튼도 랜딩으로
            onBack: () => Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false),
            onCalendar: () => Navigator.pushNamed(context, '/calendar'),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _medicines.isEmpty
              ? const Center(child: Text('등록된 약이 없습니다.'))
              : RefreshIndicator(                       // ✅ 당겨서 새로고침
            onRefresh: _fetchMedicines,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _medicines.length,
              itemBuilder: (ctx, i) {
                final med = _medicines[i];
                return MedicationCard(
                  medicine: med,
                  onToggleFavorite: () => _toggleFavorite(med),
                  onToggleTaking: (alarm) => _toggleTaking(med, alarm),
                  onAskConfirm: (alarm) => _askConfirm(ctx, med, alarm),
                  onEdited: (updatedMed) {
                    setState(() {
                      final idx = _medicines.indexWhere(
                            (m) => m.medicineId == updatedMed.medicineId,
                      );
                      if (idx != -1) _medicines[idx] = updatedMed;
                    });
                  },
                  // (옵션) 카드 내에서 삭제 발생 시를 대비한 콜백이 있다면 여기서 _fetchMedicines() 호출
                );
              },
            ),
          ),
          bottomNavigationBar: CustomPrimaryButton(
            label: '알림 받을 약 추가',
              onPressed: () {
                Navigator.of(context)
                    .push<bool>(
                  MaterialPageRoute(
                    builder: (_) => MediStartScreen(initialDate: DateTime.now()),
                  ),
                )
                    .then((result) {
                  if (result == true) _loadAll(); // ✅ 추가 후 자동 새로고침
                });
              },
          ),
        ),
    );
  }
}
