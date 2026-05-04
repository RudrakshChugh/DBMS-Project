/* {% raw %} */
const Scoreboard = () => {
  const [rows, setRows] = useState(null);
  const [sortKey, setSortKey] = useState('matchid');
  const [sortDir, setSortDir] = useState('desc');
  const [filterEvent, setFilterEvent] = useState('');
  
  const load = () => {
    setRows(null);
    F(`${API}/scoreboard`).then(setRows);
  };
  
  useEffect(load, []);
  
  const handleSort = (key) => {
    if (sortKey === key) {
      setSortDir(sortDir === 'asc' ? 'desc' : 'asc');
    } else {
      setSortKey(key);
      setSortDir('asc');
    }
  };

  if (!rows) return <div className="space-y-6"><PageHeader title="Results & Scoreboard" /><SkeletonLoader type="table" rows={8} /></div>;

  const events = [...new Set(rows.map(r => r.event_name))];
  
  let processedRows = rows;
  if (filterEvent) {
    processedRows = processedRows.filter(r => r.event_name === filterEvent);
  }
  
  processedRows = [...processedRows].sort((a, b) => {
    let va = a[sortKey];
    let vb = b[sortKey];
    if (va < vb) return sortDir === 'asc' ? -1 : 1;
    if (va > vb) return sortDir === 'asc' ? 1 : -1;
    return 0;
  });

  const getStatus = (winner) => {
    if (!winner || winner === 'TBD') return <Badge variant="gray">Scheduled</Badge>;
    return <Badge variant="blue">Completed</Badge>;
  };

  return (
    <div className="space-y-6 fade-in">
      <PageHeader 
        title="Results & Scoreboard" 
        actions={
          <div className="flex gap-3">
            <select 
              value={filterEvent} 
              onChange={e => setFilterEvent(e.target.value)}
              className="h-8 px-3 text-[13px] bg-base-surface border border-border-default rounded-sm outline-none"
            >
              <option value="">All Events</option>
              {events.map(e => <option key={e} value={e}>{e}</option>)}
            </select>
            <Button variant="ghost" onClick={load} icon={<Icons.Refresh />} size="compact">
              Refresh
            </Button>
          </div>
        }
      />
      
      {processedRows.length === 0 ? (
        <Card><EmptyState title="No matches found" description="Adjust your filters or schedule a new match." /></Card>
      ) : (
        <Card className="overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-[14px]">
              <thead className="bg-slate-50 dark:bg-slate-800 border-b border-border-default">
                <tr>
                  {[
                    { k: 'matchid', l: 'ID' },
                    { k: 'event_name', l: 'Event' },
                    { k: 'match_date', l: 'Date & Time' },
                    { k: 'teams', l: 'Matchup' },
                    { k: 'winner', l: 'Winner' },
                    { k: 'status', l: 'Status' }
                  ].map(h => {
                    const isSorted = sortKey === h.k;
                    return (
                      <th 
                        key={h.k} 
                        onClick={() => handleSort(h.k)}
                        className={`px-4 py-3 text-[12px] font-medium uppercase tracking-wider text-muted cursor-pointer select-none hover:text-base-text transition-colors ${isSorted ? 'bg-blue-50 dark:bg-blue-900/20 text-accent-blue' : ''}`}
                      >
                        <div className="flex items-center gap-1">
                          {h.l}
                          {isSorted && (sortDir === 'asc' ? <Icons.ChevronUp /> : <Icons.ChevronDown />)}
                        </div>
                      </th>
                    );
                  })}
                </tr>
              </thead>
              <tbody className="divide-y divide-border-default">
                {processedRows.map(r => {
                  const done = r.winner && r.winner !== 'TBD';
                  return (
                    <tr key={r.matchid} className="min-h-[44px] hover:bg-slate-50 dark:bg-slate-800 transition-colors">
                      <td className="px-4 py-3 font-mono text-[13px] text-muted">{r.matchid}</td>
                      <td className="px-4 py-3"><Badge variant="gray">{r.event_name}</Badge></td>
                      <td className="px-4 py-3 text-[13px]">
                        <div className="text-base-text">{r.match_date}</div>
                        <div className="text-muted">{r.match_time}</div>
                      </td>
                      <td className="px-4 py-3 font-medium">
                        <span className={done && r.winner === r.team1 ? 'text-base-text font-bold' : 'text-muted'}>{r.team1}</span>
                        <span className="mx-2 text-[11px] text-slate-400 dark:text-slate-500 dark:text-slate-400 font-bold">VS</span>
                        <span className={done && r.winner === r.team2 ? 'text-base-text font-bold' : 'text-muted'}>{r.team2}</span>
                      </td>
                      <td className={`px-4 py-3 font-medium ${done ? 'text-status-success' : 'text-muted'}`}>
                        {done ? r.winner : '–'}
                      </td>
                      <td className="px-4 py-3">
                        {getStatus(r.winner)}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </Card>
      )}
    </div>
  );
};
/* {% endraw %} */