import 'package:flutter/material.dart';
import 'package:medife/screens/landing.dart';
import 'package:medife/features/login/login.dart';
import 'package:medife/features/calendar/calendar.dart';
import 'package:medife/features/chatbot/chatbot.dart';
import 'package:medife/features/eatlist/eatlist.dart';
import 'package:medife/features/medication/MediDetail.dart';
import 'package:medife/features/medication/MediEdit.dart';
import 'package:medife/features/medication/MediEnd.dart';
import 'package:medife/features/medication/MediMain.dart';
import 'package:medife/features/medication/MediMiddle.dart';
import 'package:medife/features/medication/MediStart.dart';
import 'package:medife/features/ocr/ocr.dart';
import 'package:medife/features/recording/recording.dart';
import 'package:medife/features/recording/recordlist.dart';
import 'package:medife/features/setting/alertsound.dart';
import 'package:medife/features/setting/mypage.dart';
import 'package:medife/features/setting/protectorEdit.dart';
import 'package:medife/features/setting/protectorAlert.dart';
import 'package:medife/features/setting/setting.dart';
import 'package:medife/features/setting/username.dart';
import 'route_names.dart';
import 'animations/slide_transition_page_route.dart'; // 애니메이션 파일 import

class AppRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.landing:
        return _buildRoute(const Landing());
      case RouteName.chatbot:
        return _buildRoute(ChatBot());
      case RouteName.calendar:
        return _buildRoute(Calendar());
      case RouteName.eatlist:
        return _buildRoute(EatList());
      case RouteName.mediDetail:
        return _buildRoute(MediDetail());
      case RouteName.mediMain:
        return _buildRoute(MediMain());
      case RouteName.recording:
        return _buildRoute(const RecordingScreen());
      case RouteName.recordlist:
        return _buildRoute(const RecordList());
      case RouteName.alertsound:
        return _buildRoute(AlertSound());
      case RouteName.mypage:
        return _buildRoute(const MyPage());
      case RouteName.protectorEdit:
        return _buildRoute(const ProtectorEdit());
      case RouteName.protectorAlert:
        final args = settings.arguments as Map<String, String>;
        return _buildRoute(ProtectorAlert(
          userName: args['userName']!,
          phoneNumber: args['phoneNumber']!,
          guardianName: args['guardianName']!,
        ));
      case RouteName.setting:
        return _buildRoute(SettingScreen());
      case RouteName.username:
        return _buildRoute(const Username(currentNickname: '000'));
      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('잘못된 경로: ${settings.name}')),
          ),
        );
    }
  }

  static Route<dynamic> _buildRoute(Widget page) {
    return SlideTransitionPageRoute(page: page); // 슬라이드 애니메이션을 사용하도록 수정
  }
}