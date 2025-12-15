#!/usr/bin/env python3
"""
"第X曜日" 형식의 미사 시간을 해당 요일로 이동하고 시간 옆에 괄호로 주차 정보 추가
예: "第1金曜日：10:00" → friday 배열에 "10:00(第1週)" 추가
"""
import json
import re
import os
from typing import Dict, List, Any

# 요일 매핑
WEEKDAY_MAP = {
    '月曜': 'monday',
    '火曜': 'tuesday',
    '水曜': 'wednesday',
    '木曜': 'thursday',
    '金曜': 'friday',
    '土曜': 'saturday',
    '日曜': 'sunday',
    '主日': 'sunday',
}

def parse_weekday_mass_time(mass_time_str: str) -> Dict[str, List[str]]:
    """
    "第X曜日：시간" 패턴을 파싱하여 {요일: [시간(주차정보)]} 형태로 반환
    "第1・第3" 같은 경우는 각각 분리하여 추가
    """
    result: Dict[str, List[str]] = {}
    
    # "第X曜日：시간" 패턴 찾기 (복합 패턴 지원)
    # 예: "第1金曜日：10:00", "第2・第4日曜：14:30", "第1・第3日曜14:00"
    # "第1・第3" 형식을 처리하기 위해 먼저 전체 패턴 찾기
    patterns = [
        # "第X・第Y曜日：시간" 형식 (복합)
        r'(第\d+・第\d+)([月火水木金土日主]曜日?)[：:]\s*(\d{1,2}:\d{2})',
        # "第X・第Y曜시간" 형식 (복합, 콜론 없음)
        r'(第\d+・第\d+)([月火水木金土日主]曜日?)(\d{1,2}:\d{2})',
        # "第X曜日：시간" 형식 (단일)
        r'第(\d+)([月火水木金土日主]曜日?)[：:]\s*(\d{1,2}:\d{2})',
        # "第X曜시간" 형식 (단일, 콜론 없음)
        r'第(\d+)([月火水木金土日主]曜日?)(\d{1,2}:\d{2})',
    ]
    
    for pattern in patterns:
        matches = re.finditer(pattern, mass_time_str)
        for match in matches:
            week_info = match.group(1)  # "1", "第1・第3" 등
            weekday_ja = match.group(2)  # "金曜日", "日曜", "土曜" 등
            time_str = match.group(3)  # "10:00", "14:30" 등
            
            # 요일 매핑
            weekday_key = None
            for ja_key, en_key in WEEKDAY_MAP.items():
                if ja_key in weekday_ja:
                    weekday_key = en_key
                    break
            
            if weekday_key:
                # 주차 정보 분리
                week_numbers = []
                
                # "第1・第3" 형식 처리
                if '・' in week_info and '第' in week_info:
                    # "第1・第3" → ["1", "3"]
                    parts = week_info.split('・')
                    for part in parts:
                        num_match = re.search(r'(\d+)', part)
                        if num_match:
                            week_numbers.append(num_match.group(1))
                elif '・' in week_info:
                    # "1・3" 형식
                    parts = week_info.split('・')
                    for part in parts:
                        part = part.strip()
                        if part.isdigit():
                            week_numbers.append(part)
                else:
                    # 단일 숫자 (예: "1")
                    num_match = re.search(r'(\d+)', week_info)
                    if num_match:
                        week_numbers.append(num_match.group(1))
                
                # 각 주차별로 시간 추가
                for week_num in week_numbers:
                    week_str = f"第{week_num}週"
                    time_with_week = f"{time_str}({week_str})"
                    
                    if weekday_key not in result:
                        result[weekday_key] = []
                    
                    if time_with_week not in result[weekday_key]:
                        result[weekday_key].append(time_with_week)
    
    return result


def process_parish(parish: Dict[str, Any]) -> bool:
    """
    성당 데이터를 처리하여 "第X曜日" 형식을 해당 요일로 이동
    Returns: 변경사항이 있으면 True
    """
    changed = False
    mass_time_str = parish.get('massTime', '')
    
    if not mass_time_str:
        return False
    
    # "第X曜日" 패턴 찾기
    weekday_times = parse_weekday_mass_time(mass_time_str)
    
    if not weekday_times:
        return False
    
    # massTimes 객체가 없으면 생성
    if 'massTimes' not in parish or not parish['massTimes']:
        parish['massTimes'] = {}
    
    mass_times = parish['massTimes']
    
    # 각 요일에 시간 추가
    for weekday, times in weekday_times.items():
        if weekday not in mass_times:
            mass_times[weekday] = []
        
        for time_with_week in times:
            if time_with_week not in mass_times[weekday]:
                mass_times[weekday].append(time_with_week)
                changed = True
    
    return changed


def process_file(file_path: str) -> int:
    """
    파일을 처리하여 변경된 성당 수 반환
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    changed_count = 0
    parishes = data.get('parishes', [])
    
    for parish in parishes:
        if process_parish(parish):
            changed_count += 1
    
    if changed_count > 0:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"{os.path.basename(file_path)}: {changed_count}개 성당 업데이트")
    
    return changed_count


def main():
    """모든 성당 파일 처리"""
    parishes_dir = 'assets/data/parishes'
    total_changed = 0
    
    for filename in os.listdir(parishes_dir):
        if filename.endswith('.json') and filename != 'dioceses.json':
            file_path = os.path.join(parishes_dir, filename)
            changed = process_file(file_path)
            total_changed += changed
    
    print(f"\n총 {total_changed}개 성당 업데이트 완료")


if __name__ == '__main__':
    main()
