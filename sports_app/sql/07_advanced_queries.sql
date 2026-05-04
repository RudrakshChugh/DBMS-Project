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
