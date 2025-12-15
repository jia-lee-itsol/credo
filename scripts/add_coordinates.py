#!/usr/bin/env python3
"""
일본 성당 JSON 파일에 좌표 데이터를 추가하는 스크립트
Google Maps Geocoding API를 사용하여 주소를 좌표로 변환
"""

import json
import os
import time
import urllib.request
import urllib.parse
import re

PARISHES_DIR = "../assets/data/parishes"
GOOGLE_MAPS_API_KEY = "AIzaSyDDvTsXVxD672gpGbBX56hjNcO-HwPj92A"

def extract_address_for_geocoding(address):
    """주소에서 우편번호를 제거하고 지오코딩에 적합한 형태로 변환"""
    # 우편번호 제거 (〒XXX-XXXX 형식)
    address = re.sub(r'〒?\d{3}-?\d{4}\s*', '', address)
    return address.strip()

def geocode_address_google(address):
    """Google Maps Geocoding API를 사용하여 주소를 좌표로 변환"""
    try:
        clean_address = extract_address_for_geocoding(address)
        if not clean_address:
            return None, None

        # Google Maps Geocoding API 호출
        encoded_address = urllib.parse.quote(clean_address)
        url = f"https://maps.googleapis.com/maps/api/geocode/json?address={encoded_address}&key={GOOGLE_MAPS_API_KEY}&language=ja&region=jp"

        req = urllib.request.Request(url)

        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode('utf-8'))

            if data.get('status') == 'OK' and data.get('results'):
                location = data['results'][0]['geometry']['location']
                lat = float(location['lat'])
                lon = float(location['lng'])
                return lat, lon
            else:
                print(f"    API Status: {data.get('status')}")

        return None, None
    except Exception as e:
        print(f"  Geocoding error for '{address}': {e}")
        return None, None

def process_parish_file(filepath):
    """성당 JSON 파일을 처리하여 좌표 추가"""
    print(f"\nProcessing: {os.path.basename(filepath)}")

    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    if 'parishes' not in data:
        print(f"  No parishes found in {filepath}")
        return

    modified = False
    for parish in data['parishes']:
        name = parish.get('name', 'Unknown')

        # 이미 좌표가 있으면 스킵 (0이 아닌 경우)
        existing_lat = parish.get('latitude')
        existing_lon = parish.get('longitude')
        if existing_lat and existing_lon and existing_lat != 0 and existing_lon != 0:
            print(f"  [SKIP] {name} - already has coordinates")
            continue

        address = parish.get('address', '')
        if not address:
            print(f"  [WARN] {name} - no address")
            continue

        print(f"  [GEOCODING] {name}")
        lat, lon = geocode_address_google(address)

        if lat and lon:
            parish['latitude'] = lat
            parish['longitude'] = lon
            modified = True
            print(f"    -> ({lat}, {lon})")
        else:
            print(f"    -> Not found")

        # API 요청 간 딜레이
        time.sleep(0.1)

    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"  Saved!")

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parishes_dir = os.path.join(script_dir, PARISHES_DIR)

    if not os.path.exists(parishes_dir):
        print(f"Directory not found: {parishes_dir}")
        return

    # 모든 JSON 파일 처리 (dioceses.json 제외)
    for filename in sorted(os.listdir(parishes_dir)):
        if filename.endswith('.json') and filename != 'dioceses.json':
            filepath = os.path.join(parishes_dir, filename)
            process_parish_file(filepath)

    print("\n=== Done ===")

if __name__ == "__main__":
    main()
