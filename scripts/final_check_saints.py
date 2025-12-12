#!/usr/bin/env python3
"""
최종 성인 데이터 확인 및 추가 스크립트
더 정교한 이름 매칭으로 빠진 항목 찾기
"""

import json
import re
from urllib.request import urlopen
from html.parser import HTMLParser
from collections import defaultdict

BASE_URL = "https://www.pauline.or.jp/calendariosanti/saint365.php?id="
MONTHS = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
JSON_FILE = "assets/data/saints/saints_feast_days.json"

class SaintsParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.saints = []
        self.current_day = None
        self.in_table = False
        self.in_row = False
        self.current_cell = None
        self.cell_text = ""
        
    def handle_starttag(self, tag, attrs):
        if tag == "table":
            self.in_table = True
        elif tag == "tr" and self.in_table:
            self.in_row = True
            self.current_day = None
        elif tag == "td" and self.in_row:
            self.current_cell = "day" if self.current_day is None else "name"
            self.cell_text = ""
            
    def handle_endtag(self, tag):
        if tag == "table":
            self.in_table = False
        elif tag == "tr" and self.in_row:
            self.in_row = False
        elif tag == "td" and self.current_cell:
            if self.current_cell == "day":
                match = re.search(r'(\d+)日', self.cell_text)
                if match:
                    self.current_day = int(match.group(1))
            elif self.current_cell == "name" and self.current_day:
                name = self.cell_text.strip()
                if name:
                    self.saints.append({
                        "day": self.current_day,
                        "name": name
                    })
            self.current_cell = None
            self.cell_text = ""
            
    def handle_data(self, data):
        if self.current_cell:
            self.cell_text += data

def crawl_month(month_code):
    """특정 월의 성인 데이터 크롤링"""
    url = BASE_URL + month_code
    try:
        with urlopen(url) as response:
            html = response.read().decode('utf-8')
            parser = SaintsParser()
            parser.feed(html)
            return parser.saints
    except Exception as e:
        print(f"Error crawling {month_code}: {e}")
        return []

def extract_core_name(name):
    """이름에서 핵심 부분만 추출 (비교용)"""
    # 괄호 내용 제거
    core = re.sub(r'[（(].*?[）)]', '', name)
    # 특수문자 제거
    core = re.sub(r'[／/・]', '', core)
    # 공백 제거
    core = core.replace(" ", "").replace("　", "")
    # "聖" 제거
    core = core.replace("聖", "")
    # 일반적인 접미사 제거
    suffixes = ["司教", "司祭", "修道女", "修道者", "おとめ", "殉教者", "教皇", "大司教", "教会博士", "使徒", "福音記者"]
    for suffix in suffixes:
        core = core.replace(suffix, "")
    return core.strip()

def names_match(name1, name2):
    """두 이름이 같은 성인을 가리키는지 확인"""
    core1 = extract_core_name(name1)
    core2 = extract_core_name(name2)
    
    # 정확히 일치
    if core1 == core2:
        return True
    
    # 한쪽이 다른 쪽을 포함
    if len(core1) > 3 and len(core2) > 3:
        if core1 in core2 or core2 in core1:
            return True
    
    # 주요 단어가 일치하는지 확인 (2글자 이상)
    if len(core1) >= 2 and len(core2) >= 2:
        # 공통 부분 찾기
        common = ""
        for i in range(min(len(core1), len(core2))):
            if core1[i] == core2[i]:
                common += core1[i]
            else:
                break
        if len(common) >= 3:  # 최소 3글자 이상 공통
            return True
    
    return False

def find_missing_saints(crawled, existing, month):
    """크롤링한 데이터와 기존 JSON 비교하여 빠진 항목 찾기"""
    existing_by_day = defaultdict(list)
    for saint in existing.get("saints", []):
        if saint["month"] == month:
            existing_by_day[saint["day"]].append(saint["name"])
    
    for saint in existing.get("japaneseSaints", []):
        if saint["month"] == month:
            existing_by_day[saint["day"]].append(saint["name"])
    
    missing = []
    for saint in crawled:
        day = saint["day"]
        name = saint["name"]
        
        # 해당 날짜에 같은 성인이 있는지 확인
        found = False
        for existing_name in existing_by_day[day]:
            if names_match(name, existing_name):
                found = True
                break
        
        if not found:
            missing.append({
                "month": month,
                "day": day,
                "name": name
            })
    
    return missing

