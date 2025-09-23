// lib/screens/login/component/login_fields.dart
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
  bool _obscurePassword = true;

  // ✅ 수정: onSaved를 사용하지 않으므로 username, password 상태 변수 제거
  // String username = '';
  // String password = '';

  // 개발 편의를 위한 초기값은 그대로 둡니다.
  final TextEditingController _usernameController =
  TextEditingController(text: "ko7584@naver.com");
  final TextEditingController _passwordController =
  TextEditingController(text: "@python7584");

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLoginSuccess() async {
    // ✅ 수정: 비동기 작업 전 context 관련 변수 미리 가져오기
    final nfcProvider = context.read<NfcProvider>();
    final navigator = Navigator.of(context); // Navigator도 미리 가져오기

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    // ✅ 수정: 위젯이 화면에 없을 경우 context를 사용하지 않도록 방어 코드 추가 (안정성 향상)
    if (!mounted) return;

    // ✅ 수정: main.dart에서 처리하므로 중복되는 초기화 로직 제거
    /*
    if (!prefs.containsKey('firstLogin')) {
      await prefs.setBool('firstLogin', true);
    }
    if (!prefs.containsKey('hasSeenGuideline')) {
      await prefs.setBool('hasSeenGuideline', false);
    }
    */

    final pending = nfcProvider.pendingRoute;
    final Set<String> allowedRoutes = {
      '/morning',
      '/lunch',
      '/dinner',
    };

    if (pending != null && allowedRoutes.contains(pending)) {
      nfcProvider.clearPendingRoute();
      navigator.pushNamedAndRemoveUntil(pending, (route) => false);
      return;
    }

    final hasSeenGuideline = prefs.getBool('hasSeenGuideline') ?? false;
    if (!hasSeenGuideline) {
      navigator.pushNamedAndRemoveUntil(RouteName.guideline, (route) => false);
    } else {
      navigator.pushNamedAndRemoveUntil(RouteName.landing, (route) => false);
    }
  }

  // ✅ 수정: 사용하지 않는 BuildContext 파라미터 제거
  Future<String?> handleKakaoLogin() async {
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
            // ✅ 수정: onSaved 제거
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
            // ✅ 수정: onSaved 제거
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
          ),
          const SizedBox(height: 24),
          LoginCustomButton(
            text: '로그인',
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // ✅ 수정: formKey.currentState!.save() 제거
                // ✅ 수정: 컨트롤러에서 직접 값 가져오기
                final username = _usernameController.text;
                final password = _passwordController.text;

                final request = LoginRequestModel(username: username, password: password);
                try {
                  final token = await repository.login(request);
                  debugPrint('로그인 성공: $token');
                  await _handleLoginSuccess();
                } catch (e) {
                  // ✅ 수정: 에러 발생 시 mounted 확인 후 스낵바 표시
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인에 실패했습니다. 아이디 또는 비밀번호를 확인해주세요.')),
                  );
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
              final token = await handleKakaoLogin();
              if (token == null) return;

              final request = KakaoLoginRequestModel(accessToken: token);
              try {
                final response = await repository.kakaoLogin(request);
                debugPrint('카카오 로그인 성공: $response');
                await _handleLoginSuccess();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('카카오 로그인에 실패했습니다. 잠시 후 다시 시도해주세요.')),
                );
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