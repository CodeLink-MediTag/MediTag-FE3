import 'package:flutter/material.dart';

/// “레이블: 값” 형태로 한 줄에 가로 정렬해서 보여줌 예) “복용 시작 날짜: 2025-06-01”
class FieldRow extends StatelessWidget {
  final String label;
  final String value;

  const FieldRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 레이블(볼드) 스타일: 테마의 bodyText에 대비되도록 설정
    final TextStyle labelStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: cs.onBackground,
    ) ??
        TextStyle(fontWeight: FontWeight.w700, color: cs.onBackground);

    // 값 스타일: 레이블보다 살짝 낮은 대비
    final TextStyle valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: cs.onBackground.withOpacity(0.9),
    ) ??
        TextStyle(color: cs.onBackground.withOpacity(0.9));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label: '레이블: '
          Flexible(
            flex: 0,
            child: Text(
              '$label: ',
              style: labelStyle,
            ),
          ),

          // value: 남는 영역 차지, 길면 줄바꿈 허용
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
              softWrap: true,
              // 필요하면 최대 줄수 제한 및 말줄임으로 변경 가능:
              // maxLines: 2,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
