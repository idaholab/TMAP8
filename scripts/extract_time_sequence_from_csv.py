#!/usr/bin/env python3
import argparse
import csv
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Extract a time column from a CSV file for CSVTimeSequenceStepper."
    )
    parser.add_argument("input_csv", type=Path)
    parser.add_argument("output_csv", type=Path)
    parser.add_argument("--column", default="time")
    args = parser.parse_args()

    with args.input_csv.open(newline="", encoding="ascii") as infile:
        reader = csv.DictReader(infile)
        if reader.fieldnames is None or args.column not in reader.fieldnames:
            raise SystemExit(f"missing column '{args.column}' in {args.input_csv}")

        times = [row[args.column] for row in reader]

    if not times:
        raise SystemExit(f"no rows found in {args.input_csv}")

    with args.output_csv.open("w", newline="", encoding="ascii") as outfile:
        writer = csv.writer(outfile)
        writer.writerow([args.column])
        for time in times:
            writer.writerow([time])


if __name__ == "__main__":
    main()
