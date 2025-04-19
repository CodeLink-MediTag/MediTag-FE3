import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medife/features/recording/recordlist.dart';
import 'package:medife/components/custom_app_bar.dart'; // 커스텀 앱바 임포트

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          top: false,
          bottom: false,
          child: Center(
            child: HomeScreen(),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CustomAppBar(title: '주의사항 녹음'), // 커스텀 앱바 사용

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _MainView(),
          ),
        ),
      ],
    );
  }
}

class _MainView extends StatefulWidget {
  @override
  State<_MainView> createState() => _MainViewState();
}

class _MainViewState extends State<_MainView> {
  late Widget content;
  bool mode = true;

  @override
  void initState() {
    super.initState();
    content = Recording(onPressed: switchMode);
  }

  void switchMode() {
    setState(() {
      mode = !mode;
      content = mode
          ? Recording(onPressed: switchMode)
          : RecordingStart(onPressed: switchMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: content),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF547EE8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size(double.infinity, 50),
            textStyle: const TextStyle(fontSize: 20),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecordList()),
            );
          },
          child: const Text('모든 녹음파일'),
        ),
      ],
    );
  }
}

class Recording extends StatelessWidget {
  final VoidCallback onPressed;

  const Recording({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
      ),
      onPressed: onPressed,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent[100],
          border: Border.all(color: Colors.blueAccent, width: 5),
        ),
        child: Center(
          child: Container(
            width: 170,
            height: 170,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
            ),
            child: const Icon(Icons.mic, size: 100, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class RecordingStart extends StatelessWidget {
  final VoidCallback onPressed;

  const RecordingStart({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent[100],
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Container(
            height: 100,
            width: 200,
            child: Center(
              child: Text(
                '00:00:01',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            child: Center(
              child: Text(
                '2024.3.28\n오후 04:26 녹음',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 80),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _circleButton('취소', onPressed),
                _iconCircleButton(Icons.pause, 90),
                _iconCircleButton(Icons.stop, 70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF547EE8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
      ),
    );
  }

  Widget _iconCircleButton(IconData icon, double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF547EE8),
      ),
      child: Icon(icon, size: size / 2, color: Colors.white),
    );
  }
}
