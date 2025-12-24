#!/usr/bin/env python3
"""
Remove all 'greeting' keys from saints_feast_days.json
"""
import json
import sys
from pathlib import Path

def remove_greeting_keys(data):
    """Recursively remove 'greeting' keys from the data structure"""
    if isinstance(data, dict):
        # Remove 'greeting' key if it exists
        data.pop('greeting', None)
        # Recursively process all values
        for value in data.values():
            remove_greeting_keys(value)
    elif isinstance(data, list):
        # Recursively process all items in the list
        for item in data:
            remove_greeting_keys(item)
    return data

def main():
    file_path = Path(__file__).parent.parent / 'assets' / 'data' / 'saints' / 'saints_feast_days.json'
    
    print(f"Reading file: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print("Removing 'greeting' keys...")
    remove_greeting_keys(data)
    
    print(f"Writing updated file: {file_path}")
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print("Done! All 'greeting' keys have been removed.")

if __name__ == '__main__':
    main()


















