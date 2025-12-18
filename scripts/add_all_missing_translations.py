#!/usr/bin/env python3
"""
모든 언어의 누락된 번역을 추가하는 스크립트
한국어, 중국어, 베트남어, 스페인어, 포르투갈어 번역을 추가합니다.
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, Any, Optional, List
import requests
import time

# .env 파일에서 API 키 읽기
def load_env_file():
    """.env 파일에서 OPENAI_API_KEY를 읽습니다."""
    env_path = Path(__file__).parent.parent / '.env'
    if not env_path.exists():
        print(f".env 파일을 찾을 수 없습니다: {env_path}")
        return None
    
    api_key = None
    with open(env_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line.startswith('OPENAI_API_KEY='):
                api_key = line.split('=', 1)[1].strip().strip('"').strip("'")
                break
    
    return api_key

def translate_saint_name(
    api_key: str,
    japanese_name: str,
    english_name: Optional[str],
    target_language: str,
    cache: Dict[str, str] = None
) -> Optional[str]:
    """ChatGPT를 사용하여 성인 이름을 번역합니다."""
    if cache is None:
        cache = {}
    
    # 캐시 확인
    cache_key = f"{japanese_name}_{english_name}_{target_language}"
    if cache_key in cache:
        return cache[cache_key]
    
    url = 'https://api.openai.com/v1/chat/completions'
    
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json'
    }
    
    language_info = {
        'ko': {
            'name': '한국어',
            'prefix': '성',
            'example': '성 요한, 성 마리아'
        },
        'zh': {
            'name': '중국어(简体中文)',
            'prefix': '聖',
            'example': '聖若望, 聖瑪利亞'
        },
        'vi': {
            'name': 'Tiếng Việt',
            'prefix': 'Thánh',
            'example': 'Thánh Gioan, Thánh Maria'
        },
        'es': {
            'name': 'Español',
            'prefix': 'San/Santa',
            'example': 'San Juan, Santa María'
        },
        'pt': {
            'name': 'Português',
            'prefix': 'São/Santa',
            'example': 'São João, Santa Maria'
        },
    }
    
    lang_info = language_info.get(target_language, {})
    lang_name = lang_info.get('name', target_language)
    prefix = lang_info.get('prefix', '')
    example = lang_info.get('example', '')
    
    prompt = f'''다음 가톨릭 성인의 이름을 {lang_name}로 번역해주세요.

일본어 이름: {japanese_name}
영어 이름: {english_name}

요구사항:
- {lang_name}로 된 성인 이름만 반환
- 가톨릭 전례에서 사용하는 표준 이름 사용
- {prefix} 접두사를 포함하여 반환 (예: {example})
- 설명이나 추가 텍스트 없이 이름만 반환'''
    
    data = {
        'model': 'gpt-4o-mini',
        'messages': [
            {
                'role': 'system',
                'content': f'당신은 가톨릭 성인 이름 번역 전문가입니다. {lang_name} 가톨릭 전례에서 사용하는 표준 이름을 사용하여 정확하게 번역합니다.'
            },
            {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.3,
        'max_tokens': 100
    }
    
    try:
        response = requests.post(url, headers=headers, json=data, timeout=30)
        response.raise_for_status()
        
        result = response.json()
        content = result['choices'][0]['message']['content'].strip()
        
        # 불필요한 텍스트 제거
        content = content.replace('"', '').replace("'", '').strip()
        
        if content:
            cache[cache_key] = content
            return content
    except Exception as e:
        print(f"  ⚠️  번역 실패 ({target_language}): {e}")
    
    return None

def process_saints_file(file_path: Path, api_key: str):
    """성인 파일을 처리하여 누락된 번역을 추가합니다."""
    import sys
    print(f"📖 파일 읽기: {file_path}", flush=True)
    sys.stdout.flush()
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    all_saints = data.get('saints', []) + data.get('japaneseSaints', [])
    
    # 번역 캐시
    translation_cache = {}
    
    # 언어별 필드 매핑
    language_fields = {
        'ko': 'nameKo',
        'zh': 'nameZh',
        'vi': 'nameVi',
        'es': 'nameEs',
        'pt': 'namePt',
    }
    
    # 누락된 번역이 있는 성인 찾기
    saints_to_update = []
    
    total_saints = len(all_saints)
    processed = 0
    
    for saint in all_saints:
        needs_update = False
        updates = {}
        
        japanese_name = saint.get('name', '')
        english_name = saint.get('nameEn', '')
        
        if not japanese_name and not english_name:
            continue
        
        # 각 언어별로 누락된 번역 확인
        for lang_code, field_name in language_fields.items():
            current_value = saint.get(field_name)
            if not current_value or str(current_value).strip() == '':
                # 번역 필요
                translated = translate_saint_name(
                    api_key,
                    japanese_name,
                    english_name,
                    lang_code,
                    translation_cache
                )
                
                if translated:
                    updates[field_name] = translated
                    needs_update = True
                    print(f"  ✅ {saint.get('name', 'N/A')} -> {field_name}: {translated}", flush=True)
                else:
                    print(f"  ⚠️  {saint.get('name', 'N/A')} -> {field_name}: 번역 실패", flush=True)
                sys.stdout.flush()
                
                time.sleep(1)  # API rate limit 방지
        
        if needs_update:
            updated_saint = saint.copy()
            updated_saint.update(updates)
            saints_to_update.append((saint, updated_saint))
        
        processed += 1
        if processed % 50 == 0:
            print(f"  진행: {processed}/{total_saints} ({processed*100//total_saints}%)", flush=True)
            sys.stdout.flush()
            # 중간 저장 (매 50개마다)
            if saints_to_update:
                _update_file(data, saints_to_update, file_path, is_final=False)
                # 파일 다시 읽기 (업데이트된 내용 반영)
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                all_saints = data.get('saints', []) + data.get('japaneseSaints', [])
                saints_to_update = []  # 업데이트된 항목 초기화
    
    if not saints_to_update and processed == total_saints:
        print("✅ 누락된 번역이 없습니다.")
        return
    
    # 최종 저장
    if saints_to_update:
        _update_file(data, saints_to_update, file_path, is_final=True)
    
    print(f"\n✅ 완료! 총 {processed}개의 성인을 처리했습니다.")

def _update_file(data: dict, saints_to_update: List, file_path: Path, is_final: bool = False):
    """파일을 업데이트합니다."""
    # 원본 리스트에서 업데이트
    for original, updated in saints_to_update:
        if original in data.get('saints', []):
            index = data['saints'].index(original)
            # 기존 값과 병합
            data['saints'][index].update(updated)
        elif original in data.get('japaneseSaints', []):
            index = data['japaneseSaints'].index(original)
            # 기존 값과 병합
            data['japaneseSaints'][index].update(updated)
    
    if is_final:
        # 백업 생성
        backup_path = file_path.with_suffix('.json.backup_all_translations')
        print(f"💾 백업 생성: {backup_path}")
        with open(backup_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    
    # 업데이트된 파일 저장
    print(f"💾 파일 저장: {file_path}")
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def main():
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    json_path = project_root / 'assets' / 'data' / 'saints' / 'saints_feast_days.json'
    
    # API 키 확인
    api_key = load_env_file()
    if not api_key:
        print("❌ OPENAI_API_KEY를 찾을 수 없습니다.")
        print("   .env 파일에 OPENAI_API_KEY=your_key 형식으로 설정해주세요.")
        sys.exit(1)
    
    if not json_path.exists():
        print(f"❌ JSON 파일을 찾을 수 없습니다: {json_path}")
        sys.exit(1)
    
    print("=" * 60)
    print("🚀 모든 언어 번역 추가 시작")
    print("=" * 60)
    print("⚠️  이 작업은 시간이 오래 걸릴 수 있습니다.")
    print("⚠️  API rate limit을 고려하여 각 번역마다 1초씩 대기합니다.")
    print("=" * 60)
    print()
    
    process_saints_file(json_path, api_key)
    
    print("\n" + "=" * 60)
    print("✅ 모든 작업 완료!")
    print("=" * 60)

if __name__ == '__main__':
    main()

