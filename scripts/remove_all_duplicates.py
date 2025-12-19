#!/usr/bin/env python3
"""
Remove ALL duplicate saints from saints_feast_days.json
모든 중복된 성인 데이터를 철저히 제거합니다.
"""
import json
from pathlib import Path
import re

def normalize_name(name):
    """이름을 정규화하여 비교"""
    if not name:
        return ""
    name = str(name).strip().lower()
    # "Saint", "St.", "St" 제거
    name = re.sub(r'\b(saint|st\.?)\s+', '', name, flags=re.IGNORECASE)
    # 공백 제거
    name = name.replace(" ", "").replace("　", "")
    return name

def normalize_korean_name(name):
    """한국어 이름 정규화"""
    if not name:
        return ""
    name = str(name).strip()
    # "성", "聖" 제거
    name = re.sub(r'^[성聖]\s*', '', name)
    # 공백 제거
    name = name.replace(" ", "").replace("　", "")
    return name.lower()

def get_saint_key(saint):
    """성인의 고유 키 생성"""
    # nameEn 정규화
    name_en = normalize_name(saint.get('nameEn', ''))
    # nameKo 정규화
    name_ko = normalize_korean_name(saint.get('nameKo', ''))
    
    # nameEn 우선, 없으면 nameKo
    key = name_en if name_en else name_ko
    return key

def are_saints_duplicate(saint1, saint2):
    """두 성인이 중복인지 확인"""
    key1 = get_saint_key(saint1)
    key2 = get_saint_key(saint2)
    
    if not key1 or not key2:
        return False
    
    # 키가 같으면 중복
    if key1 == key2:
        return True
    
    # 하나가 다른 하나를 포함하는 경우 (최소 3글자 이상)
    if len(key1) >= 3 and len(key2) >= 3:
        if key1 in key2 or key2 in key1:
            return True
    
    return False

def remove_duplicates_from_list(saints):
    """리스트에서 중복 제거 (더 완전한 데이터 우선)"""
    if len(saints) <= 1:
        return saints
    
    unique_saints = []
    seen_keys = set()
    
    for saint in saints:
        key = get_saint_key(saint)
        is_duplicate = False
        
        if key:
            # 이미 본 키인지 확인
            if key in seen_keys:
                is_duplicate = True
            else:
                # 기존 unique_saints와 비교
                for i, existing in enumerate(unique_saints):
                    if are_saints_duplicate(saint, existing):
                        is_duplicate = True
                        # 더 완전한 데이터로 교체
                        saint_fields = sum(1 for k, v in saint.items() if v and k not in ['month', 'day'])
                        existing_fields = sum(1 for k, v in existing.items() if v and k not in ['month', 'day'])
                        
                        # nameEn이 더 완전한 것 우선
                        saint_name_en = saint.get('nameEn', '')
                        existing_name_en = existing.get('nameEn', '')
                        saint_has_saint = 'saint' in saint_name_en.lower()
                        existing_has_saint = 'saint' in existing_name_en.lower()
                        
                        if (saint_fields > existing_fields) or \
                           (saint_has_saint and not existing_has_saint) or \
                           (len(saint_name_en) > len(existing_name_en)):
                            unique_saints[i] = saint
                        break
                
                if not is_duplicate:
                    seen_keys.add(key)
        else:
            # 키가 없으면 중복 체크만 (같은 name으로 비교)
            name1 = saint.get('name', '').strip().lower()
            for existing in unique_saints:
                name2 = existing.get('name', '').strip().lower()
                if name1 and name2 and name1 == name2:
                    is_duplicate = True
                    break
        
        if not is_duplicate:
            unique_saints.append(saint)
    
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
            date_str = day_data.get('date', f"{day_data.get('month')}-{day_data.get('day')}")
            duplicates_found.append({
                'date': date_str,
                'removed': removed_count,
                'before': len(saints),
                'after': len(unique_saints),
                'removed_names': [s.get('nameEn', s.get('name', '')) for s in saints if s not in unique_saints]
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
        for dup in duplicates_found[:30]:
            print(f"  {dup['date']}: {dup['removed']} duplicates removed ({dup['before']} -> {dup['after']})")
            if dup['removed_names']:
                print(f"    Removed: {', '.join(dup['removed_names'])}")
        if len(duplicates_found) > 30:
            print(f"  ... and {len(duplicates_found) - 30} more days")
    
    print(f"\nWriting updated file: {file_path}")
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print("Done! All duplicate saints have been removed.")

if __name__ == '__main__':
    main()








