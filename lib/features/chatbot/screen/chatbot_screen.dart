import 'package:flutter/material.dart';
import 'package:medife/components/custom_app_bar.dart';
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
  late final FlutterTts _tts;

  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final ScrollController scrollController = ScrollController();

  late stt.SpeechToText speech;
  bool isListening = false;
  String? accessToken;
  int? sessionId;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.5);
    _tts.setVolume(1.0);

    speech = stt.SpeechToText();
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
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
    const double baseOffset = 92.0;
    final double bottomOffset = keyboardHeight + baseOffset;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: '챗봇',
        onBack: () => Navigator.of(context).pop(),
        onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/landing', (r) => false),
        height: kToolbarHeight,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: topInset),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedList(
                    key: _listKey,
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12 + 72),
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
                SafeArea(
                  top: false,
                  child: ChatInputField(
                    controller: controller,
                    onSend: sendMessageToServer,
                  ),
                ),
              ],
            ),
          ),
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
    );
  }

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
