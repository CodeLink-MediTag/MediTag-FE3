import 'package:flutter/material.dart';
import 'package:medife/features/medication/MediMain.dart';
import 'package:medife/models/selection_data.dart';

class MediEnd extends StatefulWidget {
  final SelectionData selectionData;

  const MediEnd({super.key, required this.selectionData});

  @override
  State<MediEnd> createState() => _MediEndState();
}

class _MediEndState extends State<MediEnd> {
  final List<String> selectedTimeGroups = [];
  final List<String> selectedTimes = [];

  final Map<String, String> defaultTimes = {
    '아침': '오전 08:00',
    '점심': '오후 01:00',
    '저녁': '오후 07:00',
  };

  void toggleTimeGroup(String group) {
    setState(() {
      final defaultTime = defaultTimes[group];
      if (selectedTimeGroups.contains(group)) {
        selectedTimeGroups.remove(group);
        selectedTimes.remove(defaultTime);
      } else {
        selectedTimeGroups.add(group);
        if (defaultTime != null && !selectedTimes.contains(defaultTime)) {
          selectedTimes.add(defaultTime);
        }
      }
    });
  }

  void toggleTime(String time) {
    setState(() {
      if (selectedTimes.contains(time)) {
        selectedTimes.remove(time);
      } else {
        selectedTimes.add(time);
      }
    });
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$period ${displayHour.toString().padLeft(2, '0')}:$minute';
  }

  Future<void> _addCustomTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );

    if (picked != null) {
      final String formatted = formatTimeOfDay(picked);
      setState(() {
        if (!selectedTimes.contains(formatted)) {
          selectedTimes.add(formatted);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 12),
            color: const Color(0xFF7D8FF7),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      '복약 알림 등록',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '마지막이에요!\n복용 시간대와 알림 받을 시간을 선택 해주세요.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // 원하는 폰트 크기 설정
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    '복용 시간대',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // 폰트 크기 설정
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      spacing: 20,
                      children: ['아침', '점심', '저녁'].map((label) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: selectedTimeGroups.contains(label),
                              onChanged: (_) => toggleTimeGroup(label),
                              activeColor: const Color(0xFF7D8FF7),
                            ),
                            Text(
                              label,
                              style: TextStyle(fontSize: 16), // 폰트 사이즈 지정
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '알림 시간',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // 원하는 크기로 조정
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ...selectedTimes.map((time) => _buildTimeButton(time)),
                        _buildAddTimeButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                SelectionData finalData = widget.selectionData.copyWith(
                  timeGroup: selectedTimeGroups.join(', '),
                  selectedTimes: selectedTimes,
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MediMain(selectionData: finalData),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D8FF7),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('등록', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String time) {
    final bool isSelected = selectedTimes.contains(time);
    return SizedBox(
      width: 100,
      child: GestureDetector(
        onTap: () => toggleTime(time),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7D8FF7) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF7D8FF7)),
          ),
          alignment: Alignment.center,
          child: Text(
            time,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddTimeButton() {
    return SizedBox(
      width: 100,
      child: GestureDetector(
        onTap: _addCustomTime,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF7D8FF7)),
          ),
          alignment: Alignment.center,
          child: const Text(
            '+ 시간 추가',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
