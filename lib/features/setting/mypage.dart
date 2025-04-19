import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/features/setting/username.dart';
import 'package:medife/features/setting/protectorAlert.dart';
import 'package:medife/features/setting/protectorEdit.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String _nickname = '김먀먀';
  Uint8List? _profileBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('nickname') ?? '김먀먀';
      final base64Image = prefs.getString('profileImageBase64');
      if (base64Image != null) {
        _profileBytes = base64Decode(base64Image);
      }
    });
  }

  Future<void> _navigateToEditNickname() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Username(currentNickname: _nickname)),
    );
    if (result != null && result is String) {
      setState(() {
        _nickname = result;
      });
      await _loadUserData(); // 새로고침
    }
  }

  Future<void> _navigateToGuardianPage() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('guardianPhone');
    final relation = prefs.getString('guardianName');

    if (phone != null && relation != null && phone.isNotEmpty && relation.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProtectorAlert(
            userName: _nickname,
            phoneNumber: phone,
            guardianName: relation,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProtectorEdit()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: const Color(0xFF547EE8),
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          '마이페이지',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _profileBytes != null ? MemoryImage(_profileBytes!) : null,
                  child: _profileBytes == null
                      ? const Icon(Icons.account_circle, size: 60, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                const Text('ID : aaaaaa', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  '$_nickname님,\n안온한 하루 되세요.',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: const [
                Icon(Icons.medication, color: Colors.redAccent),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("오늘 복용한 약", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("3번 중 2번"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem("내 정보 수정", _navigateToEditNickname),
                _buildMenuItem("보호자 알림", _navigateToGuardianPage),
                _buildMenuItem("보기 방식 변경", () {}),
                _buildMenuItem("로그아웃", () {}),
                _buildMenuItem("회원탈퇴", () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: Border(bottom: BorderSide(color: Colors.grey.shade300)),
    );
  }
}
