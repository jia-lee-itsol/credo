import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../shared/providers/liturgy_theme_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/widgets/expandable_content_card.dart';

/// 주요기도문 화면
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = ref.watch(liturgyPrimaryColorProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('主な祈り'),
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
        children: _prayers
            .map(
              (prayer) => ExpandableContentCard(
                title: prayer['title']!,
                subtitle: prayer['subtitle']!,
                icon: _getIconData(prayer['icon']!),
                primaryColor: primaryColor,
                content: prayer['content']!,
              ),
            )
            .toList(),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'brightness_7':
        return Icons.brightness_7;
      case 'book':
        return Icons.book;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'route':
        return Icons.route;
      case 'restaurant':
        return Icons.restaurant;
      case 'coffee':
        return Icons.coffee;
      case 'church':
        return Icons.church;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'bedtime':
        return Icons.bedtime;
      case 'person':
        return Icons.person;
      case 'shield':
        return Icons.shield;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'self_improvement':
        return Icons.self_improvement;
      default:
        return Icons.article;
    }
  }
}

// 기도문 데이터
const _prayers = [
  {
    'title': '主の祈り',
    'subtitle': 'Pater Noster',
    'icon': 'favorite',
    'content':
        '天におられるわたしたちの父よ、\n'
        'み名が聖とされますように。\n'
        'み国が来ますように。\n'
        'みこころが天に行われるとおり地にも行われますように。\n'
        'わたしたちの日ごとの糧を今日もお与えください。\n'
        'わたしたちの罪をおゆるしください。\n'
        'わたしたちも人をゆるします。\n'
        'わたしたちを誘惑におちいらせず、\n'
        '悪からお救いください。アーメン。',
  },
  {
    'title': 'アヴェ・マリアの祈り',
    'subtitle': 'Ave Maria',
    'icon': 'star',
    'content':
        'アヴェ、マリア、恵みに満ちた方、\n'
        '主はあなたとともにおられます。\n'
        'あなたは女のうちで祝福され、\n'
        'ご胎内の御子イエスも祝福されています。\n'
        '神の母聖マリア、\n'
        'わたしたち罪びとのために、\n'
        '今も、死を迎える時も、お祈りください。\n'
        'アーメン。',
  },
  {
    'title': '栄唱',
    'subtitle': 'Gloria Patri',
    'icon': 'brightness_7',
    'content':
        '栄光は父と子と聖霊に。\n'
        '初めのように今もいつも世々に。\n'
        'アーメン。',
  },
  {
    'title': '使徒信条',
    'subtitle': 'Credo',
    'icon': 'book',
    'content':
        '天地の創造主、全能の父である神を信じます。\n'
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
  },
  {
    'title': 'ニケア信条',
    'subtitle': 'Symbolum Nicaenum',
    'icon': 'book',
    'content':
        'わたしたちは、唯一の神、\n'
        '全能の父、天と地、\n'
        '見えるもの、見えないもの、すべてのものの造り主を信じます。\n\n'
        'わたしたちは、唯一の主イエス・キリスト、\n'
        '神のひとり子、\n'
        'すべての時代に先立って父から生まれた方を信じます。\n'
        '神から出た神、光から出た光、\n'
        'まことの神から出たまことの神、\n'
        '造られたものではなく、父と一体の方、\n'
        'すべてのものはこの方によって造られました。\n'
        'わたしたち人類のため、またわたしたちの救いのために、\n'
        '天から降り、\n'
        '聖霊によっておとめマリアからからだを受け、\n'
        '人となられました。\n'
        'ポンティオ・ピラトのもとで、\n'
        'わたしたちのために十字架につけられ、\n'
        '苦しみを受け、葬られ、\n'
        '聖書に書かれているとおり、三日目に復活し、\n'
        '天に昇り、父の右の座に着かれました。\n'
        '栄光のうちに再び来て、\n'
        '生者と死者を裁かれます。\n'
        'その国は終わることがありません。\n\n'
        'わたしたちは、主であり、いのちを与える方、\n'
        '父から出る聖霊を信じます。\n'
        '父と子とともに礼拝され、\n'
        '父と子とともに栄光を受けられます。\n'
        '預言者たちを通して語られました。\n\n'
        'わたしたちは、唯一の、聖なる、\n'
        '公同の、使徒的な教会を信じます。\n'
        '罪のゆるしのための唯一の洗礼を告白します。\n'
        '死者の復活と来世のいのちを待ち望みます。\n'
        'アーメン。',
  },
  {
    'title': 'ロザリオの祈り',
    'subtitle': 'Rosarium',
    'icon': 'auto_awesome',
    'content':
        '【喜びの神秘】\n'
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
  },
  {
    'title': '十字架の道行き',
    'subtitle': 'Via Crucis',
    'icon': 'route',
    'content':
        '第一留：イエス、死刑の宣告を受ける\n'
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
  },
  {
    'title': '食前の祈り',
    'subtitle': 'Benedictio Mensae',
    'icon': 'restaurant',
    'content':
        '父よ、あなたのいつくしみに感謝して\n'
        'この食事をいただきます。\n'
        'ここに用意されたものを祝福し、\n'
        'わたしたちの心とからだを支える糧としてください。\n'
        'わたしたちの主イエス・キリストによって。\n'
        'アーメン。',
  },
  {
    'title': '食後の祈り',
    'subtitle': 'Gratiarum Actio',
    'icon': 'coffee',
    'content':
        '全能の神よ、\n'
        'この食事を感謝してお礼申し上げます。\n'
        'これによってわたしたちの心身を強め、\n'
        'あなたに奉仕することができますように。\n'
        'わたしたちの主イエス・キリストによって。\n'
        'アーメン。',
  },
  {
    'title': 'サルヴェ・レジーナ',
    'subtitle': 'Salve Regina',
    'icon': 'favorite_border',
    'content':
        'めでたし、元后、\n'
        '慈しみ深き方、\n'
        'いのち、甘美、希望、\n'
        'われらの母、マリア。\n'
        'エバの子ら、この涙の谷で、\n'
        'あなたに向かって嘆き、\n'
        'あなたを呼び求めます。\n'
        'われらの執り成し手よ、\n'
        'あの目を向けてください。\n'
        'そして、この流刑の後、\n'
        'イエス、いつくしみ深き御子の実を、\n'
        'われらに見せてください。\n'
        'ああ、いつくしみ深く、\n'
        'ああ、優しく、\n'
        'ああ、甘美なる、\n'
        'おとめマリア。',
  },
  {
    'title': '聖ヨセフへの祈り',
    'subtitle': 'Oratio ad Sanctum Ioseph',
    'icon': 'person',
    'content':
        '祝福された守護者、\n'
        '聖なるマリアの配偶者、\n'
        '聖ヨセフよ、\n'
        'あなたは神の御子の養父として選ばれ、\n'
        'その母マリアの守護者として定められました。\n'
        'わたしたちのために、\n'
        '神に執り成してください。\n'
        'あなたの保護のもとに、\n'
        'わたしたちを守ってください。\n'
        'アーメン。',
  },
  {
    'title': 'アンジェラスの祈り',
    'subtitle': 'Angelus',
    'icon': 'church',
    'content':
        '【主の御使いがマリアに告げた】\n'
        '主の御使いがマリアに告げた。\n'
        '「おめでとう、恵まれた方。\n'
        '主があなたと共におられる。」\n'
        '（アヴェ・マリアの祈り）\n\n'
        '【マリアは答えた】\n'
        '「わたしは主のはしためです。\n'
        'お言葉どおり、この身に成りますように。」\n'
        '（アヴェ・マリアの祈り）\n\n'
        '【ことばは人となった】\n'
        'そして、ことばは人となって、\n'
        'わたしたちの間に住まわれた。\n'
        '（アヴェ・マリアの祈り）',
  },
  {
    'title': '朝の祈り',
    'subtitle': 'Oratio Matutina',
    'icon': 'wb_sunny',
    'content':
        '主よ、この新しい一日を\n'
        'あなたの祝福のもとに始めさせてください。\n'
        '今日もあなたの愛と導きを感じながら、\n'
        'あなたの御心に従って歩むことができますように。\n'
        'わたしたちの主イエス・キリストによって。\n'
        'アーメン。',
  },
  {
    'title': '夜の祈り',
    'subtitle': 'Oratio Vespertina',
    'icon': 'bedtime',
    'content':
        '主よ、この一日の終わりに、\n'
        'あなたに感謝をささげます。\n'
        '今日もあなたの守りと恵みをいただき、\n'
        '無事に過ごすことができました。\n'
        '今夜もあなたの保護のもとに、\n'
        '安らかに眠ることができますように。\n'
        'わたしたちの主イエス・キリストによって。\n'
        'アーメン。',
  },
  {
    'title': '聖体拝領後の祈り',
    'subtitle': 'Post Communionem',
    'icon': 'self_improvement',
    'content':
        '主イエス・キリストよ、\n'
        'あなたの聖体をいただき、\n'
        '心から感謝いたします。\n'
        'この聖体によって、\n'
        'わたしたちの心とからだを強め、\n'
        'あなたの愛に生きることができますように。\n'
        'あなたとともに、\n'
        '父と聖霊の栄光のうちに、\n'
        '世々に生き、支配されます。\n'
        'アーメン。',
  },
  {
    'title': '痛悔の祈り',
    'subtitle': 'Actus Contritionis',
    'icon': 'shield',
    'content':
        'ああ、わたしの神よ、\n'
        'あなたの愛と恵みに背き、\n'
        '罪を犯したことを深く悲しみ、\n'
        '心から悔い改めます。\n'
        'あなたの御子イエス・キリストの\n'
        '受難と死によって、\n'
        'わたしの罪をおゆるしください。\n'
        '聖霊の助けによって、\n'
        'もう二度と罪を犯さないよう、\n'
        'あなたの愛に生きることができますように。\n'
        'アーメン。',
  },
  {
    'title': '聖三位一体への祈り',
    'subtitle': 'Oratio ad Sanctam Trinitatem',
    'icon': 'brightness_7',
    'content':
        '父と子と聖霊、\n'
        '三位一体の神よ、\n'
        'あなたの愛と恵みに感謝いたします。\n'
        '父の創造、\n'
        '子の贖い、\n'
        '聖霊の聖化によって、\n'
        'わたしたちは救われました。\n'
        'あなたの栄光をたたえ、\n'
        'あなたに仕えることができますように。\n'
        'アーメン。',
  },
  {
    'title': '平和の祈り',
    'subtitle': 'Oratio pro Pace',
    'icon': 'favorite',
    'content':
        '主よ、わたしたちを\n'
        'あなたの平和の道具としてください。\n'
        '憎しみのあるところに愛を、\n'
        '傷つけ合うところにゆるしを、\n'
        '分裂のあるところに一致を、\n'
        '誤りのあるところに真理を、\n'
        '疑いのあるところに信仰を、\n'
        '絶望のあるところに希望を、\n'
        '暗闇のあるところに光を、\n'
        '悲しみのあるところに喜びをもたらすことができますように。\n'
        'アーメン。',
  },
];
