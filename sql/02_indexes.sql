-- ============================================================
-- SPORTS EVENT MANAGEMENT SYSTEM — INDEXES
-- ============================================================

-- 1. idx_match_event  — Match(EventID)
--    WHY: Queries that retrieve all matches for a given event
--    (e.g. get_event_summary, schedule screens) perform a
--    lookup by EventID. An index eliminates a full-table scan
--    on the Match table.
CREATE INDEX idx_match_event ON Match(EventID);

-- 2. idx_player_team  — Player(TeamID)
--    WHY: Team rosters are fetched frequently. Indexing TeamID
--    speeds up JOINs between Player and Team and enables quick
--    roster lookups and player-count aggregations.
CREATE INDEX idx_player_team ON Player(TeamID);

-- 3. idx_result_match  — Result(MatchID)
--    WHY: The Result table is queried by MatchID to fetch
--    scores / outcomes. An index accelerates these lookups,
--    especially when computing win counts or win rates.
CREATE INDEX idx_result_match ON Result(MatchID);

-- ============================================================
-- END OF INDEXES
-- ============================================================
