#!/usr/bin/env python3
"""
AppLocalizations 자동 생성 스크립트

JSON 파일에서 Dart 코드를 자동 생성합니다.
사용법: python scripts/generate_localizations.py
"""

import json
import os
import re
from pathlib import Path
from typing import Any, Dict, List, Set

# 프로젝트 루트 디렉토리
PROJECT_ROOT = Path(__file__).parent.parent
L10N_DIR = PROJECT_ROOT / "assets" / "l10n"
OUTPUT_FILE = PROJECT_ROOT / "lib" / "core" / "utils" / "app_localizations.dart"

# 기본 JSON 파일 (일본어)
BASE_JSON = L10N_DIR / "app_ja.json"


def to_camel_case(snake_str: str) -> str:
    """snake_case를 camelCase로 변환"""
    components = snake_str.split("_")
    return components[0] + "".join(x.capitalize() for x in components[1:])


def to_pascal_case(snake_str: str) -> str:
    """snake_case를 PascalCase로 변환"""
    components = snake_str.split("_")
    return "".join(x.capitalize() for x in components)


def extract_placeholders(text: str) -> List[str]:
    """문자열에서 플레이스홀더 추출 (예: {language}, {count})"""
    return re.findall(r"\{(\w+)\}", text)


def get_placeholder_type(key: str, data: Dict[str, Any]) -> Dict[str, str]:
    """플레이스홀더 타입 정보 추출 (key@param 형식)"""
    placeholder_types = {}
    for k, v in data.items():
        if k.startswith(f"{key}@") and isinstance(v, str):
            param_name = k.split("@")[1]
            placeholder_types[param_name] = v
    return placeholder_types


def generate_class(
    class_name: str,
    data: Dict[str, Any],
    indent: int = 0,
    parent_key: str = "",
) -> str:
    """Dart 클래스 생성"""
    indent_str = "  " * indent
    lines = [f"{indent_str}/// {class_name.replace('Translations', '')} 번역"]
    lines.append(f"{indent_str}class {class_name} {{")
    lines.append(f"{indent_str}  final dynamic _data;")
    lines.append("")
    lines.append(f"{indent_str}  {class_name}(this._data);")
    lines.append("")

    # 문자열 속성과 중첩 객체 구분
    string_props = []
    nested_objects = []
    placeholder_functions = []

    for key, value in data.items():
        # 플레이스홀더 타입 정보는 건너뛰기
        if "@" in key:
            continue

        if isinstance(value, str):
            placeholders = extract_placeholders(value)
            placeholder_types = get_placeholder_type(key, data)

            if placeholders:
                # 플레이스홀더가 있으면 함수로 생성
                params = []
                for param in placeholders:
                    param_type = placeholder_types.get(param, "String")
                    # 타입 추론: 숫자면 int, 아니면 String
                    if "count" in param.lower() or "max" in param.lower():
                        param_type = "int"
                    params.append(f"required {param_type} {param}")

                param_str = ", ".join(params)
                function_name = to_camel_case(key)

                # 함수 본문 생성
                template_var = f"_getString('{key}')"
                default_value = json.dumps(value, ensure_ascii=False)
                replacements = "".join(
                    f".replaceAll('{{{p}}}', {p}.toString())" for p in placeholders
                )

                placeholder_functions.append(
                    f"{indent_str}  String {function_name}({{{param_str}}}) {{"
                )
                placeholder_functions.append(
                    f"{indent_str}    final template = {template_var} ?? {default_value};"
                )
                placeholder_functions.append(f"{indent_str}    return template{replacements};")
                placeholder_functions.append(f"{indent_str}  }}")
                placeholder_functions.append("")
            else:
                # 일반 문자열 속성
                prop_name = to_camel_case(key)
                default_value = json.dumps(value, ensure_ascii=False)
                string_props.append(
                    f"{indent_str}  String get {prop_name} => "
                    f"_getString('{key}') ?? {default_value};"
                )
        elif isinstance(value, dict):
            # 중첩 객체
            nested_class_name = to_pascal_case(key) + "Translations"
            nested_key = f"{parent_key}.{key}" if parent_key else key
            nested_objects.append((key, nested_class_name, value, nested_key))

    # 문자열 속성 출력
    for prop in string_props:
        lines.append(prop)

    # 플레이스홀더 함수 출력
    for func in placeholder_functions:
        lines.append(func)

    # 중첩 객체 getter 출력
    for key, class_name, value, nested_key in nested_objects:
        prop_name = to_camel_case(key)
        lines.append(
            f"{indent_str}  {class_name} get {prop_name} => "
            f"{class_name}(_getValue('{key}'));"
        )

    # 헬퍼 메서드 추가
    if indent == 0:  # 최상위 클래스만
        lines.append("")
        lines.append(f"{indent_str}  String? _getString(String key) {{")
        lines.append(f"{indent_str}    if (_data is Map<String, dynamic>) {{")
        lines.append(f"{indent_str}      return _data[key] as String?;")
        lines.append(f"{indent_str}    }}")
        lines.append(f"{indent_str}    return null;")
        lines.append(f"{indent_str}  }}")
        lines.append("")
        lines.append(f"{indent_str}  dynamic _getValue(String key) {{")
        lines.append(f"{indent_str}    if (_data is Map<String, dynamic>) {{")
        lines.append(f"{indent_str}      return _data[key];")
        lines.append(f"{indent_str}    }}")
        lines.append(f"{indent_str}    return null;")
        lines.append(f"{indent_str}  }}")

    lines.append(f"{indent_str}}}")

    # 중첩 클래스 생성
    nested_classes = []
    for key, class_name, value, nested_key in nested_objects:
        nested_class = generate_class(class_name, value, indent + 1, nested_key)
        nested_classes.append(nested_class)

    return "\n".join(lines) + ("\n\n" if nested_classes else "") + "\n\n".join(
        nested_classes
    )


