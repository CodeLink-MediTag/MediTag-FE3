import 'package:flutter/material.dart';
import 'package:medife/components/custom_app_bar.dart'; // CustomAppBar 경로 맞게 수정하세요
import 'package:medife/features/chatbot/component/chat_input_field.dart';
import 'package:medife/features/chatbot/component/chat_message.dart';
import 'package:medife/features/chatbot/component/chat_voice_record_button.dart';
import 'package:medife/features/chatbot/model/send_message_request_model.dart';
import 'package:medife/features/chatbot/model/session_creation_request_model.dart';
import 'package:medife/features/chatbot/repository/chat_repository.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  ChatRepository chatRepository = ChatRepository();

  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final ScrollController scrollController = ScrollController();

  // 음성인식을 위해 필요한 맴버변수
  late stt.SpeechToText speech;
  bool isListening = false;
  String? accessToken;
  int? sessionId;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    // 채팅 세션 생성
    chatStart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          Column(
            children: [
              // 커스텀 앱바
              CustomAppBar(
                title: '챗봇',
                onBack: () {
                  Navigator.pop(context);
                },
                onHome: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
                },
              ),

              // 메시지 리스트
              Expanded(
                child: AnimatedList(
                  key: _listKey,
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  initialItemCount: messages.length,
                  itemBuilder: (context, index, animation) {
                    final msg = messages[index];
                    return SizeTransition(
                      sizeFactor: animation,
                      child: msg['type'] == 'user'
                          ? Message(message: msg['text']!, alignLeft: false)
                          : Message(message: msg['text']!),
                    );
                  },
                ),
              ),

              // 입력창 & 버튼
              ChatInputField(controller: controller, onSend: sendMessageToServer),
            ],
          ),

          // 중앙 음성 녹음 아이콘
          VoiceRecordButton(
            isListening: isListening,
            onPressed: listen,
          ),
        ],
      ),
    );
  }

  // 채팅 시작
  Future<void> chatStart() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');

    final request = SessionCreationRequestModel(accessToken: accessToken!);
    try {
      sessionId = await chatRepository.sessionCreation(request);
    } catch (e) {
      print('채팅 생성 오류$e');
    }
  }

  // 사용자 질문 서버에 전송 및 응답 받기
  Future<void> sendMessageToServer(String userMessage) async {
    if (sessionId == null || accessToken == null) return;

    String? answer;
    try {
      answer = await chatRepository.sendMessage(SendMessageRequestModel(
        accessToken: accessToken!,
        sessionId: sessionId!,
        content: userMessage,
      ));
    } catch (e) {
      print('채팅 오류: $e');
      return;
    }

    setState(() {
      controller.text = "";
      messages.add({'type': 'user', 'text': userMessage});
      messages.add({'type': 'bot', 'text': answer ?? ''});
    });

    _listKey.currentState?.insertItem(messages.length - 1, duration: const Duration(milliseconds: 300));

    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // 음성녹음
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
          pauseFor: const Duration(seconds: 3),
          partialResults: false,
        );
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }
}
