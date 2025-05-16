import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Signup extends StatelessWidget {

  final TextEditingController usernameController = TextEditingController(text: 'test@gmail.com');
  final TextEditingController nameController = TextEditingController(text: 'test');
  final TextEditingController phoneController = TextEditingController(text: '010-1234-5678');
  final TextEditingController passwordController = TextEditingController(text: 'test12345');

  String responseText = '';

  Future<void> registration(BuildContext context) async{
    var url = Uri.parse('http://localhost:8080/api/member/register');
    var headers = {"Content-Type": "application/json"};
    var body = jsonEncode({
      "username": usernameController.text,
      "name": nameController.text,
      "phone": phoneController.text,
      "password": passwordController.text
    });

    try{
      var response = await http.post(url, headers: headers, body: body);
      var data = jsonDecode(response.body);
      responseText = data.toString();
      if (response.statusCode == 200) {
        await showPopupAndWait(context, "회원가입 성공");
        Navigator.pop(context); // 현재 화면 종료 (이전 화면으로 돌아감)
      }else{
        await showPopupAndWait(context, "회원가입 실패");
      }
    }catch(e){
      await showPopupAndWait(context, "에러: $e");
    }
  }

  Future<void> showPopupAndWait(BuildContext context, String title) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text('서버 반환 내용:\n$responseText'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 확인 누르면 dialog 닫히고 함수가 다시 이어짐
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );

    // 이 아래 코드는 팝업이 닫힌 후 실행됨
    print('사용자가 확인을 눌렀습니다!');
    // 여기에 다음 로직을 이어서 작성하면 됩니다
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30),
            _buildInputField('아이디', '아이디 입력', usernameController),
            _buildInputField('이름', '이름 입력', nameController),
            _buildInputField('전화번호', '010-0000-0000', phoneController),
            _buildInputField('비밀번호', '비밀번호', passwordController, isPassword: true),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  registration(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF547EE8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '회원가입',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 5),
          TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
