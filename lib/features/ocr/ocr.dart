import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../components/custom_app_bar.dart';


class OcrScreen extends StatefulWidget {
  @override
  _OcrScreenState createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  String _resultText = '약 봉투를 앞에 두고 사진을 촬영해주세요.';

  // tts 인스턴스 추가
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _captureImageAndCheckText() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    final text = recognizedText.text;

    // 아침, 점심, 저녁 중 포함된 단어 추출
    List<String> keywords = [];
    if (text.contains('아침')) keywords.add('아침');
    if (text.contains('점심')) keywords.add('점심');
    if (text.contains('저녁')) keywords.add('저녁');

    String spokenText;
    if (keywords.isNotEmpty) {
      spokenText = '${keywords.join(' ')} 약입니다';
    } else {
      spokenText = '약봉투를 카메라 앞에 두고 촬영해주세요';
    }

    // 음성 출력
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(spokenText);

    setState(() {
      _resultText = spokenText;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          CustomAppBar(
            title: '약 시간 확인기',
            onBack: () {
              Navigator.pop(context);
            },
            onHome: () {
              Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
            },
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // 안내 문구
                    Text(
                      '약봉투에 적힌\n아침, 점심, 저녁 중 하나를 인식합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),

                    SizedBox(height: 40),

                    // 촬영 버튼
                    ElevatedButton.icon(
                      onPressed: _captureImageAndCheckText,
                      icon: Icon(Icons.camera_alt, size: 32),
                      label: Text(
                        '약 시간 확인하기',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        elevation: 5,
                      ),
                    ),

                    SizedBox(height: 40),

                    // 결과 텍스트
                    Text(
                      _resultText,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }
}
