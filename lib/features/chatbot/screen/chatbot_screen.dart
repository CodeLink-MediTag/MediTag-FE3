import 'package:flutter/material.dart';
import 'package:medife/components/custom_app_bar.dart'; // 경로 네가 맞게 사용
import 'package:medife/features/chatbot/component/chat_input_field.dart';
import 'package:medife/features/chatbot/component/chat_message.dart';
import 'package:medife/features/chatbot/component/chat_voice_record_button.dart';
import 'package:medife/features/chatbot/model/send_message_request_model.dart';
import 'package:medife/features/chatbot/model/session_creation_request_model.dart';
import 'package:medife/features/chatbot/repository/chat_repository.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final ChatRepository chatRepository = ChatRepository();
  late final FlutterTts _tts; // TTS 인스턴스

  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final ScrollController scrollController = ScrollController();

  // 음성인식
  late stt.SpeechToText speech;
  bool isListening = false;
  String? accessToken;
  int? sessionId;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    // TTS 기본 세팅
    _tts = FlutterTts();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.5);
    _tts.setVolume(1.0);

    speech = stt.SpeechToText();

    // 세션 생성
    chatStart();
  }

  @override
  void dispose() {
    _tts.stop();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 키보드 높이에 따라 마이크가 올라가게 계산
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // 입력창 높이/마진 고려해서 offset 설정 (필요하면 값 조정)
    final double baseOffset = 92.0; // 입력창 위에 띄울 기본 거리 (원하면 조절)
    final double bottomOffset = keyboardHeight + baseOffset;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 앱바 (CustomAppBar는 theme-aware로 만들어져 있어야 함)
                CustomAppBar(
                  title: '챗봇',
                  onBack: () => Navigator.of(context).pop(),
                  onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/landing', (r) => false),
                ),

                // 메시지 리스트
                Expanded(
                  child: AnimatedList(
                    key: _listKey,
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                // 입력창: ChatInputField가 하드코딩 색을 쓰지 않고 Theme을 따르도록 수정되어 있어야 함
                ChatInputField(controller: controller, onSend: sendMessageToServer),
              ],
            ),

            // 마이크 버튼: 화면 하단 중앙에 위치시키고 키보드 있을 때는 위로 올라오게 함
            // left/right 0 + Center로 중앙정렬
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomOffset,
              child: Center(
                child: VoiceRecordButton(
                  isListening: isListening,
                  onPressed: listen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 채팅 세션 생성
  Future<void> chatStart() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken');
    if (accessToken == null) return;

    final request = SessionCreationRequestModel(accessToken: accessToken!);
    try {
      sessionId = await chatRepository.sessionCreation(request);
    } catch (e) {
      debugPrint('채팅 생성 오류: $e');
    }
  }

  // 서버로 보내고 리스트에 추가
  Future<void> sendMessageToServer(String userMessage) async {
    if (sessionId == null || accessToken == null) return;

    setState(() {
      controller.clear();
      messages.add({'type': 'user', 'text': userMessage});
      _listKey.currentState?.insertItem(messages.length - 1, duration: const Duration(milliseconds: 300));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    String? answer;
    try {
      answer = await chatRepository.sendMessage(
        SendMessageRequestModel(
          accessToken: accessToken!,
          sessionId: sessionId!,
          content: userMessage,
        ),
      );
    } catch (e) {
      debugPrint('채팅 오류: $e');
      return;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        messages.add({'type': 'bot', 'text': answer ?? ''});
        _listKey.currentState?.insertItem(messages.length - 1, duration: const Duration(milliseconds: 300));
      });

      if ((answer ?? '').isNotEmpty) {
        _tts.speak(answer!);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  // 음성 녹음 토글
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