def create_saint_entry(month, day, name):
    """성인 항목 생성"""
    # 타입 추정
    if "大祝日" in name or "solemnity" in name.lower():
        type_val = "solemnity"
        greeting = f"{name}の大祝日を祝います！"
    elif "祝日" in name or "feast" in name.lower():
        type_val = "feast"
        greeting = f"{name}の祝日を祝います！"
    else:
        type_val = "memorial"
        greeting = f"{name}の記念日を祝います！"
    
    # 영어 이름 생성 (기본 변환)
    name_en = generate_name_en(name)
    
    return {
        "month": month,
        "day": day,
        "name": name,
        "nameEn": name_en,
        "type": type_val,
        "isJapanese": False,
        "greeting": greeting
    }

def generate_name_en(japanese_name):
    """일본어 이름에서 영어 이름 생성"""
    # 일반적인 매핑
    mappings = {
        "マリア": "Mary",
        "ヨセフ": "Joseph",
        "ペトロ": "Peter",
        "パウロ": "Paul",
        "ヨハネ": "John",
        "アントニオ": "Anthony",
        "フランシスコ": "Francis",
        "アグネス": "Agnes",
        "カタリナ": "Catherine",
        "テレジア": "Theresa",
        "アンナ": "Anne",
        "エリザベト": "Elizabeth",
        "マルタ": "Martha",
        "ルチア": "Lucy",
        "セシリア": "Cecilia",
        "アンブロジオ": "Ambrose",
        "アウグスティヌス": "Augustine",
        "トマス": "Thomas",
        "ステファノ": "Stephen",
        "ニコラオ": "Nicholas",
        "ベネディクト": "Benedict",
        "ドミニコ": "Dominic",
        "クララ": "Clare",
        "ルカ": "Luke",
        "マタイ": "Matthew",
        "マルコ": "Mark",
        "アンドレ": "Andrew",
        "シモン": "Simon",
        "ユダ": "Jude",
        "バルトロマイ": "Bartholomew",
        "フィリポ": "Philip",
        "ヤコブ": "James",
        "タデオ": "Thaddeus",
    }
    
    # 복합 이름 처리
    for jp, en in mappings.items():
        if jp in japanese_name:
            # 복합 이름인 경우
            if "・" in japanese_name or "／" in japanese_name:
                parts = re.split(r'[・／]', japanese_name)
                en_parts = []
                for part in parts:
                    for jp2, en2 in mappings.items():
                        if jp2 in part:
                            en_parts.append(en2)
                            break
                if en_parts:
                    return "Saints " + " and ".join(en_parts)
            return f"Saint {en}"
    
    # 매핑이 없는 경우 기본 형식
    return f"Saint {japanese_name.replace('聖', '')}"

def main():
    print("JSON 파일 로드 중...")
    with open(JSON_FILE, 'r', encoding='utf-8') as f:
        existing_data = json.load(f)
    
    all_missing = []
    
    for i, month_code in enumerate(MONTHS, 1):
        print(f"\n{i}월 크롤링 중... ({month_code})")
        crawled = crawl_month(month_code)
        print(f"  크롤링된 항목: {len(crawled)}개")
        
        missing = find_missing_saints(crawled, existing_data, i)
        if missing:
            print(f"  빠진 항목: {len(missing)}개")
            for m in missing[:5]:  # 처음 5개만 출력
                print(f"    - {m['day']}日: {m['name']}")
            if len(missing) > 5:
                print(f"    ... 외 {len(missing) - 5}개")
            all_missing.extend(missing)
    
    print(f"\n총 빠진 항목: {len(all_missing)}개")
    
    if all_missing:
        print("\n빠진 항목들을 JSON에 추가 중...")
        for missing in all_missing:
            new_entry = create_saint_entry(
                missing["month"],
                missing["day"],
                missing["name"]
            )
            existing_data["saints"].append(new_entry)
        
        # 월/일 순으로 정렬
        existing_data["saints"].sort(key=lambda x: (x["month"], x["day"]))
        
        # JSON 파일 저장
        with open(JSON_FILE, 'w', encoding='utf-8') as f:
            json.dump(existing_data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ {len(all_missing)}개 항목이 추가되었습니다!")
    else:
        print("✅ 빠진 항목이 없습니다!")

if __name__ == "__main__":
    main()
