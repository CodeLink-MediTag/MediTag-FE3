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
  final MediStartSelectionData? selectionData;

  const MediStartScreen({Key? key, this.selectionData}) : super(key: key);

  @override
  _MediStartScreenState createState() => _MediStartScreenState();
}

class _MediStartScreenState extends State<MediStartScreen> {
  final TextEditingController _medicineNameCtrl = TextEditingController();
  File? _selectedImage;
  final List<String> _recordings = ['녹음 1', '녹음 2', '녹음 3'];
  String? _selectedRecording;

  @override
  void initState() {
    super.initState();
    final data = widget.selectionData;
    if (data != null) {
      _medicineNameCtrl.text = data.name!;
      _selectedRecording = data.characteristic;
      if (data.imageUrl != null) {
        _selectedImage = File(data.imageUrl!);
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _onNext() {
    if (_medicineNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('약 이름을 입력해주세요.')),
      );
      return;
    }

    final data = MediStartSelectionData(
      name: _medicineNameCtrl.text.trim(),
      characteristic: _selectedRecording,
      imageUrl: _selectedImage?.path,
    );

    Navigator.of(context)
        .push<bool>(
      MaterialPageRoute(
        builder: (_) => MediMiddleScreen(selectionData: data),
      ),
    )
        .then((middleResult) {
      if (middleResult == true) {
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
