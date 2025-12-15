import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _fontScaleKey = 'font_scale';
const double _defaultFontScale = 1.0;

/// 글씨 크기 배율 Provider
/// 1.0 = 기본, 1.2 = 20% 크게, 1.5 = 50% 크게 등
final fontScaleProvider =
    StateNotifierProvider<FontScaleNotifier, double>((ref) {
  return FontScaleNotifier();
});

class FontScaleNotifier extends StateNotifier<double> {
  FontScaleNotifier() : super(_defaultFontScale) {
    _loadFontScale();
  }

  Future<void> _loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_fontScaleKey) ?? _defaultFontScale;
  }

  Future<void> setFontScale(double scale) async {
    // 0.8 ~ 1.6 범위로 제한
    final clampedScale = scale.clamp(0.8, 1.6);
    state = clampedScale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, clampedScale);
  }

  Future<void> resetFontScale() async {
    await setFontScale(_defaultFontScale);
  }
}

/// 글씨 크기 옵션
enum FontScaleOption {
  small(0.85, '小'),
  medium(1.0, '中'),
  large(1.15, '大'),
  extraLarge(1.3, '特大');

  final double scale;
  final String label;

  const FontScaleOption(this.scale, this.label);
}
