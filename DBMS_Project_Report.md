# Sports Event Management System

## DBMS Project Report

---

**Course:** UCS310 – Database Management Systems

**Degree:** Bachelor of Technology (2nd Year)

**Institute:** Thapar Institute of Engineering and Technology, Patiala

**Academic Year:** 2025–2026

---

**Submitted By:**

| Name | Roll Number |
|------|-------------|
| ___________________ | ___________ |
| ___________________ | ___________ |
| ___________________ | ___________ |

**Submitted To:** ___________________

---

## Table of Contents

1. Introduction
2. Problem Statement
3. Objectives
4. Scope
5. Proposed System
6. Database Design
7. Normalization
8. Database Implementation
9. Transaction Management
10. Tools and Technologies
11. Expected Outcomes

---

## 1. Introduction

A Sports Event Management System is a database-driven application designed to streamline the planning, scheduling, and management of sporting events and tournaments. It consolidates information about players, teams, coaches, referees, organizers, venues, matches, results, sponsors, and media partners into a single, structured relational database.

### 1.1 Importance of DBMS over File Systems

Traditional file-based systems suffer from data redundancy, inconsistency, lack of concurrent access control, and absence of data integrity constraints. A Database Management System overcomes these limitations by providing:

- **Data Integrity:** Enforcement of primary key, foreign key, unique, and check constraints at the schema level ensures that only valid data enters the system.
- **Concurrency Control:** Multiple users (organizers, referees, media partners) can access and modify data simultaneously without conflict.
- **Data Security:** Role-based access and centralized control prevent unauthorized modifications.
- **Efficient Querying:** Structured Query Language (SQL) enables complex data retrieval across multiple related entities in a single statement.
- **Transaction Support:** ACID-compliant transactions guarantee that operations such as player registration or match scheduling either complete fully or are rolled back entirely.

### 1.2 Real-World Application

Consider a college-level sports festival involving multiple games (cricket, football, basketball, badminton, tennis), dozens of teams, hundreds of players, multiple venues, and several concurrent events spanning several weeks. Without a centralized database, organizers would struggle with scheduling conflicts, duplicate registrations, lost result records, and untracked sponsorship commitments. This system addresses all such concerns through a well-normalized relational schema implemented in PostgreSQL.

---

## 2. Problem Statement

Manual management of sports events using spreadsheets, paper records, or disconnected digital files introduces several critical problems:

- **Scheduling Conflicts:** Without a unified match scheduling system, two matches may be assigned to the same venue at the same time, or a team may be double-booked.
- **Data Inconsistency:** Player details may be recorded differently across multiple files, leading to conflicting records regarding team membership, jersey numbers, or contact information.
- **Result Tracking Failures:** Match outcomes recorded on paper or in isolated spreadsheets are prone to loss, duplication, or transcription errors.
- **Sponsorship Mismanagement:** Tracking which sponsors are associated with which events, along with their contribution amounts and tiers, becomes unmanageable at scale.
- **No Referential Integrity:** File-based systems cannot enforce that a player must belong to an existing team, or that a match must reference valid participating teams.
- **Limited Reporting:** Generating cross-entity reports (e.g., win rate of a team, total sponsorship per event, referee workload) requires manual aggregation, which is time-consuming and error-prone.

There is a clear need for a centralized, constraint-enforced, query-capable database system to manage the complete lifecycle of sports events.

---

## 3. Objectives

The primary objectives of this project are:

1. **Design a normalized relational schema** that captures all entities involved in sports event management — users, players, coaches, referees, organizers, teams, games, venues, events, matches, results, sponsors, and media partners — with appropriate constraints.

2. **Implement the schema in PostgreSQL** using standard DDL constructs including `GENERATED ALWAYS AS IDENTITY`, `VARCHAR`, `DATE`, `TIMESTAMP`, `NUMERIC`, custom `ENUM` types, and comprehensive `CHECK`, `UNIQUE`, and `FOREIGN KEY` constraints.

