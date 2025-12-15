#!/usr/bin/env python3
"""
미사 시간 데이터를 요일별로 분리하고 외국어 미사를 언어별로 분리하는 스크립트
"""

import json
import re
import os
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple

# 언어 코드 매핑
LANGUAGE_PATTERNS = {
    'EN': [r'英語', r'English', r'\[E\]'],
    'ES': [r'スペイン語', r'Spanish', r'Español', r'\[S\]'],
    'CN': [r'中国語', r'Chinese', r'中文'],
    'PH': [r'フィリピン', r'Filipino'],
    'PT': [r'ポルトガル', r'Português', r'\[P\]'],
    'KR': [r'韓国語', r'Korean'],
    'FR': [r'フランス語', r'French', r'Français'],
    'DE': [r'ドイツ語', r'German', r'Deutsch'],
    'IT': [r'イタリア語', r'Italian', r'Italiano'],
    'VI': [r'ベトナム', r'Vietnamese', r'\[V\]'],
    'TH': [r'タイ', r'Thai', r'\[T\]'],
    'ID': [r'インドネシア', r'Indonesian', r'\[O\]'],
    'JA': [r'\[J\]'],  # 일본어는 보통 기본이므로 특별히 표시할 때만
}

# 요일 매핑
WEEKDAY_MAP = {
    '平日': 'weekdays',
    '月曜': 'monday',
    '火曜': 'tuesday',
    '水曜': 'wednesday',
    '木曜': 'thursday',
    '金曜': 'friday',
    '土曜': 'saturday',
    '土曜日': 'saturday',
    '主日': 'sunday',
    '日曜': 'sunday',
}


def detect_language(text: str) -> Optional[Tuple[str, str]]:
    """
    텍스트에서 언어를 감지
    Returns: (language_code, matched_text) or None
    """
    for lang_code, patterns in LANGUAGE_PATTERNS.items():
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return (lang_code, match.group(0))
    return None


def is_foreign_language(text: str) -> bool:
    """외국어 미사인지 확인"""
    return detect_language(text) is not None


def parse_weekday(text: str) -> Optional[str]:
    """요일 파싱"""
    for ja_key, en_key in WEEKDAY_MAP.items():
        if text.startswith(ja_key):
            return en_key
    return None


