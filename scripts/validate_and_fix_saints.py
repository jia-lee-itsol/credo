#!/usr/bin/env python3
"""
성인 축일 JSON 파일을 ChatGPT로 검증하고 수정/추가하는 스크립트
- 각 날짜별로 ChatGPT에게 정확한 성인 목록을 물어봄
- 잘못된 성인 수정
- 누락된 성인 추가
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any, Set, Optional
import requests
import time
from collections import defaultdict

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

def normalize_name(name: str) -> str:
    """성인 이름을 정규화합니다 (비교용)."""
    return name.lower().strip().replace(' ', '').replace('　', '')

def ask_chatgpt_for_saints(api_key: str, month: int, day: int) -> List[Dict[str, Any]]:
    """ChatGPT에게 특정 날짜의 정확한 성인 목록을 물어봅니다."""
    url = 'https://api.openai.com/v1/chat/completions'
    
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json'
    }
    
    prompt = f'''다음 날짜의 가톨릭 성인 축일을 정확하게 검색해주세요: {month}월 {day}일

요구사항:
- 해당 날짜에 기념되는 모든 가톨릭 성인을 정확하게 찾아주세요
- 각 성인의 일본어 이름(name), 영어 이름(nameEn), 축일 유형(type: solemnity/feast/memorial)을 제공해주세요
- JSON 형식으로 반환해주세요
- 형식: {{"saints": [{{"name": "일본어 이름", "nameEn": "English name", "type": "solemnity|feast|memorial"}}]}}
- 여러 성인이 있으면 모두 포함해주세요
- 설명이나 추가 텍스트 없이 JSON만 반환해주세요
- 정확한 가톨릭 전례력을 기준으로 해주세요'''

    data = {
        'model': 'gpt-4o-mini',
        'messages': [
            {
                'role': 'system',
                'content': '당신은 가톨릭 성인 축일 전문가입니다. 정확한 날짜와 성인 정보를 제공합니다. JSON 형식으로만 응답합니다.'
            },
            {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.3,
        'max_tokens': 1000
    }
    
    try:
        response = requests.post(url, headers=headers, json=data, timeout=30)
        response.raise_for_status()
        
        result = response.json()
        content = result['choices'][0]['message']['content'].strip()
        
        # JSON 코드 블록 제거
        if content.startswith('```'):
            lines = content.split('\n')
            content = '\n'.join([line for line in lines if not line.strip().startswith('```')]).strip()
        
        # JSON 객체만 추출
        json_start = content.find('{')
        json_end = content.rfind('}')
        if json_start != -1 and json_end != -1:
            content = content[json_start:json_end+1]
        
        parsed = json.loads(content)
        saints = parsed.get('saints', [])
        
        # 기본 필드 추가
        for saint in saints:
            saint['month'] = month
            saint['day'] = day
            saint['isJapanese'] = False
            saint.setdefault('greeting', f"{saint.get('name', '')}の{'大祝日' if saint.get('type') == 'solemnity' else '祝日' if saint.get('type') == 'feast' else '記念日'}を祝います！")
        
        return saints
    except Exception as e:
        print(f"  ⚠️  ChatGPT API 오류: {e}")
        return []

def get_saints_by_date(data: Dict[str, Any]) -> Dict[str, List[Dict[str, Any]]]:
    """날짜별로 성인을 그룹화합니다."""
    all_saints = data.get('saints', []) + data.get('japaneseSaints', [])
    saints_by_date = defaultdict(list)
    
    for saint in all_saints:
        key = f"{saint.get('month')}-{saint.get('day')}"
        saints_by_date[key].append(saint)
    
    return saints_by_date

def compare_saints(existing: List[Dict[str, Any]], chatgpt: List[Dict[str, Any]]) -> Dict[str, Any]:
    """기존 성인과 ChatGPT 결과를 비교합니다."""
    result = {
        'to_add': [],
        'to_remove': [],
        'to_update': []
    }
    
    # ChatGPT 결과를 정규화된 이름으로 매핑
    chatgpt_map = {}
    for saint in chatgpt:
        name_key = normalize_name(saint.get('name', ''))
        name_en_key = normalize_name(saint.get('nameEn', ''))
        chatgpt_map[name_key] = saint
        if name_en_key:
            chatgpt_map[name_en_key] = saint
    
    # 기존 성인 확인
    existing_map = {}
    for saint in existing:
        name_key = normalize_name(saint.get('name', ''))
        name_en_key = normalize_name(saint.get('nameEn', ''))
        existing_map[name_key] = saint
        if name_en_key:
            existing_map[name_en_key] = saint
    
    # 추가할 성인 찾기
    for saint in chatgpt:
        name_key = normalize_name(saint.get('name', ''))
        name_en_key = normalize_name(saint.get('nameEn', ''))
        
        if name_key not in existing_map and (not name_en_key or name_en_key not in existing_map):
            result['to_add'].append(saint)
    
    # 수정할 성인 찾기 (이름은 같지만 타입이 다른 경우)
    for saint in chatgpt:
        name_key = normalize_name(saint.get('name', ''))
        name_en_key = normalize_name(saint.get('nameEn', ''))
        
        existing_saint = None
        if name_key in existing_map:
            existing_saint = existing_map[name_key]
        elif name_en_key and name_en_key in existing_map:
            existing_saint = existing_map[name_en_key]
        
        if existing_saint:
            # 타입이 다른 경우 업데이트
            if existing_saint.get('type') != saint.get('type'):
                updated = existing_saint.copy()
                updated['type'] = saint.get('type')
                result['to_update'].append(updated)
    
    # 제거할 성인 찾기 (ChatGPT에 없고 기존에만 있는 경우 - 신중하게 처리)
    # 이 부분은 주석 처리 (ChatGPT가 모든 성인을 다 찾지 못할 수 있으므로)
    
    return result

def main():
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    json_path = project_root / 'assets' / 'data' / 'saints' / 'saints_feast_days.json'
    backup_path = json_path.with_suffix('.json.backup')
    
    # API 키 확인
    api_key = load_env_file()
    if not api_key:
        print("❌ OPENAI_API_KEY를 찾을 수 없습니다.")
        print("   .env 파일에 OPENAI_API_KEY=your_key 형식으로 설정해주세요.")
        sys.exit(1)
    
    # JSON 파일 읽기
    print(f"📖 JSON 파일 읽기: {json_path}")
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # 백업 생성
    print(f"💾 백업 생성: {backup_path}")
    with open(backup_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    # 날짜별로 그룹화
    saints_by_date = get_saints_by_date(data)
    total_dates = len(saints_by_date)
    
    print(f"\n📅 총 {total_dates}개의 날짜를 검증합니다...")
    print("   (각 날짜마다 ChatGPT API를 호출하므로 시간이 걸릴 수 있습니다)\n")
    
    # 진행 상황 추적
    stats = {
        'checked': 0,
        'added': 0,
        'updated': 0,
        'errors': 0
    }
    
    # 각 날짜별로 검증
    for date_key in sorted(saints_by_date.keys()):
        month, day = map(int, date_key.split('-'))
        existing_saints = saints_by_date[date_key]
        
        print(f"🔍 {month}월 {day}일 검증 중... (기존: {len(existing_saints)}명)", end=' ', flush=True)
        
        # ChatGPT에게 물어보기
        chatgpt_saints = ask_chatgpt_for_saints(api_key, month, day)
        
        if not chatgpt_saints:
            print("⚠️  ChatGPT 결과 없음")
            stats['errors'] += 1
            time.sleep(1)  # API rate limit 방지
            continue
        
        # 비교
        comparison = compare_saints(existing_saints, chatgpt_saints)
        
        # 업데이트
        changes = []
        if comparison['to_add']:
            changes.append(f"+{len(comparison['to_add'])}명 추가")
            stats['added'] += len(comparison['to_add'])
            # 기존 리스트에 추가
            for saint in comparison['to_add']:
                if saint not in existing_saints:
                    existing_saints.append(saint)
        
        if comparison['to_update']:
            changes.append(f"~{len(comparison['to_update'])}명 수정")
            stats['updated'] += len(comparison['to_update'])
            # 기존 항목 업데이트
            for updated_saint in comparison['to_update']:
                for i, existing in enumerate(existing_saints):
                    if normalize_name(existing.get('name', '')) == normalize_name(updated_saint.get('name', '')):
                        existing_saints[i] = updated_saint
                        break
        
        if changes:
            print(f"✅ {' '.join(changes)}")
        else:
            print("✓ 정상")
        
        stats['checked'] += 1
        time.sleep(1)  # API rate limit 방지
        
        # 진행 상황 출력 (10개마다)
        if stats['checked'] % 10 == 0:
            print(f"\n   진행: {stats['checked']}/{total_dates} ({stats['checked']*100//total_dates}%)")
            print(f"   추가: {stats['added']}명, 수정: {stats['updated']}명, 오류: {stats['errors']}개\n")
    
    # 업데이트된 데이터 저장
    print(f"\n💾 업데이트된 데이터 저장 중...")
    
    # saints와 japaneseSaints 분리
    all_saints = []
    japanese_saints = []
    
    for date_key, saints in saints_by_date.items():
        for saint in saints:
            if saint.get('isJapanese', False):
                japanese_saints.append(saint)
            else:
                all_saints.append(saint)
    
    # 정렬 (월, 일 순)
    all_saints.sort(key=lambda x: (x.get('month', 0), x.get('day', 0)))
    japanese_saints.sort(key=lambda x: (x.get('month', 0), x.get('day', 0)))
    
    output_data = {
        'saints': all_saints,
        'japaneseSaints': japanese_saints
    }
    
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ 완료!")
    print(f"   검증된 날짜: {stats['checked']}/{total_dates}")
    print(f"   추가된 성인: {stats['added']}명")
    print(f"   수정된 성인: {stats['updated']}명")
    print(f"   오류: {stats['errors']}개")
    print(f"\n   백업 파일: {backup_path}")

if __name__ == '__main__':
    main()

