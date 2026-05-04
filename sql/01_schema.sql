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
