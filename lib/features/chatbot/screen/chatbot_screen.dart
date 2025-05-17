import 'package:flutter/material.dart';
import 'package:medife/features/chatbot/component/chat_input_field.dart';
import 'package:medife/features/chatbot/component/chat_top_bar.dart';
import 'package:medife/features/chatbot/component/chat_message.dart';
import 'package:medife/features/chatbot/component/chat_voice_record_button.dart';
import 'package:medife/features/chatbot/model/send_message_request_model.dart';
import 'package:medife/features/chatbot/model/session_creation_request_model.dart';
import 'package:medife/features/chatbot/repository/chat_repository.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medife/routes/animations/slide_transition_page_route.dart';
import '../../../screens/landing.dart';

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  ChatRepository chatRepository = ChatRepository();

  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final ScrollController scrollController = ScrollController();

  late stt.SpeechToText speech;
  bool isListening = false;
  String? accessToken;
  int? sessionId;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    chatStart();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          SlideTransitionPageRoute(page: Landing()),
        );
        return false; // 기본 pop 방지
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF6F6F6),
        body: Stack(
          children: [
            Column(
              children: [
                ChatTopBar(
                  onBack: () {
                    Navigator.pushReplacement(
                      context,
                      SlideTransitionPageRoute(page: Landing()),
                    );
                  },
                  onHome: () {},
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return msg['type'] == 'user'
                          ? Message(message: msg['text']!, alignLeft: false)
                          : Message(message: msg['text']!);
                    },
                  ),
                ),
                ChatInputField(controller: controller, onSend: sendMessageToServer),
              ],
            ),
            VoiceRecordButton(isListening: isListening, onPressed: listen),
          ],
        ),
      ),
    );
  }

  Future<void> chatStart() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');

    final request = SessionCreationRequestModel(accessToken: accessToken!);
    try {
      sessionId = await chatRepository.sessionCreation(request);
    } catch (e) {
      print('채팅 생성 오류: $e');
    }
  }

  Future<void> sendMessageToServer(String userMessage) async {
    if (sessionId == null || accessToken == null) return;

    try {
      final answer = await chatRepository.sendMessage(
        SendMessageRequestModel(
          accessToken: accessToken!,
          sessionId: sessionId!,
          content: userMessage,
        ),
      );

      setState(() {
        controller.text = "";
        messages.add({'type': 'user', 'text': userMessage});
        messages.add({'type': 'bot', 'text': answer});
      });

      Future.delayed(Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      print('채팅 오류: $e');
    }
  }

  void listen() async {
    if (!isListening) {
      bool available = await speech.initialize();
      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (val) async {
            if (val.hasConfidenceRating && val.confidence > 0) {
              setState(() {
                isListening = false;
                speech.stop();
              });
              sendMessageToServer(val.recognizedWords);
            }
          },
          localeId: 'ko_KR',
          listenMode: stt.ListenMode.dictation,
          pauseFor: Duration(seconds: 3),
          partialResults: false,
        );
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }
}