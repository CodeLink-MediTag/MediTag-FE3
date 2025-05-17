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
      backgroundColor: Color(0xFFF6F6F6),
      body: Stack(
        children: [
          Column(
            children: [
              // 상단 바
              ChatTopBar(
                onBack: () {
                  Navigator.pop(context); // 현재 화면 종료 (이전 화면으로 돌아감)
                },
                onHome: () {},
              ),

              // 메시지 리스트
              Expanded(
                child: AnimatedList(
                  key: _listKey,
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
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
    // 로그인 확인하기
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');

    // 토큰 서버로 보내서 세션 생성하고 id 받아오기
    final request = SessionCreationRequestModel(accessToken: accessToken!);
    // 생성한 세션 id 를 저장해놓기
    try {
      sessionId = await chatRepository.sessionCreation(request);
    } catch (e) {
      print('채팅 생성 오류$e');
    }
  }

  // 사용자 질문 서버에 전송 및 응답 받기
  Future<void> sendMessageToServer(String userMessage) async {
    final answer;

    if (sessionId == null || accessToken == null) return;

    try {
      answer = await chatRepository.sendMessage(SendMessageRequestModel(
        accessToken: accessToken!,
        sessionId: sessionId!,
        content: userMessage,
      ));
    } catch (e) {
      print('채팅 오류: $e');
      return null;
    }

    // 메시지 추가 후 애니메이션 적용
    setState(() {
      controller.text = "";
      messages.add({'type': 'user', 'text': userMessage}); // 사용자 메시지 추가
      messages.add({'type': 'bot', 'text': answer}); // 봇 응답 메시지 추가
    });

    // 애니메이션으로 새로운 항목 삽입
    _listKey.currentState?.insertItem(messages.length - 1, duration: Duration(milliseconds: 300));

    // 화면 아래로 내리기
    Future.delayed(Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // 음성녹음
  void listen() async {
    if (!isListening) {
      bool available = await speech.initialize(); // 마이크 접근 권한 확인
      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (val) async {
            // val에 음성인식 결과 담김
            if (val.hasConfidenceRating && val.confidence > 0) {
              setState(() {
                isListening = false;
                speech.stop();
              });
              sendMessageToServer(val.recognizedWords);
            }
          },
          localeId: 'ko_KR',
          listenMode: stt.ListenMode.dictation, // 연속 듣기 모드
          pauseFor: Duration(seconds: 3), // 3초 이상 정적이면 멈춤
          partialResults: false, // 부분 결과 무시
        );
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }
}