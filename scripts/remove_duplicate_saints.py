#!/usr/bin/env python3
"""
Remove duplicate saints from saints_feast_days.json
중복된 성인 데이터를 제거합니다.
"""
import json
from pathlib import Path
from collections import defaultdict

def normalize_name(name):
    """이름을 정규화하여 비교 (Saint, St. 등 제거)"""
    if not name:
        return ""
    name = name.strip().lower()
    # "Saint", "St.", "St" 제거
    name = name.replace("saint ", "").replace("st. ", "").replace("st ", "")
    return name

def are_saints_duplicate(saint1, saint2):
    """두 성인이 중복인지 확인"""
    # nameEn이 같거나 정규화했을 때 같으면 중복
    name_en1 = normalize_name(saint1.get('nameEn', ''))
    name_en2 = normalize_name(saint2.get('nameEn', ''))
    
    if name_en1 and name_en2 and name_en1 == name_en2:
        return True
    
    # nameKo가 같으면 중복
    name_ko1 = saint1.get('nameKo', '').strip()
    name_ko2 = saint2.get('nameKo', '').strip()
    if name_ko1 and name_ko2 and name_ko1 == name_ko2:
        return True
    
    # name이 같고 nameEn이 비슷하면 중복
    name1 = normalize_name(saint1.get('name', ''))
    name2 = normalize_name(saint2.get('name', ''))
    if name1 and name2 and name1 == name2:
        name_en1 = saint1.get('nameEn', '').strip().lower()
        name_en2 = saint2.get('nameEn', '').strip().lower()
        if name_en1 and name_en2:
            # "monica"와 "saint monica" 같은 경우
            if name_en1 in name_en2 or name_en2 in name_en1:
                return True
    
    return False

def remove_duplicates_from_list(saints):
    """리스트에서 중복 제거 (더 완전한 데이터 우선)"""
    if len(saints) <= 1:
        return saints
    
    # 중복 그룹 찾기
    unique_saints = []
    seen = set()
    
    for i, saint in enumerate(saints):
        is_duplicate = False
        saint_key = None
        
        # 고유 키 생성 (nameEn 또는 nameKo 사용)
        name_en = saint.get('nameEn', '').strip().lower()
        name_ko = saint.get('nameKo', '').strip()
        
        if name_en:
            saint_key = f"en:{normalize_name(name_en)}"
        elif name_ko:
            saint_key = f"ko:{name_ko}"
        else:
            saint_key = f"name:{normalize_name(saint.get('name', ''))}"
        
        # 이미 본 성인인지 확인
        if saint_key in seen:
            is_duplicate = True
        else:
            # 기존 unique_saints와 비교
            for existing in unique_saints:
                if are_saints_duplicate(saint, existing):
                    is_duplicate = True
                    # 더 완전한 데이터로 교체
                    saint_fields = sum(1 for v in saint.values() if v)
                    existing_fields = sum(1 for v in existing.values() if v)
                    if saint_fields > existing_fields:
                        unique_saints.remove(existing)
                        unique_saints.append(saint)
                        seen.remove(saint_key)
                        seen.add(saint_key)
                    break
        
        if not is_duplicate:
            unique_saints.append(saint)
            seen.add(saint_key)
    
    return unique_saints

def main():
    file_path = Path(__file__).parent.parent / 'assets' / 'data' / 'saints' / 'saints_feast_days.json'
    
    print(f"Reading file: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    total_before = 0
    total_after = 0
    duplicates_found = []
    
    print("Removing duplicate saints...")
    for day_data in data.get('days', []):
        saints = day_data.get('saints', [])
        total_before += len(saints)
        
        # 중복 제거
        unique_saints = remove_duplicates_from_list(saints)
        removed_count = len(saints) - len(unique_saints)
        
        if removed_count > 0:
            duplicates_found.append({
                'date': day_data.get('date', f"{day_data.get('month')}-{day_data.get('day')}"),
                'removed': removed_count,
                'before': len(saints),
                'after': len(unique_saints)
            })
        
        day_data['saints'] = unique_saints
        total_after += len(unique_saints)
    
    print(f"\nSummary:")
    print(f"  Total saints before: {total_before}")
    print(f"  Total saints after: {total_after}")
    print(f"  Removed: {total_before - total_after}")
    print(f"  Days with duplicates: {len(duplicates_found)}")
    
    if duplicates_found:
        print(f"\nDays with duplicates removed:")
        for dup in duplicates_found[:20]:  # 처음 20개만 출력
            print(f"  {dup['date']}: {dup['removed']} duplicates removed ({dup['before']} -> {dup['after']})")
        if len(duplicates_found) > 20:
            print(f"  ... and {len(duplicates_found) - 20} more days")
    
    print(f"\nWriting updated file: {file_path}")
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print("Done! Duplicate saints have been removed.")

if __name__ == '__main__':
    main()









