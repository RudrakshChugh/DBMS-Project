-- ============================================================
-- SPORTS EVENT MANAGEMENT SYSTEM — SCHEMA (DDL)
-- Database  : PostgreSQL 15+
-- Purpose   : Create all tables with PK, FK, UNIQUE, CHECK
-- ============================================================

-- Clean slate (drop in reverse-dependency order)
DROP TABLE IF EXISTS Result       CASCADE;
DROP TABLE IF EXISTS Sponsor      CASCADE;
DROP TABLE IF EXISTS MediaPartner CASCADE;
DROP TABLE IF EXISTS Match        CASCADE;
DROP TABLE IF EXISTS Event        CASCADE;
DROP TABLE IF EXISTS Venue        CASCADE;
DROP TABLE IF EXISTS Referee      CASCADE;
DROP TABLE IF EXISTS Player       CASCADE;
DROP TABLE IF EXISTS Coach        CASCADE;
DROP TABLE IF EXISTS Organizer    CASCADE;
DROP TABLE IF EXISTS Team         CASCADE;
DROP TABLE IF EXISTS Game         CASCADE;
DROP TABLE IF EXISTS Users        CASCADE;

DROP TYPE IF EXISTS gender_enum CASCADE;

-- ============================================================
-- ENUM TYPE
-- ============================================================
CREATE TYPE gender_enum AS ENUM ('Male', 'Female', 'Other');

