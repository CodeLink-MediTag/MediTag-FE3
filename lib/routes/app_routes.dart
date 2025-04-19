import 'package:flutter/material.dart';
import 'package:medife/screens/landing.dart';
import 'package:medife/features/sign/login.dart';
import 'package:medife/features/sign/signup.dart';
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


class AppRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.landing:
        return MaterialPageRoute(builder: (_) => const Landing());
      case RouteName.signup:
        return MaterialPageRoute(builder: (_) => Signup());
      case RouteName.chatbot:
        return MaterialPageRoute(builder: (_) => ChatBot());
      case RouteName.calendar:
        return MaterialPageRoute(builder: (_) => Calendar());
      case RouteName.eatlist:
        return MaterialPageRoute(builder: (_) => EatList());
      case RouteName.mediDetail:
        return MaterialPageRoute(builder: (_) => MediDetail());
      case RouteName.mediMain:
        return MaterialPageRoute(builder: (_) => MediMain());
      case RouteName.recording:
        return MaterialPageRoute(builder: (_) => const RecordingScreen());
      case RouteName.recordlist:
        return MaterialPageRoute(builder: (_) => const RecordList());
      case RouteName.alertsound:
        return MaterialPageRoute(builder: (_) => AlertSound());
      case RouteName.mypage:
        return MaterialPageRoute(builder: (_) => const MyPage());
      case RouteName.protectorEdit:
        return MaterialPageRoute(builder: (_) => const ProtectorEdit());
      case RouteName.setting:
        return MaterialPageRoute(builder: (_) => SettingScreen());
      case RouteName.username:
        return MaterialPageRoute(
            builder: (_) => const Username(currentNickname: '000',));

      default:
        return MaterialPageRoute(
          builder: (_) =>
              Scaffold(
                body: Center(child: Text('잘못된 경로: ${settings.name}')),
              ),
        );
    }
  }
}