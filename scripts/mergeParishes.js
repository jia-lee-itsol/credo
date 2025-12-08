const fs = require('fs');
const path = require('path');

const PARISHES_DIR = path.join(__dirname, '..', 'assets', 'data', 'parishes');

/**
 * Recursively find all JSON files in a directory, excluding specific files
 */
function findJsonFiles(dir, excludeFiles = []) {
  const files = [];
  const entries = fs.readdirSync(dir, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    
    // Skip excluded files
    if (excludeFiles.includes(entry.name)) {
      continue;
    }

    if (entry.isDirectory()) {
      // Recursively search subdirectories
      files.push(...findJsonFiles(fullPath, excludeFiles));
    } else if (entry.isFile() && entry.name.endsWith('.json')) {
      files.push(fullPath);
    }
  }

  return files;
}

/**
 * Read and parse a JSON file, handling both arrays and objects
 */
function readParishFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const data = JSON.parse(content);
    
    // If it's an object with a 'parishes' array, extract it
    if (data && typeof data === 'object' && !Array.isArray(data)) {
      if (Array.isArray(data.parishes)) {
        return data.parishes;
      }
      // If it's a single object (parish), wrap it in an array
      return [data];
    }
    
    // If it's already an array, return it
    if (Array.isArray(data)) {
      return data;
    }
    
    return [];
  } catch (error) {
    console.error(`Error reading ${filePath}:`, error.message);
    return [];
  }
}

/**
 * Extract deanery name from file path
 * e.g., parishes/yokohama/shizuoka/toubu/toubu.json -> "toubu"
 * e.g., parishes/yokohama/kanagawa/kanagawa.json -> "kanagawa"
 */
function extractDeanery(filePath, dioceseDir) {
  const relativePath = path.relative(dioceseDir, filePath);
  const parts = path.dirname(relativePath).split(path.sep).filter(p => p);
  
  // If there's a subdirectory, use the last one as deanery
  // Otherwise, use the filename without extension
  if (parts.length > 0) {
    return parts[parts.length - 1];
  }
  
  // Fallback: use filename without extension
  const fileName = path.basename(filePath, '.json');
  return fileName !== path.basename(dioceseDir) ? fileName : null;
}

/**
 * Generate a unique ID for a parish (for deduplication)
 */
function getParishId(parish) {
  // Try to use existing id, name+address, or just name
  if (parish.id) {
    return parish.id;
  }
  if (parish.name && parish.address) {
    return `${parish.name}|${parish.address}`;
  }
  return parish.name || JSON.stringify(parish);
}

/**
 * Merge all parish files for a diocese
 */
function mergeDioceseParishes(dioceseDir, dioceseName) {
  console.log(`\nProcessing diocese: ${dioceseName}`);
  
  const excludeFiles = ['dioceses.json', `${dioceseName}.json`];
  const jsonFiles = findJsonFiles(dioceseDir, excludeFiles);
  
  console.log(`  Found ${jsonFiles.length} JSON files`);
  
  const allParishes = [];
  const seenIds = new Set();
  
  for (const filePath of jsonFiles) {
    const deanery = extractDeanery(filePath, dioceseDir);
    const parishes = readParishFile(filePath);
    
    console.log(`  Reading ${path.relative(PARISHES_DIR, filePath)}: ${parishes.length} parishes (deanery: ${deanery || 'none'})`);
    
    for (const parish of parishes) {
      // Add normalized fields
      const normalizedParish = {
        ...parish,
        diocese: dioceseName,
        deanery: deanery || null,
      };
      
      // Deduplicate: keep first occurrence
      const parishId = getParishId(normalizedParish);
      if (!seenIds.has(parishId)) {
        seenIds.add(parishId);
        allParishes.push(normalizedParish);
      } else {
        console.log(`    Skipping duplicate: ${parish.name || parishId}`);
      }
    }
  }
  
  return allParishes;
}

/**
 * Main function
 */
function main() {
  console.log('Starting parish merge process...');
  console.log(`Parishes directory: ${PARISHES_DIR}`);
  
  if (!fs.existsSync(PARISHES_DIR)) {
    console.error(`Error: Parishes directory not found: ${PARISHES_DIR}`);
    process.exit(1);
  }
  
  // Find all diocese directories
  const entries = fs.readdirSync(PARISHES_DIR, { withFileTypes: true });
  const dioceseDirs = entries
    .filter(entry => entry.isDirectory())
    .map(entry => ({
      name: entry.name,
      path: path.join(PARISHES_DIR, entry.name),
    }));
  
  console.log(`\nFound ${dioceseDirs.length} diocese directories`);
  
  // Process each diocese
  for (const { name, path: diocesePath } of dioceseDirs) {
    const parishes = mergeDioceseParishes(diocesePath, name);
    
    if (parishes.length === 0) {
      console.log(`  Warning: No parishes found for ${name}, skipping...`);
      continue;
    }
    
    // Write merged file
    const outputPath = path.join(PARISHES_DIR, `${name}.json`);
    const output = {
      diocese: name,
      parishes: parishes,
    };
    
    fs.writeFileSync(
      outputPath,
      JSON.stringify(output, null, 2),
      'utf8'
    );
    
    console.log(`  ✓ Wrote ${parishes.length} parishes to ${path.relative(PARISHES_DIR, outputPath)}`);
  }
  
  console.log('\n✓ Merge process completed!');
}

// Run the script
main();

