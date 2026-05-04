/* {% raw %} */
// --- Core UI Components ---

const Badge = ({ children, variant = 'gray' }) => {
  const variants = {
    gray: 'bg-slate-100 dark:bg-slate-800/50 text-slate-600 dark:text-slate-300',
    blue: 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400',
    green: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    amber: 'bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400',
    red: 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400'
  };
  return (
    <span className={`inline-flex items-center px-2 py-0.5 rounded-sm text-[11px] font-medium uppercase tracking-wider ${variants[variant] || variants.gray}`}>
      {children}
    </span>
  );
};

const Button = ({ children, variant = 'primary', size = 'default', icon, className = '', disabled, onClick, type = 'button' }) => {
  const baseStyle = "inline-flex items-center justify-center font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-accent-blue rounded-md";
  
  const sizes = {
    compact: "h-8 px-3 text-[13px]",
    default: "h-9 px-4 text-[14px]",
    prominent: "h-10 px-5 text-[14px]"
  };
  
  const variants = {
    primary: "bg-accent-blue text-white hover:bg-blue-700",
    secondary: "bg-base-surface text-base-text border border-border-default hover:bg-slate-50 dark:bg-slate-800",
    destructive: "bg-status-danger text-white hover:bg-red-700",
    ghost: "bg-transparent text-muted hover:text-base-text hover:bg-slate-100 dark:bg-slate-800/50"
  };

  const disabledStyle = disabled ? "opacity-50 cursor-not-allowed pointer-events-none" : "";

  return (
    <button 
      type={type} 
      onClick={onClick} 
      disabled={disabled}
      className={`${baseStyle} ${sizes[size]} ${variants[variant]} ${disabledStyle} ${className}`}
    >
      {icon && <span className="mr-2">{icon}</span>}
      {children}
    </button>
  );
};

const Input = ({ label, type = 'text', value, onChange, placeholder, required, error, helperText }) => (
  <div className="mb-4">
    {label && <label className="block text-[13px] font-medium text-base-text mb-1.5">{label} {required && <span className="text-status-danger">*</span>}</label>}
    <input 
      type={type} 
      value={value} 
      onChange={e => onChange(e.target.value)} 
      placeholder={placeholder} 
      required={required}
      className={`w-full h-9 bg-base-surface border rounded-sm px-3 text-[14px] text-base-text placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-accent-blue focus:border-transparent transition-shadow ${
        error ? 'border-status-danger focus:ring-status-danger' : 'border-border-default'
      }`}
    />
    {error && <p className="mt-1 text-[12px] text-status-danger" role="alert">{error}</p>}
    {!error && helperText && <p className="mt-1 text-[12px] text-muted">{helperText}</p>}
  </div>
);

const Select = ({ label, value, onChange, options, vk, lk, required, error, helperText }) => (
  <div className="mb-4">
    {label && <label className="block text-[13px] font-medium text-base-text mb-1.5">{label} {required && <span className="text-status-danger">*</span>}</label>}
    <select 
      value={value} 
      onChange={e => onChange(e.target.value)} 
      required={required}
      className={`w-full h-9 bg-base-surface border rounded-sm px-3 text-[14px] text-base-text focus:outline-none focus:ring-2 focus:ring-accent-blue focus:border-transparent transition-shadow appearance-none cursor-pointer ${
        error ? 'border-status-danger focus:ring-status-danger' : 'border-border-default'
      }`}
      style={{ backgroundImage: 'url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' fill=\'none\' viewBox=\'0 0 20 20\'%3E%3Cpath stroke=\'%2364748b\' stroke-linecap=\'round\' stroke-linejoin=\'round\' stroke-width=\'1.5\' d=\'M6 8l4 4 4-4\'/%3E%3C/svg%3E")', backgroundPosition: 'right 0.5rem center', backgroundRepeat: 'no-repeat', backgroundSize: '1.2em 1.2em', paddingRight: '2.5rem' }}
    >
      <option value="" disabled>Select {label}...</option>
      {options.map(o => <option key={o[vk]} value={o[vk]}>{o[lk]}</option>)}
    </select>
    {error && <p className="mt-1 text-[12px] text-status-danger" role="alert">{error}</p>}
    {!error && helperText && <p className="mt-1 text-[12px] text-muted">{helperText}</p>}
  </div>
);

const Card = ({ children, className = '' }) => (
  <div className={`bg-base-surface rounded-md border border-border-default shadow-card ${className}`}>
    {children}
  </div>
);

const EmptyState = ({ icon, title, description, action }) => (
  <div className="flex flex-col items-center justify-center text-center p-8 max-w-[320px] mx-auto fade-in">
    <div className="text-muted opacity-50 mb-4">{icon || <Icons.Info />}</div>
    <h3 className="text-[16px] font-medium text-base-text mb-1">{title || 'No data found'}</h3>
    <p className="text-[14px] text-muted mb-6">{description}</p>
    {action}
  </div>
);

