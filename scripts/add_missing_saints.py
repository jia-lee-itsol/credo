#!/usr/bin/env python3
"""
빠진 성인 축일 데이터를 JSON 파일에 자동 추가
"""

import json
import re
from urllib.request import urlopen
from html.parser import HTMLParser
from collections import defaultdict

BASE_URL = "https://www.pauline.or.jp/calendariosanti/saint365.php?id="
MONTHS = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]

# 이름 매핑 (웹사이트 이름 -> JSON 이름)
NAME_MAPPING = {
    "聖ヒラリオ司教教会博士": "聖ヒラリオ",
    "聖アントニオ修道院長": "聖アントニオ",
    "聖アグネスおとめ殉教者": "聖アグネス",
    "聖ヴィンチェンツィオ助祭殉教者": "聖ビンセント",
    "使徒聖パウロの回心": "聖パウロの回心",
    "聖テモテ／聖テトス司教": "聖ティモテオとティト",
    "聖フランシスコ・ザビエル司祭": "聖フランシスコ・ザビエル",
    "聖ニコラオ司教": "聖ニコラオ",
    "聖アンブロジオ司教教会博士": "聖アンブロジオ",
    "無原罪の聖母マリア": "無原罪の御宿り",
    "聖エウラリア（バルセロナ)／聖エウラリア（メリダ）": "聖エウラリア",
    "聖ダマソ1世教皇": "聖ダマソ一世",
    "グアダルペの聖母マリア": "グアダルーペの聖母",
    "聖ルチアおとめ殉教者": "聖ルチア",
    "十字架の聖ヨハネ司祭教会博士": "聖ヨハネ・十字架",
    "聖ペトロ・カニジオ司祭教会博士": "聖ペトロ・カニシオ",
    "聖ヨハネ（ケンティ）司祭": "聖ヨハネ・カンタベリ",
    "最初の殉教者聖ステファノ殉教者": "聖ステファノ",
    "聖ヨハネ使徒福音記者": "聖ヨハネ使徒",
    "聖なる幼子殉教者": "幼子殉教者",
    "聖トマス・ベケット司教殉教者": "聖トマス・ベケット",
    "聖シルヴェストロ1世教皇": "聖シルベストロ一世",
}

def normalize_name(name):
    """이름 정규화 (매핑 확인)"""
    return NAME_MAPPING.get(name, name)

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

def load_existing_json(filepath):
    """기존 JSON 파일 로드"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def normalize_saint_name(name):
    """성인 이름 정규화 (비교를 위해)"""
    # 괄호와 특수문자 제거, 공백 정규화
    normalized = name.replace("（", "(").replace("）", ")")
    normalized = re.sub(r'\([^)]*\)', '', normalized)  # 괄호 내용 제거
    normalized = normalized.replace("／", "/").replace("・", "・")
    # 공백 제거
    normalized = normalized.replace(" ", "").replace("　", "")
    return normalized

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
        normalized_crawled = normalize_saint_name(name)
        
        # 정확히 일치하는지 확인
        exact_match = False
        partial_match = False
        
        for existing_name in existing_by_day[day]:
            normalized_existing = normalize_saint_name(existing_name)
            
            # 정확히 일치
            if name == existing_name or normalized_crawled == normalized_existing:
                exact_match = True
                break
            
            # 부분 일치 확인 (핵심 이름 부분이 같은지)
            # "聖" 제거하고 비교
            core_crawled = normalized_crawled.replace("聖", "")
            core_existing = normalized_existing.replace("聖", "")
            
            # 한쪽이 다른 쪽을 포함하는지 확인
            if core_crawled in core_existing or core_existing in core_crawled:
                # 너무 짧은 경우는 제외 (예: "聖"만 있는 경우)
                if len(core_crawled) > 2 and len(core_existing) > 2:
                    partial_match = True
                    break
        
        if not exact_match and not partial_match:
            missing.append({
                "month": month,
                "day": day,
                "name": name
            })
    
    return missing

def create_saint_entry(month, day, name):
    """성인 항목 생성 (기본값 사용)"""
    # 이름에서 type 추정
    if "大祝日" in name or "solemnity" in name.lower():
        type_val = "solemnity"
        greeting = f"{name}の大祝日を祝います！"
    elif "祝日" in name or "feast" in name.lower():
        type_val = "feast"
        greeting = f"{name}の祝日を祝います！"
    else:
        type_val = "memorial"
        greeting = f"{name}の記念日を祝います！"
    
    # 영어 이름 추정 (간단한 변환)
    name_en = name.replace("聖", "Saint ").replace("おとめ", "").replace("殉教者", "").replace("司教", "").replace("司祭", "").replace("修道女", "").replace("修道者", "").strip()
    if not name_en.startswith("Saint"):
        name_en = "Saint " + name_en
    
    return {
        "month": month,
        "day": day,
        "name": name,
        "nameEn": name_en,
        "type": type_val,
        "isJapanese": False,
        "greeting": greeting
    }

def main():
    json_file = "assets/data/saints/saints_feast_days.json"
    
    print("기존 JSON 파일 로드 중...")
    existing_data = load_existing_json(json_file)
    
    all_missing = []
    
    for i, month_code in enumerate(MONTHS, 1):
        print(f"\n{i}월 크롤링 중... ({month_code})")
        crawled = crawl_month(month_code)
        print(f"  크롤링된 항목: {len(crawled)}개")
        
        missing = find_missing_saints(crawled, existing_data, i)
        if missing:
            print(f"  빠진 항목: {len(missing)}개")
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
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump(existing_data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ {len(all_missing)}개 항목이 추가되었습니다!")
    else:
        print("빠진 항목이 없습니다.")

if __name__ == "__main__":
    main()
