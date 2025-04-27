import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medife/main.dart';

import '../component/login_fields.dart';
import '../component/login_logo.dart';
import '../repository/login_auth_repository.dart';

void main (){
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              LoginLogo(),

              const SizedBox(height: 16),

              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoginFields(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}





