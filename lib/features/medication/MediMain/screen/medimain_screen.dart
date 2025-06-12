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
      // 토큰이 없으면 빈 화면 처리
      setState(() {
        _isLoading = false;
        _medicines = [];
        _favoriteMedName = null;
      });
      return;
    }

    setState(() { _isLoading = true; });

    // 2) 오늘 날짜 약 리스트 가져오기
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<Medicine> meds;
    try {
      meds = await _repo.fetchMedicines(_token!, today);
    } catch (_) {
      meds = [];
    }

    // 3) 로컬에 저장된 favoriteMedicine 키 읽어서 반영
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
  /// _favoriteMedName 과 리스트의 isFavorite 에 반영
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

  /// 즐겨찾기 토글 로직 일단 임시임
  Future<void> _toggleFavorite(Medicine med) async {
    // 1) 이전에 즐겨찾기 된 약 모두 해제
    for (var other in _medicines) {
      other.isFavorite = false;
    }

    // 2) 선택된 약만 토글
    med.isFavorite = !med.isFavorite;

    // 3) 로컬에 저장 (한 번에 하나만 저장)
    final prefs = await SharedPreferences.getInstance();
    if (med.isFavorite) {
      await prefs.setString('favoriteMedicine', med.medicineName);
    } else {
      await prefs.remove('favoriteMedicine');
    }

    // 4) 화면 갱신
    setState(() {});
  }

  void _toggleTaking(Medicine med, Alarm alarm) {
    setState(() => alarm.taking = !alarm.taking);
    if (_token != null) {
      _repo.updateTaking(_token!, med, alarm);
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
    // 인사말 문구
    final greeting = _favoriteMedName != null
        ? '$_favoriteMedName 약 복용 하셨나요?'
        : '좋은 하루 보내세요';

    return Scaffold(
      appBar: MediMainAppBar(
        onBack: () => Navigator.pop(context),
        onCalendar: () => Navigator.pushNamed(context, '/calendar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicines.isEmpty
          ? const Center(child: Text('등록된 약이 없습니다.'))
          : Column(
        children: [
          // 약 리스트
          Expanded(
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
                );
              },
            ),
          ),
        ],
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
              if (result == true) _loadAll();
            });
        },
      )
    );
  }
}
