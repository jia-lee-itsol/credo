#!/usr/bin/env python3
"""
각 성당의 상세 주소를 업데이트하는 스크립트
현재 간략한 주소만 있는 성당들을 찾아서 상세 주소를 검색하고 업데이트
"""
import json
import os
import re

# 이미 확인된 주소 매핑 (수동으로 확인한 주소)
KNOWN_ADDRESSES = {
    "tokyo.json": {
        "カトリック浅草教会": "東京都台東区浅草橋5-20-5",
        "カトリック足立教会": "東京都足立区綾瀬2丁目32-12",
        "カトリック赤羽教会": "東京都北区赤羽1丁目19-6",
        "カトリック赤堤教会": "東京都世田谷区赤堤3-20-1",
        "カトリック板橋教会": "東京都板橋区幸町8-6",
        "カトリック上野教会": "東京都台東区下谷1丁目5-9",
        "カトリック大森教会": "東京都大田区大森北2-5-11",
    }
}

def is_incomplete_address(address: str) -> bool:
    """주소가 상세 주소를 포함하지 않는지 확인"""
    if not address:
        return True
    # 숫자, ー, 丁目, 番地, 号 등이 없으면 간략한 주소로 간주
    return not any(char in address for char in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'ー', '丁目', '番地', '号'])

def update_addresses_in_file(file_path: str) -> int:
    """파일 내의 주소를 업데이트"""
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    filename = os.path.basename(file_path)
    updated_count = 0
    
    for parish in data.get('parishes', []):
        current_address = parish.get('address', '')
        parish_name = parish.get('name', '')
        
        # 이미 상세 주소가 있으면 스킵
        if not is_incomplete_address(current_address):
            continue
        
        # 알려진 주소가 있으면 사용
        if filename in KNOWN_ADDRESSES and parish_name in KNOWN_ADDRESSES[filename]:
            parish['address'] = KNOWN_ADDRESSES[filename][parish_name]
            updated_count += 1
            print(f"✓ {parish_name}: {KNOWN_ADDRESSES[filename][parish_name]}")
    
    if updated_count > 0:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    
    return updated_count

def main():
    """모든 성당 파일의 주소 업데이트"""
    parishes_dir = 'assets/data/parishes'
    total_updated = 0
    
    for filename in os.listdir(parishes_dir):
        if filename.endswith('.json') and filename != 'dioceses.json':
            file_path = os.path.join(parishes_dir, filename)
            updated = update_addresses_in_file(file_path)
            total_updated += updated
            if updated > 0:
                print(f"\n{filename}: {updated}개 주소 업데이트\n")
    
    print(f"총 {total_updated}개 주소 업데이트 완료")
    print("\n⚠️  알려진 주소만 업데이트했습니다.")
    print("나머지 성당의 주소는 수동으로 확인하여 KNOWN_ADDRESSES에 추가하거나 웹 검색이 필요합니다.")

if __name__ == '__main__':
    main()
