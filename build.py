import yaml
import json
import os

def load_yaml(file_path):
    with open(file_path, 'r') as file:
        return yaml.safe_load(file)

def combine_yaml_files(collections_file, papers_file, base_path='', output_dir=''):
    collections = load_yaml(os.path.join(base_path, collections_file))
    papers = load_yaml(os.path.join(base_path, papers_file))

    parts = {}
    for collection_name, collection_data in collections.items():
        parts_file_path = os.path.join(base_path, collection_data['file'])
        collection_parts = load_yaml(parts_file_path)

        # Store the part names for each collection
        collection_data['parts'] = list(collection_parts.keys())

        # Process each part
        for part_name, part_data in collection_parts.items():
            part_data['collection'] = collection_name
            parts[part_name] = part_data

        # Remove the 'file' key from the collection
        del collection_data['file']

    # Optionally remove the 'file' key from each reference if it exists
    # Uncomment the following lines if needed:
    for reference_key, reference_data in papers.items():
        if 'file' in reference_data:
            del reference_data['file']

    final_data = {
        'parts': parts,
        'collections': collections,
        'references': papers
    }

    output_file = os.path.join(output_dir, 'api/toolkit.json')
    with open(output_file, 'w') as file:
        json.dump(final_data, file, indent=2)

    return final_data

def convert_yaml_to_json(yaml_file, output_dir):
    with open(yaml_file, 'r') as file:
        yaml_content = yaml.safe_load(file)

    output_file = os.path.join(output_dir, 'spec.json')
    with open(output_file, 'w') as file:
        json.dump(yaml_content, file, indent=2)

combine_yaml_files('collections.yaml', 'papers/papers.yaml', base_path='', output_dir='docs')
convert_yaml_to_json('spec.yaml', 'docs')

