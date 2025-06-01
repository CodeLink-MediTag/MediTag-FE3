import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

void main(){
  runApp(MaterialApp(
    home: Scaffold(
      body: OcrCheckPage(),
    ),
  ));
}

class OcrCheckPage extends StatefulWidget {
  @override
  State<OcrCheckPage> createState() => _OcrCheckPageState();
}

class _OcrCheckPageState extends State<OcrCheckPage> {
  final picker = ImagePicker();
  final FlutterTts tts = FlutterTts();

  String resultText = "";

  Future<void> pickImageAndDetectText() async {
    final picked = await picker.pickImage(source: ImageSource.gallery); // or camera
    if (picked == null) return;

    final inputImage = InputImage.fromFile(File(picked.path));
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    final text = recognizedText.text;
    print("전체 텍스트: $text");

    final timeKeywords = ["아침", "점심", "저녁"];
    final detected = timeKeywords.where((keyword) => text.contains(keyword)).toList();

    if (detected.isNotEmpty) {
      final detectedStr = detected.join(", ");
      resultText = "$detectedStr 복용 시간이 감지되었습니다.";
      await tts.speak(resultText);
    } else {
      resultText = "약 복용 시간이 감지되지 않았습니다.";
      await tts.speak(resultText);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("약 복용 시간 OCR")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickImageAndDetectText,
              child: Text("약 봉투 이미지 선택"),
            ),
            SizedBox(height: 20),
            Text(resultText, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
