-- ============================================================
-- SPORTS EVENT MANAGEMENT SYSTEM — TRANSACTIONS
-- Demonstrates BEGIN, COMMIT, ROLLBACK
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- TRANSACTION 1: Successful — Register a new player via procedure
-- ────────────────────────────────────────────────────────────
BEGIN;

    -- Use the register_player procedure to add a new player
    CALL register_player(
        'Amit'::VARCHAR,                  -- first name
        'Chauhan'::VARCHAR,               -- last name
        'amit.chauhan@mail.com'::VARCHAR, -- email
        '9998887770'::VARCHAR,            -- phone
        'Male'::gender_enum,              -- gender (explicit cast)
        '2001-08-15'::DATE,               -- dob   (explicit cast)
        1,                                -- team_id (Mumbai Mavericks)
        99,                               -- jersey_no
        'All-Rounder'::VARCHAR            -- position
    );

    -- Verify the insert
    SELECT u.FirstName, u.LastName, p.JerseyNo, t.TeamName
      FROM Player p
      JOIN Users u ON u.UserID = p.UserID
      JOIN Team  t ON t.TeamID = p.TeamID
     WHERE u.Email = 'amit.chauhan@mail.com';

COMMIT;  -- persist the changes


-- ────────────────────────────────────────────────────────────
-- TRANSACTION 2: Rollback — Schedule a match then undo
-- ────────────────────────────────────────────────────────────
BEGIN;

    -- Schedule a new match
    CALL schedule_match(
        1,                   -- event_id  (IPL 2026)
        1,                   -- team1_id  (Mumbai Mavericks)
        2,                   -- team2_id  (Delhi Dynamos)
        1,                   -- referee_id
        '2026-05-01'::DATE,  -- match_date (explicit cast)
        '20:00'::TIME,       -- match_time (explicit cast)
        1                    -- venue_id
    );

    -- Oops — wrong date; rollback the entire transaction
ROLLBACK;


-- ────────────────────────────────────────────────────────────
-- TRANSACTION 3: Update match winner — trigger auto-inserts Result
-- ────────────────────────────────────────────────────────────
BEGIN;

    -- Set winner for Match 4 (Football: Bangalore vs Chennai)
    UPDATE Match
       SET WinnerID = 3      -- Bangalore Blazers win
     WHERE MatchID = 4;

    -- The trigger (trg_match_winner_update) should have
    -- auto-inserted a row into Result.
    SELECT * FROM Result WHERE MatchID = 4;

COMMIT;

-- ============================================================
-- END OF TRANSACTIONS
-- ============================================================
