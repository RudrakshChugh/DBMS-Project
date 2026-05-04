/* {% raw %} */
const TopBar = ({ title, mobileNavToggle, isDark, toggleDark }) => (
  <header className="h-[60px] border-b border-border-default bg-base-surface flex items-center justify-between px-6 shrink-0 sticky top-0 z-20">
    <div className="flex items-center gap-4">
      <button onClick={mobileNavToggle} className="md:hidden text-muted hover:text-base-text">
        <Icons.Menu />
      </button>
      <h2 className="text-[16px] font-semibold text-base-text hidden md:block">{title}</h2>
    </div>
    
    <div className="flex items-center gap-4 text-muted">
      <div className="hidden sm:flex items-center gap-2 px-3 py-1.5 bg-slate-100 dark:bg-slate-800/50 rounded-sm w-[240px] text-[13px] border border-transparent focus-within:border-border-emphasis focus-within:bg-base-surface transition-colors">
        <Icons.Search />
        <input type="text" placeholder="Search system..." className="bg-transparent border-none outline-none w-full text-base-text placeholder-slate-400" />
      </div>
      <button onClick={toggleDark} className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-slate-100 dark:hover:bg-slate-800/50 transition-colors">
        {isDark ? <Icons.Sun /> : <Icons.Moon />}
      </button>
      <button className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-slate-100 dark:hover:bg-slate-800/50 transition-colors relative">
        <Icons.Bell />
        <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-status-danger rounded-full ring-2 ring-white dark:ring-base-surface"></span>
      </button>
      <div className="w-8 h-8 rounded-full bg-slate-200 dark:bg-slate-700 border border-border-emphasis flex items-center justify-center font-semibold text-[12px] text-slate-600 dark:text-slate-300 select-none cursor-pointer">
        A
      </div>
    </div>
  </header>
);

const SidebarItem = ({ icon, label, isActive, onClick, badge }) => (
  <button 
    onClick={onClick}
    className={`w-full flex items-center gap-3 px-3 py-2 text-[13px] font-medium transition-colors ${
      isActive 
        ? 'bg-blue-50 dark:bg-blue-900/20 text-accent-blue border-l-2 border-accent-blue' 
        : 'text-muted hover:bg-slate-100 dark:bg-slate-800/50 hover:text-base-text border-l-2 border-transparent'
    }`}
  >
    <div className={isActive ? 'text-accent-blue' : 'text-muted'}>{icon}</div>
    <span className="flex-1 text-left">{label}</span>
    {badge && <span className="bg-slate-200 dark:bg-slate-700 text-slate-700 dark:text-slate-200 text-[10px] px-1.5 py-0.5 rounded-sm font-semibold">{badge}</span>}
  </button>
);

const App = () => {
  const [page, setPage] = useState('dashboard');
  const [toast, setToast] = useState(null);
  const [mobNav, setMobNav] = useState(false);
  const [isDark, setIsDark] = useState(false);
  
  useEffect(() => {
    if (isDark) document.documentElement.classList.add('dark');
    else document.documentElement.classList.remove('dark');
  }, [isDark]);
  
  const showToast = (msg, type = 'success', title) => setToast({ msg, type, title });
  
  const navGroups = [
    {
      label: 'Overview',
      items: [
        { id: 'dashboard', icon: <Icons.Dashboard />, label: 'Dashboard' },
        { id: 'analytics', icon: <Icons.Chart />, label: 'Analytics' }
      ]
    },
    {
      label: 'Operations',
      items: [
        { id: 'schedule', icon: <Icons.Calendar />, label: 'Schedule Match' },
        { id: 'winner', icon: <Icons.Target />, label: 'Set Winner' },
        { id: 'register', icon: <Icons.UserAdd />, label: 'Register Player' }
      ]
    },
    {
      label: 'Data',
      items: [
        { id: 'scoreboard', icon: <Icons.Trophy />, label: 'Scoreboard' },
        { id: 'tables', icon: <Icons.Table />, label: 'Database Explorer' }
      ]
    }
  ];

  const getPageTitle = () => {
    for (const g of navGroups) {
      const found = g.items.find(i => i.id === page);
      if (found) return found.label;
    }
    return 'SEMS';
  };

  return (
    <div className="flex h-screen bg-base-bg overflow-hidden text-base-text">
      {/* Mobile Nav Overlay */}
      {mobNav && <div className="md:hidden fixed inset-0 bg-slate-900 dark:bg-slate-950/50 z-40" onClick={() => setMobNav(false)}></div>}

      {/* Sidebar */}
      <aside className={`fixed md:static top-0 left-0 h-full w-[240px] bg-base-surface border-r border-border-default flex flex-col z-50 transition-transform duration-200 ${mobNav ? 'translate-x-0' : '-translate-x-full md:translate-x-0'}`}>
        <div className="h-[60px] flex items-center px-6 border-b border-border-default shrink-0">
          <div className="w-6 h-6 bg-base-text rounded-sm flex items-center justify-center mr-2">
            <span className="text-base-surface text-[12px] font-bold">S</span>
          </div>
          <span className="font-semibold tracking-tight text-[16px]">SEMS</span>
        </div>
        
        <nav className="flex-1 overflow-y-auto py-4">
          {navGroups.map((group, idx) => (
            <div key={group.label} className={idx > 0 ? 'mt-6' : ''}>
              <h4 className="px-4 text-[11px] font-semibold text-slate-400 dark:text-slate-500 dark:text-slate-400 uppercase tracking-wider mb-2">{group.label}</h4>
              <div className="flex flex-col">
                {group.items.map(item => (
                  <SidebarItem 
                    key={item.id} 
                    icon={item.icon} 
                    label={item.label} 
                    isActive={page === item.id} 
                    onClick={() => { setPage(item.id); setMobNav(false); }} 
                  />
                ))}
              </div>
            </div>
          ))}
        </nav>
        
        <div className="p-4 border-t border-border-default shrink-0">
          <div className="flex items-center gap-3">
            <div className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-status-success opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-status-success"></span>
            </div>
            <div>
              <p className="text-[12px] font-medium text-base-text">System Online</p>
              <p className="text-[11px] text-muted">PostgreSQL Connected</p>
            </div>
          </div>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 bg-base-bg">
        <TopBar title={getPageTitle()} mobileNavToggle={() => setMobNav(true)} isDark={isDark} toggleDark={() => setIsDark(!isDark)} />
        
        <main className="flex-1 overflow-y-auto p-6 md:p-8">
          <div className="max-w-[1280px] mx-auto fade-in">
            {page === 'dashboard' && <Dashboard />}
            {page === 'tables' && <BrowseTables />}
            {page === 'register' && <RegisterPlayer toast={showToast} />}
            {page === 'schedule' && <ScheduleMatch toast={showToast} />}
            {page === 'winner' && <SetWinner toast={showToast} />}
            {page === 'scoreboard' && <Scoreboard />}
            {page === 'analytics' && <Analytics />}
          </div>
        </main>
      </div>

      {toast && <Toast title={toast.title} msg={toast.msg} type={toast.type} onClose={() => setToast(null)} />}
    </div>
  );
};

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
/* {% endraw %} */