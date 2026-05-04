/* {% raw %} */
const ScheduleMatch = ({ toast }) => {
  const [meta, setMeta] = useState(null);
  const [busy, setBusy] = useState(false);
  const [f, setF] = useState({
    event_id: '', team1_id: '', team2_id: '', referee_id: '', 
    match_date: '', match_time: '', venue_id: ''
  });
  const [errors, setErrors] = useState({});
  const [view, setView] = useState('form');
  
  useEffect(() => { F(`${API}/meta`).then(setMeta); }, []);
  
  const set = (k, v) => {
    setF(p => ({ ...p, [k]: v }));
    if (errors[k]) setErrors(p => ({ ...p, [k]: null }));
  };

  const handleEventChange = (v) => {
    setF(p => ({ ...p, event_id: v, team1_id: '', team2_id: '' }));
    setErrors(p => ({ ...p, event_id: null, team1_id: null, team2_id: null }));
  };

  const availableTeams = (meta && meta.teams) ? (
    f.event_id 
      ? meta.teams.filter(t => {
          const ev = meta.events.find(e => e.eventid == f.event_id);
          return ev ? t.gameid == ev.gameid : true;
        })
      : meta.teams
  ) : [];
  
  const validate = () => {
    const e = {};
    if (!f.event_id) e.event_id = "Required";
    if (!f.venue_id) e.venue_id = "Required";
    if (!f.team1_id) e.team1_id = "Required";
    if (!f.team2_id) e.team2_id = "Required";
    if (f.team1_id && f.team2_id && f.team1_id === f.team2_id) {
      e.team2_id = "Teams must be different";
    }
    if (!f.referee_id) e.referee_id = "Required";
    if (!f.match_date) e.match_date = "Required";
    if (!f.match_time) e.match_time = "Required";
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const submit = async (e) => {
    e.preventDefault();
    if (!validate()) return;
    
    setBusy(true);
    const r = await P(`${API}/schedule_match`, f);
    setBusy(false);
    
    if (r.error) {
      toast(r.error, 'error', 'Scheduling Failed');
    } else {
      toast(r.message, 'success', 'Match Scheduled');
      setF({
        event_id: '', team1_id: '', team2_id: '', referee_id: '', 
        match_date: '', match_time: '', venue_id: ''
      });
      setView('list');
    }
  };
  
  const TeamOption = ({ teamId }) => {
    if (!teamId || !meta) return null;
    const teamName = resolveIdToName(teamId, meta.teams, 'teamid', 'teamname');
    return (
      <div className="flex items-center gap-2">
        <div className="w-6 h-6 rounded-full bg-slate-200 dark:bg-slate-700 border border-border-default flex items-center justify-center text-[10px] font-bold text-slate-500 dark:text-slate-400">
          {teamName.substring(0, 2).toUpperCase()}
        </div>
        <span>{teamName}</span>
      </div>
    );
  };
  
  return (
    <div className="max-w-4xl fade-in">
      <PageHeader 
        title="Schedule Match" 
        actions={
          <div className="flex bg-slate-100 dark:bg-slate-800/50 p-0.5 rounded-md">
            <button onClick={() => setView('form')} className={`px-3 py-1 text-[13px] font-medium rounded-sm ${view === 'form' ? 'bg-base-surface shadow-sm text-base-text' : 'text-muted'}`}>Form</button>
            <button onClick={() => setView('list')} className={`px-3 py-1 text-[13px] font-medium rounded-sm ${view === 'list' ? 'bg-base-surface shadow-sm text-base-text' : 'text-muted'}`}>List View</button>
          </div>
        }
      />
      
      {view === 'form' ? (
        <form onSubmit={submit}>
          <div className="flex flex-col lg:flex-row gap-8">
            <div className="flex-1">
              <div className="mb-6 pb-2 border-b border-border-default">
                <h3 className="text-[12px] font-semibold text-muted uppercase tracking-wider">Event Details</h3>
              </div>
              
              {meta ? (
                <>
                  <Select label="Tournament / Event" value={f.event_id} onChange={handleEventChange} options={meta.events} vk="eventid" lk="eventname" error={errors.event_id} />
                  <Select label="Venue" value={f.venue_id} onChange={v => set('venue_id', v)} options={meta.venues} vk="venueid" lk="venuename" error={errors.venue_id} />
                  <div className="grid grid-cols-2 gap-4">
                    <Input label="Date" type="date" value={f.match_date} onChange={v => set('match_date', v)} error={errors.match_date} />
                    <Input label="Time" type="time" value={f.match_time} onChange={v => set('match_time', v)} error={errors.match_time} />
                  </div>
                  <Select label="Match Referee" value={f.referee_id} onChange={v => set('referee_id', v)} options={meta.referees} vk="refereeid" lk="name" error={errors.referee_id} />
                </>
              ) : <SkeletonLoader type="card" />}
            </div>
            
            <div className="flex-1">
              <div className="mb-6 pb-2 border-b border-border-default">
                <h3 className="text-[12px] font-semibold text-muted uppercase tracking-wider">Teams</h3>
              </div>
              
              <Card className="p-6 bg-slate-50 dark:bg-slate-800 border-dashed">
                {meta ? (
                  <div className="flex flex-col gap-4 relative">
                    <Select label="Team A (Home)" value={f.team1_id} onChange={v => set('team1_id', v)} options={availableTeams} vk="teamid" lk="teamname" error={errors.team1_id} />
                    
                    <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-8 h-8 bg-base-surface border border-border-default rounded-full flex items-center justify-center text-[11px] font-bold text-muted z-10 shadow-sm">
                      VS
                    </div>
                    
                    <Select label="Team B (Away)" value={f.team2_id} onChange={v => set('team2_id', v)} options={availableTeams} vk="teamid" lk="teamname" error={errors.team2_id} />
                  </div>
                ) : <SkeletonLoader type="card" />}
                
                {f.team1_id && f.team2_id && f.team1_id !== f.team2_id && (
                  <div className="mt-6 flex items-center justify-between p-3 bg-base-surface border border-border-default rounded-sm shadow-sm">
                    <TeamOption teamId={f.team1_id} />
                    <span className="text-[11px] font-bold text-muted">VS</span>
                    <TeamOption teamId={f.team2_id} />
                  </div>
                )}
              </Card>
              
              <div className="mt-8 flex justify-end">
                <Button type="submit" variant="primary" disabled={busy || !meta} icon={busy ? null : <Icons.Calendar />}>
                  {busy ? 'Scheduling...' : 'Schedule Match'}
                </Button>
              </div>
            </div>
          </div>
        </form>
      ) : (
        <div className="fade-in">
          <MatchTable />
        </div>
      )}
    </div>
  );
};

const MatchTable = () => {
  const [r, setR] = useState(null);
  useEffect(() => { F(`${API}/table/match`).then(setR); }, []);
  return r ? <Table rows={r} /> : <SkeletonLoader />;
};
/* {% endraw %} */