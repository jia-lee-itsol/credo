import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/liturgy_theme_provider.dart';

/// 주요기도문 화면
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('主な祈り'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExpandablePrayerCard(
            title: '主の祈り',
            subtitle: 'Pater Noster',
            icon: Icons.favorite,
            primaryColor: primaryColor,
            content: '天におられるわたしたちの父よ、\n'
                'み名が聖とされますように。\n'
                'み国が来ますように。\n'
                'みこころが天に行われるとおり地にも行われますように。\n'
                'わたしたちの日ごとの糧を今日もお与えください。\n'
                'わたしたちの罪をおゆるしください。\n'
                'わたしたちも人をゆるします。\n'
                'わたしたちを誘惑におちいらせず、\n'
                '悪からお救いください。アーメン。',
          ),
          _ExpandablePrayerCard(
            title: 'アヴェ・マリアの祈り',
            subtitle: 'Ave Maria',
            icon: Icons.star,
            primaryColor: primaryColor,
            content: 'アヴェ、マリア、恵みに満ちた方、\n'
                '主はあなたとともにおられます。\n'
                'あなたは女のうちで祝福され、\n'
                'ご胎内の御子イエスも祝福されています。\n'
                '神の母聖マリア、\n'
                'わたしたち罪びとのために、\n'
                '今も、死を迎える時も、お祈りください。\n'
                'アーメン。',
          ),
          _ExpandablePrayerCard(
            title: '栄唱',
            subtitle: 'Gloria Patri',
            icon: Icons.brightness_7,
            primaryColor: primaryColor,
            content: '栄光は父と子と聖霊に。\n'
                '初めのように今もいつも世々に。\n'
                'アーメン。',
          ),
          _ExpandablePrayerCard(
            title: '使徒信条',
            subtitle: 'Credo',
            icon: Icons.book,
            primaryColor: primaryColor,
            content: '天地の創造主、全能の父である神を信じます。\n'
                '父のひとり子、わたしたちの主イエス・キリストを信じます。\n'
                '主は聖霊によってやどり、おとめマリアから生まれ、\n'
                'ポンティオ・ピラトのもとで苦しみを受け、\n'
                '十字架につけられて死に、葬られ、陰府に下り、\n'
                '三日目に死者のうちから復活し、天に昇って、\n'
                '全能の父である神の右の座に着き、\n'
                '生者と死者を裁くために来られます。\n'
                '聖霊を信じ、聖なる普遍の教会、聖徒の交わり、\n'
                '罪のゆるし、からだの復活、永遠のいのちを信じます。\n'
                'アーメン。',
          ),
          _ExpandablePrayerCard(
            title: 'ロザリオの祈り',
            subtitle: 'Rosarium',
            icon: Icons.auto_awesome,
            primaryColor: primaryColor,
            content: '【喜びの神秘】\n'
                '第一玄義：お告げ\n'
                '第二玄義：ご訪問\n'
                '第三玄義：ご降誕\n'
                '第四玄義：奉献\n'
                '第五玄義：神殿での発見\n\n'
                '【光の神秘】\n'
                '第一玄義：ヨルダン川での洗礼\n'
                '第二玄義：カナの婚宴\n'
                '第三玄義：神の国の宣教\n'
                '第四玄義：主の変容\n'
                '第五玄義：聖体の制定',
          ),
          _ExpandablePrayerCard(
            title: '十字架の道行き',
            subtitle: 'Via Crucis',
            icon: Icons.route,
            primaryColor: primaryColor,
            content: '第一留：イエス、死刑の宣告を受ける\n'
                '第二留：イエス、十字架を担う\n'
                '第三留：イエス、初めて倒れる\n'
                '第四留：イエス、母マリアに会う\n'
                '第五留：シモン、イエスを助ける\n'
                '第六留：ベロニカ、イエスの顔を拭う\n'
                '第七留：イエス、再び倒れる\n'
                '第八留：イエス、婦人たちを慰める\n'
                '第九留：イエス、三度倒れる\n'
                '第十留：イエス、衣を剥がされる\n'
                '第十一留：イエス、十字架に釘付けられる\n'
                '第十二留：イエス、十字架上で息を引き取る\n'
                '第十三留：イエス、十字架から降ろされる\n'
                '第十四留：イエス、墓に葬られる',
          ),
          _ExpandablePrayerCard(
            title: '食前の祈り',
            subtitle: 'Benedictio Mensae',
            icon: Icons.restaurant,
            primaryColor: primaryColor,
            content: '父よ、あなたのいつくしみに感謝して\n'
                'この食事をいただきます。\n'
                'ここに用意されたものを祝福し、\n'
                'わたしたちの心とからだを支える糧としてください。\n'
                'わたしたちの主イエス・キリストによって。\n'
                'アーメン。',
          ),
          _ExpandablePrayerCard(
            title: '食後の祈り',
            subtitle: 'Gratiarum Actio',
            icon: Icons.coffee,
            primaryColor: primaryColor,
            content: '全能の神よ、\n'
                'この食事を感謝してお礼申し上げます。\n'
                'これによってわたしたちの心身を強め、\n'
                'あなたに奉仕することができますように。\n'
                'わたしたちの主イエス・キリストによって。\n'
                'アーメン。',
          ),
        ],
      ),
    );
  }
}

class _ExpandablePrayerCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final String content;

  const _ExpandablePrayerCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.content,
  });

  @override
  State<_ExpandablePrayerCard> createState() => _ExpandablePrayerCardState();
}

class _ExpandablePrayerCardState extends State<_ExpandablePrayerCard> {
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
