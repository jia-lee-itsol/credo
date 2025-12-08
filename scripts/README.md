# Parish Merge Script

This script merges all parish JSON files from subdirectories into a single file per diocese.

## Usage

Run the script using Node.js:

```bash
node scripts/mergeParishes.js
```

## What it does

1. Scans all diocese directories under `assets/data/parishes/`
2. Recursively finds all JSON files (excluding `dioceses.json` and final `<diocese>.json`)
3. Extracts parish objects from each file (handles both `{parishes: [...]}` and direct arrays)
4. Adds normalized fields:
   - `diocese`: the diocese ID (e.g., "yokohama")
   - `deanery`: the sub-region/deanery name (e.g., "toubu", "kanagawa"), or `null` if none
5. Deduplicates parishes (keeps first occurrence based on ID, name+address, or name)
6. Writes merged result to `parishes/<diocese>.json`

## Output format

Each merged file has the structure:

```json
{
  "diocese": "yokohama",
  "parishes": [
    {
      "name": "...",
      "diocese": "yokohama",
      "deanery": "toubu",
      ...
    }
  ]
}
```

