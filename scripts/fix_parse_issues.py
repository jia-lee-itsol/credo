#!/usr/bin/env python3
"""
parse_mass_times.py 스크립트의 파싱 문제를 수정하는 스크립트
특히:
1. "第X日曜XX:XX(언어)" 패턴이 여러 개 있을 때 모두 처리
2. "XX:XX(日本語)" 형식의 일본어 미사를 massTimes에 추가
3. 토요일 외국어 미사 처리
"""
import json
import re
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple

# 언어 코드 매핑 (parse_mass_times.py와 동일)
LANGUAGE_PATTERNS = {
    'EN': [r'英語', r'English', r'\[E\]'],
    'ES': [r'スペイン語', r'Spanish', r'Español', r'\[S\]'],
    'CN': [r'中国語', r'Chinese', r'中文'],
    'PH': [r'フィリピン', r'タガログ', r'Filipino'],
    'PT': [r'ポルトガル', r'Português', r'\[P\]'],
    'KR': [r'韓国語', r'Korean'],
    'FR': [r'フランス語', r'French', r'Français'],
    'DE': [r'ドイツ語', r'German', r'Deutsch'],
    'IT': [r'イタリア語', r'Italian', r'Italiano'],
    'VI': [r'ベトナム', r'ベトナム語', r'Vietnamese', r'\[V\]'],
    'TH': [r'タイ', r'Thai', r'\[T\]'],
    'ID': [r'インドネシア', r'インドネシア語', r'Indonesian', r'\[O\]'],
    'PL': [r'ポーランド', r'ポーランド語', r'Polish'],
    'JA': [r'\[J\]', r'日本語'],
}

WEEKDAY_MAP = {
    '平日': 'weekdays',
    '月曜': 'monday',
    '火曜': 'tuesday',
    '水曜': 'wednesday',
    '木曜': 'thursday',
    '金曜': 'friday',
    '土曜': 'saturday',
    '土曜日': 'saturday',
    '前土曜': 'saturday',
    '主日': 'sunday',
    '日曜': 'sunday',
}


def detect_language(text: str) -> Optional[Tuple[str, str]]:
    """텍스트에서 언어를 감지"""
    for lang_code, patterns in LANGUAGE_PATTERNS.items():
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return (lang_code, match.group(0))
    return None


def parse_weekday(text: str) -> Optional[str]:
    """요일 파싱"""
    for ja_key, en_key in WEEKDAY_MAP.items():
        if ja_key in text:
            return en_key
    return None


