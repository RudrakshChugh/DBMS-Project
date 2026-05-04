-- ============================================================
-- SPORTS EVENT MANAGEMENT SYSTEM — MASTER RUNNER
-- Execute this file to build the entire database in one go.
-- Usage:  psql -U <user> -d <database> -f 00_run_all.sql
-- ============================================================

\echo '──────────────────────────────────────────────────'
\echo '  Building Sports Event Management System...'
\echo '──────────────────────────────────────────────────'

\echo '→ 01  Creating schema (DDL)...'
\i 01_schema.sql

\echo '→ 02  Creating indexes...'
\i 02_indexes.sql

\echo '→ 03  Inserting sample data...'
\i 03_sample_data.sql

\echo '→ 04  Creating functions...'
\i 04_functions.sql

\echo '→ 05  Creating procedures...'
\i 05_procedures.sql

\echo '→ 06  Creating triggers...'
\i 06_triggers.sql

\echo '→ 07  Running advanced queries...'
\i 07_advanced_queries.sql

\echo '→ 08  Running transaction demos...'
\i 08_transactions.sql

\echo ''
\echo '══════════════════════════════════════════════════'
\echo '    All scripts executed successfully!'
\echo '══════════════════════════════════════════════════'

-- ────────────────────────────────────────────────────────────
-- Quick smoke test: call each function
-- ────────────────────────────────────────────────────────────
\echo ''
\echo '── Smoke Tests ─────────────────────────────────────'

\echo 'get_team_win_count(1) ='
SELECT get_team_win_count(1);

\echo 'get_total_sponsorship(1) ='
SELECT get_total_sponsorship(1);

\echo 'get_win_rate(1) ='
SELECT get_win_rate(1);

\echo 'get_event_summary():'
SELECT * FROM get_event_summary();

\echo 'get_match_details():'
SELECT * FROM get_match_details();

\echo 'get_upcoming_matches(3):'
SELECT * FROM get_upcoming_matches(3);

\echo ''
\echo '── Done! ───────────────────────────────────────────'
