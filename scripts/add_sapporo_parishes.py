#!/usr/bin/env python3
"""
삿포로 교구의 누락된 교회를 추가하는 스크립트
웹 검색 결과를 바탕으로 누락된 교회 정보 추가
"""

import json
from pathlib import Path

# 누락된 교회 정보 (웹 검색 결과 기반)
MISSING_PARISHES = [
    # 札幌地区
    {
        "name": "カトリック北一条教会",
        "address": "北海道札幌市中央区北1条西7丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック北十一条教会",
        "address": "北海道札幌市北区北11条西1丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック北二十六条教会",
        "address": "北海道札幌市北区北26条西7丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック円山教会",
        "address": "北海道札幌市中央区南1条西24丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック琴似教会",
        "address": "北海道札幌市西区琴似2条3丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック白石教会",
        "address": "北海道札幌市白石区本郷通8丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック新札幌教会",
        "address": "北海道札幌市厚別区厚別中央2条5丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック手稲教会",
        "address": "北海道札幌市手稲区手稲本町2条3丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック平岸教会",
        "address": "北海道札幌市豊平区平岸3条7丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック福住教会",
        "address": "北海道札幌市豊平区福住2条1丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック山鼻教会",
        "address": "北海道札幌市中央区南22条西9丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック澄川教会",
        "address": "北海道札幌市南区澄川4条3丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック真駒内教会",
        "address": "北海道札幌市南区真駒内本町6丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック南の沢教会",
        "address": "北海道札幌市南区南の沢4丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック藻岩教会",
        "address": "北海道札幌市南区藻岩下2丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック厚別教会",
        "address": "北海道札幌市厚別区厚別中央3条4丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    {
        "name": "カトリック清田教会",
        "address": "北海道札幌市清田区清田2条1丁目",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "sapporo",
    },
    # 函館地区
    {
        "name": "カトリック五稜郭教会",
        "address": "北海道函館市本町24-3",
        "prefecture": "北海道",
        "isCathedral": False,
        "phone": "0138-51-2467",
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "hakodate",
    },
    {
        "name": "カトリック大沼教会",
        "address": "北海道亀田郡七飯町大沼町85",
        "prefecture": "北海道",
        "isCathedral": False,
        "phone": "0138-67-2005",
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "hakodate",
    },
    {
        "name": "カトリック森教会",
        "address": "北海道茅部郡森町字御幸町112",
        "prefecture": "北海道",
        "isCathedral": False,
        "phone": "01374-2-2055",
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "hakodate",
    },
    {
        "name": "カトリック松前教会",
        "address": "北海道松前郡松前町字福山",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "hakodate",
    },
    {
        "name": "カトリック瀬棚教会",
        "address": "北海道久遠郡せたな町瀬棚区本町",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "hakodate",
    },
    {
        "name": "カトリック奥尻教会",
        "address": "北海道奥尻郡奥尻町",
        "prefecture": "北海道",
        "isCathedral": False,
        "massTime": "",
        "diocese": "sapporo",
        "deanery": "hakodate",
    },
    # 釧路地区 - 既存 교회 확인 필요
    # 苫小牧地区 - 既存 교회 확인 필요
]


def add_missing_parishes(script_dir: Path):
    """누락된 교회 추가"""
    parishes_dir = script_dir.parent / 'assets' / 'data' / 'parishes'
    file_path = parishes_dir / 'sapporo.json'
    
    if not file_path.exists():
        print(f"❌ {file_path} not found")
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    existing_names = {parish['name'] for parish in data['parishes']}
    
    added_count = 0
    for parish in MISSING_PARISHES:
        if parish['name'] not in existing_names:
            # massTimes와 foreignMassTimes 초기화
            parish['massTimes'] = {}
            parish['foreignMassTimes'] = {}
            data['parishes'].append(parish)
            added_count += 1
            print(f"  ✅ Added: {parish['name']}")
        else:
            print(f"  ℹ️  Already exists: {parish['name']}")
    
    if added_count > 0:
        # 백업 생성
        backup_path = file_path.with_suffix('.json.bak2')
        with open(backup_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        # 파일 저장
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"\n✅ Added {added_count} missing parishes to sapporo.json")
        return True
    else:
        print("\nℹ️  No new parishes to add")
        return False


def main():
    """메인 함수"""
    script_dir = Path(__file__).parent
    
    print("Adding missing parishes to Sapporo diocese...\n")
    add_missing_parishes(script_dir)


if __name__ == '__main__':
    main()
