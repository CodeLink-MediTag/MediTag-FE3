import 'package:flutter/material.dart';
import '../../components/custom_app_bar.dart';


class AlertSound extends StatefulWidget {
  @override
  _AlertSoundPageState createState() => _AlertSoundPageState();
}

class _AlertSoundPageState extends State<AlertSound> {
  String selectedSound = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      // 1) CustomAppBar 사용
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: '알림음',
          // fontSize 같은 옵션이 있다면 여기에 넘겨줄 수 있습니다.
        ),
      ),

      // 2) body는 기존에 쓰시던 Column → ListView로 바꿔도 되고,
      //    Column 안에 Expanded(ListView)로 쓰셔도 됩니다.
      body: ListView(
        children: [
          _buildSoundTile('알림음1'),
          _buildDivider(),
          _buildSoundTile('알림음2'),
          _buildDivider(),
          _buildSoundTile('알림음3'),
        ],
      ),
    );
  }

  Widget _buildSoundTile(String soundName) {
    return Container(
      color: Colors.white, // 알림음 칸만 흰색
      child: ListTile(
        title: Text(
          soundName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400), // 폰트 크기 20, Regular 적용
        ),
        trailing: Checkbox(
          value: selectedSound == soundName,
          activeColor: const Color(0xFF61B781),
          onChanged: (checked) {
            setState(() {
              selectedSound = (checked! ? soundName : "");
            });
          },
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 2,
      color: Color(0xFFDADADA),
      width: double.infinity, // 좌우 여백 없이 끝까지
    );
  }
}


