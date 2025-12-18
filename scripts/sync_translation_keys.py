#!/usr/bin/env python3
"""
일본어 번역 파일을 기준으로 다른 언어 파일에 누락된 키를 추가하는 스크립트
"""

import json
from pathlib import Path
from typing import Dict, Any, Set

def get_all_keys(obj: Any, prefix: str = '') -> Set[str]:
    """JSON 객체에서 모든 키 경로를 재귀적으로 추출합니다."""
    keys = set()
    
    if isinstance(obj, dict):
        for key, value in obj.items():
            current_key = f"{prefix}.{key}" if prefix else key
            keys.add(current_key)
            
            if isinstance(value, (dict, list)):
                keys.update(get_all_keys(value, current_key))
    elif isinstance(obj, list):
        for i, item in enumerate(obj):
            current_key = f"{prefix}[{i}]" if prefix else f"[{i}]"
            if isinstance(item, (dict, list)):
                keys.update(get_all_keys(item, current_key))
    
    return keys

def get_nested_value(obj: Any, key_path: str) -> Any:
    """점으로 구분된 키 경로로 중첩된 값을 가져옵니다."""
    keys = key_path.split('.')
    current = obj
    
    for key in keys:
        if isinstance(current, dict):
            current = current.get(key)
            if current is None:
                return None
        else:
            return None
    
    return current

def set_nested_value(obj: Any, key_path: str, value: Any):
    """점으로 구분된 키 경로로 중첩된 값을 설정합니다."""
    keys = key_path.split('.')
    current = obj
    
    for i, key in enumerate(keys[:-1]):
        if key not in current:
            current[key] = {}
        elif not isinstance(current[key], dict):
            # 이미 다른 타입의 값이 있으면 딕셔너리로 교체
            current[key] = {}
        current = current[key]
    
    # 값이 딕셔너리인 경우, 기존 값과 병합
    if isinstance(value, dict) and isinstance(current.get(keys[-1]), dict):
        current[keys[-1]].update(value)
    else:
        current[keys[-1]] = value

def sync_translation_files(base_file: Path, target_files: list[Path]):
    """기준 파일의 키를 다른 파일들과 동기화합니다."""
    print(f"📖 기준 파일 읽기: {base_file}")
    with open(base_file, 'r', encoding='utf-8') as f:
        base_data = json.load(f)
    
    # 기준 파일의 모든 키 추출
    base_keys = get_all_keys(base_data)
    print(f"✅ 기준 파일 키 개수: {len(base_keys)}")
    
    for target_file in target_files:
        if not target_file.exists():
            print(f"⚠️  파일이 없습니다: {target_file}")
            continue
        
        print(f"\n📖 대상 파일 읽기: {target_file}")
        with open(target_file, 'r', encoding='utf-8') as f:
            target_data = json.load(f)
        
        target_keys = get_all_keys(target_data)
        missing_keys = base_keys - target_keys
        
        if not missing_keys:
            print(f"✅ 누락된 키가 없습니다.")
            continue
        
        print(f"📝 누락된 키 개수: {len(missing_keys)}")
        
        # 누락된 키 추가
        added_count = 0
        for key_path in sorted(missing_keys):
            # 리스트 인덱스가 포함된 키는 건너뛰기
            if '[' in key_path:
                continue
                
            base_value = get_nested_value(base_data, key_path)
            if base_value is not None:
                set_nested_value(target_data, key_path, base_value)
                added_count += 1
                print(f"  ✅ 추가: {key_path}")
        
        if added_count > 0:
            # 백업 생성
            backup_file = target_file.with_suffix('.json.backup')
            print(f"💾 백업 생성: {backup_file}")
            with open(backup_file, 'w', encoding='utf-8') as f:
                json.dump(target_data, f, ensure_ascii=False, indent=2)
            
            # 업데이트된 파일 저장
            print(f"💾 업데이트된 파일 저장: {target_file}")
            with open(target_file, 'w', encoding='utf-8') as f:
                json.dump(target_data, f, ensure_ascii=False, indent=2)
            
            print(f"✅ {added_count}개의 키가 추가되었습니다.")
        else:
            print("⚠️  추가할 수 있는 키가 없습니다.")

def main():
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    l10n_dir = project_root / 'assets' / 'l10n'
    
    # 기준 파일 (일본어)
    base_file = l10n_dir / 'app_ja.json'
    
    # 대상 파일들
    target_files = [
        l10n_dir / 'app_en.json',
        l10n_dir / 'app_ko.json',
        l10n_dir / 'app_zh.json',
        l10n_dir / 'app_vi.json',
        l10n_dir / 'app_es.json',
        l10n_dir / 'app_pt.json',
    ]
    
    if not base_file.exists():
        print(f"❌ 기준 파일을 찾을 수 없습니다: {base_file}")
        return
    
    sync_translation_files(base_file, target_files)
    print("\n✅ 모든 파일 동기화 완료!")

if __name__ == '__main__':
    main()