def parse_mass_time(mass_time_str: str) -> Dict[str, Any]:
    """
    미사 시간 문자열을 파싱하여 구조화된 데이터로 변환
    
    Returns:
    {
        "massTimes": {
            "weekdays": ["07:00"],
            "sunday": ["08:00", "10:00"]
        },
        "foreignMassTimes": {
            "sunday": [
                {
                    "time": "14:00",
                    "language": "EN",
                    "note": "第2・第4日曜"
                }
            ]
        }
    }
    """
    if not mass_time_str or not mass_time_str.strip():
        return {"massTimes": {}, "foreignMassTimes": {}}
    
    mass_times: Dict[str, List[str]] = {}
    foreign_mass_times: Dict[str, List[Dict[str, str]]] = {}
    
    # " / "로 분리
    parts = [p.strip() for p in mass_time_str.split(' / ') if p.strip()]
    
    # 이전 부분의 요일 정보를 저장 (예: "主日：09:00 / 14:00英語ミサ"에서 두 번째 부분이 일요일)
    previous_weekday = None
    
    for i, part in enumerate(parts):
        # "第X日曜XX:XX(언어)" 형식 먼저 처리
        week_sunday_pattern = re.compile(r'第(\d+)[・]?第?(\d*)[日曜]\s*(\d{1,2}:\d{2})\s*\(([^)]+)\)')
        week_matches = list(week_sunday_pattern.finditer(part))
        if week_matches:
            for match in week_matches:
                week1 = match.group(1)
                week2 = match.group(2) if match.group(2) else ""
                time_str = match.group(3)
                lang_text = match.group(4)
                
                lang_code = detect_language(lang_text)
                if lang_code and lang_code != 'JA':
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
            
            # 처리된 패턴을 part에서 제거하고 계속 처리
            for match in week_matches:
                part = part.replace(match.group(0), '').strip()
            # part가 비어있으면 다음으로
            if not part:
                continue
        
        # 먼저 언어 코드 패턴 확인 ([E], [V], [S], [P], [T], [O] 등)
        lang_code_from_bracket = None
        bracket_match = re.search(r'\[([EVSPTOJ])\]', part)
        if bracket_match:
            bracket_code = bracket_match.group(1)
            bracket_to_lang = {
                'E': 'EN', 'V': 'VI', 'S': 'ES', 'P': 'PT', 
                'T': 'TH', 'O': 'ID', 'J': 'JA'
            }
            lang_code_from_bracket = bracket_to_lang.get(bracket_code)
        
        # 외국어 미사인지 확인
        lang_info = detect_language(part)
        if lang_code_from_bracket:
            lang_code = lang_code_from_bracket
        elif lang_info:
            lang_code, lang_text = lang_info
        else:
            lang_code = None
        
        if lang_code:
            # 외국어 미사 처리
            # 요일 파싱
            weekday = None
            for ja_key, en_key in WEEKDAY_MAP.items():
                if part.startswith(ja_key):
                    weekday = en_key
                    break
            
            # 특정 주일 처리 (예: 第2・第4日曜14:00, 第3主日 14:00 [V])
            if not weekday:
                if '日曜' in part or '主日' in part:
                    weekday = 'sunday'
                elif '土曜' in part:
                    weekday = 'saturday'
            
            # 이전 부분이 일요일이었고 현재 부분에 요일 표시가 없으면 일요일로 처리
            if not weekday and previous_weekday == 'sunday' and not any(part.startswith(ja_key) for ja_key in WEEKDAY_MAP.keys()):
                weekday = 'sunday'
            
            if not weekday:
                weekday = 'other'
            
            # 시간 추출
            time_match = re.search(r'(\d{1,2}:\d{2})', part)
            time_str = time_match.group(1) if time_match else ''
            
            # 노트 추출 (예: "第2・第4日曜", "第3主日")
            note_match = re.search(r'(第\d+[・・]?第\d+[日主]曜|第\d+[日主]曜)', part)
            note = note_match.group(1) if note_match else ''
            
            if weekday not in foreign_mass_times:
                foreign_mass_times[weekday] = []
            
            foreign_mass_times[weekday].append({
                "time": time_str,
                "language": lang_code,
                "note": note
            })
        else:
            # 일본어 미사 처리
            weekday = None
            times_str = ''
            
            # 평일 처리
            if part.startswith('平日：') or part.startswith('平日:'):
                weekday = 'weekdays'
                times_str = re.sub(r'^平日[：:]', '', part).strip()
            # 토요일 처리
            elif part.startswith('土曜日：') or part.startswith('土曜日:') or \
                 part.startswith('土曜：') or part.startswith('土曜:'):
                weekday = 'saturday'
                times_str = re.sub(r'^土曜日?[：:]', '', part).strip()
                
                # 시간들을 분리하여 각각 처리
                times_list = re.split(r'[,、]', times_str)
                for single_time_str in times_list:
                    single_time_str = single_time_str.strip()
                    
                    # 언어 감지
                    time_lang = detect_language(single_time_str)
                    
                    # 시간 추출
                    time_match = re.search(r'(\d{1,2}:\d{2})', single_time_str)
                    if not time_match:
                        continue
                    
                    time_str = time_match.group(1)
                    
                    # 외국어 미사인 경우
                    if time_lang and time_lang[0] != 'JA':
                        lang_code, _ = time_lang
                        if weekday not in foreign_mass_times:
                            foreign_mass_times[weekday] = []
                        
                        exists = any(
                            existing.get('time') == time_str and 
                            existing.get('language') == lang_code
                            for existing in foreign_mass_times[weekday]
                        )
                        if not exists:
                            foreign_mass_times[weekday].append({
                                "time": time_str,
                                "language": lang_code,
                                "note": ""
                            })
                    else:
                        # 일본어 미사인 경우
                        if weekday not in mass_times:
                            mass_times[weekday] = []
                        if time_str not in mass_times[weekday]:
                            mass_times[weekday].append(time_str)
                
                previous_weekday = weekday
                continue  # 이미 처리했으므로 다음으로
            # 일요일 처리
            elif part.startswith('主日：') or part.startswith('主日:') or \
                 part.startswith('日曜：') or part.startswith('日曜:'):
                weekday = 'sunday'
                times_str = re.sub(r'^(主日|日曜)[：:]', '', part).strip()
                
                # 시간들을 분리하여 각각 처리
                times_list = re.split(r'[,、]', times_str)
                for single_time_str in times_list:
                    single_time_str = single_time_str.strip()
                    
                    # 언어 감지
                    time_lang = detect_language(single_time_str)
                    
                    # 시간 추출
                    time_match = re.search(r'(\d{1,2}:\d{2})', single_time_str)
                    if not time_match:
                        continue
                    
                    time_str = time_match.group(1)
                    
                    # 외국어 미사인 경우
                    if time_lang and time_lang[0] != 'JA':
                        lang_code, _ = time_lang
                        if weekday not in foreign_mass_times:
                            foreign_mass_times[weekday] = []
                        
                        exists = any(
                            existing.get('time') == time_str and 
                            existing.get('language') == lang_code
                            for existing in foreign_mass_times[weekday]
                        )
                        if not exists:
                            foreign_mass_times[weekday].append({
                                "time": time_str,
                                "language": lang_code,
                                "note": ""
                            })
                    else:
                        # 일본어 미사인 경우
                        if weekday not in mass_times:
                            mass_times[weekday] = []
                        if time_str not in mass_times[weekday]:
                            mass_times[weekday].append(time_str)
                
                previous_weekday = weekday
                continue  # 이미 처리했으므로 다음으로
            # 개별 요일 처리
            else:
                for ja_key, en_key in WEEKDAY_MAP.items():
                    if part.startswith(ja_key):
                        weekday = en_key
                        times_str = re.sub(rf'^{ja_key}[：:]?', '', part).strip()
                        break
            
            if weekday:
                # 시간 추출 (쉼표로 구분된 여러 시간)
                # 외국어 표시가 포함된 시간은 제외
                all_times = re.findall(r'\d{1,2}:\d{2}', times_str)
                japanese_times = []
                
                # 각 시간이 외국어 미사인지 확인
                for time in all_times:
                    # 시간 주변 텍스트 확인
                    time_index = times_str.find(time)
                    context_start = max(0, time_index - 20)
                    context_end = min(len(times_str), time_index + len(time) + 20)
                    context = times_str[context_start:context_end]
                    
                    if not is_foreign_language(context):
                        japanese_times.append(time)
                    else:
                        # 외국어 미사로 추가
                        lang_info = detect_language(context)
                        if lang_info:
                            lang_code, _ = lang_info
                            if weekday not in foreign_mass_times:
                                foreign_mass_times[weekday] = []
                            foreign_mass_times[weekday].append({
                                "time": time,
                                "language": lang_code,
                                "note": ""
                            })
                
                if japanese_times:
                    if weekday not in mass_times:
                        mass_times[weekday] = []
                    mass_times[weekday].extend(japanese_times)
                
                # 시간 형식이 아닌 경우 (예: "火、木、土曜 6:30、水曜 10:00")
                if not all_times:
                    parse_individual_weekdays(part, mass_times)
                
                # 다음 반복을 위해 요일 저장
                previous_weekday = weekday
        
        # "平日：月曜日から土曜日XX:XX(日本語・水曜日は英語)" 형식 처리
        if '平日' in part and 'から' in part and 'まで' in part:
            time_match = re.search(r'(\d{1,2}:\d{2})', part)
            if time_match:
                time = time_match.group(1)
                # 기본적으로 모든 평일에 일본어 미사로 추가
                for day in ['monday', 'tuesday', 'thursday', 'friday', 'saturday']:
                    if day not in mass_times:
                        mass_times[day] = []
                    if time not in mass_times[day]:
                        mass_times[day].append(time)
                
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
                        foreign_mass_times[exception_day].append({
                            'time': time,
                            'language': exception_lang_code,
                            'note': ''
                        })
                        # massTimes에서 제거
                        if exception_day in mass_times and time in mass_times[exception_day]:
                            mass_times[exception_day].remove(time)
    
    # weekdays를 개별 요일로 분리
    if 'weekdays' in mass_times:
        weekdays_times = mass_times['weekdays']
        # 월~금요일로 분리
        for day in ['monday', 'tuesday', 'wednesday', 'thursday', 'friday']:
            if day not in mass_times:
                mass_times[day] = []
            mass_times[day].extend(weekdays_times)
        # weekdays 제거
        del mass_times['weekdays']
    
    # foreignMassTimes의 weekdays도 분리
    if 'weekdays' in foreign_mass_times:
        weekdays_foreign = foreign_mass_times['weekdays']
        # 월~금요일로 분리
        for day in ['monday', 'tuesday', 'wednesday', 'thursday', 'friday']:
            if day not in foreign_mass_times:
                foreign_mass_times[day] = []
            foreign_mass_times[day].extend(weekdays_foreign)
        # weekdays 제거
        del foreign_mass_times['weekdays']
    
    return {
        "massTimes": mass_times,
        "foreignMassTimes": foreign_mass_times
    }


