#!/usr/bin/env python3
"""
파싱 가능한 빈 데이터 항목 처리 스크립트
"""

import json
import glob
import os
import re

def parse_week_pattern(mass_time_str):
    """주별 패턴 파싱 (제X주 일요일, 제X주 토요일 등)"""
    mass_times = {}
    foreign_mass_times = {}
    
    if not mass_time_str or not mass_time_str.strip():
        return {"massTimes": mass_times, "foreignMassTimes": foreign_mass_times}
    
    # " / "로 분리
    parts = [p.strip() for p in mass_time_str.split(' / ') if p.strip()]
    
    for part in parts:
        # "第X日曜XX:XX" 패턴 (일요일)
        sunday_pattern = re.compile(r'第(\d+)[・,]?第?(\d*)[日曜]\s*(\d{1,2}:\d{2})')
        sunday_matches = list(sunday_pattern.finditer(part))
        
        for match in sunday_matches:
            week1 = match.group(1)
            week2 = match.group(2) if match.group(2) else ""
            time_str = match.group(3)
            
            # 일요일 시간 추가 (주별 정보는 유지)
            if 'sunday' not in mass_times:
                mass_times['sunday'] = []
            if time_str not in mass_times['sunday']:
                mass_times['sunday'].append(time_str)
        
        # "第X前土曜XX:XX" 패턴 (전주 토요일)
        prev_sat_pattern = re.compile(r'第(\d+)[・,]?第?(\d*)[前土曜]\s*(\d{1,2}:\d{2})')
        prev_sat_matches = list(prev_sat_pattern.finditer(part))
        
        for match in prev_sat_matches:
            time_str = match.group(3)
            # 전주 토요일은 토요일로 처리
            if 'saturday' not in mass_times:
                mass_times['saturday'] = []
            if time_str not in mass_times['saturday']:
                mass_times['saturday'].append(time_str)
        
        # "第X土曜XX:XX" 패턴 (토요일)
        sat_pattern = re.compile(r'第(\d+)[・,]?第?(\d*)[土曜]\s*(\d{1,2}:\d{2})')
        sat_matches = list(sat_pattern.finditer(part))
        
        for match in sat_matches:
            time_str = match.group(3)
            if 'saturday' not in mass_times:
                mass_times['saturday'] = []
            if time_str not in mass_times['saturday']:
                mass_times['saturday'].append(time_str)
        
        # "第X金曜XX:XX" 패턴 (금요일)
        fri_pattern = re.compile(r'第(\d+)[・,]?第?(\d*)[金曜]\s*(\d{1,2}:\d{2})')
        fri_matches = list(fri_pattern.finditer(part))
        
        for match in fri_matches:
            time_str = match.group(3)
            if 'friday' not in mass_times:
                mass_times['friday'] = []
            if time_str not in mass_times['friday']:
                mass_times['friday'].append(time_str)
        
        # "第X～第Y日曜XX:XX" 패턴 (범위)
        range_pattern = re.compile(r'第(\d+)～第(\d+)[日曜]\s*(\d{1,2}:\d{2})')
        range_matches = list(range_pattern.finditer(part))
        
        for match in range_matches:
            time_str = match.group(3)
            if 'sunday' not in mass_times:
                mass_times['sunday'] = []
            if time_str not in mass_times['sunday']:
                mass_times['sunday'].append(time_str)
        
        # 특정 날짜 패턴 제외 (예: "10月第1日曜")
        if re.search(r'\d+月第', part):
            continue
        
        # "原則" 또는 조건부 패턴도 처리 시도
        if '原則' in part:
            # "原則第X日曜XX:XX" 패턴
            principle_match = re.search(r'原則第(\d+)[日曜]\s*(\d{1,2}:\d{2})', part)
            if principle_match:
                time_str = principle_match.group(2)
                if 'sunday' not in mass_times:
                    mass_times['sunday'] = []
                if time_str not in mass_times['sunday']:
                    mass_times['sunday'].append(time_str)
    
    return {"massTimes": mass_times, "foreignMassTimes": foreign_mass_times}

def is_empty(parish):
    """massTimes와 foreignMassTimes가 모두 비어있는지 확인"""
    mass_times = parish.get('massTimes', {})
    foreign_mass_times = parish.get('foreignMassTimes', {})
    
    mass_times_empty = True
    for day, times in mass_times.items():
        if times and len(times) > 0:
            mass_times_empty = False
            break
    
    foreign_empty = True
    if isinstance(foreign_mass_times, dict):
        for day, entries in foreign_mass_times.items():
            if entries and len(entries) > 0:
                foreign_empty = False
                break
    
    return mass_times_empty and foreign_empty

def fix_parsable_empty():
    """파싱 가능한 빈 데이터 항목 처리"""
    parish_files = glob.glob("assets/data/parishes/*.json")
    total_fixed = 0
    files_modified = []
    
    for file_path in sorted(parish_files):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            if 'parishes' not in data:
                continue
            
            file_modified = False
            fixed_in_file = 0
            
            for parish in data['parishes']:
                mass_time = parish.get('massTime', '').strip()
                
                if not mass_time:
                    continue
                
                # 빈 데이터 항목인지 확인
                if is_empty(parish):
                    # 파싱 가능한 패턴인지 확인
                    if re.search(r'第\d+[・,]?第?\d*[日前]?[日土金]曜\s*\d{1,2}:\d{2}', mass_time):
                        # 파싱 시도
                        parsed = parse_week_pattern(mass_time)
                        
                        # 결과가 있는 경우 업데이트
                        has_results = False
                        for day, times in parsed['massTimes'].items():
                            if times and len(times) > 0:
                                has_results = True
                                break
                        
                        if has_results:
                            parish['massTimes'] = parsed['massTimes']
                            parish['foreignMassTimes'] = parsed['foreignMassTimes']
                            file_modified = True
                            fixed_in_file += 1
                            print(f"  ✅ {parish.get('name', 'Unknown')}")
                            print(f"     {mass_time[:70]}")
            
            if file_modified:
                # 백업 생성
                backup_path = file_path + '.bak_parsable'
                with open(backup_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
                
                # 원본 업데이트
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
                
                files_modified.append(os.path.basename(file_path))
                total_fixed += fixed_in_file
                print(f"✅ [{os.path.basename(file_path)}] {fixed_in_file}개 수정")
        
        except Exception as e:
            print(f"❌ Error processing {file_path}: {e}")
    
    print("\n" + "=" * 80)
    print(f"✅ 총 {total_fixed}개의 파싱 가능한 빈 데이터 항목 수정 완료")
    print(f"📝 수정된 파일: {len(files_modified)}개")
    if files_modified:
        print(f"   - {', '.join(files_modified)}")

if __name__ == '__main__':
    fix_parsable_empty()
