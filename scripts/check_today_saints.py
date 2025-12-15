#!/usr/bin/env python3
"""
오늘의 성인을 ChatGPT에게 물어봐서 JSON 파일에 누락된 것이 있는지 확인하는 스크립트
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any
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
                api_key = line.split('=', 1)[1].strip().strip('"').strip("'")
                break
    
    return api_key

def get_saints_from_json(json_path: Path, month: int, day: int) -> List[Dict[str, Any]]:
    """JSON 파일에서 특정 날짜의 성인을 가져옵니다."""
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    all_saints = data.get('saints', []) + data.get('japaneseSaints', [])
    
    saints_for_date = [
        saint for saint in all_saints
        if saint.get('month') == month and saint.get('day') == day
    ]
    
    return saints_for_date

def ask_chatgpt_for_saints(api_key: str, year: int, month: int, day: int, language_code: str = 'ko') -> List[Dict[str, str]]:
    """ChatGPT에게 특정 날짜의 성인을 물어봅니다."""
    url = 'https://api.openai.com/v1/chat/completions'
    
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json',
    }
    
    language_name = {
        'ja': '일본어',
        'ko': '한국어',
        'en': '영어',
        'zh': '중국어',
        'vi': '베트남어',
        'es': '스페인어',
        'pt': '포르투갈어',
    }.get(language_code, '한국어')
    
    prompt = f'''{year}년 {month}월 {day}일 가톨릭 성인 축일을 검색해주세요.

요구사항:
- 해당 날짜에 기념되는 모든 가톨릭 성인을 찾아주세요
- 각 성인의 이름을 {language_name}로 제공해주세요
- JSON 형식으로 반환해주세요
- 형식: {{"saints": [{{"name": "성인 이름", "nameEn": "English name", "type": "solemnity|feast|memorial"}}]}}
- 여러 성인이 있으면 모두 포함해주세요
- 설명이나 추가 텍스트 없이 JSON만 반환해주세요'''
    
    data = {
        'model': 'gpt-4o-mini',
        'messages': [
            {
                'role': 'system',
                'content': '당신은 가톨릭 성인 축일 전문가입니다. 정확한 날짜와 성인 정보를 제공합니다. JSON 형식으로만 응답합니다.',
            },
            {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.3,
        'max_tokens': 500,
    }
    
    try:
        response = requests.post(url, headers=headers, json=data, timeout=30)
        response.raise_for_status()
        
        result = response.json()
        choices = result.get('choices', [])
        if not choices:
            print("ChatGPT 응답에 choices가 없습니다.")
            return []
        
        message = choices[0].get('message', {})
        content = message.get('content', '').strip()
        
        if not content:
            print("ChatGPT 응답에 content가 없습니다.")
            return []
        
        # JSON 코드 블록 제거
        if content.startswith('```'):
            lines = content.split('\n')
            content = '\n'.join([line for line in lines if not line.strip().startswith('```')]).strip()
        
        # JSON 객체만 추출
        json_start = content.find('{')
        json_end = content.rfind('}')
        if json_start != -1 and json_end != -1 and json_end > json_start:
            content = content[json_start:json_end + 1]
        
        # JSON 파싱
        parsed = json.loads(content)
        saints = parsed.get('saints', [])
        
        return saints
    except requests.exceptions.RequestException as e:
        print(f"ChatGPT API 호출 실패: {e}")
        return []
    except json.JSONDecodeError as e:
        print(f"JSON 파싱 실패: {e}")
        print(f"응답 내용: {content[:500]}")
        return []
    except Exception as e:
        print(f"오류 발생: {e}")
        import traceback
        traceback.print_exc()
        return []

def normalize_name(name: str) -> str:
    """성인 이름을 정규화합니다 (비교를 위해)."""
    # 공백 제거, 소문자 변환, 특수문자 제거
    import re
    normalized = re.sub(r'[^\w\s]', '', name.lower())
    normalized = ' '.join(normalized.split())
    return normalized

def compare_saints(json_saints: List[Dict[str, Any]], chatgpt_saints: List[Dict[str, str]]) -> Dict[str, Any]:
    """JSON 파일의 성인과 ChatGPT 결과를 비교합니다."""
    # JSON 파일의 성인 이름 정규화
    json_names = {}
    for saint in json_saints:
        name_ja = saint.get('name', '')
        name_en = saint.get('nameEn', '')
        name_ko = saint.get('nameKo', '')
        
        # 일본어, 영어, 한국어 이름 모두 정규화해서 저장
        if name_ja:
            json_names[normalize_name(name_ja)] = saint
        if name_en:
            json_names[normalize_name(name_en)] = saint
        if name_ko:
            json_names[normalize_name(name_ko)] = saint
    
    # ChatGPT 결과의 성인 이름 정규화
    chatgpt_names = {}
    for saint in chatgpt_saints:
        name = saint.get('name', '')
        name_en = saint.get('nameEn', '')
        
        if name:
            chatgpt_names[normalize_name(name)] = saint
        if name_en:
            chatgpt_names[normalize_name(name_en)] = saint
    
    # JSON에 있는 성인
    json_only = []
    for norm_name, saint in json_names.items():
        if norm_name not in chatgpt_names:
            json_only.append(saint)
    
    # ChatGPT에만 있는 성인 (누락된 것)
    chatgpt_only = []
    for norm_name, saint in chatgpt_names.items():
        if norm_name not in json_names:
            chatgpt_only.append(saint)
    
    # 공통 성인
    common = []
    for norm_name in json_names.keys():
        if norm_name in chatgpt_names:
            common.append(json_names[norm_name])
    
    return {
        'json_only': json_only,
        'chatgpt_only': chatgpt_only,
        'common': common,
    }

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
    
    # 오늘 날짜
    today = datetime.now()
    year = today.year
    month = today.month
    day = today.day
    
    print(f"\n{'='*60}")
    print(f"오늘의 성인 확인: {year}년 {month}월 {day}일")
    print(f"{'='*60}\n")
    
    # JSON 파일에서 성인 가져오기
    print("JSON 파일에서 성인 로드 중...")
    json_saints = get_saints_from_json(json_path, month, day)
    print(f"JSON 파일에 {len(json_saints)}명의 성인이 있습니다:")
    for saint in json_saints:
        name_ja = saint.get('name', '')
        name_ko = saint.get('nameKo', '')
        name_en = saint.get('nameEn', '')
        print(f"  - {name_ja} ({name_ko or name_en or ''})")
    
    # ChatGPT에게 물어보기
    print(f"\nChatGPT에게 {year}년 {month}월 {day}일의 성인을 물어보는 중...")
    chatgpt_saints = ask_chatgpt_for_saints(api_key, year, month, day, 'ko')
    print(f"ChatGPT가 {len(chatgpt_saints)}명의 성인을 반환했습니다:")
    for saint in chatgpt_saints:
        name = saint.get('name', '')
        name_en = saint.get('nameEn', '')
        saint_type = saint.get('type', 'memorial')
        print(f"  - {name} ({name_en or ''}) [{saint_type}]")
    
    # 비교
    print(f"\n{'='*60}")
    print("비교 결과:")
    print(f"{'='*60}\n")
    
    comparison = compare_saints(json_saints, chatgpt_saints)
    
    print(f"✅ 공통 성인 ({len(comparison['common'])}명):")
    for saint in comparison['common']:
        name_ja = saint.get('name', '')
        name_ko = saint.get('nameKo', '')
        print(f"  - {name_ja} ({name_ko or ''})")
    
    if comparison['json_only']:
        print(f"\n📋 JSON에만 있는 성인 ({len(comparison['json_only'])}명):")
        for saint in comparison['json_only']:
            name_ja = saint.get('name', '')
            name_ko = saint.get('nameKo', '')
            print(f"  - {name_ja} ({name_ko or ''})")
    
    if comparison['chatgpt_only']:
        print(f"\n⚠️  ChatGPT에만 있는 성인 (누락 가능성) ({len(comparison['chatgpt_only'])}명):")
        for saint in comparison['chatgpt_only']:
            name = saint.get('name', '')
            name_en = saint.get('nameEn', '')
            saint_type = saint.get('type', 'memorial')
            print(f"  - {name} ({name_en or ''}) [{saint_type}]")
    else:
        print("\n✅ 누락된 성인이 없습니다!")
    
    print(f"\n{'='*60}\n")

if __name__ == '__main__':
    main()
