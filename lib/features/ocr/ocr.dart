/*
import 'dart:typed_data';
import 'dart:io' as io show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR + TTS 데모 (웹 호환)',
      home: const OCRScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  final ImagePicker _picker = ImagePicker();
  final FlutterTts flutterTts = FlutterTts();
  String scannedText = '';
  Uint8List? imageBytes;
  bool isLoading = false;

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        scannedText = '';
        isLoading = true;
      });

      final bytes = await pickedFile.readAsBytes();
      setState(() => imageBytes = bytes);

      if (kIsWeb) {
        setState(() {
          isLoading = false;
          scannedText = '⚠️ 웹에서는 OCR 기능이 지원되지 않습니다.';
        });
        return;
      } else {
        final file = io.File(pickedFile.path);
        await _processInputImage(InputImage.fromFile(file));
      }
    }
  }

  Future<void> _processInputImage(InputImage image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    final recognizedText = await textRecognizer.processImage(image);
    await textRecognizer.close();

    setState(() {
      scannedText = recognizedText.text;
      isLoading = false;
    });

    if (scannedText.isNotEmpty) {
      String spoken = '해당 약은 일반 약입니다';
      if (scannedText.contains('아침')) {
        spoken = '해당 약은 아침약입니다';
      } else if (scannedText.contains('저녁')) {
        spoken = '해당 약은 저녁약입니다';
      }

      await flutterTts.setLanguage("ko-KR");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak(spoken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR + 음성출력 (웹 호환)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (imageBytes != null)
              Image.memory(imageBytes!, height: 250),
            const SizedBox(height: 16),
            if (isLoading)
              const CircularProgressIndicator()
            else if (scannedText.isNotEmpty)
              Text('인식된 텍스트: $scannedText')
            else
              const Text('이미지를 선택하거나 촬영해주세요'),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _getImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('카메라'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _getImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text('갤러리'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}


 */