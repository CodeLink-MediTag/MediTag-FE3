import 'package:flutter/material.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final TextStyle? textStyle;
  final Color? backgroundColor; // nullable -> Theme에서 가져옴
  final double borderRadius;

  const CustomPrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.height = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.margin = const EdgeInsets.all(16),
    this.textStyle,
    this.backgroundColor,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 전달된 색상이 없으면 theme의 primary 사용
    final Color bg = backgroundColor ?? cs.primary;
    // 텍스트 색은 onPrimary에 맞추되, 만약 버튼이 밝으면 onPrimary가 적절치 않을 수 있다.
    final Color fg = theme.colorScheme.onPrimary;

    return Padding(
      padding: margin,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            elevation: 2,
            textStyle: textStyle ?? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // allow null to indicate disabled
  final double height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final TextStyle? textStyle;
  final Color? backgroundColor; // use theme if null
  final double borderRadius;

  const CustomPrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.height = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.margin = const EdgeInsets.all(16),
    this.textStyle,
    this.backgroundColor,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryBg = backgroundColor ?? theme.colorScheme.primary;
    final Color fgColor = theme.colorScheme.onPrimary;
    final Color disabledBg = theme.colorScheme.surfaceVariant;

    final ButtonStyle style = ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) return disabledBg;
        return primaryBg;
      }),
      foregroundColor: MaterialStateProperty.all<Color>(fgColor),
      minimumSize: MaterialStateProperty.all(Size.fromHeight(height)),
      padding: MaterialStateProperty.all(padding),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))),
      elevation: MaterialStateProperty.resolveWith<double>((states) => states.contains(MaterialState.disabled) ? 0 : 2),
    );

    return Padding(
      padding: margin,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          style: style,
          onPressed: onPressed,
          child: Text(
            label,
            style: textStyle ??
                TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: fgColor, // text color is managed by style too, but keep this for fallback
                ),
          ),
        ),
      ),
    );
  }
}


 */