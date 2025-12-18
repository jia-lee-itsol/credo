#!/usr/bin/env python3
"""
중국어 번역이 누락된 성인에 대해 중국어 번역을 추가하는 스크립트
다른 언어(nameEn, nameKo, name 등)를 참고하여 중국어 번역을 생성합니다.
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

def translate_to_chinese(
    api_key: str,
    japanese_name: str,
    english_name: Optional[str],
    korean_name: Optional[str],
    other_names: Dict[str, str],
    cache: Dict[str, str] = None
) -> Optional[str]:
    """ChatGPT를 사용하여 성인 이름을 중국어로 번역합니다."""
    if cache is None:
        cache = {}
    
    # 캐시 확인
    cache_key = f"{japanese_name}_{english_name}_zh"
    if cache_key in cache:
        return cache[cache_key]
    
    url = 'https://api.openai.com/v1/chat/completions'
    
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json'
    }
    
    # 다른 언어 이름 정보 수집
    other_lang_info = []
    if korean_name:
        other_lang_info.append(f'한국어: {korean_name}')
    if other_names.get('nameVi'):
        other_lang_info.append(f'베트남어: {other_names["nameVi"]}')
    if other_names.get('nameEs'):
        other_lang_info.append(f'스페인어: {other_names["nameEs"]}')
    if other_names.get('namePt'):
        other_lang_info.append(f'포르투갈어: {other_names["namePt"]}')
    
    other_lang_text = '\n'.join(other_lang_info) if other_lang_info else ''
    
    prompt = f'''다음 가톨릭 성인의 이름을 중국어(简体中文)로 번역해주세요.

일본어 이름: {japanese_name}
${f'영어 이름: {english_name}' if english_name else ''}
${f'한국어 이름: {korean_name}' if korean_name else ''}
${other_lang_text if other_lang_text else ''}

요구사항:
- 중국어(简体中文)로 된 성인 이름만 반환
- 가톨릭 전례에서 사용하는 표준 중국어 이름 사용
- "聖" 접두사를 포함하여 반환 (예: "聖若望", "聖瑪利亞")
- 설명이나 추가 텍스트 없이 이름만 반환'''
    
    data = {
        'model': 'gpt-4o-mini',
        'messages': [
            {
                'role': 'system',
                'content': '당신은 가톨릭 성인 이름 번역 전문가입니다. 중국어 가톨릭 전례에서 사용하는 표준 이름을 사용하여 정확하게 번역합니다.'
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
        print(f"  ⚠️  중국어 번역 실패: {e}")
    
    return None

def process_saints_file(file_path: Path, api_key: str):
    """성인 파일을 처리하여 누락된 중국어 번역을 추가합니다."""
    print(f"📖 파일 읽기: {file_path}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    all_saints = data.get('saints', []) + data.get('japaneseSaints', [])
    
    # 번역 캐시
    translation_cache = {}
    
    # 누락된 중국어 번역이 있는 성인 찾기
    saints_to_update = []
    
    total_saints = len(all_saints)
    processed = 0
    
    for saint in all_saints:
        name_zh = saint.get('nameZh')
        if name_zh and str(name_zh).strip():
            continue  # 중국어 이름이 이미 있으면 스킵
        
        # 다른 언어 이름 수집
        other_names = {
            'nameVi': saint.get('nameVi'),
            'nameEs': saint.get('nameEs'),
            'namePt': saint.get('namePt'),
        }
        
        # 중국어 번역 생성
        translated_zh = translate_to_chinese(
            api_key,
            saint.get('name', ''),
            saint.get('nameEn'),
            saint.get('nameKo'),
            other_names,
            translation_cache
        )
        
        if translated_zh:
            updated_saint = saint.copy()
            updated_saint['nameZh'] = translated_zh
            saints_to_update.append((saint, updated_saint))
            print(f"  ✅ {saint.get('name')} -> nameZh: {translated_zh}")
        else:
            print(f"  ⚠️  {saint.get('name')} -> nameZh: 번역 실패")
        
        processed += 1
        if processed % 10 == 0:
            print(f"  진행: {processed}/{total_saints} ({processed*100//total_saints}%)")
        
        time.sleep(1)  # API rate limit 방지
    
    if not saints_to_update:
        print("✅ 누락된 중국어 번역이 없습니다.")
        return
    
    # 파일 업데이트
    print(f"\n💾 {len(saints_to_update)}개의 성인에 중국어 번역 추가 중...")
    
    # 원본 리스트에서 업데이트
    for original, updated in saints_to_update:
        # 원본 리스트에서 찾아서 업데이트
        if original in data.get('saints', []):
            index = data['saints'].index(original)
            data['saints'][index] = updated
        elif original in data.get('japaneseSaints', []):
            index = data['japaneseSaints'].index(original)
            data['japaneseSaints'][index] = updated
    
    # 백업 생성
    backup_path = file_path.with_suffix('.json.backup_chinese')
    print(f"💾 백업 생성: {backup_path}")
    with open(backup_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    # 업데이트된 파일 저장
    print(f"💾 업데이트된 파일 저장: {file_path}")
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ 완료! {len(saints_to_update)}개의 성인에 중국어 번역이 추가되었습니다.")

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
    
    process_saints_file(json_path, api_key)

if __name__ == '__main__':
    main()

