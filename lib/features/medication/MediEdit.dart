import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medife/features/medication/MediDetail.dart';


class MediEdit extends StatefulWidget {
  final String name;
  final DateTime startDate;
  final int duration;
  final String selectedTime;
  final String selectedFrequency;
  final TimeOfDay alarmTime;

  MediEdit({
    required this.name,
    required this.startDate,
    required this.duration,
    required this.selectedTime,
    required this.selectedFrequency,
    required this.alarmTime,
  });

  @override
  _MediEditState createState() => _MediEditState();
}

class _MediEditState extends State<MediEdit> {
  late TextEditingController nameController;
  late TextEditingController durationController;
  late DateTime startDate;
  late String selectedTime;
  late String selectedFrequency;
  late TimeOfDay alarmTime;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    durationController = TextEditingController(text: widget.duration.toString());
    startDate = widget.startDate;
    selectedTime = widget.selectedTime;
    selectedFrequency = widget.selectedFrequency;
    alarmTime = widget.alarmTime;
  }

  void _saveChanges() {
    Navigator.pop(context, {
      'name': nameController.text,
      'startDate': startDate,
      'duration': int.parse(durationController.text),
      'selectedTime': selectedTime,
      'selectedFrequency': selectedFrequency,
      'alarmTime': alarmTime,
    });
  }

  Future<void> _pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> _pickAlarmTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: alarmTime,
    );
    if (picked != null) {
      setState(() => alarmTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: Column(
        children: [
          Container(
            color: Color(0xFF547EE8),
            padding: EdgeInsets.only(top: 37, bottom: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Center(
                  child: Text(
                    '정보 수정',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFF547EE8), width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: "약 이름"),
                        ),
                        ListTile(
                          title: Text("복용 시작 날짜: ${DateFormat('yyyy-MM-dd').format(startDate)}"),
                          trailing: Icon(Icons.calendar_today),
                          onTap: _pickStartDate,
                        ),
                        TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: "복용 기간 (일)"),
                        ),
                        SizedBox(height: 16),
                        Text("복용 시간대", style: TextStyle(fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 10,
                          children: ["아침", "점심", "저녁"].map((time) {
                            return ChoiceChip(
                              label: Text(time),
                              selected: selectedTime == time,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) selectedTime = time;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16),
                        Text("복용 주기", style: TextStyle(fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 10,
                          children: ["1번", "2번", "3번"].map((freq) {
                            return ChoiceChip(
                              label: Text(freq),
                              selected: selectedFrequency == freq,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) selectedFrequency = freq;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        ListTile(
                          title: Text("알림 시간: ${alarmTime.format(context)}"),
                          trailing: Icon(Icons.access_time),
                          onTap: _pickAlarmTime,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20), // 흰색 박스와 버튼 사이 간격 추가

                  // 저장 버튼
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF547EE8),
                      minimumSize: Size(358, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
