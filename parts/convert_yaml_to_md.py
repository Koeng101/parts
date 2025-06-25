#!/usr/bin/env python3
"""
Script to convert bsub.yaml entries into individual markdown files.
Creates files exactly like PxylA.md format.
"""

import yaml
import os
import sys

def convert_yaml_to_markdown(yaml_file, output_dir="./"):
    """Convert YAML entries to individual markdown files."""
    
    # Read the YAML file
    with open(yaml_file, 'r') as f:
        data = yaml.safe_load(f)
    
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # Process each entry
    for name, entry in data.items():
        # Skip if entry is not a dictionary (malformed entry)
        if not isinstance(entry, dict):
            print(f"Skipping {name}: not a valid entry")
            continue
            
        # Create markdown content - exactly like PxylA.md
        md_content = "---\n"
        md_content += f"name: {name}\n"
        md_content += "creator: keoni\n"
        
        if 'description' in entry:
            md_content += f"description: {entry['description']}\n"
        
        if 'prefix' in entry:
            md_content += f"prefix: {entry['prefix']}\n"
            
        if 'suffix' in entry:
            md_content += f"suffix: {entry['suffix']}\n"
            
        if 'sequence' in entry:
            md_content += f"sequence: {entry['sequence']}\n"
        
        md_content += "---\n"
        
        # Write to file
        filename = f"{name}.md"
        filepath = os.path.join(output_dir, filename)
        
        with open(filepath, 'w') as f:
            f.write(md_content)
        
        print(f"Created: {filename}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python convert_yaml_to_md.py <yaml_file> [output_directory]")
        sys.exit(1)
    
    yaml_file = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else "./"
    
    if not os.path.exists(yaml_file):
        print(f"Error: YAML file '{yaml_file}' not found")
        sys.exit(1)
    
    convert_yaml_to_markdown(yaml_file, output_dir)
    print("Conversion complete!")