def generate_app_localizations(data: Dict[str, Any]) -> str:
    """AppLocalizations 클래스와 모든 번역 클래스 생성"""
    lines = [
        "import 'package:flutter/material.dart';",
        "import 'package:flutter_riverpod/flutter_riverpod.dart';",
        "import '../data/services/localization_service.dart';",
        "import '../../shared/providers/locale_provider.dart';",
        "",
        "/// 앱 다국어 지원 유틸리티",
        "///",
        "/// 사용 예:",
        "/// ```dart",
        "/// final l10n = ref.watch(appLocalizationsProvider);",
        "/// Text(l10n.language.settings)",
        "/// Text(l10n.language.switched(language: '日本語'))",
        "/// ```",
        "class AppLocalizations {",
        "  final Locale locale;",
        "  final Map<String, dynamic> _translations;",
        "",
        "  AppLocalizations(this.locale, this._translations);",
        "",
        "  /// BuildContext에서 AppLocalizations 가져오기",
        "  static AppLocalizations of(BuildContext context) {",
        "    final locale = Localizations.localeOf(context);",
        "    return _AppLocalizationsDelegate.instance.loadSync(locale);",
        "  }",
        "",
        "  /// 중첩된 키 접근을 위한 getter",
        "  dynamic _getValue(String key) {",
        "    final keys = key.split('.');",
        "    dynamic value = _translations;",
        "",
        "    for (final k in keys) {",
        "      if (value is Map<String, dynamic>) {",
        "        value = value[k];",
        "      } else {",
        "        return null;",
        "      }",
        "    }",
        "",
        "    return value;",
        "  }",
        "",
    ]

    # 각 섹션에 대한 getter 생성
    section_classes = []
    for key, value in data.items():
        if isinstance(value, dict):
            class_name = to_pascal_case(key) + "Translations"
            prop_name = to_camel_case(key)
            lines.append(f"  /// {key} 번역")
            lines.append(
                f"  {class_name} get {prop_name} => "
                f"{class_name}(_getValue('{key}'));"
            )
            section_classes.append((class_name, value))

    lines.append("}")
    lines.append("")

    # 각 섹션 클래스 생성
    for class_name, value in section_classes:
        lines.append(generate_class(class_name, value))

    # _AppLocalizationsDelegate 클래스는 수동으로 유지
    lines.append(
        """/// AppLocalizations 로드 델리게이트 (내부용)
class _AppLocalizationsDelegate {
  static final _AppLocalizationsDelegate instance =
      _AppLocalizationsDelegate();

  AppLocalizations loadSync(Locale locale) {
    final service = LocalizationService();
    final translations = service.loadTranslationsSync(locale);
    return AppLocalizations(locale, translations);
  }
}

/// AppLocalizations Provider
final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(localeProvider);
  return _AppLocalizationsDelegate.instance.loadSync(locale);
});

/// AppLocalizations 동기 Provider (빌드 시 사용)
final appLocalizationsSyncProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(localeProvider);
  return _AppLocalizationsDelegate.instance.loadSync(locale);
});
"""
    )

    return "\n".join(lines)


def main():
    """메인 함수"""
    print("AppLocalizations 자동 생성 시작...")

    # JSON 파일 읽기
    if not BASE_JSON.exists():
        print(f"오류: {BASE_JSON} 파일을 찾을 수 없습니다.")
        return

    with open(BASE_JSON, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Dart 코드 생성
    dart_code = generate_app_localizations(data)

    # 파일 쓰기
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write(dart_code)

    print(f"✅ {OUTPUT_FILE} 생성 완료!")
    print(f"   생성된 코드 라인 수: {len(dart_code.splitlines())}")


if __name__ == "__main__":
    main()

