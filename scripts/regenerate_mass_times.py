#!/usr/bin/env python3
"""
massTime 문자열을 기반으로 massTimes와 foreignMassTimes를 재생성하는 스크립트
외국어 미사는 massTimes에서 제거하고 foreignMassTimes에만 포함
"""
import json
import re
import os
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple

# 언어 코드 매핑
LANGUAGE_PATTERNS = {
    'EN': [r'英語', r'English', r'\[E\]', r'英語ミサ'],
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
    'JA': [r'\[J\]', r'日本語'],  # 일본어는 보통 기본이므로 특별히 표시할 때만
    'SIGN': [r'手話', r'Sign'],
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
    '前土曜': 'saturday',
    '主日': 'sunday',
    '日曜': 'sunday',
    '第1日曜': 'sunday',
    '第2日曜': 'sunday',
    '第3日曜': 'sunday',
    '第4日曜': 'sunday',
    '第5日曜': 'sunday',
}


def detect_language(text: str) -> Optional[str]:
    """텍스트에서 언어 코드 감지"""
    for lang_code, patterns in LANGUAGE_PATTERNS.items():
        for pattern in patterns:
            if re.search(pattern, text, re.IGNORECASE):
                return lang_code
    return None


def parse_weekday(text: str) -> Optional[str]:
    """요일 파싱"""
    for ja_key, en_key in WEEKDAY_MAP.items():
        if ja_key in text:
            return en_key
    return None


def parse_mass_time(mass_time_str: str) -> Dict[str, Any]:
    """
    massTime 문자열을 파싱하여 구조화된 데이터로 변환
    외국어 미사는 foreignMassTimes에만 포함하고 massTimes에는 포함하지 않음
    """
    if not mass_time_str or not mass_time_str.strip() or mass_time_str == "要問い合わせ":
        return {"massTimes": {}, "foreignMassTimes": {}}
    
    mass_times: Dict[str, List[str]] = {}
    foreign_mass_times: Dict[str, List[Dict[str, str]]] = {}
    
    # " / "로 분리
    parts = [p.strip() for p in mass_time_str.split(' / ') if p.strip()]
    
    current_weekday = None
    
    for part in parts:
        # 요일 확인
        weekday = parse_weekday(part)
        if weekday:
            current_weekday = weekday
        elif current_weekday is None:
            # 요일이 명시되지 않은 경우 기본값
            continue
        
        # 시간 추출
        # "主日：09:30" 또는 "第2日曜13:30(タガログ語ミサ)" 형식
        if '：' in part or ':' in part:
            # "：" 또는 ":" 뒤의 시간 부분
            time_part = part.split('：')[-1] if '：' in part else part.split(':')[-1]
            times = re.split(r'[,、]', time_part)
        else:
            # "第2日曜13:30" 형식
            times = [part]
        
        for time_str in times:
            time_str = time_str.strip()
            if not time_str:
                continue
            
            # 언어 감지
            language = detect_language(time_str)
            
            # 시간 추출
            time_match = re.search(r'(\d{1,2}:\d{2})', time_str)
            if not time_match:
                continue
            
            time = time_match.group(1)
            
            # 주 정보 추출
            week_match = re.search(r'第(\d+)[・]?第?(\d*)[日曜週]', time_str)
            week_note = ""
            if week_match:
                week1 = week_match.group(1)
                week2 = week_match.group(2) if week_match.group(2) else ""
                if week2:
                    week_note = f"第{week1}・第{week2}日曜"
                else:
                    week_note = f"第{week1}日曜"
            
            # 외국어 미사인 경우
            if language and language != 'JA':
                weekday_key = current_weekday if current_weekday else 'sunday'
                if weekday_key not in foreign_mass_times:
                    foreign_mass_times[weekday_key] = []
                
                # 중복 확인
                exists = any(
                    existing.get('time') == time and 
                    existing.get('language') == language and
                    existing.get('note') == week_note
                    for existing in foreign_mass_times[weekday_key]
                )
                
                if not exists:
                    foreign_mass_times[weekday_key].append({
                        'time': time,
                        'language': language,
                        'note': week_note
                    })
            else:
                # 일본어 미사인 경우만 massTimes에 추가
                # 주 정보가 있는 경우 (예: "13:30(第2週)")는 제외 (외국어 미사로 처리됨)
                if not week_match and not detect_language(time_str):
                    weekday_key = current_weekday if current_weekday else 'sunday'
                    
                    # "weekdays"는 개별 요일로 변환
                    if weekday_key == 'weekdays':
                        for day in ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']:
                            if day not in mass_times:
                                mass_times[day] = []
                            if time not in mass_times[day]:
                                mass_times[day].append(time)
                    else:
                        if weekday_key not in mass_times:
                            mass_times[weekday_key] = []
                        if time not in mass_times[weekday_key]:
                            mass_times[weekday_key].append(time)
        
        # "平日：月曜日から土曜日まで07:00" 같은 형식 처리
        if '平日' in part and 'から' in part and 'まで' in part:
            time_match = re.search(r'(\d{1,2}:\d{2})', part)
            if time_match:
                time = time_match.group(1)
                language = detect_language(part)
                if not language or language == 'JA':
                    for day in ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']:
                        if day not in mass_times:
                            mass_times[day] = []
                        if time not in mass_times[day]:
                            mass_times[day].append(time)
        
        # "水曜日、木曜日、土曜日07:00" 형식 처리
        if '曜日' in part and '、' in part:
            weekdays_in_part = re.findall(r'(\w+曜日)', part)
            time_match = re.search(r'(\d{1,2}:\d{2})', part)
            if time_match:
                time = time_match.group(1)
                language = detect_language(part)
                if not language or language == 'JA':
                    for wd in weekdays_in_part:
                        weekday_key = parse_weekday(wd)
                        if weekday_key and weekday_key != 'weekdays':
                            if weekday_key not in mass_times:
                                mass_times[weekday_key] = []
                            if time not in mass_times[weekday_key]:
                                mass_times[weekday_key].append(time)
        
        # "金曜日10:00" 형식 처리
        weekday_match = re.search(r'(\w+曜日)(\d{1,2}:\d{2})', part)
        if weekday_match:
            wd = weekday_match.group(1)
            time = weekday_match.group(2)
            language = detect_language(part)
            if not language or language == 'JA':
                weekday_key = parse_weekday(wd)
                if weekday_key and weekday_key != 'weekdays':
                    if weekday_key not in mass_times:
                        mass_times[weekday_key] = []
                    if time not in mass_times[weekday_key]:
                        mass_times[weekday_key].append(time)
    
    return {"massTimes": mass_times, "foreignMassTimes": foreign_mass_times}


