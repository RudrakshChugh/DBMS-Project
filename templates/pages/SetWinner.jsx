/* {% raw %} */
const SetWinner = ({ toast }) => {
  const [meta, setMeta] = useState(null);
  const [demo, setDemo] = useState(null);
  const [busy, setBusy] = useState(null);
  
  const load = () => {
    setMeta(null);
    F(`${API}/meta`).then(setMeta);
  };
  
  useEffect(() => { load(); }, []);
  
  const doSet = async (matchId, winnerId) => {
    setBusy(matchId);
    const r = await P(`${API}/set_winner`, { match_id: matchId, winner_id: winnerId });
    setBusy(null);
    
    if (r.error) {
      toast(r.error, 'error', 'Failed');
    } else {
      toast(r.message, 'success', 'Winner Set');
      setDemo(r.trigger_demo);
      load();
    }
  };
  
  if (!meta) return <div className="space-y-6"><PageHeader title="Set Match Winner" /><SkeletonLoader type="card" /><SkeletonLoader type="card" /></div>;
  
  const pm = meta.pending_matches || [];
  
  return (
    <div className="space-y-8 fade-in max-w-5xl">
      <PageHeader 
        title="Set Match Winner (Trigger Demo)" 
        actions={<Button variant="secondary" onClick={load} icon={<Icons.Refresh />} size="compact">Refresh</Button>}
      />
      
      <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-100 dark:border-blue-900/30 rounded-md p-4 flex items-start gap-3">
        <Icons.Info className="text-accent-blue shrink-0 mt-0.5" />
        <p className="text-[13px] text-blue-900 dark:text-blue-100 leading-relaxed">
          <strong>Database Trigger Demonstration:</strong> Setting a winner below fires a PostgreSQL trigger that automatically creates a <code className="bg-base-surface px-1 py-0.5 rounded border border-blue-200 dark:border-blue-800/30">Result</code> record. The before/after states will appear at the bottom of the page.
        </p>
      </div>
      
      {pm.length === 0 ? (
        <Card><EmptyState icon={<Icons.CheckCircle />} title="All Caught Up" description="There are no pending matches requiring a result." /></Card>
      ) : (
        <div className="grid gap-4">
          {pm.map(m => (
            <Card key={m.matchid} className="p-4 md:p-6 hover:border-border-emphasis transition-colors">
              <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
                
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <Badge variant="gray">Match #{m.matchid}</Badge>
                    <span className="text-[12px] text-muted">{m.eventname}</span>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-[16px] font-semibold text-base-text">{m.team1}</span>
                    <span className="text-[11px] font-bold text-slate-400 dark:text-slate-500 dark:text-slate-400 bg-slate-100 dark:bg-slate-800/50 px-1.5 py-0.5 rounded-sm">VS</span>
                    <span className="text-[16px] font-semibold text-base-text">{m.team2}</span>
                  </div>
                </div>
                
                <div className="flex flex-col sm:flex-row gap-2 w-full md:w-auto shrink-0">
                  <Button 
                    variant="secondary" 
                    onClick={() => doSet(m.matchid, m.team1id)} 
                    disabled={busy === m.matchid}
                    icon={<Icons.Trophy />}
                    className="flex-1 md:flex-none text-accent-blue hover:text-accent-blue hover:border-accent-blue"
                  >
                    {m.team1} Wins
                  </Button>
                  <Button 
                    variant="secondary" 
                    onClick={() => doSet(m.matchid, m.team2id)} 
                    disabled={busy === m.matchid}
                    icon={<Icons.Trophy />}
                    className="flex-1 md:flex-none text-accent-blue hover:text-accent-blue hover:border-accent-blue"
                  >
                    {m.team2} Wins
                  </Button>
                </div>

              </div>
            </Card>
          ))}
        </div>
      )}
      
      {demo && (
        <div className="mt-8 pt-8 border-t border-border-default fade-in">
          <h3 className="text-[16px] font-semibold text-base-text mb-4">Trigger Execution Results</h3>
          <div className="grid lg:grid-cols-2 gap-6">
            
            <div>
              <p className="text-[12px] font-semibold text-muted uppercase tracking-wider mb-2 flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-slate-400"></span> Before Execution
              </p>
              {demo.before ? <Table rows={[demo.before]} /> : (
                <Card className="p-8 text-center bg-slate-50 dark:bg-slate-800"><p className="text-[13px] text-muted">No result record existed</p></Card>
              )}
            </div>
            
            <div>
              <p className="text-[12px] font-semibold text-status-success uppercase tracking-wider mb-2 flex items-center gap-2">
                <Icons.CheckCircle /> After Execution
              </p>
              {demo.after ? (
                <div className="ring-2 ring-status-success rounded-md shadow-sm">
                  <Table rows={[demo.after]} />
                </div>
              ) : (
                <Card className="p-8 text-center bg-slate-50 dark:bg-slate-800"><p className="text-[13px] text-muted">No data</p></Card>
              )}
            </div>
            
          </div>
        </div>
      )}
    </div>
  );
};
/* {% endraw %} */