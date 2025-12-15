#!/usr/bin/env python3
"""
massTime 텍스트와 foreignMassTimes 데이터 불일치를 찾아서 수정하는 스크립트
"""

import json
import os
import re

PARISHES_DIR = "../assets/data/parishes"

# 언어 키워드 매핑
LANGUAGE_KEYWORDS = {
    'EN': ['英語', 'English', '(英語)', '（英語）'],
    'ES': ['スペイン語', 'Spanish', 'Español', '(スペイン語)', '（スペイン語）'],
    'KR': ['韓国語', 'Korean', '(韓国語)', '（韓国語）'],
    'CN': ['中国語', 'Chinese', '中文', '(中国語)', '（中国語）'],
    'PT': ['ポルトガル語', 'Portuguese', 'Português', '(ポルトガル語)', '（ポルトガル語）'],
    'VI': ['ベトナム語', 'Vietnamese', '(ベトナム語)', '（ベトナム語）'],
    'PH': ['フィリピン語', 'Filipino', 'Tagalog', '(フィリピン語)', '（フィリピン語）'],
    'ID': ['インドネシア語', 'Indonesian', '(インドネシア語)', '（インドネシア語）'],
}

def extract_foreign_masses_from_text(mass_time_text):
    """massTime 텍스트에서 외국어 미사 정보를 추출"""
    if not mass_time_text:
        return []

    foreign_masses = []

    # 각 언어별로 검색
    for lang_code, keywords in LANGUAGE_KEYWORDS.items():
        for keyword in keywords:
            if keyword in mass_time_text:
                # 해당 키워드 주변에서 시간과 노트 추출
                # 패턴: 시간(HH:MM) + 언어 또는 언어 + 시간
                patterns = [
                    # 14:00(英語) 또는 14:00（英語）
                    rf'(\d{{1,2}}:\d{{2}})\s*[（(]{keyword}[)）]',
                    rf'(\d{{1,2}}:\d{{2}})\s*{keyword}',
                    # 第1日曜14:00(英語)
                    rf'(第[\d１２３４]+[・,、]?第?[\d１２３４]*日曜?)\s*(\d{{1,2}}:\d{{2}})\s*[（(]?{keyword}',
                    # 英語ミサ14:00
                    rf'{keyword}ミサ\s*(\d{{1,2}}:\d{{2}})',
                    # 14:00英語ミサ
                    rf'(\d{{1,2}}:\d{{2}})\s*{keyword}ミサ',
                ]

                for pattern in patterns:
                    matches = re.finditer(pattern, mass_time_text)
                    for match in matches:
                        groups = match.groups()
                        time_val = None
                        note_val = ""

                        for g in groups:
                            if g and re.match(r'\d{1,2}:\d{2}', g):
                                time_val = g
                            elif g and '日' in g:
                                note_val = g

                        if time_val:
                            # 중복 체크
                            exists = any(
                                fm['language'] == lang_code and fm['time'] == time_val
                                for fm in foreign_masses
                            )
                            if not exists:
                                foreign_masses.append({
                                    'time': time_val,
                                    'language': lang_code,
                                    'note': note_val
                                })
                break  # 한 언어에서 키워드 발견하면 다음 언어로

    return foreign_masses

def get_existing_foreign_masses(parish):
    """기존 foreignMassTimes에서 외국어 미사 목록 추출"""
    foreign_mass_times = parish.get('foreignMassTimes', {})
    existing = []

    for day, masses in foreign_mass_times.items():
        if isinstance(masses, list):
            for mass in masses:
                if isinstance(mass, dict):
                    existing.append({
                        'day': day,
                        'time': mass.get('time', ''),
                        'language': mass.get('language', ''),
                        'note': mass.get('note', '')
                    })

    return existing

def compare_masses(text_masses, existing_masses):
    """텍스트에서 추출한 미사와 기존 데이터 비교"""
    text_set = set()
    for m in text_masses:
        text_set.add((m['language'], m['time']))

    existing_set = set()
    for m in existing_masses:
        existing_set.add((m['language'], m['time']))

    missing_in_data = text_set - existing_set  # 텍스트에는 있지만 데이터에 없는 것
    extra_in_data = existing_set - text_set    # 데이터에는 있지만 텍스트에 없는 것

    return missing_in_data, extra_in_data

def analyze_parish(parish):
    """개별 성당 분석"""
    name = parish.get('name', 'Unknown')
    mass_time = parish.get('massTime', '')

    # 외국어 키워드가 있는지 확인
    has_foreign = False
    for keywords in LANGUAGE_KEYWORDS.values():
        for kw in keywords:
            if kw in mass_time:
                has_foreign = True
                break
        if has_foreign:
            break

    if not has_foreign:
        return None

    text_masses = extract_foreign_masses_from_text(mass_time)
    existing_masses = get_existing_foreign_masses(parish)

    missing, extra = compare_masses(text_masses, existing_masses)

    if missing or extra:
        return {
            'name': name,
            'massTime': mass_time,
            'text_masses': text_masses,
            'existing_masses': existing_masses,
            'missing_in_data': list(missing),
            'extra_in_data': list(extra)
        }

    return None

def process_all_parishes():
    """모든 성당 파일 처리"""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parishes_dir = os.path.join(script_dir, PARISHES_DIR)

    issues = []

    for filename in sorted(os.listdir(parishes_dir)):
        if filename.endswith('.json') and filename != 'dioceses.json':
            filepath = os.path.join(parishes_dir, filename)

            with open(filepath, 'r', encoding='utf-8') as f:
                data = json.load(f)

            if 'parishes' not in data:
                continue

            for parish in data['parishes']:
                issue = analyze_parish(parish)
                if issue:
                    issue['file'] = filename
                    issues.append(issue)

    return issues

def main():
    print("외국어 미사 데이터 불일치 분석 중...\n")

    issues = process_all_parishes()

    if not issues:
        print("불일치 없음!")
        return

    print(f"총 {len(issues)}개 성당에서 불일치 발견:\n")
    print("=" * 80)

    for issue in issues:
        print(f"\n📍 {issue['name']} ({issue['file']})")
        print(f"   massTime: {issue['massTime'][:100]}...")

        if issue['missing_in_data']:
            print(f"   ❌ foreignMassTimes에 누락된 항목:")
            for lang, time in issue['missing_in_data']:
                print(f"      - {lang} {time}")

        if issue['extra_in_data']:
            print(f"   ⚠️  foreignMassTimes에 있지만 massTime에 없는 항목:")
            for lang, time in issue['extra_in_data']:
                print(f"      - {lang} {time}")

        print(f"   현재 foreignMassTimes: {issue['existing_masses']}")

if __name__ == "__main__":
    main()
