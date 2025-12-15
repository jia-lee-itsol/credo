#!/usr/bin/env python3
"""
JSON 파일의 각 날짜별 성인을 ChatGPT와 비교하여 누락된 성인을 확인하고 추가하는 스크립트
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime, timedelta
from typing import List, Dict, Any, Set
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

def ask_chatgpt_for_saints(api_key: str, year: int, month: int, day: int, language_code: str = 'ja') -> List[Dict[str, str]]:
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
    }.get(language_code, '일본어')
    
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
            return []
        
        message = choices[0].get('message', {})
        content = message.get('content', '').strip()
        
        if not content:
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
    except Exception as e:
        print(f"  ⚠️  ChatGPT API 호출 실패: {e}")
        return []

def normalize_name(name: str) -> str:
    """성인 이름을 정규화합니다 (비교를 위해)."""
    import re
    # 공백 제거, 소문자 변환, 특수문자 제거
    normalized = re.sub(r'[^\w\s]', '', name.lower())
    normalized = ' '.join(normalized.split())
    # "聖", "Saint", "성" 같은 접두사 제거
    normalized = re.sub(r'^(聖|saint|성)\s*', '', normalized, flags=re.IGNORECASE)
    return normalized

def find_missing_saints(json_saints: List[Dict[str, Any]], chatgpt_saints: List[Dict[str, str]]) -> List[Dict[str, str]]:
    """JSON 파일의 성인과 ChatGPT 결과를 비교하여 누락된 성인을 찾습니다."""
    # JSON 파일의 성인 이름 정규화
    json_names: Set[str] = set()
    for saint in json_saints:
        name_ja = saint.get('name', '')
        name_en = saint.get('nameEn', '')
        name_ko = saint.get('nameKo', '')
        
        if name_ja:
            json_names.add(normalize_name(name_ja))
        if name_en:
            json_names.add(normalize_name(name_en))
        if name_ko:
            json_names.add(normalize_name(name_ko))
    
    # ChatGPT 결과에서 누락된 성인 찾기
    missing = []
    for saint in chatgpt_saints:
        name = saint.get('name', '')
        name_en = saint.get('nameEn', '')
        
        norm_name = normalize_name(name)
        norm_name_en = normalize_name(name_en) if name_en else ''
        
        # JSON에 없는 경우
        if norm_name not in json_names and norm_name_en not in json_names:
            # 부분 일치 확인 (너무 엄격하지 않게)
            is_found = False
            for json_name in json_names:
                # 핵심 이름 부분이 포함되어 있는지 확인
                if norm_name and json_name:
                    # 한쪽이 다른 쪽을 포함하거나, 핵심 단어가 일치하는 경우
                    core_words = set(norm_name.split())
                    json_core_words = set(json_name.split())
                    if core_words and json_core_words:
                        # 공통 단어가 있으면 일치로 간주
                        if core_words.intersection(json_core_words):
                            is_found = True
                            break
            
            if not is_found:
                missing.append(saint)
    
    return missing

def create_saint_entry(month: int, day: int, saint: Dict[str, str]) -> Dict[str, Any]:
    """성인 항목 생성"""
    name_ja = saint.get('name', '')
    name_en = saint.get('nameEn', '')
    saint_type = saint.get('type', 'memorial')
    
    # greeting 생성
    if saint_type == 'solemnity':
        greeting = f"{name_ja}の大祝日を祝います！"
    elif saint_type == 'feast':
        greeting = f"{name_ja}の祝日を祝います！"
    else:
        greeting = f"{name_ja}の記念日を祝います！"
    
    return {
        "month": month,
        "day": day,
        "name": name_ja,
        "nameEn": name_en,
        "type": saint_type,
        "isJapanese": False,
        "greeting": greeting
    }

def check_date_range(json_path: Path, api_key: str, start_date: datetime = None, end_date: datetime = None, sample_days: int = None):
    """날짜 범위의 성인을 확인합니다."""
    if start_date is None:
        # 기본값: 올해 1월 1일부터 12월 31일까지
        year = datetime.now().year
        start_date = datetime(year, 1, 1)
        end_date = datetime(year, 12, 31)
    
    # 샘플링 모드: 매 N일마다 확인
    if sample_days:
        dates_to_check = []
        current = start_date
        while current <= end_date:
            dates_to_check.append(current)
            current += timedelta(days=sample_days)
    else:
        # 모든 날짜 확인
        dates_to_check = []
        current = start_date
        while current <= end_date:
            dates_to_check.append(current)
            current += timedelta(days=1)
    
    print(f"\n{'='*60}")
    print(f"성인 축일 확인 및 수정")
    print(f"날짜 범위: {start_date.strftime('%Y-%m-%d')} ~ {end_date.strftime('%Y-%m-%d')}")
    print(f"확인할 날짜 수: {len(dates_to_check)}개")
    if sample_days:
        print(f"샘플링: 매 {sample_days}일마다 확인")
    print(f"{'='*60}\n")
    
    # JSON 파일 로드
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    all_missing = []
    checked_dates = 0
    
    for date in dates_to_check:
        month = date.month
        day = date.day
        year = date.year
        
        checked_dates += 1
        print(f"[{checked_dates}/{len(dates_to_check)}] {year}년 {month}월 {day}일 확인 중...", end=' ')
        
        # JSON에서 성인 가져오기
        json_saints = get_saints_from_json(json_path, month, day)
        
        # ChatGPT에게 물어보기
        chatgpt_saints = ask_chatgpt_for_saints(api_key, year, month, day, 'ja')
        
        if not chatgpt_saints:
            print("⚠️  ChatGPT 응답 없음")
            time.sleep(1)  # API rate limit 방지
            continue
        
        # 누락된 성인 찾기
        missing = find_missing_saints(json_saints, chatgpt_saints)
        
        if missing:
            print(f"⚠️  누락된 성인 {len(missing)}명 발견:")
            for saint in missing:
                name = saint.get('name', '')
                name_en = saint.get('nameEn', '')
                print(f"    - {name} ({name_en})")
            
            # 사용자에게 추가 여부 확인
            for saint in missing:
                new_entry = create_saint_entry(month, day, saint)
                all_missing.append(new_entry)
        else:
            print("✅ 누락 없음")
        
        time.sleep(1)  # API rate limit 방지 (더 안전하게)
        
        # 진행 상황 출력 (매 10일마다)
        if checked_dates % 10 == 0:
            print(f"\n진행 상황: {checked_dates}/{len(dates_to_check)}일 확인 완료 ({len(all_missing)}명 추가됨)\n")
    
    # 누락된 성인 추가
    if all_missing:
        print(f"\n{'='*60}")
        print(f"총 {len(all_missing)}명의 누락된 성인을 발견했습니다.")
        print(f"{'='*60}\n")
        
        # JSON에 추가
        data['saints'].extend(all_missing)
        
        # 월/일 순으로 정렬
        data['saints'].sort(key=lambda x: (x.get('month', 0), x.get('day', 0)))
        
        # 백업 생성
        backup_path = json_path.with_suffix('.json.backup')
        if not backup_path.exists():
            with open(backup_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"백업 파일 생성: {backup_path}")
        
        # JSON 파일 저장
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ {len(all_missing)}명의 성인이 추가되었습니다!")
    else:
        print(f"\n{'='*60}")
        print("✅ 누락된 성인이 없습니다!")
        print(f"{'='*60}\n")

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
    sample_days = None
    months_to_check = None
    
    if len(sys.argv) > 1:
        # 첫 번째 인자가 숫자면 샘플링 일수 또는 월
        try:
            first_arg = int(sys.argv[1])
            if len(sys.argv) > 2:
                # 여러 월 지정
                months_to_check = [first_arg]
                for arg in sys.argv[2:]:
                    months_to_check.append(int(arg))
            else:
                # 샘플링 일수
                sample_days = first_arg
        except ValueError:
            print("인자는 숫자여야 합니다.")
            sys.exit(1)
    
    # 날짜 범위 설정
    year = datetime.now().year
    
    if months_to_check:
        # 여러 월을 개별적으로 확인
        all_missing_total = []
        for month in months_to_check:
            # 해당 월의 첫 날과 마지막 날 계산
            if month == 12:
                start_date = datetime(year, 12, 1)
                end_date = datetime(year, 12, 31)
            else:
                start_date = datetime(year, month, 1)
                # 다음 달 1일에서 1일 빼면 이번 달 마지막 날
                if month == 11:
                    end_date = datetime(year, 12, 1) - timedelta(days=1)
                else:
                    end_date = datetime(year, month + 1, 1) - timedelta(days=1)
            
            print(f"\n{'='*60}")
            print(f"{month}월 확인 시작")
            print(f"{'='*60}")
            
            # JSON 파일 로드 (각 월마다)
            with open(json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            all_missing = []
            dates_to_check = []
            current = start_date
            while current <= end_date:
                dates_to_check.append(current)
                current += timedelta(days=1)
            
            checked_dates = 0
            for date in dates_to_check:
                month_num = date.month
                day = date.day
                year_num = date.year
                
                checked_dates += 1
                print(f"[{checked_dates}/{len(dates_to_check)}] {year_num}년 {month_num}월 {day}일 확인 중...", end=' ')
                
                # JSON에서 성인 가져오기
                json_saints = get_saints_from_json(json_path, month_num, day)
                
                # ChatGPT에게 물어보기
                chatgpt_saints = ask_chatgpt_for_saints(api_key, year_num, month_num, day, 'ja')
                
                if not chatgpt_saints:
                    print("⚠️  ChatGPT 응답 없음")
                    time.sleep(1)
                    continue
                
                # 누락된 성인 찾기
                missing = find_missing_saints(json_saints, chatgpt_saints)
                
                if missing:
                    print(f"⚠️  누락된 성인 {len(missing)}명 발견:")
                    for saint in missing:
                        name = saint.get('name', '')
                        name_en = saint.get('nameEn', '')
                        print(f"    - {name} ({name_en})")
                    
                    for saint in missing:
                        new_entry = create_saint_entry(month_num, day, saint)
                        all_missing.append(new_entry)
                else:
                    print("✅ 누락 없음")
                
                time.sleep(1)
            
            if all_missing:
                all_missing_total.extend(all_missing)
                print(f"\n{month}월: {len(all_missing)}명의 누락된 성인 발견")
            else:
                print(f"\n{month}월: ✅ 누락된 성인 없음")
        
        # 모든 누락된 성인을 한 번에 추가
        if all_missing_total:
            print(f"\n{'='*60}")
            print(f"총 {len(all_missing_total)}명의 누락된 성인을 발견했습니다.")
            print(f"{'='*60}\n")
            
            # JSON 파일 로드
            with open(json_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # JSON에 추가
            data['saints'].extend(all_missing_total)
            
            # 월/일 순으로 정렬
            data['saints'].sort(key=lambda x: (x.get('month', 0), x.get('day', 0)))
            
            # 백업 생성
            backup_path = json_path.with_suffix('.json.backup')
            if not backup_path.exists():
                with open(backup_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
                print(f"백업 파일 생성: {backup_path}")
            
            # JSON 파일 저장
            with open(json_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            
            print(f"✅ {len(all_missing_total)}명의 성인이 추가되었습니다!")
        else:
            print(f"\n{'='*60}")
            print("✅ 누락된 성인이 없습니다!")
            print(f"{'='*60}\n")
    else:
        # 기존 로직 (전체 연도 또는 샘플링)
        if sample_days:
            start_date = datetime(year, 1, 1)
            end_date = datetime(year, 12, 31)
        else:
            start_date = datetime(year, 1, 1)
            end_date = datetime(year, 12, 31)
        
        # 확인 실행
        check_date_range(json_path, api_key, start_date, end_date, sample_days)

if __name__ == '__main__':
    main()
