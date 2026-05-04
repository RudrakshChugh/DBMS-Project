-- ============================================================
-- SPORTS EVENT MANAGEMENT SYSTEM — PROCEDURES
-- Language : PL/pgSQL
-- PostgreSQL procedures use CALL to invoke.
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. register_player(...)
--    Creates a Users row (role = 'Player') and a Player row
--    inside a single transaction.  Rolls back on any error.
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE PROCEDURE register_player(
    p_first_name  VARCHAR,
    p_last_name   VARCHAR,
    p_email       VARCHAR,
    p_phone       VARCHAR,
    p_gender      gender_enum,
    p_dob         DATE,
    p_team_id     INT,
    p_jersey_no   INT,
    p_position    VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_id INT;
BEGIN
    -- ── Validate: team must exist ──
    IF NOT EXISTS (SELECT 1 FROM Team WHERE TeamID = p_team_id) THEN
        RAISE EXCEPTION 'Team ID % does not exist.', p_team_id;
    END IF;

    -- ── Validate: jersey number must be unique within the team ──
    IF EXISTS (
        SELECT 1 FROM Player
         WHERE TeamID = p_team_id AND JerseyNo = p_jersey_no
    ) THEN
        RAISE EXCEPTION 'Jersey #% is already taken in team %.', p_jersey_no, p_team_id;
    END IF;

    -- ── Insert into Users ──
    INSERT INTO Users (FirstName, LastName, Email, Phone, Gender, DOB, Role)
    VALUES (p_first_name, p_last_name, p_email, p_phone, p_gender, p_dob, 'Player')
    RETURNING UserID INTO v_user_id;

    -- ── Insert into Player ──
    INSERT INTO Player (UserID, TeamID, JerseyNo, Position, JoinDate)
    VALUES (v_user_id, p_team_id, p_jersey_no, p_position, CURRENT_DATE);

    RAISE NOTICE 'Player "% %" registered successfully (UserID=%, TeamID=%).',
                 p_first_name, p_last_name, v_user_id, p_team_id;

EXCEPTION
    WHEN OTHERS THEN
        -- Procedure automatically rolls back the implicit transaction
        RAISE EXCEPTION 'register_player failed: %', SQLERRM;
END;
$$;

-- ────────────────────────────────────────────────────────────
-- 2. schedule_match(...)
--    Inserts a new match into the Match table.
--    Validates that both teams belong to the event's game,
--    and that the match date falls within the event window.
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE PROCEDURE schedule_match(
    p_event_id    INT,
    p_team1_id    INT,
    p_team2_id    INT,
    p_referee_id  INT,
    p_match_date  DATE,
    p_match_time  TIME,
    p_venue_id    INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_game_id    INT;
    v_start_date DATE;
    v_end_date   DATE;
BEGIN
    -- ── Validate: event must exist ──
    SELECT GameID, StartDate, EndDate
      INTO v_game_id, v_start_date, v_end_date
      FROM Event
     WHERE EventID = p_event_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Event ID % does not exist.', p_event_id;
    END IF;

    -- ── Validate: teams must not be the same ──
    IF p_team1_id = p_team2_id THEN
        RAISE EXCEPTION 'A team cannot play against itself.';
    END IF;

    -- ── Validate: both teams belong to the event's game ──
    IF NOT EXISTS (SELECT 1 FROM Team WHERE TeamID = p_team1_id AND GameID = v_game_id) THEN
        RAISE EXCEPTION 'Team % does not belong to Game %.', p_team1_id, v_game_id;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Team WHERE TeamID = p_team2_id AND GameID = v_game_id) THEN
        RAISE EXCEPTION 'Team % does not belong to Game %.', p_team2_id, v_game_id;
    END IF;

    -- ── Validate: match date within event window ──
    IF p_match_date < v_start_date OR p_match_date > v_end_date THEN
        RAISE EXCEPTION 'Match date % is outside event window (% to %).',
                        p_match_date, v_start_date, v_end_date;
    END IF;

    -- ── Insert Match ──
    INSERT INTO Match (EventID, Team1ID, Team2ID, RefereeID,
                       MatchDate, MatchTime, VenueID)
    VALUES (p_event_id, p_team1_id, p_team2_id, p_referee_id,
            p_match_date, p_match_time, p_venue_id);

    RAISE NOTICE 'Match scheduled: Team % vs Team % on % at event %.',
                 p_team1_id, p_team2_id, p_match_date, p_event_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'schedule_match failed: %', SQLERRM;
END;
$$;

-- ============================================================
-- END OF PROCEDURES
-- ============================================================
