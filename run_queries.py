"""
==================================================================
DecodeLabs Data Analytics Internship — Project 3
SQL Data Analysis — Query Runner & Validator
==================================================================

Executes every query in project3_queries.sql against orders.db,
validates that each one runs with zero errors, and saves the
result of every named query to query_results/<label>.csv for use
in the written report.

Run with: python3 run_queries.py
==================================================================
"""

import sqlite3
import re
import os
import csv
import json

DB_PATH = "orders.db"
SQL_PATH = "project3_queries.sql"
RESULTS_DIR = "query_results"

os.makedirs(RESULTS_DIR, exist_ok=True)


def split_queries(sql_text):
    """Split the .sql file into (label, query) pairs using the '-- X#.' comment markers."""
    # Remove the big block comment header
    sql_text = re.sub(r"/\*.*?\*/", "", sql_text, flags=re.DOTALL)

    # Find each labeled query: a comment line like "-- A1. Description" followed by SQL
    pattern = re.compile(
        r"--\s*([A-G]\d+)\.\s*(.+?)\n(.*?)(?=(?:\n--\s*[A-G]\d+\.)|\Z)",
        re.DOTALL,
    )
    queries = []
    for match in pattern.finditer(sql_text):
        label, description, body = match.groups()
        body = body.strip()
        if not body:
            continue
        queries.append((label.strip(), description.strip(), body))
    return queries


def main():
    with open(SQL_PATH, "r") as f:
        sql_text = f.read()

    queries = split_queries(sql_text)
    print(f"Found {len(queries)} labeled queries in {SQL_PATH}\n")

    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    errors = []
    summary = []

    for label, description, query in queries:
        try:
            cur.execute(query)
            cols = [d[0] for d in cur.description] if cur.description else []
            rows = cur.fetchall()

            # Save to CSV
            csv_path = os.path.join(RESULTS_DIR, f"{label}.csv")
            with open(csv_path, "w", newline="") as cf:
                writer = csv.writer(cf)
                if cols:
                    writer.writerow(cols)
                writer.writerows(rows)

            print(f"[OK] {label}: {description}  -> {len(rows)} row(s)")
            summary.append(
                {
                    "label": label,
                    "description": description,
                    "row_count": len(rows),
                    "columns": cols,
                    "sample_rows": rows[:5],
                }
            )
        except Exception as e:
            print(f"[ERROR] {label}: {description}\n   Query: {query}\n   Error: {e}")
            errors.append({"label": label, "error": str(e)})

    conn.close()

    with open(os.path.join(RESULTS_DIR, "_summary.json"), "w") as f:
        json.dump(summary, f, indent=2, default=str)

    print("\n" + "=" * 70)
    if errors:
        print(f"COMPLETED WITH {len(errors)} ERROR(S):")
        for e in errors:
            print(f"  - {e['label']}: {e['error']}")
    else:
        print(f"ALL {len(queries)} QUERIES EXECUTED SUCCESSFULLY. 0 ERRORS.")
    print("=" * 70)

    return len(errors)


if __name__ == "__main__":
    n_errors = main()
    exit(1 if n_errors else 0)
