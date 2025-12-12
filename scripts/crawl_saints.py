#!/usr/bin/env python3
"""
성인 축일 데이터 크롤링 스크립트
웹사이트에서 각 월별 성인 축일 데이터를 가져와서 JSON 파일과 비교
"""

import json
import re
from urllib.request import urlopen
from html.parser import HTMLParser
from collections import defaultdict

BASE_URL = "https://www.pauline.or.jp/calendariosanti/saint365.php?id="
MONTHS = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]

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
                # "1日" 형식에서 숫자 추출
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

def find_missing_saints(crawled, existing, month):
    """크롤링한 데이터와 기존 JSON 비교하여 빠진 항목 찾기"""
    existing_by_day = defaultdict(list)
    for saint in existing.get("saints", []):
        if saint["month"] == month:
            existing_by_day[saint["day"]].append(saint["name"])
    
    missing = []
    for saint in crawled:
        day = saint["day"]
        name = saint["name"]
        if name not in existing_by_day[day]:
            missing.append({
                "month": month,
                "day": day,
                "name": name
            })
    
    return missing

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
            for m in missing:
                print(f"    - {m['day']}日: {m['name']}")
            all_missing.extend(missing)
        else:
            print(f"  빠진 항목 없음")
    
    print(f"\n총 빠진 항목: {len(all_missing)}개")
    
    if all_missing:
        print("\n빠진 항목 목록:")
        for m in all_missing:
            print(f"  {m['month']}月{m['day']}日: {m['name']}")

if __name__ == "__main__":
    main()
