# 데이터 파일 관리

## 개요

앱에서 사용하는 모든 정적 데이터를 JSON 파일로 관리합니다.

## 파일 구조

```
assets/data/
  ├── liturgical/                      # 전례력 데이터
  │   ├── liturgical_calendar_2025.json
  │   └── liturgical_calendar_2026.json
  ├── saints/                          # 성인 축일 데이터
  │   └── saints_feast_days.json
  └── parishes/                        # 교구 및 교회 데이터
      ├── dioceses.json                # 교구 목록
      ├── tokyo.json                   # 도쿄 대사교구 (병합된 파일)
      ├── yokohama.json                # 요코하마 교구 (병합된 파일)
      ├── saitama.json                 # 사이타마 교구 (병합된 파일)
      ├── sapporo.json                 # 삿포로 교구 (병합된 파일)
      ├── sendai.json                  # 센다이 교구 (병합된 파일)
      ├── niigata.json                 # 니가타 교구 (병합된 파일)
      ├── osaka.json                   # 오사카-다카마쓰 대사교구 (병합된 파일)
      ├── nagoya.json                  # 나고야 교구
      ├── kyoto.json                   # 교토 교구
      ├── fukuoka.json                 # 후쿠오카 교구
      └── nagasaki.json                # 나가사키 대사교구
```

## 전례력 데이터

## 연도별 데이터 파일 추가 방법

1. 새 연도 파일 생성: `liturgical/liturgical_calendar_YYYY.json`
2. 다음 형식으로 작성:

```json
{
  "year": 2026,
  "seasons": {
    "advent": {
      "start": "2025-11-30",
      "end": "2025-12-24"
    },
    "christmas": {
      "start": "2025-12-25",
      "end": "2026-01-05"
    },
    "lent": {
      "start": "2026-03-04",
      "end": "2026-04-18"
    },
    "easter": {
      "start": "2026-04-19",
      "end": "2026-06-06"
    },
    "pentecost": {
      "date": "2026-06-07"
    }
  },
  "specialDays": [
    {
      "date": "2026-01-01",
      "name": "神の母聖マリア",
      "type": "solemnity"
    }
  ]
}
```

## 주요 날짜 계산 참고

- **부활절**: 매년 달라지므로 정확한 날짜 확인 필요
- **대림절 시작**: 11월 30일에 가장 가까운 일요일
- **사순절 시작**: 부활절 46일 전 (재의 수요일)
- **성령 강림**: 부활절 후 50일 (부활절 포함)

## 사용 방법

앱은 자동으로 현재 연도의 데이터 파일을 찾아 사용합니다. 파일이 없으면 자동으로 계산 로직을 사용합니다.

## 특별한 축일 추가

`specialDays` 배열에 추가하면 해당 날짜의 특별한 축일 정보를 가져올 수 있습니다.

- `type`: "solemnity" (대축일), "feast" (축일), "memorial" (기념일)

## 교구 및 교회 데이터

### 교구 목록 (parishes/dioceses.json)

모든 교구의 메타데이터를 포함합니다:

```json
{
  "dioceses": [
    {
      "id": "sapporo",
      "name": "札幌教区",
      "nameEn": "Sapporo Diocese",
      "prefectures": ["北海道"],
      "isArchdiocese": false
    }
  ]
}
```

### 교구별 성당 데이터

각 교구는 하나의 병합된 JSON 파일로 관리됩니다:

```json
{
  "diocese": "tokyo",
  "parishes": [
    {
      "name": "カトリック関口教会",
      "churchName": "東京カテドラル聖マリア大聖堂",
      "address": "東京都文京区関口3-16-15",
      "prefecture": "東京都",
      "isCathedral": true,
      "massTime": "日 7:00, 10:00, 18:00",
      "diocese": "tokyo",
      "deanery": "tokyo"
    }
  ]
}
```

### 교구 데이터 필드

- `diocese`: 교구 ID (예: "tokyo", "yokohama")
- `parishes`: 교회 목록 배열

### 교회 데이터 필드

- `name`: 교회 이름 (필수)
- `churchName`: 교회당 이름 (선택)
- `address`: 주소 (필수)
- `prefecture`: 도도부현 (필수)
- `isCathedral`: 주교좌 성당 여부 (true/false)
- `massTime`: 미사 시간 (문자열, 레거시 필드 - 호환성을 위해 유지)
- `massTimes`: 구조화된 미사 시간 (객체, 필수)
  - `sunday`: 일요일 미사 시간 배열 (예: `["08:00", "10:00"]`)
  - `saturday`: 토요일 미사 시간 배열
  - `monday` ~ `friday`: 평일 미사 시간 배열
  - `wednesday`, `thursday` 등: 특정 요일 미사 시간 배열
