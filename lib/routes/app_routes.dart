import 'package:flutter/material.dart';
import 'package:medife/features/medication/MediMiddle/screen/medimiddle_screen.dart';
import 'package:medife/screens/landing.dart';
import 'package:medife/features/login/login.dart';
import 'package:medife/features/calendar/calendar.dart';
import 'package:medife/features/chatbot/chatbot.dart';
import 'package:medife/features/eatlist/eatlist.dart';
import 'package:medife/features/medication/MediDetail/MediDetail.dart';
import 'package:medife/features/medication/MediEdit/MediEdit.dart';
import 'package:medife/features/medication/MediEnd/screen/mediend_screen.dart';
import 'package:medife/features/medication/MediMain/MediMain.dart';
import 'package:medife/features/medication/MediMiddle/MediMiddle.dart';
import 'package:medife/features/medication/MediStart/screen/medistart_screen.dart';
import 'package:medife/features/ocr/ocr.dart';
import 'package:medife/features/recording/recording.dart';
import 'package:medife/features/recording/recordlist.dart';
import 'package:medife/features/setting/alertsound.dart';
import 'package:medife/features/setting/mypage.dart';
import 'package:medife/features/setting/protectorEdit.dart';
import 'package:medife/features/setting/protectorAlert.dart';
import 'package:medife/features/setting/setting.dart';
import 'package:medife/features/setting/username.dart';

import '../features/login/screen/login_screen.dart';
import '../features/medication/MediMain.dart';
import 'route_names.dart';
import 'animations/slide_transition_page_route.dart';

class AppRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.landing:
        return _buildRoute(const Landing());

      case RouteName.login:
        return _buildRoute(LoginScreen());

      case RouteName.chatbot:
        return _buildRoute(ChatBot());

      case RouteName.calendar:
        return _buildRoute(Calendar());

      case RouteName.eatlist:
        return _buildRoute(EatList());

      case RouteName.mediMain:
        return _buildRoute(MediMain());

      case RouteName.mediStart:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          MediStartScreen(
            selectionData: args?['selectionData'],
          ),
        );

      case RouteName.mediDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['medicine'] == null) {
          return _buildRoute(
            Scaffold(
              body: Center(
                child: Text('medicine 정보가 필요합니다.'),
              ),
            ),
          );
        }
        return _buildRoute(MediDetail(medicine: args['medicine']));

      case RouteName.mediEdit:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['medicine'] == null) {
          return _buildRoute(
            Scaffold(
              body: Center(
                child: Text('medicine 정보가 필요합니다.'),
              ),
            ),
          );
        }
        return _buildRoute(MediEdit(medicine: args['medicine']));

      case RouteName.mediMiddle:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          MediMiddleScreen(
            selectionData: args?['selectionData'],
          ),
        );

      case RouteName.mediEnd:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          MediEndScreen(
            selectionData: args?['selectionData'],
          ),
        );

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
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ProtectorAlert(
            userName: args?['userName'] ?? '',
            phoneNumber: args?['phoneNumber'] ?? '',
            guardianName: args?['guardianName'] ?? '',
          ),
        );

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
    return SlideTransitionPageRoute(page: page);
  }
}
