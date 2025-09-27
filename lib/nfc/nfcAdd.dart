import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medife/components/custom_app_bar.dart';

class CardRegistration extends StatelessWidget {
  const CardRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomAppBar(
          title: '시간카드 등록',
          onBack: () => Navigator.of(context).pop(),
          onHome: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/landing',
                  (route) => false, // 스택 초기화
            );
          },
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: _MainView(),
      ),
    );
  }
}

class _MainView extends StatefulWidget {
  const _MainView({Key? key}) : super(key: key);

  @override
  State<_MainView> createState() => _MainViewState();
}

class _MainViewState extends State<_MainView> {
  String? _selectedLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme
        .of(context)
        .textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            _buildTimeButton('아침'),
            const SizedBox(height: 60),
            _buildTimeButton('점심'),
            const SizedBox(height: 60),
            _buildTimeButton('저녁'),
          ],
        ),
        Text(
          '시간을 선택하고 카드를 태그해주세요',
          style: textTheme.bodyLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton(String label) {
    final isSelected = _selectedLabel == label;
    final scheme = Theme
        .of(context)
        .colorScheme;

    return Center(
      child: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.85, // 화면의 85%만 차지
        height: 80, // 높이
        child: ElevatedButton(
          onPressed: () => setState(() => _selectedLabel = label),
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            fixedSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: isSelected ? 8 : 2,
            textStyle: const TextStyle(fontSize: 30),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