- `foreignMassTimes`: 외국어 미사 시간 (객체, 선택)
  - 요일별 배열로 구성
  - 각 항목은 `{ "time": "14:00", "language": "EN", "note": "第1・第3日曜" }` 형식
  - `language`: 언어 코드 (예: "EN", "VI", "KO", "ZH", "PT")
  - `note`: 특별한 조건 (예: "第1日曜", "第2・4日曜", "第3日曜")
- `phone`: 전화번호 (선택)
- `fax`: 팩스번호 (선택)
- `website`: 웹사이트 URL (선택)
- `note`: 비고 (선택)
- `diocese`: 교구 ID (필수, 앱에서 교회 조회를 위해 필요)
- `deanery`: 소교구/지역 ID (선택, null 가능)
- `latitude`: 위도 (필수)
- `longitude`: 경도 (필수)

### 파일 구조 규칙

- 각 교구는 하나의 JSON 파일로 관리됩니다: `parishes/{dioceseId}.json`
- 예: 
  - `parishes/tokyo.json` (도쿄 대사교구)
  - `parishes/yokohama.json` (요코하마 교구)
  - `parishes/sapporo.json` (삿포로 교구)

### 미사 시간 데이터 구조 예시

```json
{
  "name": "福岡カテドラル",
  "massTime": "主日：08:00, 10:00, 12:00 / 第1・第3日曜14:00(英語ミサ)",
  "massTimes": {
    "sunday": ["08:00", "10:00", "12:00"]
  },
  "foreignMassTimes": {
    "sunday": [
      {
        "time": "14:00",
        "language": "EN",
        "note": "第1・第3日曜"
      }
    ]
  }
}
```

### 중요 사항

1. **`diocese` 필드는 필수입니다**: 앱에서 교회를 조회하기 위해 `parishId`를 생성할 때 `diocese`와 `name`을 조합합니다. `diocese` 필드가 없으면 교회 정보를 찾을 수 없습니다.

2. **`massTimes`와 `foreignMassTimes` 구조**: 
   - `massTimes`: 일반 미사 시간을 요일별로 구조화
   - `foreignMassTimes`: 외국어 미사 시간을 요일별로 구조화하며, 각 항목은 `time`, `language`, `note` 필드를 포함

3. **`note` 필드 일관성**: 
   - 외국어 미사 시간의 `note` 필드에는 "第○日" 대신 "第○日曜" 형식을 사용합니다 (예: "第1日曜", "第2・4日曜")

4. **`massTime` 필드**: 
   - 레거시 필드로 호환성을 위해 유지되지만, 실제 사용은 `massTimes`와 `foreignMassTimes`를 우선합니다.

## 최근 업데이트 (2025-01-XX)

### osaka.json 대규모 데이터 추가 (2025-01-XX)

1. **교회 데이터 대폭 확장**:
   - 기존 1개 교회에서 **106개 교회**로 확장
   - 웹사이트 데이터 기반 추가: https://ostk.catholic.jp/parish_mass/
   - 지역별 분포:
     - 大阪府: 36개
     - 兵庫県: 33개
     - 和歌山県: 11개
     - 香川県: 9개
     - 愛媛県: 8개
     - 徳島県: 4개
     - 高知県: 5개

2. **미사 시간 데이터 구조화**:
   - 모든 교회의 `massTime` 문자열을 `massTimes`와 `foreignMassTimes`로 정확히 분리
   - 특수 조건 처리 (第X日曜, 前晩, 계절별 시간 등)
   - 외국어 미사 시간의 `note` 필드 표준화

3. **데이터 검증 완료**:
   - 모든 106개 교회의 `massTime`과 구조화된 데이터 일치 확인
   - JSON 형식 유효성 검증 완료
   - 특수 조건(初金曜日, 第X日曜, 외국어 미사 등) 정확성 확인

4. **참고 사항**:
   - 위도/경도는 임시 값(0.0)으로 설정됨
   - geocoding 스크립트(`scripts/add_coordinates.py`)로 업데이트 필요

### fukuoka.json 데이터 개선

1. **필수 필드 추가**: 
   - 모든 교구에 `diocese` 필드 추가 (앱 연결을 위해 필수)
   - `deanery` 필드 추가 (일관성 유지)

2. **미사 시간 데이터 보완**:
   - 일부 교구의 누락된 미사 시간 추가
   - `massTimes` 구조에서 요일별 시간 정확성 개선

3. **외국어 미사 시간 note 필드 표준화**:
   - "第○日" → "第○日曜" 형식으로 통일
   - 예: "第1日" → "第1日曜", "第2・4日" → "第2・4日曜"

4. **데이터 검증 완료**:
   - 모든 교구에 `massTimes`와 `foreignMassTimes` 필드 존재 확인
   - JSON 형식 유효성 검증 완료

