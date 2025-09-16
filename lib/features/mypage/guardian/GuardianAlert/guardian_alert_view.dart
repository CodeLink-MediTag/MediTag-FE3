import 'package:flutter/material.dart';
import 'package:medife/features/mypage/guardian/guardian_api.dart';
import 'package:medife/components/custom_app_bar.dart';
import 'package:medife/components/custom_primary_button.dart';

class GuardianAlertView extends StatelessWidget {
  final bool loading;
  final List<GuardianResponse> guards;
  final Future<void> Function(int guardianId) onDelete;
  final VoidCallback onAddPressed;

  const GuardianAlertView({
    Key? key,
    required this.loading,
    required this.guards,
    required this.onDelete,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    if (loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CustomAppBar(title: '보호자 알림'),
        ),
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: '보호자 알림',
        onBack: () => Navigator.of(context).pop(),
        onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/landing', (_) => false),
      ),
      body: guards.isEmpty
          ? Center(
        child: Text(
          '등록된 보호자가 없습니다.',
          style: tt.bodyLarge,
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: guards.length,
        itemBuilder: (ctx, i) {
          final g = guards[i];
          return Card(
            color: theme.cardColor,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(
                '${g.relationship} • ${g.phoneNumber}',
                style: tt.titleMedium,
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: cs.error),
                onPressed: () => onDelete(g.id),
                tooltip: '삭제',
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: CustomPrimaryButton(
          label: '보호자 알림 대상 추가',
          onPressed: onAddPressed,
          margin: EdgeInsets.zero,
          backgroundColor: cs.primary,
          textStyle: tt.titleMedium?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
