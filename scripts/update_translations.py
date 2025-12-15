#!/usr/bin/env python3
"""
번역 파일 업데이트 스크립트
일본어 파일을 기준으로 다른 언어 파일의 누락된 키를 추가합니다.
"""

import json
import os
from pathlib import Path

# 기준 파일 (일본어)
BASE_FILE = Path(__file__).parent.parent / 'assets/l10n/app_ja.json'

# 업데이트할 언어 파일들
LANGUAGE_FILES = {
    'en': Path(__file__).parent.parent / 'assets/l10n/app_en.json',
    'zh': Path(__file__).parent.parent / 'assets/l10n/app_zh.json',
    'vi': Path(__file__).parent.parent / 'assets/l10n/app_vi.json',
    'es': Path(__file__).parent.parent / 'assets/l10n/app_es.json',
    'pt': Path(__file__).parent.parent / 'assets/l10n/app_pt.json',
}

def deep_merge(base_dict, target_dict):
    """기본 딕셔너리를 기준으로 대상 딕셔너리에 누락된 키를 추가"""
    result = target_dict.copy()
    
    for key, value in base_dict.items():
        if key not in result:
            # 키가 없으면 추가 (일본어 값 사용)
            result[key] = value
        elif isinstance(value, dict) and isinstance(result[key], dict):
            # 둘 다 딕셔너리면 재귀적으로 병합
            result[key] = deep_merge(value, result[key])
        # 이미 값이 있으면 유지
    
    return result

def main():
    # 기준 파일 읽기
    with open(BASE_FILE, 'r', encoding='utf-8') as f:
        base_data = json.load(f)
    
    print(f'기준 파일: {BASE_FILE.name}')
    print(f'기준 파일 키 개수: {len(json.dumps(base_data))} bytes\n')
    
    # 각 언어 파일 업데이트
    for lang, file_path in LANGUAGE_FILES.items():
        print(f'처리 중: {file_path.name}')
        
        # 기존 파일 읽기 (없으면 빈 딕셔너리)
        if file_path.exists():
            with open(file_path, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
        else:
            existing_data = {}
        
        # 병합
        merged_data = deep_merge(base_data, existing_data)
        
        # 파일 저장 (들여쓰기 2칸으로 포맷팅)
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(merged_data, f, ensure_ascii=False, indent=2)
        
        print(f'  ✓ 업데이트 완료: {file_path.name}\n')

if __name__ == '__main__':
    main()
