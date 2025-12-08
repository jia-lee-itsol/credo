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

- `name`: 교회 이름
- `churchName`: 교회당 이름 (선택)
- `address`: 주소
- `prefecture`: 도도부현
- `isCathedral`: 주교좌 성당 여부 (true/false)
- `massTime`: 미사 시간 (문자열)
- `phone`: 전화번호 (선택)
- `fax`: 팩스번호 (선택)
- `website`: 웹사이트 URL (선택)
- `note`: 비고 (선택)
- `diocese`: 교구 ID (정규화된 필드)
- `deanery`: 소교구/지역 ID (정규화된 필드, null 가능)

### 파일 구조 규칙

- 각 교구는 하나의 JSON 파일로 관리됩니다: `parishes/{dioceseId}.json`
- 예: 
  - `parishes/tokyo.json` (도쿄 대사교구)
  - `parishes/yokohama.json` (요코하마 교구)
  - `parishes/sapporo.json` (삿포로 교구)

