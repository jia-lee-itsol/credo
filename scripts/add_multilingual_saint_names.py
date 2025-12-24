#!/usr/bin/env python3
"""
성인 축일 JSON 파일에 다국어 이름 필드를 추가하는 스크립트
OpenAI API를 사용하여 번역을 생성합니다.
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, Any, Optional
import time

# OpenAI API 설정
import requests

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
                api_key = line.split('=', 1)[1].strip()
                break
    
    return api_key

# 언어별 번역 함수
def translate_saint_name(
    api_key: str,
    japanese_name: str,
    english_name: str,
    target_language: str,
    cache: Dict[str, str] = None
) -> Optional[str]:
    """성인 이름을 대상 언어로 번역합니다."""
    if cache is None:
        cache = {}
    
    # 캐시 확인
    cache_key = f"{japanese_name}|{english_name}|{target_language}"
    if cache_key in cache:
        return cache[cache_key]
    
    # 언어 이름 매핑
    language_names = {
        'ko': '한국어',
        'zh': '중국어',
        'vi': '베트남어',
        'es': '스페인어',
        'pt': '포르투갈어',
    }
    
    language_name = language_names.get(target_language, target_language)
    
    # 프롬프트 생성
    prompt = f"""다음 가톨릭 성인 이름을 {language_name}로 번역해주세요.

일본어: {japanese_name}
영어: {english_name}

요구사항:
- 가톨릭 교회에서 공식적으로 사용하는 {language_name} 성인 이름을 사용하세요
- 성인 이름의 표준 번역을 사용하세요
- "聖" (성) 같은 접두사는 {language_name} 관례에 맞게 번역하세요
- 번역된 이름만 반환하세요 (설명 없이)

{language_name} 이름:"""
    
    try:
        response = requests.post(
            'https://api.openai.com/v1/chat/completions',
            headers={
                'Authorization': f'Bearer {api_key}',
                'Content-Type': 'application/json',
            },
            json={
                'model': 'gpt-4o-mini',
                'messages': [
                    {
                        'role': 'system',
                        'content': '당신은 가톨릭 성인 이름 번역 전문가입니다. 각 언어의 표준 가톨릭 용어를 사용하여 정확하게 번역합니다.'
                    },
                    {
                        'role': 'user',
                        'content': prompt
                    }
                ],
                'temperature': 0.3,
                'max_tokens': 100,
            },
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            translated = data['choices'][0]['message']['content'].strip()
            
            # 캐시에 저장
            cache[cache_key] = translated
            
            # API 호출 제한을 위한 딜레이
            time.sleep(0.1)
            
            return translated
        else:
            print(f"API 오류 ({response.status_code}): {response.text[:200]}")
            return None
    except Exception as e:
        print(f"번역 실패 ({target_language}): {e}")
        return None

def process_saints_file(
    file_path: Path,
    api_key: str,
    languages: list = None,
    start_index: int = 0,
    max_items: int = None
):
    """성인 축일 JSON 파일을 처리합니다."""
    if languages is None:
        languages = ['ko', 'zh', 'vi', 'es', 'pt']
    
    print(f"JSON 파일 로드 중: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    saints = data.get('saints', [])
    japanese_saints = data.get('japaneseSaints', [])
    
    total_saints = len(saints) + len(japanese_saints)
    print(f"총 {total_saints}개의 성인 항목 발견")
    
    # 번역 캐시
    translation_cache = {}
    
    # 처리할 항목 수 결정
    items_to_process = saints[start_index:]
    if max_items:
        items_to_process = items_to_process[:max_items]
    
    print(f"처리 시작: 인덱스 {start_index}부터 {len(items_to_process)}개 항목")
    
    # 성인 목록 처리
    for idx, saint in enumerate(items_to_process):
        current_idx = start_index + idx
        print(f"\n[{current_idx + 1}/{len(saints)}] 처리 중: {saint.get('name', 'N/A')}")
        
        japanese_name = saint.get('name', '')
        english_name = saint.get('nameEn', '')
        
        if not japanese_name:
            print("  경고: 일본어 이름이 없습니다. 건너뜁니다.")
            continue
        
        # 각 언어로 번역
        for lang in languages:
            # 이미 번역이 있으면 건너뛰기
            lang_key = f'name{lang.capitalize()}'
            if lang_key in saint and saint[lang_key]:
                print(f"  {lang}: 이미 존재 (건너뜀)")
                continue
            
            print(f"  {lang} 번역 중...", end=' ', flush=True)
            translated = translate_saint_name(
                api_key,
                japanese_name,
                english_name,
                lang,
                translation_cache
            )
            
            if translated:
                saint[lang_key] = translated
                print(f"✓ {translated}")
            else:
                print("✗ 실패")
    
    # 일본 성인 목록도 처리
    if japanese_saints:
        print(f"\n일본 성인 {len(japanese_saints)}개 처리 중...")
        for idx, saint in enumerate(japanese_saints):
            print(f"\n[일본 {idx + 1}/{len(japanese_saints)}] 처리 중: {saint.get('name', 'N/A')}")
            
            japanese_name = saint.get('name', '')
            english_name = saint.get('nameEn', '')
            
            if not japanese_name:
                continue
            
            for lang in languages:
                lang_key = f'name{lang.capitalize()}'
                if lang_key in saint and saint[lang_key]:
                    continue
                
                print(f"  {lang} 번역 중...", end=' ', flush=True)
                translated = translate_saint_name(
                    api_key,
                    japanese_name,
                    english_name,
                    lang,
                    translation_cache
                )
                
                if translated:
                    saint[lang_key] = translated
                    print(f"✓ {translated}")
                else:
                    print("✗ 실패")
    
    # 백업 생성
    backup_path = file_path.with_suffix('.json.backup')
    print(f"\n백업 생성 중: {backup_path}")
    with open(backup_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    # 수정된 파일 저장
    print(f"수정된 파일 저장 중: {file_path}")
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print("\n완료!")

def main():
    """메인 함수"""
    # API 키 로드
    api_key = load_env_file()
    if not api_key:
        print("OPENAI_API_KEY를 찾을 수 없습니다.")
        sys.exit(1)
    
    # JSON 파일 경로
    script_dir = Path(__file__).parent
    json_path = script_dir.parent / 'assets' / 'data' / 'saints' / 'saints_feast_days.json'
    
    if not json_path.exists():
        print(f"JSON 파일을 찾을 수 없습니다: {json_path}")
        sys.exit(1)
    
    # 명령줄 인자 처리
    start_index = 0
    max_items = None
    
    if len(sys.argv) > 1:
        try:
            start_index = int(sys.argv[1])
        except ValueError:
            print("시작 인덱스는 숫자여야 합니다.")
            sys.exit(1)
    
    if len(sys.argv) > 2:
        try:
            max_items = int(sys.argv[2])
        except ValueError:
            print("최대 항목 수는 숫자여야 합니다.")
            sys.exit(1)
    
    # 처리 실행
    try:
        process_saints_file(
            json_path,
            api_key,
            languages=['ko', 'zh', 'vi', 'es', 'pt'],
            start_index=start_index,
            max_items=max_items
        )
    except KeyboardInterrupt:
        print("\n\n사용자에 의해 중단되었습니다.")
        print("현재까지의 진행 상황이 저장되었습니다.")
    except Exception as e:
        print(f"\n오류 발생: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()
