-- ============================================================
-- 1. Users
-- Central user table; every actor references this.
-- ============================================================
CREATE TABLE Users (
    UserID      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FirstName   VARCHAR(50)   NOT NULL,
    LastName    VARCHAR(50)   NOT NULL,
    Email       VARCHAR(100)  NOT NULL UNIQUE,
    Phone       VARCHAR(15),
    Gender      gender_enum   NOT NULL,
    DOB         DATE,
    Role        VARCHAR(20)   NOT NULL
                    CHECK (Role IN ('Player','Coach','Referee','Organizer','MediaPartner')),
    CreatedAt   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE Users IS 'Master user table for all system actors.';

-- ============================================================
-- 2. Game
-- Sport / discipline (e.g. Cricket, Football)
-- ============================================================
CREATE TABLE Game (
    GameID      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    GameName    VARCHAR(50)   NOT NULL UNIQUE,
    GameType    VARCHAR(30)   NOT NULL
                    CHECK (GameType IN ('Indoor','Outdoor','Both')),
    MaxPlayers  INT           NOT NULL CHECK (MaxPlayers > 0)
);

COMMENT ON TABLE Game IS 'Catalogue of sports / games available in the system.';

-- ============================================================
-- 3. Team
-- ============================================================
CREATE TABLE Team (
    TeamID      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TeamName    VARCHAR(80)   NOT NULL UNIQUE,
    GameID      INT           NOT NULL REFERENCES Game(GameID),
    HomeCity    VARCHAR(50),
    FoundedYear INT           CHECK (FoundedYear > 1800)
);

COMMENT ON TABLE Team IS 'Teams participating in various games.';

-- ============================================================
-- 4. Player
-- ============================================================
CREATE TABLE Player (
    PlayerID    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID      INT           NOT NULL REFERENCES Users(UserID),
    TeamID      INT           NOT NULL REFERENCES Team(TeamID),
    JerseyNo    INT           CHECK (JerseyNo BETWEEN 0 AND 99),
    Position    VARCHAR(30),
    JoinDate    DATE          DEFAULT CURRENT_DATE,
    UNIQUE (TeamID, JerseyNo)              -- no duplicate jersey within a team
);

COMMENT ON TABLE Player IS 'Players registered under specific teams.';

-- ============================================================
-- 5. Coach
-- ============================================================
CREATE TABLE Coach (
    CoachID     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID      INT           NOT NULL REFERENCES Users(UserID),
    TeamID      INT           NOT NULL REFERENCES Team(TeamID),
    Experience  INT           CHECK (Experience >= 0),
    Specialty   VARCHAR(50)
);

COMMENT ON TABLE Coach IS 'Coaches assigned to teams.';

-- ============================================================
-- 6. Referee
-- ============================================================
CREATE TABLE Referee (
    RefereeID   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID      INT           NOT NULL REFERENCES Users(UserID),
    GameID      INT           NOT NULL REFERENCES Game(GameID),
    Certification VARCHAR(50),
    MatchesOfficiated INT     DEFAULT 0 CHECK (MatchesOfficiated >= 0)
);

COMMENT ON TABLE Referee IS 'Referees certified for specific games.';

-- ============================================================
-- 7. Organizer
-- ============================================================
CREATE TABLE Organizer (
    OrganizerID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID      INT           NOT NULL REFERENCES Users(UserID),
    OrgName     VARCHAR(100)  NOT NULL,
    OrgType     VARCHAR(30)   CHECK (OrgType IN ('Government','Private','NGO','University'))
);

COMMENT ON TABLE Organizer IS 'Event organizers (companies, universities, etc.).';

-- ============================================================
-- 8. Venue
-- ============================================================
CREATE TABLE Venue (
    VenueID     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    VenueName   VARCHAR(100)  NOT NULL,
    City        VARCHAR(50)   NOT NULL,
    State       VARCHAR(50),
    Capacity    INT           NOT NULL CHECK (Capacity > 0),
    SurfaceType VARCHAR(30)
);

COMMENT ON TABLE Venue IS 'Physical locations where events / matches take place.';

-- ============================================================
-- 9. Event
-- ============================================================
CREATE TABLE Event (
    EventID     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    EventName   VARCHAR(100)  NOT NULL,
    GameID      INT           NOT NULL REFERENCES Game(GameID),
    OrganizerID INT           NOT NULL REFERENCES Organizer(OrganizerID),
    VenueID     INT           NOT NULL REFERENCES Venue(VenueID),
    StartDate   DATE          NOT NULL,
    EndDate     DATE          NOT NULL,
    Status      VARCHAR(20)   DEFAULT 'Upcoming'
                    CHECK (Status IN ('Upcoming','Ongoing','Completed','Cancelled')),
    CHECK (EndDate >= StartDate)
);

COMMENT ON TABLE Event IS 'Sporting events / tournaments.';

-- ============================================================
-- 10. Match
-- ============================================================
CREATE TABLE Match (
    MatchID     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    EventID     INT           NOT NULL REFERENCES Event(EventID),
    Team1ID     INT           NOT NULL REFERENCES Team(TeamID),
    Team2ID     INT           NOT NULL REFERENCES Team(TeamID),
    RefereeID   INT           REFERENCES Referee(RefereeID),
    MatchDate   DATE          NOT NULL,
    MatchTime   TIME,
    VenueID     INT           REFERENCES Venue(VenueID),
    WinnerID    INT           REFERENCES Team(TeamID),
    CHECK (Team1ID <> Team2ID)
);

COMMENT ON TABLE Match IS 'Individual matches within an event.';

-- ============================================================
-- 11. Result
-- ============================================================
CREATE TABLE Result (
    ResultID    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    MatchID     INT           NOT NULL REFERENCES Match(MatchID),
    WinnerID    INT           NOT NULL REFERENCES Team(TeamID),
    LoserID     INT           NOT NULL REFERENCES Team(TeamID),
    ScoreWinner VARCHAR(20),
    ScoreLoser  VARCHAR(20),
    Remarks     TEXT,
    RecordedAt  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (MatchID)                       -- one result per match
);

COMMENT ON TABLE Result IS 'Outcome of each match, auto-populated by trigger.';

-- ============================================================
-- 12. Sponsor
-- ============================================================
CREATE TABLE Sponsor (
    SponsorID   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    SponsorName VARCHAR(100)  NOT NULL,
    EventID     INT           NOT NULL REFERENCES Event(EventID),
    Amount      NUMERIC(12,2) NOT NULL CHECK (Amount > 0),
    SponsorType VARCHAR(30)   CHECK (SponsorType IN ('Title','Gold','Silver','Bronze','Media'))
);

COMMENT ON TABLE Sponsor IS 'Sponsors associated with events.';

-- ============================================================
-- 13. MediaPartner
-- ============================================================
CREATE TABLE MediaPartner (
    MediaID     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID      INT           NOT NULL REFERENCES Users(UserID),
    EventID     INT           NOT NULL REFERENCES Event(EventID),
    CompanyName VARCHAR(100)  NOT NULL,
    CoverageType VARCHAR(30)  CHECK (CoverageType IN ('TV','Online','Print','Radio','Social Media'))
);

COMMENT ON TABLE MediaPartner IS 'Media partners covering events.';

-- ============================================================
-- END OF SCHEMA
-- ============================================================
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
-- ============================================================
-- SPORTS EVENT MANAGEMENT SYSTEM — SAMPLE DATA (DML)
-- All inserts respect referential integrity (parent-first).
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. Users  (20 users across all roles)
-- ────────────────────────────────────────────────────────────
INSERT INTO Users (FirstName, LastName, Email, Phone, Gender, DOB, Role) VALUES
('Arjun',   'Sharma',    'arjun.sharma@mail.com',     '9876543210', 'Male',   '1998-05-14', 'Player'),
('Priya',   'Verma',     'priya.verma@mail.com',      '9876543211', 'Female', '1997-08-22', 'Player'),
('Rohit',   'Patel',     'rohit.patel@mail.com',      '9876543212', 'Male',   '1999-01-10', 'Player'),
('Sneha',   'Iyer',      'sneha.iyer@mail.com',       '9876543213', 'Female', '2000-03-05', 'Player'),
('Vikram',  'Singh',     'vikram.singh@mail.com',      '9876543214', 'Male',   '1996-11-30', 'Player'),
('Ananya',  'Reddy',     'ananya.reddy@mail.com',      '9876543215', 'Female', '1998-09-17', 'Player'),
('Kabir',   'Malhotra',  'kabir.malhotra@mail.com',    '9876543216', 'Male',   '1995-07-08', 'Player'),
('Divya',   'Nair',      'divya.nair@mail.com',        '9876543217', 'Female', '1999-12-25', 'Player'),
('Ravi',    'Kumar',     'ravi.kumar@mail.com',         '9876543218', 'Male',   '1985-04-20', 'Coach'),
('Meena',   'Desai',     'meena.desai@mail.com',        '9876543219', 'Female', '1982-06-15', 'Coach'),
('Suresh',  'Joshi',     'suresh.joshi@mail.com',       '9876543220', 'Male',   '1978-02-28', 'Referee'),
('Lakshmi', 'Rao',       'lakshmi.rao@mail.com',        '9876543221', 'Female', '1980-10-12', 'Referee'),
('Anil',    'Gupta',     'anil.gupta@mail.com',         '9876543222', 'Male',   '1975-01-01', 'Organizer'),
('Pooja',   'Banerjee',  'pooja.banerjee@mail.com',     '9876543223', 'Female', '1988-03-14', 'Organizer'),
('Deepak',  'Mehta',     'deepak.mehta@mail.com',       '9876543224', 'Male',   '1990-07-07', 'MediaPartner'),
('Neha',    'Kapoor',    'neha.kapoor@mail.com',        '9876543225', 'Female', '1992-11-11', 'MediaPartner'),
('Rahul',   'Tiwari',    'rahul.tiwari@mail.com',       '9876543226', 'Male',   '1997-04-18', 'Player'),
('Simran',  'Kaur',      'simran.kaur@mail.com',        '9876543227', 'Female', '1998-06-30', 'Player'),
('Manish',  'Dubey',     'manish.dubey@mail.com',       '9876543228', 'Male',   '2001-02-14', 'Player'),
('Kavita',  'Saxena',    'kavita.saxena@mail.com',      '9876543229', 'Female', '1999-09-09', 'Player');

-- ────────────────────────────────────────────────────────────
-- 2. Game
-- ────────────────────────────────────────────────────────────
INSERT INTO Game (GameName, GameType, MaxPlayers) VALUES
('Cricket',       'Outdoor', 11),
('Football',      'Outdoor', 11),
('Badminton',     'Indoor',   2),
('Basketball',    'Indoor',   5),
('Tennis',        'Outdoor',  2);

-- ────────────────────────────────────────────────────────────
-- 3. Team
-- ────────────────────────────────────────────────────────────
INSERT INTO Team (TeamName, GameID, HomeCity, FoundedYear) VALUES
('Mumbai Mavericks',   1, 'Mumbai',     2010),
('Delhi Dynamos',      1, 'Delhi',      2012),
('Bangalore Blazers',  2, 'Bangalore',  2015),
('Chennai Chargers',   2, 'Chennai',    2014),
('Kolkata Knights',    4, 'Kolkata',    2018),
('Hyderabad Hawks',    4, 'Hyderabad',  2019);

-- ────────────────────────────────────────────────────────────
-- 4. Player  (12 players across 6 teams)
-- ────────────────────────────────────────────────────────────
INSERT INTO Player (UserID, TeamID, JerseyNo, Position, JoinDate) VALUES
(1,  1, 10, 'Batsman',       '2022-01-15'),
(2,  1, 7,  'Bowler',        '2022-03-20'),
(3,  2, 18, 'All-Rounder',   '2021-06-10'),
(4,  2, 5,  'Wicketkeeper',  '2022-07-01'),
(5,  3, 9,  'Forward',       '2023-01-05'),
(6,  3, 11, 'Midfielder',    '2023-02-14'),
(7,  4, 1,  'Goalkeeper',    '2022-11-20'),
(8,  4, 14, 'Defender',      '2023-04-18'),
(17, 5, 23, 'Point Guard',   '2024-01-10'),
(18, 5, 30, 'Shooting Guard','2024-02-20'),
(19, 6, 12, 'Center',        '2024-03-01'),
(20, 6, 8,  'Power Forward', '2024-03-15');

-- ────────────────────────────────────────────────────────────
-- 5. Coach
-- ────────────────────────────────────────────────────────────
INSERT INTO Coach (UserID, TeamID, Experience, Specialty) VALUES
(9,  1, 15, 'Batting'),
(10, 3, 12, 'Defence Strategy');

-- ────────────────────────────────────────────────────────────
-- 6. Referee
-- ────────────────────────────────────────────────────────────
INSERT INTO Referee (UserID, GameID, Certification, MatchesOfficiated) VALUES
(11, 1, 'ICC Level 2',    120),
(12, 2, 'FIFA Category 1', 85);

-- ────────────────────────────────────────────────────────────
-- 7. Organizer
-- ────────────────────────────────────────────────────────────
INSERT INTO Organizer (UserID, OrgName, OrgType) VALUES
(13, 'National Sports Authority',  'Government'),
(14, 'SportSync Pvt. Ltd.',        'Private');

-- ────────────────────────────────────────────────────────────
-- 8. Venue
-- ────────────────────────────────────────────────────────────
INSERT INTO Venue (VenueName, City, State, Capacity, SurfaceType) VALUES
('Wankhede Stadium',          'Mumbai',     'Maharashtra',  33000, 'Grass'),
('Jawaharlal Nehru Stadium',  'Delhi',      'Delhi',        60000, 'Grass'),
('Chinnaswamy Stadium',       'Bangalore',  'Karnataka',    40000, 'Grass'),
('Indira Gandhi Arena',       'Delhi',      'Delhi',        15000, 'Hardwood');

-- ────────────────────────────────────────────────────────────
-- 9. Event
-- ────────────────────────────────────────────────────────────
INSERT INTO Event (EventName, GameID, OrganizerID, VenueID, StartDate, EndDate, Status) VALUES
('Indian Premier League 2026',   1, 1, 1, '2026-03-22', '2026-05-28', 'Ongoing'),
('Super Football League 2026',   2, 2, 2, '2026-06-01', '2026-08-15', 'Upcoming'),
('National Basketball Open 2026',4, 1, 4, '2026-09-10', '2026-09-20', 'Upcoming');

-- ────────────────────────────────────────────────────────────
-- 10. Match  (WinnerID set for completed matches)
-- ────────────────────────────────────────────────────────────
INSERT INTO Match (EventID, Team1ID, Team2ID, RefereeID, MatchDate, MatchTime, VenueID, WinnerID) VALUES
(1, 1, 2, 1, '2026-03-23', '19:30', 1, 1),     -- Match 1 — Team 1 won
(1, 2, 1, 1, '2026-04-05', '19:30', 1, 2),     -- Match 2 — Team 2 won
(1, 1, 2, 1, '2026-04-18', '15:00', 1, 1),     -- Match 3 — Team 1 won
(2, 3, 4, 2, '2026-06-05', '18:00', 2, NULL),  -- Match 4 — upcoming
(2, 4, 3, 2, '2026-06-12', '18:00', 3, NULL),  -- Match 5 — upcoming
(3, 5, 6, NULL, '2026-09-12', '17:00', 4, NULL); -- Match 6 — upcoming

-- ────────────────────────────────────────────────────────────
-- 11. Result  (only for completed matches)
-- ────────────────────────────────────────────────────────────
INSERT INTO Result (MatchID, WinnerID, LoserID, ScoreWinner, ScoreLoser, Remarks) VALUES
(1, 1, 2, '185/4', '170/10', 'Mumbai won by 15 runs'),
(2, 2, 1, '200/6', '195/8',  'Delhi won by 5 runs'),
(3, 1, 2, '220/3', '210/7',  'Mumbai won by 10 runs');

-- ────────────────────────────────────────────────────────────
-- 12. Sponsor
-- ────────────────────────────────────────────────────────────
INSERT INTO Sponsor (SponsorName, EventID, Amount, SponsorType) VALUES
('Tata Group',         1, 50000000.00, 'Title'),
('Dream11',            1, 25000000.00, 'Gold'),
('CRED',               1, 10000000.00, 'Silver'),
('Coca-Cola',          2, 30000000.00, 'Title'),
('Adidas',             2, 15000000.00, 'Gold'),
('PepsiCo',            3,  8000000.00, 'Title');

-- ────────────────────────────────────────────────────────────
-- 13. MediaPartner
-- ────────────────────────────────────────────────────────────
INSERT INTO MediaPartner (UserID, EventID, CompanyName, CoverageType) VALUES
(15, 1, 'Star Sports',       'TV'),
(16, 1, 'Cricbuzz',          'Online'),
(15, 2, 'Sony Sports',       'TV'),
(16, 3, 'ESPN India',        'Online');

-- ============================================================
-- END OF SAMPLE DATA
-- ============================================================
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
-- ============================================================
-- SPORTS EVENT MANAGEMENT SYSTEM — TRIGGERS
-- ============================================================

CREATE OR REPLACE FUNCTION trg_auto_insert_result()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_loser_id INT;
BEGIN
    IF OLD.WinnerID IS NOT NULL OR NEW.WinnerID IS NULL THEN
        RETURN NEW;
    END IF;

    IF NEW.WinnerID = NEW.Team1ID THEN
        v_loser_id := NEW.Team2ID;
    ELSIF NEW.WinnerID = NEW.Team2ID THEN
        v_loser_id := NEW.Team1ID;
    ELSE
        RAISE EXCEPTION 'WinnerID % is neither Team1 nor Team2.', NEW.WinnerID;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Result WHERE MatchID = NEW.MatchID) THEN
        INSERT INTO Result (MatchID, WinnerID, LoserID, Remarks)
        VALUES (NEW.MatchID, NEW.WinnerID, v_loser_id,
                'Auto-generated by trigger');
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_match_winner_update ON Match;

