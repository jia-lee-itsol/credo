#!/usr/bin/env python3
"""
Remove duplicate saints from saints_feast_days.json
중복된 성인 데이터를 제거합니다 (개선 버전).
"""
import json
from pathlib import Path

def normalize_name(name):
    """이름을 정규화하여 비교"""
    if not name:
        return ""
    name = str(name).strip().lower()
    # "Saint", "St.", "St" 제거
    name = name.replace("saint ", "").replace("st. ", "").replace("st ", "")
    # 공백 제거
    name = name.replace(" ", "")
    return name

def are_saints_duplicate(saint1, saint2):
    """두 성인이 중복인지 확인"""
    # nameEn 정규화 비교
    name_en1 = normalize_name(saint1.get('nameEn', ''))
    name_en2 = normalize_name(saint2.get('nameEn', ''))
    
    if name_en1 and name_en2:
        # 완전히 같거나, 하나가 다른 하나를 포함하는 경우
        if name_en1 == name_en2:
            return True
        if name_en1 and name_en2 and (name_en1 in name_en2 or name_en2 in name_en1):
            return True
    
    # nameKo 비교
    name_ko1 = saint1.get('nameKo', '').strip()
    name_ko2 = saint2.get('nameKo', '').strip()
    if name_ko1 and name_ko2:
        # "성모니카"와 "성 모니카" 같은 경우 (공백 제거 후 비교)
        ko1_normalized = name_ko1.replace(" ", "").replace("성", "").replace("聖", "")
        ko2_normalized = name_ko2.replace(" ", "").replace("성", "").replace("聖", "")
        if ko1_normalized and ko2_normalized and ko1_normalized == ko2_normalized:
            return True
    
    return False

def remove_duplicates_from_list(saints):
    """리스트에서 중복 제거 (더 완전한 데이터 우선)"""
    if len(saints) <= 1:
        return saints
    
    unique_saints = []
    
    for saint in saints:
        is_duplicate = False
        
        # 기존 unique_saints와 비교
        for i, existing in enumerate(unique_saints):
            if are_saints_duplicate(saint, existing):
                is_duplicate = True
                # 더 완전한 데이터로 교체 (더 많은 필드가 있는 것)
                saint_fields = sum(1 for k, v in saint.items() if v and k not in ['month', 'day'])
                existing_fields = sum(1 for k, v in existing.items() if v and k not in ['month', 'day'])
                
                if saint_fields > existing_fields:
                    unique_saints[i] = saint
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
        for dup in duplicates_found[:30]:  # 처음 30개만 출력
            print(f"  {dup['date']}: {dup['removed']} duplicates removed ({dup['before']} -> {dup['after']})")
        if len(duplicates_found) > 30:
            print(f"  ... and {len(duplicates_found) - 30} more days")
    
    print(f"\nWriting updated file: {file_path}")
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print("Done! Duplicate saints have been removed.")

if __name__ == '__main__':
    main()

















