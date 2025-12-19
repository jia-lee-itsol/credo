#!/usr/bin/env python3
"""
같은 날짜 내에서 nameEn과 nameKo가 정확히 동일한 중복 제거
"""
import json
from pathlib import Path

def main():
    file_path = Path(__file__).parent.parent / 'assets' / 'data' / 'saints' / 'saints_feast_days.json'
    
    print(f"파일 읽기: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print("="*60)
    print("같은 날짜 내에서 nameEn과 nameKo가 동일한 중복 찾기 및 제거")
    print("="*60)
    
    total_removed = 0
    duplicates_info = []
    
    # type 우선순위 (높을수록 우선)
    type_priority = {'solemnity': 3, 'feast': 2, 'memorial': 1}
    
    for day_data in data.get('days', []):
        month = day_data.get('month')
        day = day_data.get('day')
        date_key = f"{month:02d}-{day:02d}"
        saints = day_data.get('saints', [])
        
        # 중복 제거
        unique_saints = []
        seen = {}  # key: "nameEn|||nameKo" -> saint
        
        for saint in saints:
            name_en = saint.get('nameEn', '').strip()
            name_ko = saint.get('nameKo', '').strip()
            
            # nameEn과 nameKo가 모두 있는 경우
            if name_en and name_ko:
                key = f"{name_en}|||{name_ko}"
                
                if key in seen:
                    # 중복 발견
                    existing = seen[key]
                    existing_priority = type_priority.get(existing.get('type', ''), 0)
                    current_priority = type_priority.get(saint.get('type', ''), 0)
                    
                    # 더 높은 우선순위로 교체
                    if current_priority > existing_priority:
                        # 기존 것을 제거하고 새로운 것으로 교체
                        unique_saints.remove(existing)
                        unique_saints.append(saint)
                        seen[key] = saint
                        total_removed += 1
                        duplicates_info.append({
                            'date': date_key,
                            'removed': existing,
                            'kept': saint
                        })
                    else:
                        # 기존 것을 유지
                        total_removed += 1
                        duplicates_info.append({
                            'date': date_key,
                            'removed': saint,
                            'kept': existing
                        })
                else:
                    seen[key] = saint
                    unique_saints.append(saint)
            else:
                # nameEn이나 nameKo가 없는 경우는 그냥 추가
                unique_saints.append(saint)
        
        # 중복이 제거된 경우 업데이트
        if len(unique_saints) < len(saints):
            day_data['saints'] = unique_saints
    
    # 결과 출력
    print(f"\n총 {total_removed}개 중복 제거됨")
    print(f"중복이 있었던 날짜: {len(duplicates_info)}개\n")
    
    if duplicates_info:
        print("중복 제거 상세 (처음 30개):")
        for info in duplicates_info[:30]:
            print(f"\n날짜: {info['date']}")
            removed = info['removed']
            kept = info['kept']
            print(f"  제거: nameEn='{removed.get('nameEn', '')}', type='{removed.get('type', '')}'")
            print(f"  유지: nameEn='{kept.get('nameEn', '')}', type='{kept.get('type', '')}'")
        
        if len(duplicates_info) > 30:
            print(f"\n... 외 {len(duplicates_info) - 30}개 더 있음")
    
    # 파일 저장
    print(f"\n파일 저장 중...")
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print("완료!")

if __name__ == '__main__':
    main()