3. **Develop PL/pgSQL functions** for analytical queries such as computing team win counts, win rates, event summaries, match details, upcoming match schedules, and total sponsorship amounts.

4. **Create transactional procedures** for critical operations (player registration, match scheduling) with input validation and error handling.

5. **Automate result recording** through a database trigger that inserts into the Result table whenever a match winner is declared.

6. **Demonstrate transaction management** with explicit `BEGIN`, `COMMIT`, and `ROLLBACK` blocks to ensure ACID compliance.

---

## 4. Scope

### 4.1 User Roles

The system supports five distinct user roles, all extending from a central `Users` entity:

| Role | Description |
|------|-------------|
| **Player** | Registered under a team; has jersey number, position, and join date |
| **Coach** | Assigned to a team; tracks experience and coaching specialty |
| **Referee** | Certified for a specific game; tracks matches officiated |
| **Organizer** | Represents an organization (government, private, NGO, university) that hosts events |
| **Media Partner** | Covers events through TV, online, print, radio, or social media |

### 4.2 Functional Modules

| Module | Entities Involved |
|--------|-------------------|
| **Team & Player Management** | Users, Player, Coach, Team, Game |
| **Event Management** | Event, Organizer, Venue, Game |
| **Match Scheduling & Results** | Match, Referee, Result, Team |
| **Sponsorship Tracking** | Sponsor, Event |
| **Media Coverage** | MediaPartner, Users, Event |

---

## 5. Proposed System

### 5.1 System Overview

The Sports Event Management System is a PostgreSQL-based relational database that centralizes all sports event data. The system workflow is as follows:

1. **Registration Phase:** Organizers, players, coaches, referees, and media partners are registered in the `Users` table with their respective role-specific details stored in child tables (`Player`, `Coach`, `Referee`, `Organizer`, `MediaPartner`).

2. **Event Setup:** An organizer creates an event by specifying the game, venue, start date, and end date. Sponsors are then associated with the event along with their contribution tier and amount.

3. **Match Scheduling:** Matches are scheduled within an event by assigning two competing teams, a referee, a date/time, and a venue. The `schedule_match` procedure validates that both teams belong to the event's game and that the match date falls within the event window.

4. **Result Recording:** When a match concludes and the `WinnerID` column is updated, a database trigger automatically inserts a corresponding row into the `Result` table, identifying the winner, loser, and recording the timestamp.

5. **Analytics & Reporting:** Functions such as `get_team_win_count()`, `get_win_rate()`, `get_event_summary()`, and `get_total_sponsorship()` provide on-demand analytical insights. A database view (`vw_match_scoreboard`) consolidates match data with team names, scores, and venue information for quick reporting.

### 5.2 Key Features

- **Automated Result Generation:** A trigger on the `Match` table eliminates the need for manual result entry when a winner is declared.
- **Transactional Player Registration:** The `register_player` procedure atomically creates both the user record and the player record, rolling back entirely if any step fails.
- **Comprehensive Validation:** Procedures validate team existence, jersey uniqueness, game compatibility, and date-range compliance before committing data.
- **Flexible Querying:** Six PL/pgSQL functions cover common analytical needs, from simple win counts to percentage-based win rates.
- **Data Integrity at Every Level:** Primary keys, foreign keys, unique constraints, check constraints, and a custom `ENUM` type enforce data quality at the schema level.

### 5.3 Benefits

- Eliminates data redundancy and inconsistency through normalization
- Prevents scheduling conflicts via validation logic in procedures
- Provides instant analytical insights through pre-built functions and views
- Ensures atomicity of multi-step operations through transaction management
- Scales to accommodate large tournaments with many teams, events, and matches

---

## 6. Database Design

### 6.1 Entity-Relationship Description

#### 6.1.1 Entities and Attributes

The system comprises 13 entities:

**1. Users**
- UserID (PK), FirstName, LastName, Email (UNIQUE), Phone, Gender (ENUM), DOB, Role, CreatedAt

**2. Game**
- GameID (PK), GameName (UNIQUE), GameType, MaxPlayers

**3. Team**
- TeamID (PK), TeamName (UNIQUE), GameID (FK -> Game), HomeCity, FoundedYear

**4. Player**
- PlayerID (PK), UserID (FK -> Users), TeamID (FK -> Team), JerseyNo, Position, JoinDate
- UNIQUE constraint on (TeamID, JerseyNo)

**5. Coach**
- CoachID (PK), UserID (FK -> Users), TeamID (FK -> Team), Experience, Specialty

**6. Referee**
- RefereeID (PK), UserID (FK -> Users), GameID (FK -> Game), Certification, MatchesOfficiated

**7. Organizer**
- OrganizerID (PK), UserID (FK -> Users), OrgName, OrgType

**8. Venue**
- VenueID (PK), VenueName, City, State, Capacity, SurfaceType

**9. Event**
- EventID (PK), EventName, GameID (FK -> Game), OrganizerID (FK -> Organizer), VenueID (FK -> Venue), StartDate, EndDate, Status
- CHECK: EndDate >= StartDate

**10. Match**
- MatchID (PK), EventID (FK -> Event), Team1ID (FK -> Team), Team2ID (FK -> Team), RefereeID (FK -> Referee), MatchDate, MatchTime, VenueID (FK -> Venue), WinnerID (FK -> Team)
- CHECK: Team1ID != Team2ID

**11. Result**
- ResultID (PK), MatchID (FK -> Match, UNIQUE), WinnerID (FK -> Team), LoserID (FK -> Team), ScoreWinner, ScoreLoser, Remarks, RecordedAt

**12. Sponsor**
- SponsorID (PK), SponsorName, EventID (FK -> Event), Amount, SponsorType

**13. MediaPartner**
- MediaID (PK), UserID (FK -> Users), EventID (FK -> Event), CompanyName, CoverageType

#### 6.1.2 Relationships and Cardinality

| Relationship | Cardinality | Description |
|---|---|---|
| Users -> Player | 1 : 1 | A user with role 'Player' has one Player record |
| Users -> Coach | 1 : 1 | A user with role 'Coach' has one Coach record |
| Users -> Referee | 1 : 1 | A user with role 'Referee' has one Referee record |
| Users -> Organizer | 1 : 1 | A user with role 'Organizer' has one Organizer record |
| Users -> MediaPartner | 1 : N | A media user may cover multiple events |
| Team -> Player | 1 : N | A team has many players |
| Team -> Coach | 1 : N | A team may have multiple coaches |
| Game -> Team | 1 : N | A game has many teams |
| Game -> Referee | 1 : N | A game has many certified referees |
| Game -> Event | 1 : N | A game can have multiple events/tournaments |
| Organizer -> Event | 1 : N | An organizer can host multiple events |
| Venue -> Event | 1 : N | A venue can host multiple events |
| Event -> Match | 1 : N | An event contains many matches |
| Event -> Sponsor | 1 : N | An event can have many sponsors |
| Event -> MediaPartner | 1 : N | An event can have many media partners |
| Match -> Result | 1 : 1 | Each match has at most one result |
| Team -> Match | 1 : N | A team participates in many matches |
| Referee -> Match | 1 : N | A referee officiates many matches |

### 6.2 Relational Schema

The relational schema (with primary and foreign keys indicated) is summarized below:

