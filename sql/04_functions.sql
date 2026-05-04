-- ============================================================
-- SPORTS EVENT MANAGEMENT SYSTEM — FUNCTIONS
-- Language : PL/pgSQL
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. get_team_win_count(team_id)
--    Returns the total number of wins for a given team.
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_team_win_count(p_team_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM Result
     WHERE WinnerID = p_team_id;

    RETURN COALESCE(v_count, 0);
END;
$$;

-- ────────────────────────────────────────────────────────────
-- 2. get_event_summary()
--    Returns a summary row per event: event name, game,
--    organizer, venue, total matches, completed matches.
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_event_summary()
RETURNS TABLE (
    event_name      VARCHAR,
    game_name       VARCHAR,
    organizer       VARCHAR,
    venue           VARCHAR,
    total_matches   BIGINT,
    completed       BIGINT,
    status          VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT e.EventName::VARCHAR,
           g.GameName::VARCHAR,
           o.OrgName::VARCHAR,
           v.VenueName::VARCHAR,
           COUNT(m.MatchID)                               AS total_matches,
           COUNT(m.WinnerID)                              AS completed,
           e.Status::VARCHAR
      FROM Event e
      JOIN Game      g ON g.GameID      = e.GameID
      JOIN Organizer o ON o.OrganizerID = e.OrganizerID
      JOIN Venue     v ON v.VenueID     = e.VenueID
      LEFT JOIN Match m ON m.EventID    = e.EventID
     GROUP BY e.EventID, e.EventName, g.GameName,
              o.OrgName, v.VenueName, e.Status;
END;
$$;

-- ────────────────────────────────────────────────────────────
-- 3. get_match_details()
--    Returns detailed info about every match including teams,
--    referee, and winner (if decided).
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_match_details()
RETURNS TABLE (
    match_id    INT,
    event_name  VARCHAR,
    team1       VARCHAR,
    team2       VARCHAR,
    match_date  DATE,
    match_time  TIME,
    venue       VARCHAR,
    referee     TEXT,
    winner      VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT m.MatchID,
           e.EventName::VARCHAR,
           t1.TeamName::VARCHAR,
           t2.TeamName::VARCHAR,
           m.MatchDate,
           m.MatchTime,
           v.VenueName::VARCHAR,
           (u.FirstName || ' ' || u.LastName)::TEXT,
           COALESCE(tw.TeamName, 'TBD')::VARCHAR
      FROM Match m
      JOIN Event   e  ON e.EventID   = m.EventID
      JOIN Team    t1 ON t1.TeamID   = m.Team1ID
      JOIN Team    t2 ON t2.TeamID   = m.Team2ID
      LEFT JOIN Venue   v  ON v.VenueID   = m.VenueID
      LEFT JOIN Referee r  ON r.RefereeID = m.RefereeID
      LEFT JOIN Users   u  ON u.UserID    = r.UserID
      LEFT JOIN Team    tw ON tw.TeamID   = m.WinnerID
     ORDER BY m.MatchDate, m.MatchTime;
END;
$$;

-- ────────────────────────────────────────────────────────────
-- 4. get_total_sponsorship(event_id)
--    Returns total sponsorship amount for a given event.
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_total_sponsorship(p_event_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC(14,2);
BEGIN
    SELECT COALESCE(SUM(Amount), 0)
      INTO v_total
      FROM Sponsor
     WHERE EventID = p_event_id;

    RETURN v_total;
END;
$$;

-- ────────────────────────────────────────────────────────────
-- 5. get_upcoming_matches(team_id)
--    Returns all future matches (WinnerID IS NULL and
--    MatchDate >= CURRENT_DATE) for a given team.
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_upcoming_matches(p_team_id INT)
RETURNS TABLE (
    match_id    INT,
    event_name  VARCHAR,
    opponent    VARCHAR,
    match_date  DATE,
    match_time  TIME,
    venue       VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT m.MatchID,
           e.EventName::VARCHAR,
           CASE
               WHEN m.Team1ID = p_team_id THEN t2.TeamName
               ELSE t1.TeamName
           END::VARCHAR,
           m.MatchDate,
           m.MatchTime,
           v.VenueName::VARCHAR
      FROM Match m
      JOIN Event e  ON e.EventID  = m.EventID
      JOIN Team  t1 ON t1.TeamID  = m.Team1ID
      JOIN Team  t2 ON t2.TeamID  = m.Team2ID
      LEFT JOIN Venue v ON v.VenueID = m.VenueID
     WHERE (m.Team1ID = p_team_id OR m.Team2ID = p_team_id)
       AND m.WinnerID IS NULL
       AND m.MatchDate >= CURRENT_DATE
     ORDER BY m.MatchDate;
END;
$$;

-- ────────────────────────────────────────────────────────────
-- 6. get_win_rate(team_id)
--    Returns win percentage: wins / total matches played × 100
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_win_rate(p_team_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INT;
    v_wins  INT;
BEGIN
    -- Total matches played (where result exists)
    SELECT COUNT(*)
      INTO v_total
      FROM Result
     WHERE WinnerID = p_team_id
        OR LoserID  = p_team_id;

    -- Wins
    SELECT COUNT(*)
      INTO v_wins
      FROM Result
     WHERE WinnerID = p_team_id;

    IF v_total = 0 THEN
        RETURN 0;
    END IF;

    RETURN ROUND((v_wins::NUMERIC / v_total) * 100, 2);
END;
$$;

-- ============================================================
-- END OF FUNCTIONS
-- ============================================================
