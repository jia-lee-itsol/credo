#!/usr/bin/env python3
"""
번역 파일 누락 키 확인 및 추가 스크립트
일본어와 한국어 파일을 기준으로 다른 언어 파일의 누락된 키를 찾아 추가합니다.
"""

import json
import os
from pathlib import Path
from typing import Dict, Any, Set, List

# 기준 파일들 (일본어, 한국어)
BASE_FILES = {
    'ja': Path(__file__).parent.parent / 'assets/l10n/app_ja.json',
    'ko': Path(__file__).parent.parent / 'assets/l10n/app_ko.json',
}

# 업데이트할 언어 파일들
LANGUAGE_FILES = {
    'en': Path(__file__).parent.parent / 'assets/l10n/app_en.json',
    'zh': Path(__file__).parent.parent / 'assets/l10n/app_zh.json',
    'vi': Path(__file__).parent.parent / 'assets/l10n/app_vi.json',
    'es': Path(__file__).parent.parent / 'assets/l10n/app_es.json',
    'pt': Path(__file__).parent.parent / 'assets/l10n/app_pt.json',
}

def get_all_keys(data: Dict[str, Any], prefix: str = '') -> Set[str]:
    """딕셔너리의 모든 키를 재귀적으로 추출 (점으로 구분된 경로)"""
    keys = set()
    for key, value in data.items():
        full_key = f"{prefix}.{key}" if prefix else key
        keys.add(full_key)
        if isinstance(value, dict):
            keys.update(get_all_keys(value, full_key))
    return keys

def get_nested_value(data: Dict[str, Any], key_path: str) -> Any:
    """점으로 구분된 키 경로로 중첩된 값을 가져옴"""
    keys = key_path.split('.')
    value = data
    for key in keys:
        if isinstance(value, dict) and key in value:
            value = value[key]
        else:
            return None
    return value

def set_nested_value(data: Dict[str, Any], key_path: str, value: Any):
    """점으로 구분된 키 경로로 중첩된 값을 설정"""
    keys = key_path.split('.')
    current = data
    for i, key in enumerate(keys[:-1]):
        if key not in current:
            current[key] = {}
        elif not isinstance(current[key], dict):
            # 이미 다른 타입의 값이 있으면 딕셔너리로 교체
            current[key] = {}
        current = current[key]
    current[keys[-1]] = value

def deep_merge(base_dict: Dict[str, Any], target_dict: Dict[str, Any], base_keys: Set[str]) -> Dict[str, Any]:
    """기본 딕셔너리를 기준으로 대상 딕셔너리에 누락된 키를 추가"""
    result = json.loads(json.dumps(target_dict))  # deep copy
    
    for key_path in base_keys:
        base_value = get_nested_value(base_dict, key_path)
        target_value = get_nested_value(result, key_path)
        
        if base_value is None:
            continue
            
        if target_value is None:
            # 키가 없으면 추가 (일본어 값 사용)
            set_nested_value(result, key_path, base_value)
        elif isinstance(base_value, dict) and isinstance(target_value, dict):
            # 둘 다 딕셔너리면 재귀적으로 병합
            merged = deep_merge(base_value, target_value, get_all_keys(base_value))
            set_nested_value(result, key_path, merged)
        # 이미 값이 있으면 유지
    
    return result

def find_missing_keys(base_keys: Set[str], target_data: Dict[str, Any]) -> List[str]:
    """대상 파일에서 빠진 키를 찾음"""
    missing = []
    for key_path in base_keys:
        if get_nested_value(target_data, key_path) is None:
            missing.append(key_path)
    return sorted(missing)

def main():
    print("=" * 60)
    print("번역 파일 누락 키 확인 및 추가")
    print("=" * 60)
    
    # 기준 파일들 읽기
    base_data = {}
    all_base_keys = set()
    
    for lang_code, file_path in BASE_FILES.items():
        if file_path.exists():
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                base_data[lang_code] = data
                keys = get_all_keys(data)
                all_base_keys.update(keys)
                print(f"✓ 기준 파일 로드: {file_path.name} ({len(keys)} keys)")
        else:
            print(f"✗ 파일 없음: {file_path.name}")
    
    print(f"\n총 기준 키 개수: {len(all_base_keys)}\n")
    
    # 일본어를 메인 기준으로 사용
    main_base = base_data.get('ja', {})
    
    # 각 언어 파일 확인 및 업데이트
    for lang, file_path in LANGUAGE_FILES.items():
        print(f"\n{'=' * 60}")
        print(f"처리 중: {file_path.name}")
        print(f"{'=' * 60}")
        
        # 기존 파일 읽기
        if file_path.exists():
            with open(file_path, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
        else:
            existing_data = {}
            print(f"  ⚠ 파일이 없어 새로 생성합니다.")
        
        # 누락된 키 찾기
        existing_keys = get_all_keys(existing_data)
        missing_keys = find_missing_keys(all_base_keys, existing_data)
        
        if missing_keys:
            print(f"  발견된 누락 키: {len(missing_keys)}개")
            # 처음 10개만 표시
            for key in missing_keys[:10]:
                print(f"    - {key}")
            if len(missing_keys) > 10:
                print(f"    ... 외 {len(missing_keys) - 10}개")
        else:
            print(f"  ✓ 누락된 키 없음")
        
        # 병합 (누락된 키 추가)
        merged_data = deep_merge(main_base, existing_data, all_base_keys)
        
        # 파일 저장
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(merged_data, f, ensure_ascii=False, indent=2)
        
        if missing_keys:
            print(f"  ✓ 업데이트 완료: {len(missing_keys)}개 키 추가됨")
        else:
            print(f"  ✓ 파일 확인 완료 (변경사항 없음)")
    
    print(f"\n{'=' * 60}")
    print("완료!")
    print(f"{'=' * 60}")

if __name__ == '__main__':
    main()
