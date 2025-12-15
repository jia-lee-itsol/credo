#!/usr/bin/env python3
"""
빈 데이터 항목만 선택적으로 파싱하는 스크립트
"""

import json
import glob
import os
import sys
from pathlib import Path

# parse_mass_times.py의 parse_mass_time 함수를 임포트하기 위해 경로 추가
sys.path.insert(0, str(Path(__file__).parent))
from parse_mass_times import parse_mass_time

def is_empty(parish):
    """massTimes와 foreignMassTimes가 모두 비어있는지 확인"""
    mass_times = parish.get('massTimes', {})
    foreign_mass_times = parish.get('foreignMassTimes', {})
    
    # massTimes 확인
    mass_times_empty = True
    for day, times in mass_times.items():
        if times and len(times) > 0:
            mass_times_empty = False
            break
    
    # foreignMassTimes 확인
    foreign_empty = True
    if isinstance(foreign_mass_times, dict):
        for day, entries in foreign_mass_times.items():
            if entries and len(entries) > 0:
                foreign_empty = False
                break
    
    return mass_times_empty and foreign_empty

def fix_empty_data():
    """빈 데이터 항목만 파싱하여 수정"""
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
                    # 파싱 시도
                    parsed = parse_mass_time(mass_time)
                    
                    # 파싱 결과가 있는 경우 업데이트
                    has_results = False
                    for day, times in parsed['massTimes'].items():
                        if times and len(times) > 0:
                            has_results = True
                            break
                    
                    if not has_results:
                        for day, entries in parsed['foreignMassTimes'].items():
                            if entries and len(entries) > 0:
                                has_results = True
                                break
                    
                    if has_results:
                        parish['massTimes'] = parsed['massTimes']
                        parish['foreignMassTimes'] = parsed['foreignMassTimes']
                        file_modified = True
                        fixed_in_file += 1
                        print(f"  ✅ {parish.get('name', 'Unknown')}")
                        print(f"     massTime: {mass_time[:70]}")
            
            if file_modified:
                # 백업 생성
                backup_path = file_path + '.bak2'
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
    print(f"✅ 총 {total_fixed}개의 빈 데이터 항목 수정 완료")
    print(f"📝 수정된 파일: {len(files_modified)}개")
    if files_modified:
        print(f"   - {', '.join(files_modified)}")

if __name__ == '__main__':
    fix_empty_data()
