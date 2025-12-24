#!/usr/bin/env python3
"""
Remove duplicate saints from saints_feast_days.json
중복된 성인 데이터를 직접 제거합니다.
"""
import json
from pathlib import Path

def main():
    file_path = Path(__file__).parent.parent / 'assets' / 'data' / 'saints' / 'saints_feast_days.json'
    
    print(f"Reading file: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # 모든 날짜에서 모니카 찾기
    monica_days = []
    for day_data in data['days']:
        saints = day_data['saints']
        monica_saints = [s for s in saints if 'monica' in s.get('nameEn', '').lower() or '모니카' in s.get('nameKo', '')]
        if len(monica_saints) > 1:
            date_str = day_data.get('date', f"{day_data['month']}-{day_data['day']}")
            monica_days.append({
                'date': date_str,
                'count': len(monica_saints),
                'saints': monica_saints
            })
    
    print(f'모니카 중복이 있는 날짜: {len(monica_days)}개')
    for day in monica_days:
        print(f"\n{day['date']}: {day['count']}개")
        for s in day['saints']:
            print(f"  - nameEn: {s.get('nameEn', '')}, nameKo: {s.get('nameKo', '')}")
    
    # 중복 제거
    total_removed = 0
    for day_data in data['days']:
        saints = day_data['saints']
        unique_saints = []
        seen_keys = set()
        
        for saint in saints:
            # 고유 키 생성 (nameEn 정규화)
            name_en = saint.get('nameEn', '').lower().strip()
            name_en_norm = name_en.replace('saint ', '').replace('st. ', '').replace('st ', '').strip()
            
            # nameKo 정규화
            name_ko = saint.get('nameKo', '').strip()
            name_ko_norm = name_ko.replace('성 ', '').replace('성', '').replace(' ', '').strip()
            
            # 키 생성 (nameEn 우선, 없으면 nameKo)
            key = name_en_norm if name_en_norm else name_ko_norm
            
            if key and key not in seen_keys:
                seen_keys.add(key)
                unique_saints.append(saint)
            elif key:
                total_removed += 1
                date_str = day_data.get('date', f"{day_data['month']}-{day_data['day']}")
                saint_name = saint.get('nameEn', saint.get('name', ''))
                print(f"중복 제거: {date_str} - {saint_name}")
            else:
                # 키가 없으면 그냥 추가
                unique_saints.append(saint)
        
        if len(unique_saints) < len(saints):
            day_data['saints'] = unique_saints
    
    print(f'\n전체 중복 제거: {total_removed}개')
    
    # 파일 저장
    print(f"Writing updated file: {file_path}")
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print('Done! Duplicate saints have been removed.')

if __name__ == '__main__':
    main()

















