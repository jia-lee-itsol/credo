#!/usr/bin/env python3
"""
성인 축일 JSON 파일에서 각 언어별 name 필드가 제대로 추가되어 있는지 확인하는 스크립트
"""

import json
from pathlib import Path
from collections import defaultdict

def check_saint_names(json_path: Path):
    """성인 이름 필드를 확인합니다."""
    print(f"📖 파일 읽기: {json_path}")
    
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    all_saints = data.get('saints', []) + data.get('japaneseSaints', [])
    total_saints = len(all_saints)
    
    print(f"✅ 총 성인 수: {total_saints}개\n")
    
    # 각 언어별 통계
    stats = {
        'name': 0,      # 일본어 (기본)
        'nameEn': 0,    # 영어
        'nameKo': 0,    # 한국어
        'nameZh': 0,    # 중국어
        'nameVi': 0,    # 베트남어
        'nameEs': 0,    # 스페인어
        'namePt': 0,    # 포르투갈어
    }
    
    # 누락된 언어별 통계
    missing_stats = defaultdict(int)
    
    # 각 성인별로 확인
    missing_examples = {
        'nameEn': [],
        'nameKo': [],
        'nameZh': [],
        'nameVi': [],
        'nameEs': [],
        'namePt': [],
    }
    
    for saint in all_saints:
        # 각 언어별로 확인
        if saint.get('name') and str(saint.get('name', '')).strip():
            stats['name'] += 1
        else:
            missing_examples['name'].append(saint)
        
        for lang_key in ['nameEn', 'nameKo', 'nameZh', 'nameVi', 'nameEs', 'namePt']:
            value = saint.get(lang_key)
            if value and str(value).strip():
                stats[lang_key] += 1
            else:
                missing_stats[lang_key] += 1
                if len(missing_examples[lang_key]) < 5:
                    missing_examples[lang_key].append({
                        'name': saint.get('name', 'N/A'),
                        'month': saint.get('month'),
                        'day': saint.get('day'),
                    })
    
    # 결과 출력
    print("=" * 60)
    print("📊 언어별 통계")
    print("=" * 60)
    print(f"{'언어':<15} {'보유':<10} {'누락':<10} {'비율':<10}")
    print("-" * 60)
    
    for lang_key, lang_name in [
        ('name', '일본어 (기본)'),
        ('nameEn', '영어'),
        ('nameKo', '한국어'),
        ('nameZh', '중국어'),
        ('nameVi', '베트남어'),
        ('nameEs', '스페인어'),
        ('namePt', '포르투갈어'),
    ]:
        has_count = stats[lang_key]
        missing_count = missing_stats.get(lang_key, 0) if lang_key != 'name' else total_saints - has_count
        percentage = (has_count / total_saints * 100) if total_saints > 0 else 0
        print(f"{lang_name:<15} {has_count:<10} {missing_count:<10} {percentage:.1f}%")
    
    print("\n" + "=" * 60)
    print("⚠️  누락된 이름 예시 (각 언어별 최대 5개)")
    print("=" * 60)
    
    for lang_key, lang_name in [
        ('nameEn', '영어'),
        ('nameKo', '한국어'),
        ('nameZh', '중국어'),
        ('nameVi', '베트남어'),
        ('nameEs', '스페인어'),
        ('namePt', '포르투갈어'),
    ]:
        if missing_examples[lang_key]:
            print(f"\n{lang_name} ({lang_key}) 누락 예시:")
            for example in missing_examples[lang_key]:
                print(f"  - {example.get('name', 'N/A')} ({example.get('month')}월 {example.get('day')}일)")
    
    # 완전한 언어 세트를 가진 성인 수
    complete_count = 0
    for saint in all_saints:
        has_all = all([
            saint.get('name'),
            saint.get('nameEn'),
            saint.get('nameKo'),
            saint.get('nameZh'),
            saint.get('nameVi'),
            saint.get('nameEs'),
            saint.get('namePt'),
        ])
        if has_all:
            complete_count += 1
    
    print("\n" + "=" * 60)
    print(f"✅ 모든 언어를 가진 성인: {complete_count}개 ({complete_count/total_saints*100:.1f}%)")
    print(f"⚠️  일부 언어가 누락된 성인: {total_saints - complete_count}개 ({(total_saints-complete_count)/total_saints*100:.1f}%)")
    print("=" * 60)

def main():
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    json_path = project_root / 'assets' / 'data' / 'saints' / 'saints_feast_days.json'
    
    if not json_path.exists():
        print(f"❌ JSON 파일을 찾을 수 없습니다: {json_path}")
        return
    
    check_saint_names(json_path)

if __name__ == '__main__':
    main()

