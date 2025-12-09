import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/providers/liturgy_theme_provider.dart';

/// 매일미사 화면
class DailyMassScreen extends ConsumerWidget {
  const DailyMassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy年M月d日 (E)', 'ja');

    return Scaffold(
      appBar: AppBar(
        title: const Text('毎日のミサ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 오늘 날짜
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  dateFormat.format(now),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 미사 전례 섹션
          _ExpandableMassSection(
            title: '入祭唱',
            subtitle: 'Introitus',
            icon: Icons.music_note,
            primaryColor: primaryColor,
            content: '主よ、あなたの道を私に示し、\nあなたの小道を私に教えてください。\nあなたの真理によって私を導き、教えてください。\nあなたは私の救いの神。',
          ),
          _ExpandableMassSection(
            title: '第一朗読',
            subtitle: 'Lectio Prima',
            icon: Icons.menu_book,
            primaryColor: primaryColor,
            content: 'イザヤの預言\n\n荒れ野で叫ぶ者の声がする。\n「主の道を整え、\n私たちの神のために、\n荒れ地に広い道を通せ。」',
          ),
          _ExpandableMassSection(
            title: '答唱詩編',
            subtitle: 'Psalmus Responsorius',
            icon: Icons.library_music,
            primaryColor: primaryColor,
            content: '詩編 85\n\n【答唱】主よ、あなたの慈しみを私たちに示し、\n救いを私たちに与えてください。\n\n主の語られることを私は聞こう。\n主は平和を約束される。',
          ),
          _ExpandableMassSection(
            title: '第二朗読',
            subtitle: 'Lectio Secunda',
            icon: Icons.menu_book,
            primaryColor: primaryColor,
            content: 'ペトロの手紙\n\n愛する皆さん、主のもとでは、\n一日は千年のようで、\n千年は一日のようです。\n主は約束の実現を遅らせておられるのではありません。',
          ),
          _ExpandableMassSection(
            title: 'アレルヤ唱',
            subtitle: 'Alleluia',
            icon: Icons.celebration,
            primaryColor: primaryColor,
            content: 'アレルヤ、アレルヤ。\n主の道を整え、\nその道筋をまっすぐにせよ。\nすべての人は神の救いを見る。\nアレルヤ、アレルヤ。',
          ),
          _ExpandableMassSection(
            title: '福音朗読',
            subtitle: 'Evangelium',
            icon: Icons.auto_stories,
            primaryColor: primaryColor,
            content: 'マルコによる福音\n\n神の子イエス・キリストの福音の初め。\n預言者イザヤの書にこう書いてある。\n「見よ、私はあなたより先に使者を遣わし、\nあなたの道を整えさせよう。」',
          ),
          _ExpandableMassSection(
            title: '拝領唱',
            subtitle: 'Communio',
            icon: Icons.music_note,
            primaryColor: primaryColor,
            content: 'エルサレムよ、立ち上がれ、\n高い所に立って、東を見よ。\nあなたの子らが集まって来る、\n日の出から日の入りまで。',
          ),
        ],
      ),
    );
  }
}

class _ExpandableMassSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final String content;

  const _ExpandableMassSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.content,
  });

  @override
  State<_ExpandableMassSection> createState() => _ExpandableMassSectionState();
}

class _ExpandableMassSectionState extends State<_ExpandableMassSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _isExpanded
              ? widget.primaryColor.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon, color: widget.primaryColor),
            ),
            title: Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              widget.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            trailing: AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.expand_more,
                color: _isExpanded
                    ? widget.primaryColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
