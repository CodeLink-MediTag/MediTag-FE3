// lib/features/mypage/mode/fancy_toggle_switch.dart
import 'package:flutter/material.dart';

/// FancyToggleSwitch
/// - value: true -> "on" (예: 라이트), false -> "off" (예: 다크)
/// - onChanged: 값 변경 콜백
/// - onLabel/offLabel: 라벨(옵션)
/// - width/height: 크기 조절
class FancyToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final String? onLabel; // 예: "라이트"
  final String? offLabel; // 예: "다크"

  const FancyToggleSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.width = 160,
    this.height = 46,
    this.onLabel,
    this.offLabel,
  }) : super(key: key);

  @override
  State<FancyToggleSwitch> createState() => _FancyToggleSwitchState();
}

class _FancyToggleSwitchState extends State<FancyToggleSwitch> with SingleTickerProviderStateMixin {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  void _handleTap() {
    final next = !_value;
    setState(() => _value = next);
    widget.onChanged(next);
  }

  @override
  void didUpdateWidget(covariant FancyToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    // 배경색 (켜짐/꺼짐)
    final Color onBg = cs.primary;
    final Color offBg = brightness == Brightness.light ? Colors.grey.shade300 : Colors.grey.shade800;

    // 라벨 색
    final Color onLabelColor = cs.onPrimary;
    final Color offLabelColor = brightness == Brightness.light ? Colors.black87 : Colors.white70;

    final double padding = 4.0;
    final double thumbSize = widget.height - padding * 2;

    return Semantics(
      container: true,
      button: true,
      label: '보기 방식 전환',
      toggled: _value,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: widget.width,
          height: widget.height,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: _value ? onBg : offBg,
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: [
              // 약한 그림자 (디자인 옵션)
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 좌/우 라벨: off(왼쪽), on(오른쪽)
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: thumbSize * 0.25),
                      child: AnimatedOpacity(
                        opacity: !_value ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          widget.offLabel ?? '다크',
                          style: TextStyle(
                            fontSize: widget.height * 0.34,
                            fontWeight: FontWeight.w600,
                            color: offLabelColor,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: thumbSize * 0.25),
                      child: AnimatedOpacity(
                        opacity: _value ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          widget.onLabel ?? '라이트',
                          style: TextStyle(
                            fontSize: widget.height * 0.34,
                            fontWeight: FontWeight.w600,
                            color: onLabelColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 썸(동그라미)
              AnimatedAlign(
                alignment: _value ? Alignment.centerRight : Alignment.centerLeft,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _value ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      size: thumbSize * 0.56,
                      color: _value ? onBg : offLabelColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
