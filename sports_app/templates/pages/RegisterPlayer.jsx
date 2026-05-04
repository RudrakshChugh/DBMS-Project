/* {% raw %} */
const RegisterPlayer = ({ toast }) => {
  const [meta, setMeta] = useState(null);
  const [busy, setBusy] = useState(false);
  const [f, setF] = useState({
    first_name: '', last_name: '', email: '', phone: '', 
    gender: 'Male', dob: '', team_id: '', jersey_no: '', position: ''
  });
  const [errors, setErrors] = useState({});
  const [success, setSuccess] = useState(false);
  
  useEffect(() => { F(`${API}/meta`).then(setMeta); }, []);
  
  const set = (k, v) => {
    setF(p => ({ ...p, [k]: v }));
    if (errors[k]) setErrors(p => ({ ...p, [k]: null }));
    setSuccess(false);
  };
  
  const validate = () => {
    const e = {};
    if (!f.first_name) e.first_name = "First name is required";
    if (!f.last_name) e.last_name = "Last name is required";
    if (!f.email || !/^\S+@\S+\.\S+$/.test(f.email)) e.email = "Valid email is required";
    if (!f.phone) e.phone = "Phone number is required";
    if (!f.dob) e.dob = "Date of birth is required";
    if (!f.team_id) e.team_id = "Team assignment is required";
    if (!f.jersey_no) e.jersey_no = "Jersey number is required";
    if (!f.position) e.position = "Position is required";
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const submit = async (e) => {
    e.preventDefault();
    if (!validate()) return;
    
    setBusy(true);
    const r = await P(`${API}/register_player`, f);
    setBusy(false);
    
    if (r.error) {
      toast(r.error, 'error', 'Registration Failed');
    } else {
      setSuccess(true);
      toast(r.message, 'success', 'Player Registered');
      setF({
        first_name: '', last_name: '', email: '', phone: '', 
        gender: 'Male', dob: '', team_id: '', jersey_no: '', position: ''
      });
    }
  };
  
  return (
    <div className="max-w-4xl fade-in">
      <PageHeader title="Register New Player" />
      
      <form onSubmit={submit}>
        <div className="flex flex-col lg:flex-row gap-8">
          
          {/* Column 1: Personal Info */}
          <div className="flex-1">
            <div className="mb-6 pb-2 border-b border-border-default">
              <h3 className="text-[12px] font-semibold text-muted uppercase tracking-wider">Personal Information</h3>
            </div>
            
            <div className="grid grid-cols-2 gap-4">
              <Input label="First Name" value={f.first_name} onChange={v => set('first_name', v)} error={errors.first_name} required />
              <Input label="Last Name" value={f.last_name} onChange={v => set('last_name', v)} error={errors.last_name} required />
            </div>
            
            <Input label="Email Address" type="email" value={f.email} onChange={v => set('email', v)} error={errors.email} required />
            <Input label="Phone Number" value={f.phone} onChange={v => set('phone', v)} error={errors.phone} required />
            
            <div className="grid grid-cols-2 gap-4">
              <Input label="Date of Birth" type="date" value={f.dob} onChange={v => set('dob', v)} error={errors.dob} required />
              <Select label="Gender" value={f.gender} onChange={v => set('gender', v)} options={[
                { id: 'Male', name: 'Male' }, { id: 'Female', name: 'Female' }, { id: 'Other', name: 'Other' }
              ]} vk="id" lk="name" />
            </div>
          </div>
          
          {/* Column 2: Team Assignment */}
          <div className="flex-1">
            <div className="mb-6 pb-2 border-b border-border-default">
              <h3 className="text-[12px] font-semibold text-muted uppercase tracking-wider">Team Assignment</h3>
            </div>
            
            <Input label="Playing Position" value={f.position} onChange={v => set('position', v)} error={errors.position} placeholder="e.g. Forward, Defender" required />
            <Input label="Jersey Number" type="number" value={f.jersey_no} onChange={v => set('jersey_no', v)} error={errors.jersey_no} required />
            
            {meta ? (
              <Select label="Assign to Team" value={f.team_id} onChange={v => set('team_id', v)} options={meta.teams} vk="teamid" lk="teamname" error={errors.team_id} required />
            ) : (
              <div className="mb-4">
                <label className="block text-[13px] font-medium text-base-text mb-1.5">Assign to Team</label>
                <div className="h-9 w-full rounded-sm skeleton-shimmer"></div>
              </div>
            )}

            <div className="mt-8 pt-6 border-t border-border-default flex items-center justify-between">
              <div>
                {success && (
                  <span className="flex items-center gap-2 text-status-success text-[13px] font-medium fade-in">
                    <Icons.CheckCircle /> Registration successful
                  </span>
                )}
              </div>
              <Button type="submit" variant="primary" disabled={busy || !meta} icon={busy ? <Icons.Refresh /> : null} className={busy ? 'animate-pulse' : ''}>
                {busy ? 'Registering...' : 'Complete Registration'}
              </Button>
            </div>
          </div>

        </div>
      </form>
    </div>
  );
};
/* {% endraw %} */