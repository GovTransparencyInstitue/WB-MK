import csv
import sys


def main(input_file, target_file, output_file):
    # Load target words from the specified CSV file
    with open(target_file, 'r') as file:
        reader = csv.DictReader(file)
        target_data = list(reader)

    # Create a set of target words from column A in the target CSV file
    target_words = set(word for row in target_data for word in row['cpv_desc_mk'].split())

    # Load data from the specified input CSV file
    with open(input_file, 'r') as file:
        reader = csv.DictReader(file)
        data = list(reader)

    # Check each row in the input CSV file
    for i, row in enumerate(data):
        # If column tender_cpvs is empty, get corresponding tender_title and lot_title and create text words set
        if not row['tender_cpvs']:
            text_set = set(word for col in [row['tender_title'], row['lot_title']] for word in col.split())
            result = None

            # check if text words set contains all target words set
            for target_row in target_data:
                target_words_set = set(word for word in target_row['cpv_desc_mk'].split())
                if target_words_set.issubset(text_set):
                    result = target_row['cpv_codes']
                    break

            # fill tender_cpvs with corresponding result, or 99000000 if no match found
            data[i]['tender_cpvs'] = result if result is not None else '99000000'

    # Write updated data to output CSV file
    with open(output_file, 'w', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=reader.fieldnames)
        writer.writeheader()
        writer.writerows(data)


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print(f"Usage: python3 {sys.argv[0]} input_file target_file output_file")
        sys.exit(1)
    input_file = sys.argv[1]
    target_file = sys.argv[2]
    output_file = sys.argv[3]
    main(input_file, target_file, output_file)
