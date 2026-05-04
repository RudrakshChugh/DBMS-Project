"""
Sports Event Management System — Flask Backend
Connects to PostgreSQL database 'sports_events' and serves REST API + React frontend.
"""

from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
import psycopg2
import psycopg2.extras
from decimal import Decimal
from datetime import date, datetime, time as dt_time
import os

app = Flask(__name__)
CORS(app)

# ── Database Configuration ──
DB_CONFIG = {
    'dbname': os.getenv('DB_NAME', 'sports_events'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', 'postgres'),
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', 5432))
}

ALLOWED_TABLES = [
    'users', 'game', 'team', 'player', 'coach', 'referee',
    'organizer', 'venue', 'event', 'match', 'result',
    'sponsor', 'mediapartner'
]

# ── Helpers ──

def get_conn():
    return psycopg2.connect(**DB_CONFIG)

def ser(v):
    """Serialize non-JSON-safe types."""
    if isinstance(v, Decimal):
        return float(v)
    if isinstance(v, (date, datetime)):
        return v.isoformat()
    if isinstance(v, dt_time):
        return str(v)
    return v

def srow(row):
    if row is None:
        return None
    return {k: ser(v) for k, v in row.items()}

def srows(rows):
    return [srow(r) for r in rows]

def query(sql, params=None):
    """Execute a SELECT and return serialized rows."""
    conn = get_conn()
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params)
            return srows(cur.fetchall())
    finally:
        conn.close()

def scalar(sql, params=None):
    """Execute and return a single scalar value."""
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(sql, params)
            val = cur.fetchone()[0]
            return ser(val)
    finally:
        conn.close()

# ── Routes ──

@app.route('/')
def index():
    return render_template('index.html')

# ── Dashboard ──
@app.route('/api/dashboard')
def dashboard():
    conn = get_conn()
    try:
        cur = conn.cursor()
        counts = {}
        for t in ALLOWED_TABLES:
            cur.execute(f'SELECT COUNT(*) FROM "{t}"')
            counts[t] = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM Match WHERE WinnerID IS NOT NULL")
        completed = cur.fetchone()[0]
        cur.execute("SELECT COUNT(*) FROM Match WHERE WinnerID IS NULL")
        upcoming = cur.fetchone()[0]
        cur.execute("SELECT COUNT(*) FROM Event WHERE Status = 'Ongoing'")
        ongoing = cur.fetchone()[0]
        cur.execute("SELECT COALESCE(SUM(Amount), 0) FROM Sponsor")
        total_sp = float(cur.fetchone()[0])

        return jsonify({
            'table_counts': counts,
            'stats': {
                'total_teams': counts['team'],
                'total_players': counts['player'],
                'total_events': counts['event'],
                'total_matches': counts['match'],
                'completed_matches': completed,
                'upcoming_matches': upcoming,
                'ongoing_events': ongoing,
                'total_sponsorship': total_sp
            }
        })
    finally:
        conn.close()

# ── Browse any table ──
@app.route('/api/table/<table_name>')
def get_table(table_name):
    t = table_name.lower()
    if t not in ALLOWED_TABLES:
        return jsonify({'error': f'Table "{table_name}" not allowed'}), 400
    return jsonify(query(f'SELECT * FROM "{t}"'))

# ── Scoreboard view ──
@app.route('/api/scoreboard')
def scoreboard():
    return jsonify(query("SELECT * FROM vw_match_scoreboard ORDER BY matchid"))

# ── Analytics: functions ──
@app.route('/api/analytics/event_summary')
def event_summary():
    return jsonify(query("SELECT * FROM get_event_summary()"))

@app.route('/api/analytics/match_details')
def match_details():
    return jsonify(query("SELECT * FROM get_match_details()"))

@app.route('/api/analytics/win_count/<int:team_id>')
def win_count(team_id):
    v = scalar("SELECT get_team_win_count(%s)", (team_id,))
    return jsonify({'team_id': team_id, 'win_count': v})

@app.route('/api/analytics/win_rate/<int:team_id>')
def win_rate(team_id):
    v = scalar("SELECT get_win_rate(%s)", (team_id,))
    return jsonify({'team_id': team_id, 'win_rate': v})

@app.route('/api/analytics/total_sponsorship/<int:event_id>')
def total_sponsorship(event_id):
    v = scalar("SELECT get_total_sponsorship(%s)", (event_id,))
    return jsonify({'event_id': event_id, 'total_sponsorship': v})

@app.route('/api/analytics/upcoming_matches/<int:team_id>')
def upcoming_matches(team_id):
    return jsonify(query("SELECT * FROM get_upcoming_matches(%s)", (team_id,)))

