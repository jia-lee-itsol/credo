#!/usr/bin/env python3
"""
외국어 미사 데이터를 massTime 텍스트 기반으로 자동 수정하는 스크립트
"""

import json
import os
import re

PARISHES_DIR = "../assets/data/parishes"

# 수정이 필요한 성당 목록 (수동 확인된 데이터)
FIXES = {
    "yokohama.json": {
        "カトリック山手教会": {
            "sunday": [
                {"time": "09:30", "language": "EN", "note": "毎週"},
                {"time": "14:00", "language": "ES", "note": "第4日曜"}
            ],
            "saturday": [
                {"time": "19:00", "language": "EN", "note": "毎週"}
            ]
        },
        "カトリック藤沢教会": {
            "sunday": [
                {"time": "13:00", "language": "EN", "note": "第1・第3日曜"},
                {"time": "16:00", "language": "VI", "note": "第1日曜"},
                {"time": "14:00", "language": "ES", "note": "第2日曜"}
            ]
        },
        "カトリック平塚教会": {
            "sunday": [
                {"time": "14:00", "language": "EN", "note": "第1・第3日曜"},
                {"time": "14:00", "language": "ES", "note": "第4日曜"}
            ]
        },
        "カトリック三島教会": {
            "sunday": [
                {"time": "14:00", "language": "EN", "note": "第1日曜"},
                {"time": "15:00", "language": "ES", "note": "第2日曜"},
                {"time": "11:00", "language": "PT", "note": "第3日曜"}
            ]
        },
        "カトリック大和教会": {
            "sunday": [
                {"time": "12:00", "language": "VI", "note": "第2日曜"},
                {"time": "12:00", "language": "PT", "note": "第3日曜"},
                {"time": "15:00", "language": "ES", "note": "第3日曜"},
                {"time": "13:30", "language": "EN", "note": "第4日曜"},
                {"time": "12:00", "language": "PH", "note": "第5日曜"}
            ]
        },
        "カトリック厚木教会": {
            "sunday": [
                {"time": "14:00", "language": "PT", "note": "第1日曜"},
                {"time": "14:00", "language": "EN", "note": "第3日曜"},
                {"time": "14:00", "language": "ES", "note": "第4日曜"}
            ]
        },
        "カトリック浜松教会": {
            "sunday": [
                {"time": "16:00", "language": "ES", "note": "第3日曜"},
                {"time": "13:00", "language": "EN", "note": "第4日曜"}
            ],
            "saturday": [
                {"time": "19:30", "language": "PT", "note": "毎週"}
            ]
        },
        "カトリック掛川教会": {
            "sunday": [
                {"time": "14:00", "language": "EN", "note": "第1日曜"},
                {"time": "17:00", "language": "ES", "note": "第2日曜"},
                {"time": "17:00", "language": "PT", "note": "第4日曜"}
            ]
        },
        "カトリック磐田教会": {
            "sunday": [
                {"time": "17:30", "language": "PT", "note": "第1日曜"},
                {"time": "14:00", "language": "EN", "note": "第2日曜"}
            ]
        },
        "カトリック諏訪教会": {
            "sunday": [
                {"time": "14:00", "language": "EN", "note": "第1日曜"}
            ],
            "saturday": [
                {"time": "20:00", "language": "PT", "note": "第3土曜"}
            ]
        },
        "カトリック伊那教会": {
            "sunday": [
                {"time": "10:00", "language": "PT", "note": "第3日曜（要問合せ）"}
            ]
        },
        "カトリック甲府教会": {
            "sunday": [
                {"time": "15:00", "language": "PT", "note": "第2日曜"},
                {"time": "12:30", "language": "KR", "note": "第3日曜"},
                {"time": "14:00", "language": "EN", "note": "第4日曜"}
            ]
        }
    }
}


def apply_fixes():
    """수정 사항 적용"""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parishes_dir = os.path.join(script_dir, PARISHES_DIR)

    for filename, parish_fixes in FIXES.items():
        filepath = os.path.join(parishes_dir, filename)

        if not os.path.exists(filepath):
            print(f"파일 없음: {filepath}")
            continue

        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        modified = False
        for parish in data.get('parishes', []):
            name = parish.get('name', '')
            if name in parish_fixes:
                parish['foreignMassTimes'] = parish_fixes[name]
                print(f"✅ 수정: {name}")
                modified = True

        if modified:
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"   저장됨: {filename}\n")


if __name__ == "__main__":
    apply_fixes()
    print("완료!")