CREATE TRIGGER trg_match_winner_update
    AFTER UPDATE OF WinnerID ON Match
    FOR EACH ROW
    EXECUTE FUNCTION trg_auto_insert_result();
-- ============================================================
-- SPORTS EVENT MANAGEMENT SYSTEM — ADVANCED QUERIES
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- VIEW: vw_match_scoreboard
-- Comprehensive match view with teams, event, venue, result
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_match_scoreboard AS
SELECT m.MatchID,
       e.EventName,
       t1.TeamName AS Team1,
       t2.TeamName AS Team2,
       m.MatchDate,
       v.VenueName,
       COALESCE(tw.TeamName, 'TBD') AS Winner,
       r.ScoreWinner,
       r.ScoreLoser,
       r.Remarks
  FROM Match m
  JOIN Event e  ON e.EventID  = m.EventID
  JOIN Team  t1 ON t1.TeamID  = m.Team1ID
  JOIN Team  t2 ON t2.TeamID  = m.Team2ID
  LEFT JOIN Venue  v  ON v.VenueID  = m.VenueID
  LEFT JOIN Team   tw ON tw.TeamID  = m.WinnerID
  LEFT JOIN Result r  ON r.MatchID  = m.MatchID;

-- ────────────────────────────────────────────────────────────
-- QUERY 1: Multi-table JOIN — Player roster with user & team info
-- ────────────────────────────────────────────────────────────
SELECT u.FirstName || ' ' || u.LastName AS PlayerName,
       u.Email,
       t.TeamName,
       g.GameName,
       p.JerseyNo,
       p.Position
  FROM Player p
  JOIN Users u ON u.UserID = p.UserID
  JOIN Team  t ON t.TeamID = p.TeamID
  JOIN Game  g ON g.GameID = t.GameID
 ORDER BY t.TeamName, p.JerseyNo;

