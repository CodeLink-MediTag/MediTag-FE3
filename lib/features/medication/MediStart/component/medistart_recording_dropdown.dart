import 'package:flutter/material.dart';

class MediStartRecordingDropdown extends StatelessWidget {
  final List<String> recordings;
  final String? selectedRecording;
  final ValueChanged<String?> onChanged;

  const MediStartRecordingDropdown({
    Key? key,
    required this.recordings,
    required this.selectedRecording,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '녹음하신 주의사항이 있다면 선택해주세요.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedRecording,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          hint: const Text('녹음 1'),
          onChanged: onChanged,
          items: recordings.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}
