// lib/features/medication/medistart/screen/medistart_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medife/components/custom_app_bar.dart';
import 'package:medife/components/custom_primary_button.dart';

import '../model/medistart_selection_data.dart';
import '../component/medistart_name_field.dart';
import '../component/medistart_image_picker.dart';
import '../component/medistart_recording_dropdown.dart';

import '../../MediMiddle/screen/medimiddle_screen.dart';

class MediStartScreen extends StatefulWidget {
  final DateTime initialDate;

  const MediStartScreen({
    Key? key,
    required this.initialDate,
  }) : super(key: key);

  @override
  _MediStartScreenState createState() => _MediStartScreenState();
}

class _MediStartScreenState extends State<MediStartScreen> {
  final TextEditingController _medicineNameCtrl = TextEditingController();
  File? _selectedImage;
  final List<String> _recordings = ['녹음 1', '녹음 2', '녹음 3'];
  String? _selectedRecording;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _onNext() {
    // ① 약 이름이 비어 있으면 경고 스낵바만 띄우고 다음 단계로 못 넘어감
    if (_medicineNameCtrl.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('약 이름을 입력해주세요.')),
      );
      return;
    }

    // ② 여기는 기존 코드 그대로
    final data = MediStartSelectionData(
      name: _medicineNameCtrl.text.trim(),
      characteristic: _selectedRecording,
      imageUrl: _selectedImage,
    );

    Navigator.of(context)
        .push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            MediMiddleScreen(selectionData: data),
      ),
    )
        .then((middleResult) {
      if (middleResult == true) {
        // MiddleScreen이 true를 돌려줬다면 StartScreen도 true로 pop
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // 하드코딩 흰색 제거 -> 테마의 scaffoldBackgroundColor 사용
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAppBar(
          title: '복약 알림 등록',
          onBack: () => Navigator.of(context).pop(),
          onHome: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/landing', (_) => false);
          },
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // 키보드가 올라올 때 스크롤 영역 하단에 패딩을 추가
              padding: EdgeInsets.only(bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                // 화면 전체 높이를 최소값으로 잡아 Column의 Expanded/Spacer가 동작하게 함
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      // mainAxisSize.max으로 채워서 IntrinsicHeight + ConstrainedBox 조합이 동작
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        MediStartNameField(controller: _medicineNameCtrl),
                        const SizedBox(height: 24),
                        MediStartImagePicker(
                          selectedImage: _selectedImage,
                          onTap: _pickImage,
                        ),
                        const SizedBox(height: 24),
                        MediStartRecordingDropdown(
                          recordings: _recordings,
                          selectedRecording: _selectedRecording,
                          onChanged: (v) =>
                              setState(() => _selectedRecording = v),
                        ),

                        // Spacer 대신 Expanded를 사용해 남은 공간을 채움
                        const SizedBox(height: 12),
                        // Expanded를 사용해서 버튼 영역까지 아래로 밀리지 않게 함
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false, // 상단 safearea 아님
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: CustomPrimaryButton(
            label: '다음',
            onPressed: _onNext,
            margin: EdgeInsets.zero, // 이미 Padding으로 여백 처리
          ),
        ),
      ),
    );
  }
  ImageProvider<Object> resolveImage(String? src) {
    if (src == null || src.isEmpty) {
      return const AssetImage('assets/images/placeholder.png');
    }
    final s = src.trim();
    if (s.startsWith('http://') || s.startsWith('https://')) {
      return NetworkImage(s);
    }
    return FileImage(File(s));
  }
}