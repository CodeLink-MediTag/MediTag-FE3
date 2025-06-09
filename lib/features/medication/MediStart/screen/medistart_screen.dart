import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/medistart_selection_data.dart';
import '../component/medistart_app_bar.dart';
import '../component/medistart_name_field.dart';
import '../component/medistart_image_picker.dart';
import '../component/medistart_recording_dropdown.dart';
import '../component/medistart_next_button.dart';

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
      backgroundColor: const Color(0xFFF3F5FA),
      appBar: MediStartAppBar(onClose: () => Navigator.pop(context)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              MediStartNameField(controller: _medicineNameCtrl),
              const SizedBox(height: 24),
              MediStartImagePicker(selectedImage: _selectedImage, onTap: _pickImage),
              const SizedBox(height: 24),
              MediStartRecordingDropdown(
                recordings: _recordings,
                selectedRecording: _selectedRecording,
                onChanged: (v) => setState(() => _selectedRecording = v),
              ),
              const Spacer(),
              MediStartNextButton(onPressed: _onNext),
            ],
          ),
        ),
      ),
    );
  }
}
