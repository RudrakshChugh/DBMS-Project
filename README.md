# Sports Event Management System

A full-stack database project for managing sports events, teams, players, coaches, referees, sponsors, and media partners. Built with **PostgreSQL** + **Flask** + **React** (served from a single Jinja2 template).

---

## Project Structure

```
DBMS/
├── DBMS_Project_Report.md          # Full academic project report
├── README.md                       # This file
│
└── sports_app/                     # Application root
    ├── .env.example                # Sample environment variables
    ├── .gitignore                  # Git ignore rules
    ├── requirements.txt            # Python dependencies
    ├── setup_db.py                 # One-time DB setup script (runs SQL files)
    ├── db_check_postgres.py        # Quick utility to verify tables exist
    ├── app.py                      # Flask backend (REST API + serves frontend)
    │
    ├── templates/
    │   └── index.html              # React SPA frontend (Tailwind + Babel)
    │
    └── sql/                        # All SQL scripts (executed in numbered order)
        ├── 00_run_all.sql          # Master psql runner (alternative to setup_db.py)
        ├── 01_schema.sql           # DDL — 13 tables, ENUM, PK/FK/CHECK/UNIQUE
        ├── 02_indexes.sql          # Performance indexes
        ├── 03_sample_data.sql      # Realistic sample data
        ├── 04_functions.sql        # 6 PL/pgSQL functions
        ├── 05_procedures.sql       # 2 transactional procedures
        ├── 06_triggers.sql         # Auto-insert Result trigger
        ├── 07_advanced_queries.sql # JOINs, aggregates, subqueries, VIEW
        ├── 08_transactions.sql     # BEGIN / COMMIT / ROLLBACK demos
        ├── 09_normalization.sql    # 1NF / 2NF / 3NF analysis (comments)
        └── FULL_PROJECT_CODE.sql   # All SQL combined into one file
```

---

## Prerequisites

- **Python 3.9+**
- **PostgreSQL 13+** installed and running
- **psql** CLI available (comes with PostgreSQL)

---

## How to Run

### Step 1 — Clone / Download the Project

```bash
git clone <your-repo-url>
cd DBMS/sports_app
```

### Step 2 — Create a Virtual Environment

```bash
python -m venv venv
```

Activate it:

```bash
# Windows (PowerShell)
.\venv\Scripts\activate

# macOS / Linux
source venv/bin/activate
```

### Step 3 — Install Python Dependencies

```bash
pip install -r requirements.txt
```

### Step 4 — Create the PostgreSQL Database

Open a terminal (or pgAdmin) and create the database:

```bash
createdb -U postgres sports_events
```

Or via psql:

```sql
CREATE DATABASE sports_events;
```

### Step 5 — Set Up the Database Schema and Sample Data

You have **two options**:

**Option A — Python script (recommended):**

```bash
python setup_db.py
```

This executes SQL files 01 through 07 in order against `sports_events`.

**Option B — psql directly:**

```bash
cd sql
psql -U postgres -d sports_events -f 00_run_all.sql
```

This also runs files 08 (transactions) and 09 (normalization analysis).

### Step 6 — Run the Flask App

```bash
python app.py
```

The app will start at: **http://localhost:5000**

Open this URL in your browser to access the full dashboard.

---

## Features

| Feature | Description |
|---|---|
| **Dashboard** | Live stats — table counts, team performance, sponsorship totals |
| **Browse Tables** | View all 13 tables with raw data |
| **Register Player** | Form that calls the `register_player` stored procedure |
| **Schedule Match** | Form that calls the `schedule_match` stored procedure |
| **Set Winner (Trigger Demo)** | Select a winner for pending matches — watch the trigger auto-create a Result row |
| **Scoreboard** | `vw_match_scoreboard` view rendered as a live scoreboard |
| **Analytics** | Event summary, match details, team win rates, sponsorship per event |

---

## Database Configuration

By default, the app connects to:

| Setting | Default Value |
|---|---|
| Database | `sports_events` |
| User | `postgres` |
| Password | `postgres` |
| Host | `localhost` |
| Port | `5432` |

To override, set environment variables (or create a `.env` file based on `.env.example`):

```bash
set DB_NAME=sports_events
set DB_USER=postgres
set DB_PASSWORD=your_password
set DB_HOST=localhost
set DB_PORT=5432
```

---

## Entity-Relationship Overview

```
Users ──┬── Player ──── Team ──── Game
        ├── Coach  ──── Team
        ├── Referee ─── Game
        ├── Organizer ── Event ─── Venue
        └── MediaPartner ── Event

Event ──── Match ──── Result
Event ──── Sponsor
```

### 13 Tables

`Users` · `Player` · `Coach` · `Referee` · `Organizer` · `Game` · `Team` · `Venue` · `Event` · `Match` · `Result` · `Sponsor` · `MediaPartner`

---

## Tech Stack

| Component | Technology |
|---|---|
| Database | PostgreSQL 18 |
| Backend | Python 3 + Flask |
| Frontend | React 18 (CDN) + Tailwind CSS (CDN) |
| DB Driver | psycopg2 |
| Template Engine | Jinja2 (serves the React SPA) |

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/` | Serves the frontend SPA |
| GET | `/api/dashboard` | Dashboard stats and table counts |
| GET | `/api/table/<name>` | Browse any of the 13 tables |
| GET | `/api/scoreboard` | Match scoreboard view |
| GET | `/api/meta` | Dropdown data (teams, events, referees, venues, pending matches) |
| GET | `/api/analytics/event_summary` | Event summary function |
| GET | `/api/analytics/match_details` | Match details function |
| GET | `/api/analytics/win_count/<id>` | Team win count |
| GET | `/api/analytics/win_rate/<id>` | Team win rate |
| GET | `/api/analytics/total_sponsorship/<id>` | Event sponsorship total |
| GET | `/api/analytics/upcoming_matches/<id>` | Upcoming matches for a team |
| GET | `/api/analytics/team_stats` | All teams win count + win rate |
| POST | `/api/register_player` | Register a new player (calls procedure) |
| POST | `/api/schedule_match` | Schedule a new match (calls procedure) |
| POST | `/api/set_winner` | Set match winner (fires trigger) |

---

## License

This project is for academic / educational purposes.
