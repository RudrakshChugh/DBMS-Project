/* {% raw %} */
const Dashboard = () => {
  const [d, setD] = useState(null);
  
  const load = () => {
    setD(null);
    F(`${API}/dashboard`).then(setD);
  };
  
  useEffect(load, []);
  
  if (!d) {
    return (
      <div className="space-y-6">
        <PageHeader title="Overview" />
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <SkeletonLoader type="card" />
          <SkeletonLoader type="card" />
          <SkeletonLoader type="card" />
          <SkeletonLoader type="card" />
        </div>
        <SkeletonLoader type="table" rows={3} />
      </div>
    );
  }
  
  const s = d.stats;
  
  const KPICard = ({ label, value, badge }) => (
    <Card className="p-5 flex flex-col justify-between h-[110px]">
      <div className="flex justify-between items-start mb-2">
        <p className="text-[12px] font-medium text-muted uppercase tracking-wider">{label}</p>
        {badge}
      </div>
      <p className="text-[28px] font-semibold tracking-tight text-base-text leading-none">{value}</p>
    </Card>
  );

  const StatusCard = ({ label, value, status }) => {
    const colors = {
      green: 'bg-status-success',
      blue: 'bg-accent-blue',
      amber: 'bg-status-warning'
    };
    return (
      <Card className="p-4 flex items-center gap-4">
        <div className={`w-3 h-3 rounded-full ${colors[status]}`}></div>
        <div className="flex-1">
          <p className="text-[13px] font-medium text-base-text">{label}</p>
          <p className="text-[12px] text-muted">{value} total</p>
        </div>
      </Card>
    );
  };
  
  return (
    <div className="space-y-8 fade-in">
      <PageHeader 
        title="Overview" 
        actions={
          <Button variant="ghost" onClick={load} icon={<Icons.Refresh />}>
            Refresh
          </Button>
        } 
      />
      
      {/* 4-column KPI strip */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <KPICard label="Total Teams" value={s.total_teams} />
        <KPICard label="Total Players" value={s.total_players} badge={<Badge variant="green">+12%</Badge>} />
        <KPICard label="Matches Played" value={s.total_matches} />
        <KPICard label="Total Sponsorship" value={`₹${(s.total_sponsorship/1e7).toFixed(1)} Cr`} badge={<Badge variant="blue">FY26</Badge>} />
      </div>
      
      {/* 3 status cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <StatusCard status="green" label="Completed Matches" value={s.completed_matches} />
        <StatusCard status="blue" label="Upcoming Matches" value={s.upcoming_matches} />
        <StatusCard status="amber" label="Ongoing Events" value={s.ongoing_events} />
      </div>
      
      {/* System Entity Counts */}
      <div>
        <h3 className="text-[14px] font-semibold text-base-text mb-4">System Entity Counts</h3>
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-4">
          {Object.entries(d.table_counts).map(([k, v]) => (
            <Card key={k} className="p-4 text-center hover:bg-slate-50 dark:bg-slate-800 transition-colors cursor-default">
              <p className="text-[20px] font-semibold text-base-text mb-1">{v}</p>
              <p className="text-[11px] font-medium text-muted uppercase tracking-wider">{k}</p>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
};
/* {% endraw %} */