```
Users (UserID[PK], FirstName, LastName, Email, Phone, Gender, DOB, Role, CreatedAt)

Game (GameID[PK], GameName, GameType, MaxPlayers)

Team (TeamID[PK], TeamName, GameID[FK->Game], HomeCity, FoundedYear)

Player (PlayerID[PK], UserID[FK->Users], TeamID[FK->Team], JerseyNo, Position, JoinDate)

Coach (CoachID[PK], UserID[FK->Users], TeamID[FK->Team], Experience, Specialty)

Referee (RefereeID[PK], UserID[FK->Users], GameID[FK->Game], Certification, MatchesOfficiated)

Organizer (OrganizerID[PK], UserID[FK->Users], OrgName, OrgType)

Venue (VenueID[PK], VenueName, City, State, Capacity, SurfaceType)

Event (EventID[PK], EventName, GameID[FK->Game], OrganizerID[FK->Organizer],
       VenueID[FK->Venue], StartDate, EndDate, Status)

Match (MatchID[PK], EventID[FK->Event], Team1ID[FK->Team], Team2ID[FK->Team],
       RefereeID[FK->Referee], MatchDate, MatchTime, VenueID[FK->Venue], WinnerID[FK->Team])

Result (ResultID[PK], MatchID[FK->Match], WinnerID[FK->Team], LoserID[FK->Team],
        ScoreWinner, ScoreLoser, Remarks, RecordedAt)

Sponsor (SponsorID[PK], SponsorName, EventID[FK->Event], Amount, SponsorType)

MediaPartner (MediaID[PK], UserID[FK->Users], EventID[FK->Event], CompanyName, CoverageType)
```

### 6.3 Indexes

Three performance indexes were created on frequently queried foreign key columns:

| Index Name | Column | Rationale |
|---|---|---|
| `idx_match_event` | Match(EventID) | Accelerates retrieval of all matches for a given event |
| `idx_player_team` | Player(TeamID) | Speeds up team roster lookups and player-count aggregations |
| `idx_result_match` | Result(MatchID) | Optimizes result lookups when computing win counts and win rates |

---

## 7. Normalization

The database schema has been verified to satisfy the First, Second, and Third Normal Forms.

### 7.1 First Normal Form (1NF)

A table is in 1NF if all column values are atomic (indivisible) and each row is uniquely identifiable.

- All tables use single-valued, atomic columns. For example, `Users` stores `FirstName` and `LastName` as separate columns rather than a combined `Name` field.
- Every table has a single-column surrogate primary key (`GENERATED ALWAYS AS IDENTITY`), ensuring unique row identification.
- No repeating groups or multi-valued attributes exist in any table.

**Conclusion:** All 13 tables satisfy 1NF.

### 7.2 Second Normal Form (2NF)

A table is in 2NF if it is in 1NF and every non-key attribute is fully functionally dependent on the entire primary key (no partial dependencies).

- Since every table in this schema uses a single-column primary key (e.g., `UserID`, `TeamID`, `MatchID`), partial dependency — which can only arise with composite primary keys — is structurally impossible.
- Even in the `Player` table, which has a `UNIQUE(TeamID, JerseyNo)` constraint, the primary key remains the single column `PlayerID`, so no partial dependency exists.

**Conclusion:** All 13 tables satisfy 2NF.

### 7.3 Third Normal Form (3NF)

A table is in 3NF if it is in 2NF and no non-key attribute transitively depends on the primary key through another non-key attribute.

- **Users:** FirstName, LastName, Email, Phone, Gender, DOB, and Role all depend directly on UserID. No column is derivable from another non-key column.
- **Game:** GameName, GameType, and MaxPlayers depend directly on GameID.
- **Team:** TeamName, HomeCity, and FoundedYear depend on TeamID. GameID is a foreign key referencing Game, not a transitive dependency.
- **Player:** UserID and TeamID are foreign keys; JerseyNo, Position, and JoinDate depend on PlayerID.
- **Coach:** Experience and Specialty depend on CoachID, not transitively through TeamID.
- **Referee:** Certification and MatchesOfficiated depend on RefereeID directly.
- **Organizer:** OrgName and OrgType depend on OrganizerID.
- **Venue:** VenueName, City, State, Capacity, and SurfaceType depend on VenueID. While State could theoretically be derived from City, it is stored independently for clarity and geographic flexibility.
- **Event:** All attributes depend on EventID; GameID, OrganizerID, and VenueID are relationship pointers (foreign keys).
- **Match:** All foreign keys (EventID, Team1ID, Team2ID, RefereeID, VenueID, WinnerID) reference external entities; MatchDate and MatchTime depend on MatchID.
- **Result:** WinnerID, LoserID, scores, and remarks depend on ResultID (and by extension, the unique MatchID).
- **Sponsor:** SponsorName, Amount, and SponsorType depend on SponsorID; EventID is a foreign key.
- **MediaPartner:** CompanyName and CoverageType depend on MediaID; UserID and EventID are foreign keys.

