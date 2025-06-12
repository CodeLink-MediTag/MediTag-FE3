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
    if (_medicineNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('약 이름을 입력해주세요.')),
      );
      return;
    }

    // ② 여기는 기존 코드 그대로
    final data = MediStartSelectionData(
      name:           _medicineNameCtrl.text.trim(),
      characteristic: _selectedRecording,
      imageUrl:       _selectedImage?.path,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAppBar(
          title: '복약 알림 등록',
          onBack: () => Navigator.of(context).pop(),
          onHome: () {
            Navigator.pushNamedAndRemoveUntil(context, '/landing', (_) => false);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
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
                onChanged: (v) => setState(() => _selectedRecording = v),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: CustomPrimaryButton(
          label: '다음',
          onPressed: _onNext,
          // 이미 외부에서 Padding으로 여백 주었으니
          margin: EdgeInsets.zero,
        ),
      ),
    );
  }
}