/// 기본 묵상 가이드 (에러 발생 시)
class MeditationGuideDefaults {
  /// 기본 묵상 가이드 반환
  static String getDefaultMeditationGuide(String language) {
    switch (language) {
      case 'ja':
        return '''今日のテーマ：神様の言葉を聞く

今日の問い：
・私は今、何を急いでいるだろうか
・神様の言葉に耳を傾けているだろうか

今日の黙想：
静かな時間の中で、
自分の心の動きを見つめてみましょう。
神様の言葉があなたの心に 어떻게響いているか感じてみてください。''';
      case 'ko':
        return '''오늘의 주제：하느님의 말씀을 듣기

오늘의 질문：
・나는 지금 무엇을 서두르고 있을까
・하느님의 말씀에 귀 기울이고 있을까

오늘의 묵상：
고요한 시간 속에서,
자신의 마음의 움직임을 살펴보세요.
하느님의 말씀이 당신의 마음에 어떻게 울려 퍼지는지 느껴보세요.''';
      case 'en':
        return '''Today's Theme: Listening to God's Word

Today's Questions:
・What am I rushing about now?
・Am I listening to God's word?

Today's Meditation:
In a quiet moment,
observe the movements of your heart.
Feel how God's word resonates in your heart.''';
      default:
        return getDefaultMeditationGuide('ja');
    }
  }
}