const SkeletonLoader = ({ type = 'table', rows = 5 }) => {
  if (type === 'card') {
    return (
      <Card className="p-5 h-[120px] flex flex-col justify-between">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full skeleton-shimmer"></div>
          <div className="w-24 h-4 rounded-sm skeleton-shimmer"></div>
        </div>
        <div className="w-16 h-8 rounded-sm skeleton-shimmer mt-auto"></div>
      </Card>
    );
  }
  
  return (
    <Card className="overflow-hidden">
      <div className="h-[44px] bg-slate-50 dark:bg-slate-800 border-b border-border-default skeleton-shimmer"></div>
      {Array.from({length: rows}).map((_, i) => (
        <div key={i} className="h-[44px] border-b border-border-default border-opacity-50 flex items-center px-4 gap-4">
          <div className="w-1/4 h-4 rounded-sm skeleton-shimmer"></div>
          <div className="w-1/4 h-4 rounded-sm skeleton-shimmer"></div>
          <div className="w-1/4 h-4 rounded-sm skeleton-shimmer"></div>
          <div className="w-1/4 h-4 rounded-sm skeleton-shimmer"></div>
        </div>
      ))}
    </Card>
  );
};

const Table = ({ cols, rows, emptyProps, onSort, sortKey, sortDir }) => {
  if (!rows) return <SkeletonLoader />;
  if (rows.length === 0) return <Card><EmptyState {...emptyProps} /></Card>;
  
  const keys = cols || Object.keys(rows[0]);
  
  return (
    <Card className="overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full text-left text-[14px]">
          <thead className="bg-slate-50 dark:bg-slate-800 border-b border-border-default">
            <tr>
              {keys.map(k => {
                const isSorted = sortKey === k;
                return (
                  <th 
                    key={k} 
                    onClick={() => onSort && onSort(k)}
                    className={`px-4 py-3 text-[12px] font-medium uppercase tracking-wider text-muted ${onSort ? 'cursor-pointer select-none hover:text-base-text transition-colors' : ''} ${isSorted ? 'bg-blue-50 dark:bg-blue-900/20 text-accent-blue' : ''}`}
                    aria-sort={isSorted ? (sortDir === 'asc' ? 'ascending' : 'descending') : 'none'}
                  >
                    <div className="flex items-center gap-1">
                      {k.replace(/_/g, ' ')}
                      {isSorted && (sortDir === 'asc' ? <Icons.ChevronUp /> : <Icons.ChevronDown />)}
                    </div>
                  </th>
                )
              })}
            </tr>
          </thead>
          <tbody className="divide-y divide-border-default">
            {rows.map((r, i) => (
              <tr key={i} className="min-h-[44px] hover:bg-slate-50 dark:bg-slate-800 transition-colors">
                {keys.map(k => (
                  <td key={k} className="px-4 py-3 text-base-text">
                    {r[k]}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Card>
  );
};

const Toast = ({ msg, title, type = 'success', onClose }) => {
  useEffect(() => {
    const t = setTimeout(onClose, 4000);
    return () => clearTimeout(t);
  }, [onClose]);
  
  const types = {
    success: { icon: <Icons.CheckCircle className="text-status-success w-5 h-5" />, border: 'border-l-4 border-status-success' },
    error: { icon: <Icons.XCircle className="text-status-danger w-5 h-5" />, border: 'border-l-4 border-status-danger' },
    warning: { icon: <Icons.Warning className="text-status-warning w-5 h-5" />, border: 'border-l-4 border-status-warning' },
    info: { icon: <Icons.Info className="text-status-info w-5 h-5" />, border: 'border-l-4 border-status-info' }
  };
  
  const style = types[type] || types.info;

  return (
    <div className={`fixed bottom-6 right-6 z-50 flex items-start gap-3 p-4 bg-base-surface shadow-lg border border-border-default rounded-md w-[320px] slide-up ${style.border}`}>
      <div className="shrink-0 mt-0.5">{style.icon}</div>
      <div className="flex-1 min-w-0">
        <p className="text-[13px] font-medium text-base-text">{title || (type.charAt(0).toUpperCase() + type.slice(1))}</p>
        <p className="text-[13px] text-muted mt-0.5 truncate whitespace-normal leading-snug">{msg}</p>
      </div>
      <button onClick={onClose} className="shrink-0 text-muted hover:text-base-text">
        <Icons.Close />
      </button>
    </div>
  );
};

const PageHeader = ({ title, actions }) => (
  <div className="flex items-center justify-between mb-6">
    <h1 className="text-[24px] font-semibold tracking-tight text-base-text">{title}</h1>
    {actions && <div className="flex items-center gap-3">{actions}</div>}
  </div>
);

// Helpers
const resolveIdToName = (id, metaArray, idKey, nameKey) => {
  if (!metaArray || !id) return id;
  const found = metaArray.find(item => item[idKey] == id);
  return found ? found[nameKey] : id;
};

/* {% endraw %} */