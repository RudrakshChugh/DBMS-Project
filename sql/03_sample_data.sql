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
