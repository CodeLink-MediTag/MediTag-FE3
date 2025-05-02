import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medife/features/medication/MediEnd.dart';
import 'package:medife/models/selection_data.dart';

class MediMiddle extends StatefulWidget {
  final SelectionData selectionData;

  const MediMiddle({Key? key, required this.selectionData}) : super(key: key);

  @override
  State<MediMiddle> createState() => _MediMiddleState();
}

class _MediMiddleState extends State<MediMiddle> {
  DateTime? _startDate;
  int _days = 1;
  String _selectedPeriodType = ''; // '특정일' or '매일'
  final TextEditingController _daysController = TextEditingController();

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _onPeriodTypeChanged(String type) {
    setState(() {
      _selectedPeriodType = type;
      if (type == '매일') {
        _days = 9999; // 반복으로 처리될 매우 큰 값 (필요에 따라 조정 가능)
        _daysController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('복약 알림 등록'),
        backgroundColor: const Color(0xFF547EE8),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '복용 시작 날짜, 복용 기간을 입력해주세요!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  const Text('복용 시작 날짜', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectStartDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        _startDate != null
                            ? DateFormat('yyyy-MM-dd').format(_startDate!)
                            : '복용 시작일을 선택해주세요.',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('복용 기간', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _onPeriodTypeChanged('특정일'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _selectedPeriodType == '특정일'
                                ? const Color(0xFF547EE8)
                                : Colors.transparent,
                            side: BorderSide(
                              color: _selectedPeriodType == '특정일'
                                  ? const Color(0xFF547EE8)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            '특정일',
                            style: TextStyle(
                              color: _selectedPeriodType == '특정일'
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _onPeriodTypeChanged('매일'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _selectedPeriodType == '매일'
                                ? const Color(0xFF547EE8)
                                : Colors.transparent,
                            side: BorderSide(
                              color: _selectedPeriodType == '매일'
                                  ? const Color(0xFF547EE8)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            '매일',
                            style: TextStyle(
                              color: _selectedPeriodType == '매일'
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  if (_selectedPeriodType == '특정일') ...[
                    const Text('며칠 동안 드시나요?', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _daysController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              hintText: '예) 3',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _days = int.tryParse(value) ?? 1;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('일 동안'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                if (_startDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('복용 시작일을 선택해주세요.')),
                  );
                  return;
                }

                if (_selectedPeriodType.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('복용 기간을 선택해주세요.')),
                  );
                  return;
                }

                if (_selectedPeriodType == '특정일') {
                  if (_daysController.text.trim().isEmpty || _days < 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('복용 일수를 올바르게 입력해주세요.')),
                    );
                    return;
                  }
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MediEnd(
                      selectionData: widget.selectionData.copyWith(
                        startDate: _startDate,
                        days: _days,
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF547EE8),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('다음', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
