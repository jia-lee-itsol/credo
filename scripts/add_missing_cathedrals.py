#!/usr/bin/env python3
"""
누락된 교구의 성당 정보를 추가하는 스크립트
웹 검색 결과를 바탕으로 기본 정보를 추가
"""

import json
from pathlib import Path

# 누락된 교구의 성당 정보 (웹 검색 결과 기반)
MISSING_CATHEDRALS = {
    "hiroshima": {
        "name": "カトリック幟町教会",
        "churchName": "世界平和記念聖堂",
        "address": "〒730-0016 広島県広島市中区幟町4-42",
        "prefecture": "広島県",
        "isCathedral": True,
        "phone": "082-221-0621",
        "fax": "082-221-8486",
        "massTime": "月～木曜日：07:00（小聖堂） / 金曜日：07:00（小聖堂）、10:00（地下聖堂） / 土曜日：07:00（小聖堂）、18:00（地下聖堂） / 主日：07:30（地下聖堂）、09:30（大聖堂） / 第1日曜15:00(ポルトガル語ミサ) / 第4日曜11:30(ベトナム語ミサ) / 最終日曜17:00(スペイン語ミサ) / 日曜14:30(英語ミサ)",
        "diocese": "hiroshima",
        "deanery": "hiroshima",
    },
    "oita": {
        "name": "カトリック大分教会",
        "churchName": "聖フランシスコ・ザビエル聖堂",
        "address": "〒870-0035 大分県大分市中央町3-7-30",
        "prefecture": "大分県",
        "isCathedral": True,
        "phone": "097-532-2452",
        "fax": "097-532-2405",
        "massTime": "土曜日：18:30 / 主日：09:30 / 主日：15:00(英語ミサ)",
        "diocese": "oita",
        "deanery": "oita",
    },
    "kagoshima": {
        "name": "鹿児島カテドラル・ザビエル記念聖堂",
        "address": "鹿児島県鹿児島市",
        "prefecture": "鹿児島県",
        "isCathedral": True,
        "massTime": "",
        "diocese": "kagoshima",
        "deanery": "kagoshima",
    },
    "naha": {
        "name": "那覇カテドラル開南教会",
        "address": "沖縄県那覇市",
        "prefecture": "沖縄県",
        "isCathedral": True,
        "massTime": "",
        "diocese": "naha",
        "deanery": "naha",
    },
}


def create_diocese_file(diocese_id: str, cathedral_data: dict, script_dir: Path):
    """교구 파일 생성"""
    parishes_dir = script_dir.parent / 'assets' / 'data' / 'parishes'
    
    file_path = parishes_dir / f'{diocese_id}.json'
    
    # 기존 파일이 있으면 확인
    if file_path.exists():
        print(f"⚠️  {diocese_id}.json already exists. Skipping...")
        return False
    
    # 기본 구조 생성
    data = {
        "diocese": diocese_id,
        "parishes": [cathedral_data]
    }
    
    # 파일 저장
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Created {diocese_id}.json with cathedral: {cathedral_data['name']}")
    return True


def main():
    """메인 함수"""
    script_dir = Path(__file__).parent
    
    print("Adding missing cathedral files...\n")
    
    success_count = 0
    for diocese_id, cathedral_data in MISSING_CATHEDRALS.items():
        if create_diocese_file(diocese_id, cathedral_data, script_dir):
            success_count += 1
    
    print(f"\n✅ Created {success_count}/{len(MISSING_CATHEDRALS)} missing diocese files")
    print("⚠️  Note: Some information (address, mass times) may need to be verified and updated.")


if __name__ == '__main__':
    main()
