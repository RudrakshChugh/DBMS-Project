/* {% raw %} */
const Analytics = () => {
  const [tab, setTab] = useState('team');
  const [meta, setMeta] = useState(null);
  const [selTeam, setSelTeam] = useState('');
  const [selEvent, setSelEvent] = useState('');
  const [teamInfo, setTeamInfo] = useState(null);
  const [spAmt, setSpAmt] = useState(null);
  const [upcoming, setUpcoming] = useState(null);
  
  const [eventData, setEventData] = useState(null);
  
  useEffect(() => { 
    F(`${API}/meta`).then(setMeta); 
    F(`${API}/analytics/event_summary`).then(setEventData);
  }, []);
  
  const loadTeam = async (tid) => {
    setSelTeam(tid);
    setTeamInfo(null);
    setUpcoming(null);
    if (!tid) return;
    const [wc, wr, um] = await Promise.all([
      F(`${API}/analytics/win_count/${tid}`),
      F(`${API}/analytics/win_rate/${tid}`),
      F(`${API}/analytics/upcoming_matches/${tid}`)
    ]);
    setTeamInfo({ wc: wc.win_count, wr: wr.win_rate });
    setUpcoming(um);
  };
  
  const loadSp = async (eid) => {
    setSelEvent(eid);
    setSpAmt(null);
    if (!eid) return;
    const r = await F(`${API}/analytics/total_sponsorship/${eid}`);
    setSpAmt(r.total_sponsorship);
  };
  
  const tabs = [
    { id: 'team', label: 'Team Analytics' },
    { id: 'sponsor', label: 'Financials' },
    { id: 'event', label: 'Event Summary' }
  ];

  return (
    <div className="space-y-6 fade-in">
      <PageHeader title="Analytics" />
      
      <div className="flex border-b border-border-default mb-6">
        {tabs.map(t => (
          <button 
            key={t.id} 
            onClick={() => setTab(t.id)} 
            className={`px-4 py-3 text-[13px] font-medium border-b-2 transition-colors ${
              tab === t.id 
                ? 'border-accent-blue text-accent-blue' 
                : 'border-transparent text-muted hover:text-base-text hover:border-border-emphasis'
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>
      
      {/* Team Analytics */}
      {tab === 'team' && (
        <div className="max-w-3xl fade-in">
          {meta ? (
            <Select label="Analyze Team Performance" value={selTeam} onChange={loadTeam} options={meta.teams} vk="teamid" lk="teamname" />
          ) : <SkeletonLoader type="card" />}
          
          {!selTeam && meta && (
            <Card className="mt-4"><EmptyState title="Select a team" description="Choose a team from the dropdown to view performance metrics." /></Card>
          )}

          {teamInfo && (
            <div className="mt-6 grid grid-cols-1 sm:grid-cols-2 gap-4 fade-in">
              <Card className="p-5 flex flex-col justify-between h-[110px] border-l-4 border-l-accent-blue">
                <p className="text-[12px] font-medium text-muted uppercase tracking-wider">Total Wins</p>
                <p className="text-[32px] font-semibold tracking-tight text-base-text">{teamInfo.wc}</p>
              </Card>
              <Card className="p-5 flex flex-col justify-between h-[110px] border-l-4 border-l-status-success">
                <p className="text-[12px] font-medium text-muted uppercase tracking-wider">Win Rate</p>
                <div className="flex items-end gap-3">
                  <p className="text-[32px] font-semibold tracking-tight text-base-text leading-none">{teamInfo.wr}%</p>
                  <div className="flex-1 h-2 bg-slate-100 dark:bg-slate-800/50 rounded-full mb-2 overflow-hidden">
                    <div className="h-full bg-status-success rounded-full" style={{ width: `${teamInfo.wr}%` }}></div>
                  </div>
                </div>
              </Card>
            </div>
          )}
          
          {upcoming && (
            <div className="mt-8 fade-in">
              <h4 className="text-[13px] font-semibold text-base-text mb-3 uppercase tracking-wider">Upcoming Schedule</h4>
              {upcoming.length > 0 ? (
                <Table rows={upcoming} />
              ) : (
                <Card><EmptyState icon={<Icons.Calendar />} title="No upcoming matches" description="This team has no upcoming matches scheduled." /></Card>
              )}
            </div>
          )}
        </div>
      )}
      
      {/* Financials */}
      {tab === 'sponsor' && (
        <div className="max-w-3xl fade-in">
          {meta ? (
            <Select label="Event Financial Breakdown" value={selEvent} onChange={loadSp} options={meta.events} vk="eventid" lk="eventname" />
          ) : <SkeletonLoader type="card" />}
          
          {!selEvent && meta && (
            <Card className="mt-4"><EmptyState icon={<Icons.Chart />} title="Select an event" description="Choose an event to view sponsorship financials." /></Card>
          )}

          {spAmt != null && selEvent && (
            <Card className="mt-6 p-8 text-center fade-in bg-slate-50 dark:bg-slate-800">
              <p className="text-[12px] font-medium text-muted uppercase tracking-wider mb-2">Total Event Sponsorship</p>
              <p className="text-[48px] font-bold text-base-text tracking-tight">₹{Number(spAmt).toLocaleString('en-IN')}</p>
            </Card>
          )}
        </div>
      )}

      {/* Event Summary */}
      {tab === 'event' && (
        <div className="fade-in">
          <p className="text-[14px] text-muted mb-4">Aggregated view of event durations and participation.</p>
          {eventData ? <Table rows={eventData} /> : <SkeletonLoader type="table" rows={4} />}
        </div>
      )}
    </div>
  );
};
/* {% endraw %} */