-- ────────────────────────────────────────────────────────────
-- QUERY 2: Aggregate — Total sponsorship per event
-- ────────────────────────────────────────────────────────────
SELECT e.EventName,
       COUNT(s.SponsorID)       AS SponsorCount,
       SUM(s.Amount)            AS TotalSponsorship,
       ROUND(AVG(s.Amount), 2)  AS AvgSponsorship
  FROM Event e
  JOIN Sponsor s ON s.EventID = e.EventID
 GROUP BY e.EventID, e.EventName
 ORDER BY TotalSponsorship DESC;

-- ────────────────────────────────────────────────────────────
-- QUERY 3: Subquery — Teams with more than 1 win
-- ────────────────────────────────────────────────────────────
SELECT TeamName, HomeCity
  FROM Team
 WHERE TeamID IN (
       SELECT WinnerID
         FROM Result
        GROUP BY WinnerID
       HAVING COUNT(*) > 1
 );

-- ────────────────────────────────────────────────────────────
-- QUERY 4: GROUP BY + HAVING — Games with > 1 team registered
-- ────────────────────────────────────────────────────────────
SELECT g.GameName,
       COUNT(t.TeamID) AS TeamCount
  FROM Game g
  JOIN Team t ON t.GameID = g.GameID
 GROUP BY g.GameID, g.GameName
