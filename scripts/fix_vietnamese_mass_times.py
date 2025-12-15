#!/usr/bin/env python3
"""
massTime 텍스트에 있는 베트ナム어 미사를 foreignMassTimes에 추가하는 스크립트
"""
import json
import os
import re
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

def extract_vietnamese_masses(mass_time_str: str) -> Dict[str, List[Dict[str, str]]]:
    """
    massTime 텍스트에서 베트ナム어 미사 정보 추출
    """
    result: Dict[str, List[Dict[str, str]]] = {}
    
    if not mass_time_str or 'ベトナム語' not in mass_time_str:
        return result
    
    # 베트ナム어 미사 패턴 찾기
    # 예: "ベトナム語：土19:30、日15:00", "ベトナム語：15:00(第2日曜)", "第1日曜15:00(ベトナム語)"
    patterns = [
        # "ベトナム語：土19:30、日15:00" 형식
        r'ベトナム語[：:]\s*([土日])(\d{1,2}:\d{2})[、,]*([土日])?(\d{1,2}:\d{2})?',
        # "第X日曜XX:XX(ベトナム語)" 형식
        r'第(\d+)[・]?第?(\d*)[日主]曜[：:]?\s*(\d{1,2}:\d{2})\s*\(ベトナム語',
        # "第X日曜XX:XX(ベトナム語ミサ)" 형식
        r'第(\d+)[・]?第?(\d*)[日主]曜[：:]?\s*(\d{1,2}:\d{2})\s*\(ベトナム語ミサ',
        # "XX:XX(第X日曜)(ベトナム語)" 형식
        r'(\d{1,2}:\d{2})\s*\(第(\d+)[・]?第?(\d*)[日主]曜\)\s*\(ベトナム語',
        # "XX:XX(ベトナム語)" 형식 (일반)
        r'(\d{1,2}:\d{2})\s*\(ベトナム語[ミサ\)]*',
        # "ベトナム語：XX:XX" 형식 (단일 시간)
        r'ベトナム語[：:]\s*(\d{1,2}:\d{2})',
    ]
    
    # 패턴 1: "ベトナム語：土19:30、日15:00" 처리
    pattern1 = re.search(r'ベトナム語[：:]\s*([土日])(\d{1,2}:\d{2})(?:[、,]([土日])(\d{1,2}:\d{2}))?', mass_time_str)
    if pattern1:
        weekday1_ja = pattern1.group(1)
        time1 = pattern1.group(2)
        weekday2_ja = pattern1.group(3)
        time2 = pattern1.group(4)
        
        # 첫 번째 시간
        weekday_key = WEEKDAY_MAP.get(weekday1_ja)
        if weekday_key:
            if weekday_key not in result:
                result[weekday_key] = []
            result[weekday_key].append({
                "time": time1,
                "language": "VI",
                "note": ""
            })
        
        # 두 번째 시간 (있는 경우)
        if weekday2_ja and time2:
            weekday_key = WEEKDAY_MAP.get(weekday2_ja)
            if weekday_key:
                if weekday_key not in result:
                    result[weekday_key] = []
                result[weekday_key].append({
                    "time": time2,
                    "language": "VI",
                    "note": ""
                })
    
    # 패턴 2: "第X日曜XX:XX(ベトナム語)" 처리
    pattern2_matches = re.finditer(r'第(\d+)[・]?第?(\d*)[日主]曜[：:]?\s*(\d{1,2}:\d{2})\s*\(ベトナム語', mass_time_str)
    for match in pattern2_matches:
        week1 = match.group(1)
        week2 = match.group(2)
        time_str = match.group(3)
        
        note = f"第{week1}日曜"
        if week2:
            note = f"第{week1}・第{week2}日曜"
        
        if 'sunday' not in result:
            result['sunday'] = []
        result['sunday'].append({
            "time": time_str,
            "language": "VI",
            "note": note
        })
    
    # 패턴 3: 일반적인 "XX:XX(ベトナム語)" 처리 (다른 패턴에 매칭되지 않은 경우)
    if not result:  # 다른 패턴에 매칭되지 않은 경우만
        pattern3_matches = re.finditer(r'(\d{1,2}:\d{2})\s*\(ベトナム語[ミサ\)]*', mass_time_str)
        for match in pattern3_matches:
            time_str = match.group(1)
            # 이전 컨텍스트에서 요일 확인
            before_text = mass_time_str[:match.start()]
            weekday_key = None
            for ja_key, en_key in WEEKDAY_MAP.items():
                if ja_key in before_text[-50:]:  # 이전 50자 내에서 요일 찾기
                    weekday_key = en_key
                    break
            
            if weekday_key:
                if weekday_key not in result:
                    result[weekday_key] = []
                result[weekday_key].append({
                    "time": time_str,
                    "language": "VI",
                    "note": ""
                })
    
    return result


def process_parish(parish: Dict[str, Any]) -> bool:
    """
    성당 데이터를 처리하여 베트ナム어 미사를 foreignMassTimes에 추가
    Returns: 변경사항이 있으면 True
    """
    changed = False
    mass_time_str = parish.get('massTime', '')
    
    if not mass_time_str or 'ベトナム語' not in mass_time_str:
        return False
    
    # 베트ナム어 미사 추출
    vietnamese_masses = extract_vietnamese_masses(mass_time_str)
    
    if not vietnamese_masses:
        return False
    
    # foreignMassTimes 객체가 없으면 생성
    if 'foreignMassTimes' not in parish or not parish['foreignMassTimes']:
        parish['foreignMassTimes'] = {}
    
    foreign_mass_times = parish['foreignMassTimes']
    
    # 각 요일에 베트ナム어 미사 추가
    for weekday, masses in vietnamese_masses.items():
        if weekday not in foreign_mass_times:
            foreign_mass_times[weekday] = []
        
        for mass in masses:
            # 중복 확인
            exists = any(
                existing.get('time') == mass['time'] and 
                existing.get('language') == 'VI'
                for existing in foreign_mass_times[weekday]
            )
            
            if not exists:
                foreign_mass_times[weekday].append(mass)
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
