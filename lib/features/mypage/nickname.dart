// lib/features/mypage/mypage/nickname.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/components/custom_app_bar.dart';
import 'package:medife/components/custom_primary_button.dart';

class Nickname extends StatefulWidget {
  final String currentNickname;
  const Nickname({super.key, required this.currentNickname});

  @override
  State<Nickname> createState() => _NicknameState();
}

class _NicknameState extends State<Nickname> {
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = theme.textTheme;

    final labelStyle = t.titleMedium?.copyWith(fontWeight: FontWeight.w600) ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    final fieldTextStyle = t.bodyMedium;
    final buttonTextStyle = t.titleMedium?.copyWith(
      color: cs.onPrimary,
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        top: false, // ✅ 앱바 위 흰 여백 제거
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(bottom: bottomInset),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // ✅ CustomAppBar 적용 + 높이 줄임
                        CustomAppBar(
                          title: '내 정보 수정',
                          onBack: () => Navigator.of(context).pop(),
                          onHome: () => Navigator.pushNamedAndRemoveUntil(
                              context, '/landing', (r) => false),
                          height: kToolbarHeight,
                        ),
                        const SizedBox(height: 24),

                        // 내용 영역
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor:
                                  cs.surfaceVariant ?? cs.surface,
                                  backgroundImage: _imageBytes != null
                                      ? MemoryImage(_imageBytes!)
                                      : null,
                                  child: _imageBytes == null
                                      ? Icon(
                                    Icons.account_circle,
                                    size: 80,
                                    color: cs.onSurface.withOpacity(0.6),
                                  )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('닉네임', style: labelStyle),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _nicknameController,
                                      style: fieldTextStyle,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: theme.inputDecorationTheme
                                            .fillColor ??
                                            cs.surfaceVariant ??
                                            cs.surface,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        hintText: '닉네임을 입력하세요',
                                        hintStyle: t.bodySmall?.copyWith(
                                          color:
                                          cs.onSurface.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (_imageBytes != null)
                                      Text(
                                        '프로필 이미지가 선택되었습니다.',
                                        style: t.bodySmall?.copyWith(
                                          color:
                                          cs.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 18.0),
                          child: CustomPrimaryButton(
                            label: '완료',
                            onPressed: _saveNickname,
                            backgroundColor: cs.primary,
                            textStyle: buttonTextStyle,
                            margin: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
