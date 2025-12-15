#!/usr/bin/env python3
"""
스페인어 번역 파일의 일본어 텍스트를 스페인어로 번역하는 스크립트
"""

import json
from pathlib import Path

# 한국어 파일을 참고
ko_file = Path(__file__).parent.parent / 'assets/l10n/app_ko.json'
es_file = Path(__file__).parent.parent / 'assets/l10n/app_es.json'

# 한국어 파일 읽기
with open(ko_file, 'r', encoding='utf-8') as f:
    ko_data = json.load(f)

# 스페인어 파일 읽기
with open(es_file, 'r', encoding='utf-8') as f:
    es_data = json.load(f)

# 한국어를 참고하여 스페인어로 번역할 매핑
# 주요 섹션별로 수정
translations = {
    # navigation
    "navigation.home": "Inicio",
    "navigation.meditation": "Meditación",
    "navigation.share": "Compartir",
    "navigation.church": "Iglesia",
    "navigation.community": "Comunidad",
    
    # mass
    "mass.title": "Meditación Diaria",
    "mass.liturgicalDays.sunday": "Domingo",
    "mass.liturgicalDays.solemnity": "Solemnidad",
    "mass.liturgicalDays.feast": "Fiesta",
    "mass.liturgicalDays.advent": "Adviento",
    "mass.liturgicalDays.christmas": "Navidad",
    "mass.liturgicalDays.lent": "Cuaresma",
    "mass.liturgicalDays.easter": "Pascua",
    "mass.liturgicalDays.ordinary": "Tiempo Ordinario",
    
    # mass.prayer
    "mass.prayer.title": "Guía de Meditación",
    "mass.prayer.morningMeditation": "Meditación Matutina",
    "mass.prayer.guides.morning.title": "Meditación Matutina",
    "mass.prayer.guides.morning.content": "Un momento para agradecer a Dios al comenzar el día y encomendar el nuevo día bajo la protección de Dios. Al levantarse por la mañana para comenzar el día, es un momento para pedir gracia y protección durante todo el día.",
    "mass.prayer.guides.meal.title": "Meditación en las Comidas",
    "mass.prayer.guides.meal.content": "Un momento para agradecer a Dios por la comida antes y después de las comidas. Antes de comer, agradecemos por la comida que Dios nos ha dado, y después de comer, agradecemos por estar satisfechos.",
    "mass.prayer.guides.evening.title": "Meditación Nocturna",
    "mass.prayer.guides.evening.content": "Al terminar el día, es un momento para agradecer a Dios, arrepentirse de los pecados del día y pedir perdón. Antes de acostarse, es un momento para reflexionar sobre el día y orar por el mañana.",
    "mass.prayer.guides.difficult.title": "Meditación en Tiempos Difíciles",
    "mass.prayer.guides.difficult.content": "En situaciones difíciles o momentos dolorosos, es un momento para pedir ayuda y consuelo de Dios. Incluso en medio de pruebas y sufrimientos, es un momento para creer en el amor y la protección de Dios.",
    "mass.prayer.guides.thanksgiving.title": "Meditación de Acción de Gracias",
    "mass.prayer.guides.thanksgiving.content": "Un momento para agradecer las gracias y bendiciones que Dios ha dado. Desde las pequeñas alegrías cotidianas hasta las grandes bendiciones, es un momento para tener un corazón agradecido por todo.",
    "mass.prayer.guides.meditation.title": "Tiempo de Meditación",
    "mass.prayer.guides.meditation.content": "Un momento para tener tiempo tranquilo, dialogar con Dios y reflexionar sobre el propio corazón. Meditamos en la Palabra, buscamos la voluntad de Dios y pasamos tiempo en paz.",
    "mass.prayer.meditationGuides.firstReading": "Meditación Basada en la Biblia I",
    "mass.prayer.meditationGuides.psalm": "Meditación Basada en los Salmos",
    "mass.prayer.meditationGuides.secondReading": "Meditación de la Segunda Lectura II",
    "mass.prayer.meditationGuides.gospel": "Meditación sobre la Palabra de la Biblia (Evangelio)",
    "mass.prayer.readings.firstReading": "Primera Lectura",
    "mass.prayer.readings.psalm": "Salmo Responsorial",
    "mass.prayer.readings.secondReading": "Segunda Lectura",
    "mass.prayer.readings.gospel": "Evangelio",
    "mass.prayer.everyoneMeditation": "Meditación de Todos ({count})",
    "mass.prayer.everyoneMeditation@count": "Número de comentarios",
    "mass.prayer.noMeditationYet": "Aún no hay meditación",
    "mass.prayer.errorOccurred": "Ocurrió un error",
    "mass.prayer.permissionDenied": "Permiso denegado. Por favor, verifique su estado de inicio de sesión.",
    "mass.prayer.networkError": "Ocurrió un error de red.",
    "mass.prayer.anonymous": "Anónimo",
    "mass.prayer.loginToShare": "Inicie sesión para compartir meditación",
}

def set_nested_value(data, key_path, value):
    """점으로 구분된 키 경로로 중첩된 값을 설정"""
    keys = key_path.split('.')
    current = data
    for i, key in enumerate(keys[:-1]):
        if key not in current:
            current[key] = {}
        elif not isinstance(current[key], dict):
            current[key] = {}
        current = current[key]
    current[keys[-1]] = value

# 번역 적용
for key_path, value in translations.items():
    set_nested_value(es_data, key_path, value)

# 파일 저장
with open(es_file, 'w', encoding='utf-8') as f:
    json.dump(es_data, f, ensure_ascii=False, indent=2)

print(f"✓ {len(translations)}개 키 번역 완료")
