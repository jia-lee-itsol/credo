import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/expandable_content_card.dart';

/// 매일미사 화면
class DailyMassScreen extends ConsumerWidget {
  const DailyMassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);
    final testDate = ref.watch(testDateOverrideProvider);
    final now = testDate ?? DateTime.now();
    final dateFormat = DateFormat('yyyy年M月d日 (E)', 'ja');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('毎日のミサ'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                context.push(AppRoutes.myPage);
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                backgroundImage: currentUser?.profileImageUrl != null
                    ? NetworkImage(currentUser!.profileImageUrl!)
                    : null,
                child: currentUser?.profileImageUrl == null
                    ? Icon(Icons.person, size: 20, color: primaryColor)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 오늘 날짜
          _buildDateHeader(theme, primaryColor, dateFormat.format(now)),

          const SizedBox(height: 24),

          // 미사 전례 섹션들
          ..._massSections.map(
            (section) => ExpandableContentCard(
              title: section['title']!,
              subtitle: section['subtitle']!,
              icon: _getIconData(section['icon']!),
              primaryColor: primaryColor,
              content: section['content']!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(ThemeData theme, Color primaryColor, String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: primaryColor),
          const SizedBox(width: 12),
          Text(
            date,
            style: theme.textTheme.titleMedium?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'music_note':
        return Icons.music_note;
      case 'menu_book':
        return Icons.menu_book;
      case 'library_music':
        return Icons.library_music;
      case 'celebration':
        return Icons.celebration;
      case 'auto_stories':
        return Icons.auto_stories;
      default:
        return Icons.article;
    }
  }
}

// 미사 전례 데이터
const _massSections = [
  {
    'title': '入祭唱',
    'subtitle': 'Introitus',
    'icon': 'music_note',
    'content':
        '主よ、あなたの道を私に示し、\nあなたの小道を私に教えてください。\nあなたの真理によって私を導き、教えてください。\nあなたは私の救いの神。',
  },
  {
    'title': '第一朗読',
    'subtitle': 'Lectio Prima',
    'icon': 'menu_book',
    'content': 'イザヤの預言\n\n荒れ野で叫ぶ者の声がする。\n「主の道を整え、\n私たちの神のために、\n荒れ地に広い道を通せ。」',
  },
  {
    'title': '答唱詩編',
    'subtitle': 'Psalmus Responsorius',
    'icon': 'library_music',
    'content':
        '詩編 85\n\n【答唱】主よ、あなたの慈しみを私たちに示し、\n救いを私たちに与えてください。\n\n主の語られることを私は聞こう。\n主は平和を約束される。',
  },
  {
    'title': '第二朗読',
    'subtitle': 'Lectio Secunda',
    'icon': 'menu_book',
    'content':
        'ペトロの手紙\n\n愛する皆さん、主のもとでは、\n一日は千年のようで、\n千年は一日のようです。\n主は約束の実現を遅らせておられるのではありません。',
  },
  {
    'title': 'アレルヤ唱',
    'subtitle': 'Alleluia',
    'icon': 'celebration',
    'content': 'アレルヤ、アレルヤ。\n主の道を整え、\nその道筋をまっすぐにせよ。\nすべての人は神の救いを見る。\nアレルヤ、アレルヤ。',
  },
  {
    'title': '福音朗読',
    'subtitle': 'Evangelium',
    'icon': 'auto_stories',
    'content':
        'マルコによる福音\n\n神の子イエス・キリストの福音の初め。\n預言者イザヤの書にこう書いてある。\n「見よ、私はあなたより先に使者を遣わし、\nあなたの道を整えさせよう。」',
  },
  {
    'title': '拝領唱',
    'subtitle': 'Communio',
    'icon': 'music_note',
    'content': 'エルサレムよ、立ち上がれ、\n高い所に立って、東を見よ。\nあなたの子らが集まって来る、\n日の出から日の入りまで。',
  },
];
