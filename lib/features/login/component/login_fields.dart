// login_fields.dart
import 'package:flutter/material.dart';
import 'package:medife/providers/nfc_provider.dart';
import '../../../routes/route_names.dart';
import 'login_custom_button.dart';
import 'login_custom_text_field.dart';
import '../model/login_request_model.dart';
import '../model/kakao_login_request_model.dart';
import '../repository/login_auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginFields extends StatefulWidget {
  const LoginFields({super.key});

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  final repository = LoginAuthRepository();
  final formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  bool _obscurePassword = true;

  final TextEditingController _usernameController = TextEditingController(text: "test@gmail.com");
  final TextEditingController _passwordController = TextEditingController(text: "test12345");

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLoginSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    if (!prefs.containsKey('firstLogin')) {
      await prefs.setBool('firstLogin', true);
    }
    if (!prefs.containsKey('hasSeenGuideline')) {
      await prefs.setBool('hasSeenGuideline', false);
    }

    final nfcProvider = context.read<NfcProvider>();
    final pending = nfcProvider.pendingRoute;
    debugPrint('[Login] pending route from NfcProvider: $pending');

    final Set<String> allowedRoutes = {
      '/morning',
      '/lunch',
      '/dinner',
      RouteName.landing,
      RouteName.guideline,
    };

    if (pending != null && pending.isNotEmpty && pending != '/' && allowedRoutes.contains(pending)) {
      Navigator.of(context).pushNamedAndRemoveUntil(pending, (route) => false);
      nfcProvider.clearPendingRoute();
      return;
    } else {
      if (pending != null && pending.isNotEmpty) {
        debugPrint('[Login] Ignoring unsafe pending route: $pending');
      }
    }

    final hasSeenGuideline = prefs.getBool('hasSeenGuideline') ?? false;

    if (!hasSeenGuideline) {
      Navigator.of(context).pushNamedAndRemoveUntil(RouteName.guideline, (route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(RouteName.landing, (route) => false);
    }
  }

  Future<String?> handleKakaoLogin(BuildContext context) async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token;
      if (isInstalled) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (_) {
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      return token.accessToken;
    } catch (e) {
      debugPrint('카카오 로그인 실패: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('아이디', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          LoginCustomTextField(
            controller: _usernameController,
            hintText: 'ID',
            validator: (value) => value!.isEmpty ? '아이디를 입력해주세요' : null,
            onSaved: (value) => username = value!,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          Text('비밀번호', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          LoginCustomTextField(
            controller: _passwordController,
            hintText: 'password',
            obscureText: _obscurePassword,
            validator: (value) => value!.isEmpty ? '비밀번호를 입력해주세요' : null,
            onSaved: (value) => password = value!,
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: theme.iconTheme.color,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            inputFormatters: [], // 필요 시 숫자 전용 등 추가
          ),
          const SizedBox(height: 24),
          LoginCustomButton(
            text: '로그인',
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final request = LoginRequestModel(username: username, password: password);
                try {
                  final token = await repository.login(request);
                  debugPrint('로그인 성공: $token');
                  await _handleLoginSuccess();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
          ),
          const SizedBox(height: 12),
          LoginCustomButton(
            text: '카카오 로그인',
            backgroundColor: const Color(0xFFFEE500),
            textColor: Colors.black,
            onPressed: () async {
              final token = await handleKakaoLogin(context);
              if (token == null) return;
              final request = KakaoLoginRequestModel(accessToken: token);
              try {
                final response = await repository.kakaoLogin(request);
                debugPrint('카카오 로그인 성공: $response');
                await _handleLoginSuccess();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
          ),
          const SizedBox(height: 12),
          LoginCustomButton(
            text: '회원가입',
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
          ),
        ],
      ),
    );
  }
}