@app.route('/api/analytics/team_stats')
def team_stats():
    teams = query("SELECT TeamID, TeamName FROM Team ORDER BY TeamID")
    result = []
    for t in teams:
        tid = t['teamid']
        wc = scalar("SELECT get_team_win_count(%s)", (tid,))
        wr = scalar("SELECT get_win_rate(%s)", (tid,))
        result.append({'team_id': tid, 'team_name': t['teamname'], 'win_count': wc, 'win_rate': wr})
    return jsonify(result)

# ── Meta: data for dropdowns ──
@app.route('/api/meta')
def meta():
    teams = query("SELECT TeamID, TeamName, GameID FROM Team ORDER BY TeamName")
    events = query("SELECT EventID, EventName, GameID FROM Event ORDER BY EventName")
    referees = query("""
        SELECT r.RefereeID, u.FirstName || ' ' || u.LastName AS name
        FROM Referee r JOIN Users u ON u.UserID = r.UserID ORDER BY name
    """)
    venues = query("SELECT VenueID, VenueName FROM Venue ORDER BY VenueName")
    pending = query("""
        SELECT m.MatchID, t1.TeamName AS team1, t1.TeamID AS team1id,
               t2.TeamName AS team2, t2.TeamID AS team2id, e.EventName
        FROM Match m
        JOIN Team t1 ON t1.TeamID = m.Team1ID
        JOIN Team t2 ON t2.TeamID = m.Team2ID
        JOIN Event e ON e.EventID = m.EventID
        WHERE m.WinnerID IS NULL ORDER BY m.MatchDate
    """)
    return jsonify({
        'teams': teams, 'events': events, 'referees': referees,
        'venues': venues, 'pending_matches': pending
    })

# ── POST: Register Player ──
@app.route('/api/register_player', methods=['POST'])
def register_player():
    d = request.json or {}
    required = ['first_name','last_name','email','phone','gender','dob','team_id','jersey_no','position']
    missing = [f for f in required if not d.get(f)]
    if missing:
        return jsonify({'error': f'Missing fields: {", ".join(missing)}'}), 400

    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                CALL register_player(
                    %s::VARCHAR, %s::VARCHAR, %s::VARCHAR, %s::VARCHAR,
                    %s::gender_enum, %s::DATE, %s, %s, %s::VARCHAR
                )
            """, (
                d['first_name'], d['last_name'], d['email'], d['phone'],
                d['gender'], d['dob'], int(d['team_id']), int(d['jersey_no']),
                d['position']
            ))
        conn.commit()
        return jsonify({'success': True, 'message': f'Player {d["first_name"]} {d["last_name"]} registered successfully'})
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        conn.close()

# ── POST: Schedule Match ──
@app.route('/api/schedule_match', methods=['POST'])
def schedule_match():
    d = request.json or {}
    required = ['event_id','team1_id','team2_id','referee_id','match_date','match_time','venue_id']
    missing = [f for f in required if not d.get(f)]
    if missing:
        return jsonify({'error': f'Missing fields: {", ".join(missing)}'}), 400

    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                CALL schedule_match(%s, %s, %s, %s, %s::DATE, %s::TIME, %s)
            """, (
                int(d['event_id']), int(d['team1_id']), int(d['team2_id']),
                int(d['referee_id']), d['match_date'], d['match_time'],
                int(d['venue_id'])
            ))
        conn.commit()
        return jsonify({'success': True, 'message': 'Match scheduled successfully'})
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        conn.close()

# ── POST: Set Winner (Trigger Demo) ──
@app.route('/api/set_winner', methods=['POST'])
def set_winner():
    d = request.json or {}
    match_id = d.get('match_id')
    winner_id = d.get('winner_id')
    if not match_id or not winner_id:
        return jsonify({'error': 'match_id and winner_id are required'}), 400

    conn = get_conn()
    try:
        cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

        # BEFORE: check Result table
        cur.execute("SELECT * FROM Result WHERE MatchID = %s", (match_id,))
        before = srow(cur.fetchone())

        # UPDATE winner → trigger fires
        cur.execute("UPDATE Match SET WinnerID = %s WHERE MatchID = %s", (winner_id, match_id))

        # AFTER: check Result table again
        cur.execute("SELECT * FROM Result WHERE MatchID = %s", (match_id,))
        after = srow(cur.fetchone())

        conn.commit()
        return jsonify({
            'success': True,
            'message': 'Winner set — trigger fired!',
            'trigger_demo': {'before': before, 'after': after}
        })
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        conn.close()

# ── Run ──
if __name__ == '__main__':
    print("  Sports Event Management System")
    print("  http://localhost:5000")
    app.run(debug=True, port=5000)
