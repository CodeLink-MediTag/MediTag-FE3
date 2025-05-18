import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medife/features/calendar/calendar.dart' hide Medicine, Alarm;
import 'package:medife/routes/route_observer.dart';

import '../model/medimain_medicine.dart';
import '../model/medimain_alarm.dart';
import '../repository/medimain_medicine_repository.dart';
import '../component/medimain_app_bar.dart';
import '../component/medimain_medication_card.dart';
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

  @override
  void initState() {
    super.initState();
    _loadToken();
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
    _fetchMedicines();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('accessToken');
    _fetchMedicines();
  }

  Future<void> _fetchMedicines() async {
    if (_token == null) return;
    setState(() => _isLoading = true);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      _medicines = await _repo.fetchMedicines(_token!, today);
    } catch (_) {
      _medicines = [];
    }
    setState(() => _isLoading = false);
  }

  void _toggleTaking(Medicine med, Alarm alarm) {
    setState(() => alarm.taking = !alarm.taking);
    _repo.updateTaking(_token!, med, alarm);
  }

  void _askConfirm(Medicine med, Alarm alarm) {
    final label = DateFormat('a hh:mm', 'ko_KR').format(alarm.alarmTime);
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: Text(med.medicineName),
            content: Text('$label 에 약을 드셨나요?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('아니요'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _toggleTaking(med, alarm);
                },
                child: const Text('네'),
              ),
            ],
          ),
    );
  }

  void _toggleFavorite(Medicine med) {
    setState(() => med.isFavorite = !med.isFavorite);
    _repo.toggleFavorite(_token!, med);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediMainAppBar(
        onBack: () => Navigator.of(context).pop(),
        onCalendar: () =>
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const Calendar()),
            ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicines.isEmpty
          ? const Center(child: Text('등록된 약이 없습니다.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _medicines.length,
        itemBuilder: (_, i) {
          final med = _medicines[i];
          return MedicationCard(
            medicine: med,
            onToggleFavorite: () => _toggleFavorite(med),
            onToggleTaking: (alarm) => _toggleTaking(med, alarm),
            onAskConfirm: (alarm) => _askConfirm(med, alarm),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context)
                .push<bool>(
              MaterialPageRoute(builder: (_) => const MediStartScreen()),
            )
                .then((startResult) {
              if (startResult == true) {
                // Start → Middle → End 까지 모두 true를 돌려줬다면
                // 새로 등록된 약을 다시 불러옵니다.
                _fetchMedicines();
              }
            });
          },
          child: const Text('알림 받을 약 추가'),
        ),
      ),
    );
  }
}
