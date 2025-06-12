import 'package:flutter/material.dart';

class CustomPrimaryButton extends StatelessWidget {
  /// 버튼에 들어갈 텍스트
  final String label;

  /// 눌렀을 때 콜백
  final VoidCallback onPressed;

  /// 버튼 높이 (기본 48)
  final double height;

  /// 버튼 안쪽 패딩 (기본 EdgeInsets.symmetric(horizontal: 16))
  final EdgeInsetsGeometry padding;

  /// 버튼 바깥쪽 마진 (기본 EdgeInsets.all(16))
  final EdgeInsetsGeometry margin;

  /// 텍스트 스타일 (기본 흰색 Bold 16)
  final TextStyle? textStyle;

  /// 배경 색상 (기본 메인 블루)
  final Color backgroundColor;

  /// 모서리 반경 (기본 12)
  final double borderRadius;

  const CustomPrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.height = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.margin = const EdgeInsets.all(16),
    this.textStyle,
    this.backgroundColor = const Color(0xFF547EE8),
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            elevation: 2,
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: textStyle ??
                const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}