HAVING COUNT(t.TeamID) > 1
 ORDER BY TeamCount DESC;

-- ────────────────────────────────────────────────────────────
-- QUERY 5: JOIN + Aggregate — Coach info with team player count
-- ────────────────────────────────────────────────────────────
SELECT u.FirstName || ' ' || u.LastName AS CoachName,
       t.TeamName,
       c.Specialty,
       c.Experience,
       (SELECT COUNT(*) FROM Player p WHERE p.TeamID = c.TeamID) AS PlayerCount
  FROM Coach c
  JOIN Users u ON u.UserID = c.UserID
  JOIN Team  t ON t.TeamID = c.TeamID;

-- ────────────────────────────────────────────────────────────
-- QUERY 6: Correlated Subquery — Events with total sponsorship > 20M
-- ────────────────────────────────────────────────────────────
SELECT EventName, StartDate, EndDate, Status
  FROM Event e
 WHERE (SELECT COALESCE(SUM(Amount), 0)
          FROM Sponsor s WHERE s.EventID = e.EventID) > 20000000;

-- ────────────────────────────────────────────────────────────
-- QUERY 7: Multi-table JOIN — Match details from the VIEW
-- ────────────────────────────────────────────────────────────
SELECT * FROM vw_match_scoreboard
 WHERE Winner <> 'TBD'
 ORDER BY MatchDate;

