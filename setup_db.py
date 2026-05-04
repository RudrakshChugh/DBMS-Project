"""
Database Setup Script
Executes all SQL files in order against the PostgreSQL database.
Usage: python setup_db.py
"""

import psycopg2
import os

# ── Configuration ──
DB_CONFIG = {
    'dbname': os.getenv('DB_NAME', 'sports_events'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', 'postgres'),
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', 5432))
}

# Use relative path — sql/ folder sits next to this script
SQL_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'sql')

FILES = [
    '01_schema.sql',
    '02_indexes.sql',
    '03_sample_data.sql',
    '04_functions.sql',
    '05_procedures.sql',
    '06_triggers.sql',
    '07_advanced_queries.sql',
]

def main():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = True
        cur = conn.cursor()

        for f in FILES:
            path = os.path.join(SQL_DIR, f)
            print(f"  Executing {f} ...")
            with open(path, 'r', encoding='utf-8') as sql_file:
                sql = sql_file.read()
                cur.execute(sql)

        print("\n  Database setup complete!")
        conn.close()
    except Exception as e:
        print(f"\n  Error during setup: {e}")
        raise

if __name__ == '__main__':
    main()
