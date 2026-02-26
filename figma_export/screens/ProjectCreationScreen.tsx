import { useMemo, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router';
import { ChevronLeft, Search, Link2 } from 'lucide-react';
import { motion } from 'motion/react';
import { JobPhase, JobStatus } from '../types';
import { useLeads } from '../state/LeadsContext';

const phaseOptions: { value: JobPhase; label: string }[] = [
  { value: 'demo', label: 'Demo' },
  { value: 'rough', label: 'Rough' },
  { value: 'electrical-plumbing', label: 'Electrical/Plumbing' },
  { value: 'finishing', label: 'Finishing' },
  { value: 'walkthrough', label: 'Walkthrough' },
  { value: 'complete', label: 'Complete' },
];

const statusOptions: { value: JobStatus; label: string }[] = [
  { value: 'on-track', label: 'On Track' },
  { value: 'needs-attention', label: 'Needs Attention' },
  { value: 'behind', label: 'Behind Schedule' },
];

export function ProjectCreationScreen() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const { leads, createJob } = useLeads();

  const preselectedLeadId = searchParams.get('leadId');
  const prefillName = searchParams.get('name') ?? '';
  const prefillPhone = searchParams.get('phone') ?? '';
  const prefillJobType = searchParams.get('jobType') ?? '';
  const preselectedLead = leads.find((lead) => lead.id === preselectedLeadId);

  const [linkedLeadId, setLinkedLeadId] = useState<string | null>(preselectedLead?.id ?? null);
  const [leadSearch, setLeadSearch] = useState(preselectedLead?.name ?? '');
  const [showLeadSearchResults, setShowLeadSearchResults] = useState(false);

  const [clientName, setClientName] = useState(preselectedLead?.name ?? prefillName);
  const [phone, setPhone] = useState(preselectedLead?.phone ?? prefillPhone);
  const [jobType, setJobType] = useState(preselectedLead?.jobType ?? prefillJobType);
  const [estimatedCompletion, setEstimatedCompletion] = useState('');
  const [currentPhase, setCurrentPhase] = useState<JobPhase>('demo');
  const [status, setStatus] = useState<JobStatus>('on-track');

  const matchingLeads = useMemo(() => {
    const trimmedQuery = leadSearch.trim().toLowerCase();
    if (!trimmedQuery) return leads.slice(0, 5);
    return leads
      .filter((lead) => lead.name.toLowerCase().includes(trimmedQuery))
      .slice(0, 5);
  }, [leadSearch, leads]);

  const canSave =
    clientName.trim() &&
    phone.trim() &&
    jobType.trim() &&
    estimatedCompletion;

  const handleLinkLead = (leadId: string) => {
    const selectedLead = leads.find((lead) => lead.id === leadId);
    if (!selectedLead) return;
    // Linking a lead should instantly pre-fill known details to minimize typing.
    setLinkedLeadId(selectedLead.id);
    setLeadSearch(selectedLead.name);
    setClientName(selectedLead.name);
    setPhone(selectedLead.phone);
    setJobType(selectedLead.jobType);
    setShowLeadSearchResults(false);
  };

  const handleSaveProject = () => {
    if (!canSave) return;
    createJob({
      clientName: clientName.trim(),
      phone: phone.trim(),
      jobType: jobType.trim(),
      estimatedCompletion: new Date(`${estimatedCompletion}T12:00:00`),
      currentPhase,
      status,
      leadId: linkedLeadId ?? undefined,
    });
    navigate('/jobs');
  };

  return (
    <div className="min-h-screen bg-background px-5 pt-14 pb-10">
      <div className="max-w-[600px] mx-auto">
        <button
          onClick={() => navigate(-1)}
          className="mb-6 text-system-blue active:opacity-70 flex items-center gap-0.5 -ml-1"
        >
          <ChevronLeft className="w-5 h-5" />
          <span className="text-[17px]">Back</span>
        </button>

        <motion.h1
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-[34px] font-bold mb-2 text-foreground tracking-tight"
        >
          New Project
        </motion.h1>
        <p className="text-[15px] text-muted-foreground mb-6">
          Create a job and start tracking progress.
        </p>

        {/* Existing leads can be linked so repeat customers can be set up quickly. */}
        <div className="mb-6">
          <label className="block text-[11px] text-muted-foreground mb-2 uppercase tracking-wider">
            Link to Existing Lead (optional)
          </label>
          <div className="relative">
            <Search className="w-4 h-4 text-muted-foreground absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              value={leadSearch}
              onFocus={() => setShowLeadSearchResults(true)}
              onChange={(e) => {
                setLeadSearch(e.target.value);
                setShowLeadSearchResults(true);
                // Typing after a prior link means the user is searching again.
                setLinkedLeadId(null);
              }}
              placeholder="Search lead by name"
              className="w-full pl-9 pr-3 py-3.5 glass-elevated rounded-2xl text-[16px] text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-system-blue/50"
            />
          </div>
          {showLeadSearchResults && matchingLeads.length > 0 && (
            <div className="mt-2 glass-elevated rounded-2xl overflow-hidden divide-y divide-white/[0.04]">
              {matchingLeads.map((lead) => (
                <button
                  key={lead.id}
                  onClick={() => handleLinkLead(lead.id)}
                  className="w-full px-3.5 py-3 text-left active:bg-white/[0.03]"
                >
                  <div className="flex items-center gap-2">
                    <Link2 className="w-3.5 h-3.5 text-system-blue" />
                    <span className="text-[15px] text-foreground font-medium">{lead.name}</span>
                  </div>
                  <p className="mt-0.5 text-[13px] text-muted-foreground">
                    {lead.phone} · {lead.jobType}
                  </p>
                </button>
              ))}
            </div>
          )}
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
              Client Name
            </label>
            <input
              value={clientName}
              onChange={(e) => setClientName(e.target.value)}
              placeholder="Client name"
              className="w-full text-[17px] p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground"
            />
          </div>

          <div>
            <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
              Phone
            </label>
            <input
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="Phone number"
              className="w-full text-[17px] p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground"
            />
          </div>

          <div>
            <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
              Job Type
            </label>
            <input
              value={jobType}
              onChange={(e) => setJobType(e.target.value)}
              placeholder="Deck, kitchen, bathroom..."
              className="w-full text-[17px] p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground"
            />
          </div>

          <div>
            <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
              Estimated Completion
            </label>
            <input
              type="date"
              value={estimatedCompletion}
              onChange={(e) => setEstimatedCompletion(e.target.value)}
              className="w-full text-[17px] p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground"
            />
          </div>

          <div>
            <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
              Starting Phase
            </label>
            <select
              value={currentPhase}
              onChange={(e) => setCurrentPhase(e.target.value as JobPhase)}
              className="w-full text-[17px] p-4 glass-elevated rounded-2xl appearance-none focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground bg-transparent"
            >
              {phaseOptions.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
              Status
            </label>
            <select
              value={status}
              onChange={(e) => setStatus(e.target.value as JobStatus)}
              className="w-full text-[17px] p-4 glass-elevated rounded-2xl appearance-none focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground bg-transparent"
            >
              {statusOptions.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>
        </div>

        <motion.button
          whileTap={{ scale: 0.97 }}
          onClick={handleSaveProject}
          disabled={!canSave}
          className="mt-7 w-full bg-system-blue text-white py-4 rounded-2xl text-[17px] font-semibold disabled:opacity-40"
        >
          Save Project
        </motion.button>
      </div>
    </div>
  );
}