-- ────────────────────────────────────────────────────────────
-- QUERY 8: Referee workload — matches officiated per referee
-- ────────────────────────────────────────────────────────────
SELECT u.FirstName || ' ' || u.LastName AS RefereeName,
       g.GameName,
       r.Certification,
       COUNT(m.MatchID) AS MatchesInSystem
  FROM Referee r
  JOIN Users u ON u.UserID = r.UserID
  JOIN Game  g ON g.GameID = r.GameID
  LEFT JOIN Match m ON m.RefereeID = r.RefereeID
 GROUP BY r.RefereeID, u.FirstName, u.LastName, g.GameName, r.Certification;

-- ============================================================
-- END OF ADVANCED QUERIES
-- ============================================================
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
-- ============================================================
-- SPORTS EVENT MANAGEMENT SYSTEM — NORMALIZATION ANALYSIS
-- ============================================================

/*
╔══════════════════════════════════════════════════════════════╗
║                  NORMALIZATION EXPLANATION                   ║
║                  1NF  ·  2NF  ·  3NF                        ║
╚══════════════════════════════════════════════════════════════╝

This document explains how every table in the Sports Event
Management System satisfies the first three normal forms.

────────────────────────────────────────────────────────────────
DEFINITIONS (Quick Reference)
────────────────────────────────────────────────────────────────
1NF — Each column contains atomic (indivisible) values;
      each row is uniquely identifiable by a primary key.

2NF — 1NF + every non-key column is fully functionally
      dependent on the *entire* primary key (relevant when
      the PK is composite).

3NF — 2NF + no transitive dependency: non-key columns
      depend only on the PK, not on other non-key columns.

────────────────────────────────────────────────────────────────
TABLE-BY-TABLE ANALYSIS
────────────────────────────────────────────────────────────────

1. Users
   PK: UserID (single-column)
   1NF ✔  All attributes are atomic (FirstName, LastName
          stored separately — not a combined "Name" field).
   2NF ✔  Single-column PK ⇒ no partial dependency possible.
   3NF ✔  No transitive dependency; every column depends
          directly on UserID.

2. Game
   PK: GameID
   1NF ✔  Atomic values; unique GameName.
   2NF ✔  Single-column PK.
   3NF ✔  GameType and MaxPlayers depend only on GameID.

3. Team
   PK: TeamID
   1NF ✔  Atomic values.
   2NF ✔  Single-column PK.
   3NF ✔  GameID is a FK, not a transitive dependency.
          HomeCity and FoundedYear depend on TeamID alone.

4. Player
   PK: PlayerID
   1NF ✔  Atomic values; unique (TeamID, JerseyNo) constraint.
   2NF ✔  Single-column PK.
   3NF ✔  UserID and TeamID are FKs; Position, JerseyNo,
          JoinDate depend only on PlayerID.

5. Coach
   PK: CoachID
   1NF ✔  Atomic values.
   2NF ✔  Single-column PK.
   3NF ✔  Experience and Specialty depend on CoachID, not
          transitively through TeamID.

6. Referee
   PK: RefereeID
   1NF ✔  Atomic values.
   2NF ✔  Single-column PK.
   3NF ✔  Certification and MatchesOfficiated depend on
          RefereeID directly.

7. Organizer
   PK: OrganizerID
   1NF ✔  Atomic values.
   2NF ✔  Single-column PK.
   3NF ✔  OrgName and OrgType depend on OrganizerID.

8. Venue
   PK: VenueID
   1NF ✔  City and State are stored separately (atomic).
   2NF ✔  Single-column PK.
   3NF ✔  All attributes depend on VenueID. (State *could*
          be derived from City in theory, but in this schema
          it is stored independently for clarity and is
          acceptable at 3NF level.)

9. Event
   PK: EventID
   1NF ✔  Atomic values; dates stored as DATE type.
   2NF ✔  Single-column PK.
   3NF ✔  GameID, OrganizerID, VenueID are FKs; remaining
          columns depend only on EventID.

10. Match
    PK: MatchID
    1NF ✔  Atomic values; MatchDate and MatchTime separated.
    2NF ✔  Single-column PK.
    3NF ✔  All FKs (EventID, Team1ID, Team2ID, RefereeID,
           VenueID, WinnerID) reference external entities;
           no transitive dependency.

11. Result
    PK: ResultID  |  UNIQUE(MatchID)
    1NF ✔  Atomic values.
    2NF ✔  Single-column PK.
    3NF ✔  WinnerID, LoserID, scores, and remarks depend on
           ResultID (and by extension, on MatchID). No
           transitive dependency.

12. Sponsor
    PK: SponsorID
    1NF ✔  Atomic values; Amount stored as NUMERIC.
    2NF ✔  Single-column PK.
    3NF ✔  All columns depend on SponsorID; EventID is a FK.

13. MediaPartner
    PK: MediaID
    1NF ✔  Atomic values.
    2NF ✔  Single-column PK.
    3NF ✔  UserID and EventID are FKs; CompanyName and
           CoverageType depend on MediaID.

────────────────────────────────────────────────────────────────
SUMMARY
────────────────────────────────────────────────────────────────
All 13 tables satisfy 1NF, 2NF, and 3NF.
• Every table uses a single surrogate primary key (IDENTITY),
  eliminating partial-dependency issues entirely.
• Foreign keys reference parent tables — they are not
  transitive dependencies but relationship pointers.
• No repeating groups, no composite attributes, and no
  derived columns are stored.
*/