def process_parish_file(file_path: Path) -> Tuple[int, int]:
    """
    교회 파일 처리
    Returns: (변경된 성당 수, 총 성당 수)
    """
    print(f"처리 중: {file_path.name}...")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if 'parishes' not in data:
            print(f"  ⚠️  'parishes' 키를 찾을 수 없음")
            return (0, 0)
        
        modified_count = 0
        total_count = len(data['parishes'])
        
        for parish in data['parishes']:
            if 'massTime' not in parish:
                continue
            
            mass_time_str = parish.get('massTime', '')
            if not mass_time_str or mass_time_str == "要問い合わせ":
                continue
            
            # 파싱하여 재생성
            parsed = parse_mass_time(mass_time_str)
            
            # 기존 데이터와 비교하여 변경 여부 확인
            old_mass_times = parish.get('massTimes', {})
            old_foreign_mass_times = parish.get('foreignMassTimes', {})
            
            new_mass_times = parsed['massTimes']
            new_foreign_mass_times = parsed['foreignMassTimes']
            
            # 변경 여부 확인
            if old_mass_times != new_mass_times or old_foreign_mass_times != new_foreign_mass_times:
                parish['massTimes'] = new_mass_times
                parish['foreignMassTimes'] = new_foreign_mass_times
                modified_count += 1
        
        if modified_count > 0:
            # 백업 생성
            backup_path = file_path.with_suffix('.json.bak')
            if not backup_path.exists():
                with open(backup_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
            
            # 원본 파일 업데이트
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            
            print(f"  ✅ {file_path.name}: {modified_count}/{total_count}개 성당 업데이트")
        else:
            print(f"  ℹ️  {file_path.name}: 변경사항 없음 ({total_count}개 성당)")
        
        return (modified_count, total_count)
            
    except Exception as e:
        print(f"  ❌ 오류: {file_path.name}: {e}")
        import traceback
        traceback.print_exc()
        return (0, 0)


def main():
    """메인 함수"""
    script_dir = Path(__file__).parent
    parishes_dir = script_dir.parent / 'assets' / 'data' / 'parishes'
    
    if not parishes_dir.exists():
        print(f"❌ 디렉토리를 찾을 수 없습니다: {parishes_dir}")
        return
    
    total_modified = 0
    total_parishes = 0
    
    # 모든 JSON 파일 처리
    for file_path in sorted(parishes_dir.glob('*.json')):
        if file_path.name == 'dioceses.json':
            continue
        
        modified, total = process_parish_file(file_path)
        total_modified += modified
        total_parishes += total
    
    print(f"\n{'='*70}")
    print(f"✅ 완료: {total_modified}/{total_parishes}개 성당 업데이트")
    print(f"{'='*70}")


if __name__ == '__main__':
    main()
