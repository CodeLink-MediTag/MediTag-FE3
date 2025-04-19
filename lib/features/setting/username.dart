import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/components/custom_app_bar.dart';

class Username extends StatefulWidget {
  final String currentNickname;
  const Username({super.key, required this.currentNickname});

  @override
  State<Username> createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  late TextEditingController _nicknameController;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.currentNickname);
    _loadImage();
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final base64Str = prefs.getString('profileImageBase64');
    if (base64Str != null) {
      setState(() {
        _imageBytes = base64Decode(base64Str);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImageBase64', base64Encode(bytes));
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveNickname() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', _nicknameController.text);
    Navigator.pop(context, _nicknameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomAppBar(title: '내 정보 수정'), // ✅ 커스텀 앱바로 교체
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
              child: _imageBytes == null
                  ? const Icon(Icons.account_circle, size: 80, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('닉네임', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: _saveNickname,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D8FF7),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('완료', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
