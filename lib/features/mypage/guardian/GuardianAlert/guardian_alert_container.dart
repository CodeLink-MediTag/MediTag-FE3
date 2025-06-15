import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'guardian_alert_view.dart';
import 'package:medife/features/mypage/guardian/guardian_api.dart';
import 'package:medife/features/mypage/guardian/GuardianEdit/guardian_edit_container.dart';

class GuardianAlert extends StatefulWidget {
  const GuardianAlert({Key? key}) : super(key: key);

  @override
  State<GuardianAlert> createState() => _GuardianAlertState();
}

class _GuardianAlertState extends State<GuardianAlert> {
  final _api = GuardianApi();
  List<GuardianResponse> _guards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGuards();
  }

  Future<void> _loadGuards() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token != null) {
      _guards = await _api.fetchAll(token);
    }
    setState(() => _loading = false);
  }

  Future<void> _deleteGuardian(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;
    await _api.delete(token, id);
    await _loadGuards();
  }

  void _onAddPressed() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const GuardianEdit()))
        .then((_) => _loadGuards());
  }

  @override
  Widget build(BuildContext context) {
    return GuardianAlertView(
      loading:       _loading,
      guards:        _guards,
      onDelete:      _deleteGuardian,
      onAddPressed:  _onAddPressed,
    );
  }
}