def fix_parish_mass_times(parish: Dict[str, Any]) -> bool:
    """개별 성당의 massTimes와 foreignMassTimes를 수정"""
    mass_time_str = parish.get('massTime', '')
    if not mass_time_str or mass_time_str == "要問い合わせ":
        return False
    
    mass_times = parish.get('massTimes', {})
    foreign_mass_times = parish.get('foreignMassTimes', {})
    
    changed = False
    
    # " / "로 분리
    parts = [p.strip() for p in mass_time_str.split(' / ') if p.strip()]
    
    # 1. "第X日曜XX:XX(언어)" 형식 찾기 및 foreignMassTimes에 추가
    for part in parts:
        # 모든 "第X日曜XX:XX(언어)" 패턴 찾기
        week_pattern = re.compile(r'第(\d+)[・]?第?(\d*)[日曜]\s*(\d{1,2}:\d{2})\s*\(([^)]+)\)')
        matches = list(week_pattern.finditer(part))
        
        for match in matches:
            week1 = match.group(1)
            week2 = match.group(2) if match.group(2) else ""
            time_str = match.group(3)
            lang_text = match.group(4)
            
            lang_info = detect_language(lang_text)
            if lang_info and lang_info[0] != 'JA':
                lang_code = lang_info[0]
                
                # 주 정보 구성
                if week2:
                    week_numbers = [week1, week2]
                else:
                    week_numbers = [week1]
                
                if 'sunday' not in foreign_mass_times:
                    foreign_mass_times['sunday'] = []
                
                for week_num in week_numbers:
                    week_note = f"第{week_num}日曜"
                    exists = any(
                        existing.get('time') == time_str and 
                        existing.get('language') == lang_code and
                        existing.get('note') == week_note
                        for existing in foreign_mass_times['sunday']
                    )
                    if not exists:
                        foreign_mass_times['sunday'].append({
                            "time": time_str,
                            "language": lang_code,
                            "note": week_note
                        })
                        changed = True
                
                # massTimes에서 제거
                if 'sunday' in mass_times:
                    times_to_remove = [t for t in mass_times['sunday'] if f"{time_str}(第{week_num}週)" in str(t)]
                    for t in times_to_remove:
                        mass_times['sunday'].remove(t)
                        changed = True
    
    # 2. "XX:XX(日本語)" 형식 처리 - massTimes에 추가
    for part in parts:
        if '主日：' in part or '日曜：' in part:
            times_str = re.sub(r'^(主日|日曜)[：:]', '', part).strip()
            times_list = re.split(r'[,、]', times_str)
            
            for single_time in times_list:
                single_time = single_time.strip()
                # "XX:XX(日本語)" 형식 찾기
                japanese_pattern = re.search(r'(\d{1,2}:\d{2})\s*\(日本語\)', single_time)
                if japanese_pattern:
                    time_str = japanese_pattern.group(1)
                    if 'sunday' not in mass_times:
                        mass_times['sunday'] = []
                    if time_str not in mass_times['sunday']:
                        mass_times['sunday'].append(time_str)
                        changed = True
        
        if '土曜日：' in part or '土曜：' in part:
            times_str = re.sub(r'^土曜日?[：:]', '', part).strip()
            times_list = re.split(r'[,、]', times_str)
            
            for single_time in times_list:
                single_time = single_time.strip()
                # 외국어 미사 확인
                lang_info = detect_language(single_time)
                if lang_info and lang_info[0] != 'JA':
                    time_match = re.search(r'(\d{1,2}:\d{2})', single_time)
                    if time_match:
                        time_str = time_match.group(1)
                        lang_code = lang_info[0]
                        if 'saturday' not in foreign_mass_times:
                            foreign_mass_times['saturday'] = []
                        exists = any(
                            existing.get('time') == time_str and 
                            existing.get('language') == lang_code
                            for existing in foreign_mass_times['saturday']
                        )
                        if not exists:
                            foreign_mass_times['saturday'].append({
                                "time": time_str,
                                "language": lang_code,
                                "note": ""
                            })
                            changed = True
    
    # 3. "平日：月曜日から土曜日XX:XX(日本語・水曜日は英語)" 형식 처리
    for part in parts:
        if '平日：' in part and 'から' in part and 'まで' in part:
            time_match = re.search(r'(\d{1,2}:\d{2})', part)
            if time_match:
                time_str = time_match.group(1)
                # 기본적으로 모든 평일에 일본어 미사로 추가
                for day in ['monday', 'tuesday', 'thursday', 'friday', 'saturday']:
                    if day not in mass_times:
                        mass_times[day] = []
                    if time_str not in mass_times[day]:
                        mass_times[day].append(time_str)
                        changed = True
                
                # 특정 요일 예외 처리 (예: "水曜日は英語")
                exception_match = re.search(r'(\w+曜日)は([^・)]+)', part)
                if exception_match:
                    exception_day = parse_weekday(exception_match.group(1))
                    exception_lang_text = exception_match.group(2)
                    exception_lang = detect_language(exception_lang_text)
                    if exception_day and exception_lang and exception_lang[0] != 'JA':
                        exception_lang_code = exception_lang[0]
                        # 해당 요일은 외국어 미사로
                        if exception_day not in foreign_mass_times:
                            foreign_mass_times[exception_day] = []
                        exists = any(
                            existing.get('time') == time_str and 
                            existing.get('language') == exception_lang_code
                            for existing in foreign_mass_times[exception_day]
                        )
                        if not exists:
                            foreign_mass_times[exception_day].append({
                                'time': time_str,
                                'language': exception_lang_code,
                                'note': ''
                            })
                            changed = True
                        # massTimes에서 제거
                        if exception_day in mass_times and time_str in mass_times[exception_day]:
                            mass_times[exception_day].remove(time_str)
                            changed = True
    
    if changed:
        parish['massTimes'] = mass_times
        parish['foreignMassTimes'] = foreign_mass_times
    
    return changed


def process_file(file_path: Path) -> int:
    """파일 처리"""
    print(f"처리 중: {file_path.name}...")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if 'parishes' not in data:
            print(f"  ⚠️  'parishes' 키를 찾을 수 없음")
            return 0
        
        modified_count = 0
        for parish in data['parishes']:
            if fix_parish_mass_times(parish):
                modified_count += 1
        
        if modified_count > 0:
            # 백업 생성
            backup_path = file_path.with_suffix('.json.bak3')
            if not backup_path.exists():
                with open(backup_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
            
            # 원본 파일 업데이트
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            
            print(f"  ✅ {file_path.name}: {modified_count}개 성당 수정")
        else:
            print(f"  ℹ️  {file_path.name}: 변경사항 없음")
        
        return modified_count
        
    except Exception as e:
        print(f"  ❌ 오류: {file_path.name}: {e}")
        import traceback
        traceback.print_exc()
        return 0


def main():
    script_dir = Path(__file__).parent
    parishes_dir = script_dir.parent / 'assets' / 'data' / 'parishes'
    
    total_modified = 0
    
    for file_path in sorted(parishes_dir.glob('*.json')):
        if file_path.name == 'dioceses.json' or file_path.name.endswith('.bak'):
            continue
        modified = process_file(file_path)
        total_modified += modified
    
    print(f"\n{'='*70}")
    print(f"✅ 완료: {total_modified}개 성당 수정")
    print(f"{'='*70}")


if __name__ == '__main__':
    main()
