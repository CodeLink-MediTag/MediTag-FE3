import 'package:flutter/material.dart';
import 'package:medife/features/calendar/screen/calendar_screen.dart';
import 'package:medife/features/recording/screen/recording_list_screen.dart';
import 'package:medife/screens/landing.dart';
import 'package:medife/features/calendar/calendar.dart';
import 'package:medife/features/chatbot/chatbot.dart';
import 'package:medife/features/medication/MediDetail/MediDetail.dart';
import 'package:medife/features/medication/MediEdit/MediEdit.dart';
import 'package:medife/features/medication/MediEnd/MediEnd.dart';
import 'package:medife/features/medication/MediMain/MediMain.dart';
import 'package:medife/features/medication/MediMiddle/MediMiddle.dart';
import 'package:medife/features/medication/MediStart/MediStart.dart';
import 'package:medife/features/ocr/ocr.dart';
import 'package:medife/features/recording/screen/recording_home_screen.dart';
import 'package:medife/features/setting/alertsound.dart';
import 'package:medife/features/mypage/mypage.dart';
import 'package:medife/features/setting/setting.dart';
import 'package:medife/features/mypage/nickname.dart';
import '../features/eatlist/component/eat-list.dart';
import 'route_names.dart';


class AppRoute {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.landing:
        return MaterialPageRoute(builder: (_) => const Landing());
      case RouteName.chatbot:
        return MaterialPageRoute(builder: (_) => ChatBot());
      case RouteName.eatlist:
        return MaterialPageRoute(builder: (_) => EatList());
      case RouteName.recording:
        return MaterialPageRoute(builder: (_) => const RecordingHomeScreen());
      case RouteName.recordlist:
        return MaterialPageRoute(builder: (_) => const RecordingListScreen());
      case RouteName.alertsound:
        return MaterialPageRoute(builder: (_) => AlertSound());
      case RouteName.mypage:
        return MaterialPageRoute(builder: (_) => const MyPage());
      case RouteName.setting:
        return MaterialPageRoute(builder: (_) => SettingScreen());
      case RouteName.username:
        return MaterialPageRoute(
            builder: (_) => const Nickname(currentNickname: '000',));
      case RouteName.calendar:
        return MaterialPageRoute(builder: (_) => CalendarScreen());
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