import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medife/components/custom_app_bar.dart';

class CardRegistration extends StatelessWidget {
  const CardRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF547EE8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 80),
            textStyle: const TextStyle(fontSize: 30),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: CustomAppBar(
            title: '시간카드 등록',
            onBack: () => Navigator.of(context).pop(),
            onHome: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/landing',
                    (route) => false, // 스택 초기화
              );
            },
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: _MainView(),
        ),
      ),
    );
  }
}

class _MainView extends StatefulWidget {
  const _MainView({Key? key}) : super(key: key);

  @override
  State<_MainView> createState() => _MainViewState();
}

class _MainViewState extends State<_MainView> {
  String? _selectedLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            _buildTimeButton('아침'),
            const SizedBox(height: 60),
            _buildTimeButton('점심'),
            const SizedBox(height: 60),
            _buildTimeButton('저녁'),
          ],
        ),
        Text(
          '시간을 선택하고 카드를 태그해주세요',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildTimeButton(String label) {
    final isSelected = _selectedLabel == label;
    return ElevatedButton(
      onPressed: () => setState(() => _selectedLabel = label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF547EE8),
        fixedSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isSelected ? 8 : 2,
      ),
      child: Text(label),
    );
  }
}


/*
// card_registration이엇음

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CardRegistration extends StatelessWidget{
  const CardRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Theme(
        data: ThemeData(
            textTheme: TextTheme(
                bodyLarge: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700]
                )
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF547EE8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(500, 80),
                    textStyle: TextStyle(
                        fontSize: 30
                    ),
                    foregroundColor: Colors.white
                )
            )
        ),
        child: Scaffold(
            body: Center(
              child: HomeScreen(),
            )
        ),
      );
  }
}

class HomeScreen extends StatelessWidget{
  const HomeScreen({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          _TopBar(),

          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _MainView()

              )
          )

        ],
      );

  }
}

class _TopBar extends StatelessWidget{
  _TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Container(
        padding: EdgeInsets.only(top: 37, bottom: 12), // 상단바 위쪽 높이 증가
        color: Color(0xFF547EE8), //상단바 컬러
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // 현재 화면 종료 (이전 화면으로 돌아감)

              },
            ),

            Container(
              // height: 70,
                width: 200,
                child: Center(
                  child: Text(
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                      '시간카드 등록'
                  ),
                )

            ),
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {},
            ),

          ],
        ),
      )

    ;
  }
}

class _MainView extends StatelessWidget{
  _MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return

      Container(
        // color: Colors.red,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Select(),
            _Notice()
          ],
        ),
      )
    ;


  }
}

class _Select extends StatelessWidget{
  _Select ({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Expanded(
          child: Container(

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [


                  ElevatedButton(
                    onPressed: (){},
                    child: Text(
                        '아침'
                    ),
                  ),

                  SizedBox(height: 60,),

                  ElevatedButton(
                    onPressed: (){},
                    child: Text(
                        '점심'
                    ),
                  ),

                  SizedBox(height: 60,),

                  ElevatedButton(
                    onPressed: (){},
                    child: Text(
                        '저녁'
                    ),
                  ),

                ],
              )
          )
      )

    ;
  }

}

class _Notice extends StatelessWidget{
  _Notice({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Container(
        child: Text(
            style: Theme.of(context).textTheme.bodyLarge,
            '시간을 선택하고 카드를 태그해주세요'
        ),
      )

    ;
  }
}



 */