def parse_individual_weekdays(text: str, mass_times: Dict[str, List[str]]):
    """개별 요일 파싱 (예: "火、木、土曜 6:30、水曜 10:00")"""
    # "、"로 분리
    items = [item.strip() for item in text.split('、') if item.strip()]
    
    for item in items:
        # 단일 요일 패턴 (예: "水曜 10:00")
        single_match = re.match(r'^([月火水木金土]曜)[：:]?\s*(.+)', item)
        if single_match:
            weekday_ja = single_match.group(1)
            times_str = single_match.group(2)
            weekday = WEEKDAY_MAP.get(weekday_ja)
            if weekday:
                times = re.findall(r'\d{1,2}:\d{2}', times_str)
                if times:
                    if weekday not in mass_times:
                        mass_times[weekday] = []
                    mass_times[weekday].extend(times)
            continue
        
        # 복수 요일 패턴 (예: "火、木、土曜 6:30")
        multiple_match = re.match(r'^([月火水木金土、]+)曜[：:]?\s*(.+)', item)
        if multiple_match:
            weekdays_str = multiple_match.group(1)
            times_str = multiple_match.group(2)
            times = re.findall(r'\d{1,2}:\d{2}', times_str)
            
            # 개별 요일 추출
            weekday_chars = re.findall(r'[月火水木金土]', weekdays_str)
            for char in weekday_chars:
                weekday_ja = f'{char}曜'
                weekday = WEEKDAY_MAP.get(weekday_ja)
                if weekday and times:
                    if weekday not in mass_times:
                        mass_times[weekday] = []
                    mass_times[weekday].extend(times)


