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
