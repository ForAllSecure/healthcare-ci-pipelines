#!/usr/bin/python3
# Custom script to postprocess Trivy JSON file and automatically insert
# observations from Dynamic SBOM CSV file.

import argparse
import csv
import json


def main():
    parser = argparse.ArgumentParser(description='Postprocess Trivy JSON file')
    parser.add_argument('trivy_json', type=str, help='Trivy JSON file')
    parser.add_argument('mdsbom_csv', type=str, help='MDSBOM CSV file')
    parser.add_argument('output_json', type=str, help='Output JSON file')
    args = parser.parse_args()

    with open(args.trivy_json, 'r') as f:
        trivy_data = json.load(f)
    with open(args.mdsbom_csv, 'r') as f:
        mdsbom_data = csv.DictReader(f)

        vulnerabilities = set(vuln["id"] for vuln in trivy_data["vulnerabilities"])

        remediations = set()
        for row in mdsbom_data:
            if row["name"] in vulnerabilities and row["observed"] == "false":
                remediations.add(row["name"])

        trivy_data["remediations"] = [
            {
                "fixes": [{"id": remediation}],
                "summary": "This vulnerability was not observed during runtime.",
                "diff": "non_observed"
            } for remediation in remediations
        ]

    with open(args.output_json, 'w') as f:
        json.dump(trivy_data, f, indent=2)


if __name__ == "__main__":
    main()

