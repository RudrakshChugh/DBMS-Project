/* {% raw %} */
const BrowseTables = () => {
  const tables = ['users', 'game', 'team', 'player', 'coach', 'referee', 'organizer', 'venue', 'event', 'match', 'result', 'sponsor', 'mediapartner'];
  const [sel, setSel] = useState('users');
  const [rows, setRows] = useState(null);
  
  const load = useCallback(() => {
    setRows(null);
    F(`${API}/table/${sel}`).then(setRows);
  }, [sel]);
  
  useEffect(load, [sel]);
  
  return (
    <div className="space-y-6 fade-in h-[calc(100vh-120px)] flex flex-col">
      <PageHeader 
        title="Database Explorer" 
        actions={<Button variant="ghost" onClick={load} icon={<Icons.Refresh />} size="compact">Refresh</Button>}
      />
      
      <div className="flex flex-wrap gap-2 pb-4 border-b border-border-default shrink-0">
        {tables.map(t => (
          <button 
            key={t} 
            onClick={() => setSel(t)} 
            className={`px-3 py-1.5 rounded-sm text-[13px] font-medium capitalize transition-colors ${
              sel === t 
                ? 'bg-slate-200 dark:bg-slate-700 text-base-text shadow-sm' 
                : 'bg-transparent text-muted hover:bg-slate-100 dark:bg-slate-800/50 hover:text-base-text'
            }`}
          >
            {t}
          </button>
        ))}
      </div>
      
      <div className="flex-1 overflow-hidden flex flex-col">
        {!rows ? (
          <SkeletonLoader type="table" rows={10} />
        ) : (
          <div className="h-full overflow-auto bg-base-surface rounded-md border border-border-default shadow-card custom-scrollbar">
            {rows.length === 0 ? (
              <EmptyState title="Table is empty" description={`No records found in the "${sel}" table.`} />
            ) : (
              <table className="w-full text-left text-[14px]">
                <thead className="bg-slate-50 dark:bg-slate-800 border-b border-border-default sticky top-0 z-10 shadow-sm">
                  <tr>
                    {Object.keys(rows[0]).map(k => (
                      <th key={k} className="px-4 py-3 text-[12px] font-medium uppercase tracking-wider text-muted whitespace-nowrap">
                        {k}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody className="divide-y divide-border-default">
                  {rows.map((r, i) => (
                    <tr key={i} className="min-h-[44px] hover:bg-slate-50 dark:bg-slate-800 transition-colors">
                      {Object.entries(r).map(([k, v]) => (
                        <td key={k} className="px-4 py-3 text-base-text whitespace-nowrap">
                          {v === null ? <span className="text-slate-300">-</span> : String(v)}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        )}
      </div>
    </div>
  );
};
/* {% endraw %} */