def process_parish_file(file_path: Path) -> bool:
    """교회 파일 처리"""
    print(f"Processing {file_path.name}...")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if 'parishes' not in data:
            print(f"  ⚠️  No 'parishes' key found in {file_path.name}")
            return False
        
        modified = False
        for parish in data['parishes']:
            if 'massTime' not in parish:
                continue
            
            mass_time_str = parish.get('massTime', '')
            if not mass_time_str:
                continue
            
            # 파싱
            parsed = parse_mass_time(mass_time_str)
            
            # 새로운 필드 추가
            parish['massTimes'] = parsed['massTimes']
            parish['foreignMassTimes'] = parsed['foreignMassTimes']
            
            # 기존 massTime은 유지 (하위 호환성)
            # 필요시 주석 처리하여 제거 가능
            # del parish['massTime']
            
            modified = True
        
        if modified:
            # 백업 생성
            backup_path = file_path.with_suffix('.json.bak')
            with open(backup_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            
            # 원본 파일 업데이트
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            
            print(f"  ✅ Updated {file_path.name}")
            return True
        else:
            print(f"  ℹ️  No changes needed for {file_path.name}")
            return False
            
    except Exception as e:
        print(f"  ❌ Error processing {file_path.name}: {e}")
        return False


def main():
    """메인 함수"""
    script_dir = Path(__file__).parent
    parishes_dir = script_dir.parent / 'assets' / 'data' / 'parishes'
    
    if not parishes_dir.exists():
        print(f"❌ Parishes directory not found: {parishes_dir}")
        return
    
    # dioceses.json 제외
    json_files = [f for f in parishes_dir.glob('*.json') 
                  if f.name != 'dioceses.json']
    
    print(f"Found {len(json_files)} parish files to process\n")
    
    success_count = 0
    for json_file in sorted(json_files):
        if process_parish_file(json_file):
            success_count += 1
        print()
    
    print(f"✅ Processed {success_count}/{len(json_files)} files successfully")
    print(f"📝 Backup files created with .bak extension")


if __name__ == '__main__':
    main()