**Conclusion:** All 13 tables satisfy 3NF. No transitive dependencies exist.

---

## 8. Database Implementation

### 8.1 SQL Implementation

#### 8.1.1 Table Creation

All 13 tables were created using PostgreSQL-specific DDL syntax:

- `GENERATED ALWAYS AS IDENTITY` for auto-incrementing primary keys (replacing Oracle's `SEQUENCE` + `TRIGGER` approach)
- `VARCHAR` for variable-length strings (replacing Oracle's `VARCHAR2`)
- `DATE` and `TIMESTAMP` for temporal data (replacing Oracle's `TO_DATE` function calls)
- A custom `ENUM` type (`gender_enum`) for the Gender column with values: `'Male'`, `'Female'`, `'Other'`
- `NUMERIC(12,2)` for monetary values (sponsorship amounts)

Constraints applied across all tables include:

- `PRIMARY KEY` on every identity column
- `FOREIGN KEY` references with implicit `ON DELETE RESTRICT`
- `UNIQUE` constraints on Email (Users), GameName (Game), TeamName (Team), and the composite (TeamID, JerseyNo) in Player
- `CHECK` constraints for value validation: Role values, GameType values, Status values, OrgType values, SponsorType values, CoverageType values, numeric ranges, and date ordering

#### 8.1.2 Queries

The project includes eight advanced queries demonstrating a range of SQL capabilities:

**Multi-Table JOIN — Player Roster:**
```sql
SELECT u.FirstName || ' ' || u.LastName AS PlayerName,
       t.TeamName, g.GameName, p.JerseyNo, p.Position
  FROM Player p
  JOIN Users u ON u.UserID = p.UserID
  JOIN Team  t ON t.TeamID = p.TeamID
  JOIN Game  g ON g.GameID = t.GameID
 ORDER BY t.TeamName, p.JerseyNo;
```

**Aggregate Query — Sponsorship per Event:**
```sql
SELECT e.EventName,
       COUNT(s.SponsorID) AS SponsorCount,
       SUM(s.Amount)      AS TotalSponsorship
  FROM Event e
  JOIN Sponsor s ON s.EventID = e.EventID
 GROUP BY e.EventID, e.EventName
 ORDER BY TotalSponsorship DESC;
```

**Subquery — Teams with More Than One Win:**
```sql
SELECT TeamName FROM Team
 WHERE TeamID IN (
       SELECT WinnerID FROM Result
        GROUP BY WinnerID
       HAVING COUNT(*) > 1
 );
```

**GROUP BY + HAVING — Games with Multiple Teams:**
```sql
SELECT g.GameName, COUNT(t.TeamID) AS TeamCount
  FROM Game g
  JOIN Team t ON t.GameID = g.GameID
 GROUP BY g.GameID, g.GameName
HAVING COUNT(t.TeamID) > 1;
```

**Correlated Subquery — Events with Sponsorship Exceeding 20 Million:**
```sql
SELECT EventName, StartDate, EndDate
  FROM Event e
 WHERE (SELECT COALESCE(SUM(Amount), 0)
          FROM Sponsor s WHERE s.EventID = e.EventID) > 20000000;
```

#### 8.1.3 View

A comprehensive view `vw_match_scoreboard` was created to consolidate match data:

```sql
CREATE OR REPLACE VIEW vw_match_scoreboard AS
SELECT m.MatchID, e.EventName,
       t1.TeamName AS Team1, t2.TeamName AS Team2,
       m.MatchDate, v.VenueName,
       COALESCE(tw.TeamName, 'TBD') AS Winner,
       r.ScoreWinner, r.ScoreLoser, r.Remarks
  FROM Match m
  JOIN Event e  ON e.EventID  = m.EventID
  JOIN Team  t1 ON t1.TeamID  = m.Team1ID
  JOIN Team  t2 ON t2.TeamID  = m.Team2ID
  LEFT JOIN Venue  v  ON v.VenueID  = m.VenueID
  LEFT JOIN Team   tw ON tw.TeamID  = m.WinnerID
  LEFT JOIN Result r  ON r.MatchID  = m.MatchID;
```

This view joins six tables and provides a ready-to-query scoreboard that can be filtered by event, date, or winner.

### 8.2 PL/pgSQL Implementation

#### 8.2.1 Functions

Six functions were implemented using `RETURNS TABLE` or scalar return types:

| Function | Return Type | Purpose |
|---|---|---|
| `get_team_win_count(team_id)` | `INT` | Returns total wins for a team |
| `get_event_summary()` | `TABLE` | Returns event name, game, organizer, venue, match counts, status |
| `get_match_details()` | `TABLE` | Returns detailed match info with team names, referee, and winner |
| `get_total_sponsorship(event_id)` | `NUMERIC` | Returns total sponsorship amount for an event |
| `get_upcoming_matches(team_id)` | `TABLE` | Returns future matches for a team (where WinnerID IS NULL) |
| `get_win_rate(team_id)` | `NUMERIC` | Returns win percentage (wins/total x 100) |

**Example — get_win_rate:**
```sql
CREATE OR REPLACE FUNCTION get_win_rate(p_team_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INT;
    v_wins  INT;
BEGIN
    SELECT COUNT(*) INTO v_total FROM Result
     WHERE WinnerID = p_team_id OR LoserID = p_team_id;
    SELECT COUNT(*) INTO v_wins FROM Result
     WHERE WinnerID = p_team_id;
    IF v_total = 0 THEN RETURN 0; END IF;
    RETURN ROUND((v_wins::NUMERIC / v_total) * 100, 2);
END;
$$;
```

#### 8.2.2 Procedures

Two transactional procedures were implemented:

**register_player(...)** — Atomically creates a `Users` row (with role = 'Player') and a `Player` row. Validates that the team exists and the jersey number is not already taken within the team. Raises an exception (triggering automatic rollback) on any failure.

**schedule_match(...)** — Inserts a new match into the `Match` table. Validates that: the event exists, the two teams are different, both teams belong to the event's game, and the match date falls within the event's date window.

Both procedures use `RAISE EXCEPTION` for error handling, which automatically aborts the current transaction in PostgreSQL.

#### 8.2.3 Trigger

A trigger was created to automate result recording:

```sql
CREATE TRIGGER trg_match_winner_update
    AFTER UPDATE OF WinnerID ON Match
    FOR EACH ROW
    EXECUTE FUNCTION trg_auto_insert_result();
```

**Behavior:** When `Match.WinnerID` is updated from `NULL` to a valid team ID, the trigger function automatically:
1. Determines the loser (the other team in the match)
2. Inserts a new row into the `Result` table with the winner, loser, and a timestamp
3. Skips insertion if a result already exists for the match (idempotency safeguard)
4. Raises an exception if the WinnerID is neither Team1 nor Team2

---

## 9. Transaction Management

### 9.1 ACID Properties

The project leverages PostgreSQL's full ACID compliance:

| Property | Implementation |
|---|---|
| **Atomicity** | The `register_player` procedure performs two inserts (Users + Player) as a single atomic unit; if either fails, both are rolled back |
| **Consistency** | CHECK, UNIQUE, and FOREIGN KEY constraints ensure the database never enters an invalid state |
| **Isolation** | PostgreSQL's default `READ COMMITTED` isolation level prevents dirty reads |
| **Durability** | Once `COMMIT` is executed, the data is permanently persisted to disk |

### 9.2 Transaction Demonstrations

Three transaction scenarios were implemented:

**Transaction 1 — Successful COMMIT:**
```sql
BEGIN;
    CALL register_player('Amit'::VARCHAR, 'Chauhan'::VARCHAR,
         'amit.chauhan@mail.com'::VARCHAR, '9998887770'::VARCHAR,
         'Male'::gender_enum, '2001-08-15'::DATE,
         1, 99, 'All-Rounder'::VARCHAR);
COMMIT;
```
The player is registered and the changes are permanently saved.

**Transaction 2 — Deliberate ROLLBACK:**
```sql
BEGIN;
    CALL schedule_match(1, 1, 2, 1, '2026-05-01'::DATE, '20:00'::TIME, 1);
ROLLBACK;
```
The match insertion is completely undone as if it never happened.

**Transaction 3 — Trigger-Driven COMMIT:**
```sql
BEGIN;
    UPDATE Match SET WinnerID = 3 WHERE MatchID = 4;
    -- Trigger auto-inserts into Result
    SELECT * FROM Result WHERE MatchID = 4;
COMMIT;
```
Updating the winner fires the trigger, which inserts the result automatically. Both changes are committed together.

---

## 10. Tools and Technologies

| Tool / Technology | Purpose |
|---|---|
| **PostgreSQL 18** | Relational database management system |
| **SQL** | Data Definition Language (DDL) and Data Manipulation Language (DML) |
| **PL/pgSQL** | Procedural language for functions, procedures, and triggers |
| **pgAdmin 4** | Graphical administration and query execution tool |
| **ENUM Type** | Custom data type for Gender column (Male, Female, Other) |
| **GENERATED ALWAYS AS IDENTITY** | Auto-incrementing primary key generation (PostgreSQL standard) |

---

## 11. Expected Outcomes

Upon successful implementation and deployment, the system achieves the following outcomes:

1. **Operational Efficiency:** Organizers can register players, schedule matches, and record results through structured procedures rather than manual data entry, reducing administrative overhead.

2. **Data Integrity:** The combination of primary keys, foreign keys, unique constraints, check constraints, and an ENUM type ensures that invalid or inconsistent data cannot enter the system at any point.

3. **Automated Result Recording:** The trigger on the `Match` table eliminates manual result entry. Setting a match winner automatically populates the `Result` table with the correct winner, loser, and timestamp.

4. **Analytical Capability:** Six pre-built functions provide instant insights — team win counts, win rates, event summaries, match details, upcoming schedules, and sponsorship totals — without requiring users to write complex queries.

5. **Transaction Safety:** Critical multi-step operations (player registration, match scheduling) are wrapped in transactions with validation and error handling, ensuring that partial failures never leave the database in an inconsistent state.

6. **Scalability:** The normalized schema (3NF), indexed foreign key columns, and efficient query design ensure that the system performs well as the number of events, teams, and matches grows.

7. **Reporting Readiness:** The `vw_match_scoreboard` view and the various table-returning functions provide ready-made data sources for dashboards, printed reports, or external application integration.

---

## References

1. Elmasri, R. and Navathe, S.B. *Fundamentals of Database Systems*, 7th Edition, Pearson.
2. PostgreSQL Official Documentation — https://www.postgresql.org/docs/
3. Silberschatz, A., Korth, H.F. and Sudarshan, S. *Database System Concepts*, 7th Edition, McGraw-Hill.

---

*End of Report*
