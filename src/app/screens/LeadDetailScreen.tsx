import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import {
  ChevronLeft,
  Phone,
  MessageSquare,
  ChevronDown,
  ChevronUp,
  Pause,
  Plus,
  Briefcase,
  CheckCircle2,
  XCircle,
  Trash2,
  StopCircle,
} from 'lucide-react';
import { LeadStatus, PreviousProject } from '../types';
import { motion, AnimatePresence } from 'motion/react';
import { format } from 'date-fns';
import { useLeads } from '../state/LeadsContext';
import { EstimateSentConfirmDialog } from '../components/EstimateSentConfirmDialog';
import { ActionConfirmDialog } from '../components/ActionConfirmDialog';

const statusOptions: { value: LeadStatus; label: string }[] = [
  { value: 'call-back-now', label: 'New / Call Back' },
  { value: 'won', label: 'Won' },
  { value: 'cold', label: 'Cold' },
];

function ProjectRow({ project }: { project: PreviousProject }) {
  const [isExpanded, setIsExpanded] = useState(false);
  const isCompleted = project.status === 'completed';

  return (
    <div className="py-3">
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full flex items-start gap-3 text-left active:opacity-70 transition-opacity"
      >
        <div className="mt-0.5 flex-shrink-0">
          {isCompleted ? (
            <CheckCircle2 className="w-4 h-4 text-system-green" />
          ) : (
            <XCircle className="w-4 h-4 text-muted-foreground" />
          )}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between gap-2">
            <span className="text-[15px] font-medium text-foreground">{project.jobType}</span>
            <div className="flex items-center gap-2">
              <span
                className={`text-[11px] font-semibold px-2 py-0.5 rounded-full flex-shrink-0 ${isCompleted
                  ? 'bg-system-green/15 text-system-green'
                  : 'bg-muted-foreground/15 text-muted-foreground'
                  }`}
              >
                {isCompleted ? 'Completed' : 'Cancelled'}
              </span>
              {isExpanded ? (
                <ChevronUp className="w-4 h-4 text-muted-foreground" />
              ) : (
                <ChevronDown className="w-4 h-4 text-muted-foreground" />
              )}
            </div>
          </div>
          {isExpanded ? (
            <div className="mt-2 text-[13px] text-muted-foreground space-y-1">
              {project.startedAt && (
                <p>Started: {format(project.startedAt, 'MMM d, yyyy')}</p>
              )}
              <p>Completed: {format(project.completedAt, 'MMM d, yyyy')}</p>
              {project.notes && (
                <p className="mt-2 text-foreground/80 leading-snug">{project.notes}</p>
              )}
            </div>
          ) : (
            <>
              <p className="text-[13px] text-muted-foreground mt-0.5">
                {format(project.completedAt, 'MMM d, yyyy')}
              </p>
              {project.notes && (
                <p className="text-[13px] text-muted-foreground/70 mt-1 leading-snug line-clamp-2">
                  {project.notes}
                </p>
              )}
            </>
          )}
        </div>
      </button>
      <AnimatePresence>
        {isExpanded && project.photos && project.photos.length > 0 && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="mt-3 pl-7 overflow-hidden"
          >
            <div className="flex gap-2 overflow-x-auto pb-2 snap-x hide-scrollbar">
              {project.photos.map((photo, i) => (
                <img
                  key={i}
                  src={photo}
                  alt={`Project preview ${i + 1}`}
                  className="h-24 w-24 object-cover rounded-xl flex-shrink-0 snap-center border border-white/10"
                />
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

export function LeadDetailScreen() {
  const navigate = useNavigate();
  const { id } = useParams();
  const {
    leads,
    updateLeadStatus,
    markEstimateSent,
    markLeadWon,
    pauseFollowUps,
    stopFollowUps,
    deleteLead,
    markLeadCold,
  } = useLeads();
  const lead = leads.find((l) => l.id === id);

  const [isEditing, setIsEditing] = useState(false);
  const [name, setName] = useState(lead?.name || '');
  const [phone, setPhone] = useState(lead?.phone || '');
  const [showDetails, setShowDetails] = useState(false);
  const [notes, setNotes] = useState(lead?.notes || '');
  const [email, setEmail] = useState(lead?.email || '');
  const [address, setAddress] = useState(lead?.address || '');
  const [showEstimateConfirm, setShowEstimateConfirm] = useState(false);
  const [showWonCelebration, setShowWonCelebration] = useState(false);
  const [showPauseConfirm, setShowPauseConfirm] = useState(false);
  const [showStopConfirm, setShowStopConfirm] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [showColdConfirm, setShowColdConfirm] = useState(false);

  if (!lead)
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <p className="text-muted-foreground">Lead not found</p>
      </div>
    );

  const handleCallNow = () => {
    window.location.href = `tel:${phone}`;
  };
  const handleSendText = () => {
    window.location.href = `sms:${phone}`;
  };
  const handleNewProject = () => {
    navigate(`/projects/new?leadId=${encodeURIComponent(lead.id)}`);
  };
  const handleStatusChange = (nextStatus: LeadStatus) => {
    if (nextStatus === 'cold') {
      setShowColdConfirm(true);
      return;
    }
    if (nextStatus === 'won') {
      // Route through markLeadWon so follow-ups are stopped and celebration triggers.
      handleMarkAsWon();
      return;
    }
    updateLeadStatus(lead.id, nextStatus);
  };
  const handleEstimateSentConfirm = () => {
    markEstimateSent(lead.id);
  };
  const handleMarkAsWon = () => {
    markLeadWon(lead.id);
    setShowWonCelebration(true);
  };
  const handleSetupProjectNow = () => {
    setShowWonCelebration(false);
    navigate(`/projects/new?leadId=${encodeURIComponent(lead.id)}`);
  };
  const handleSetupProjectLater = () => {
    setShowWonCelebration(false);
    navigate('/leads');
  };
  const handlePauseFollowUps = () => {
    pauseFollowUps(lead.id);
  };
  const handleStopFollowUps = () => {
    stopFollowUps(lead.id);
  };
  const handleDeleteLead = () => {
    deleteLead(lead.id);
    navigate('/leads');
  };
  const handleConfirmMarkCold = () => {
    markLeadCold(lead.id);
  };

  const previousProjects = lead.previousProjects ?? [];
  const isCallBackLead = lead.status === 'call-back-now';
  const isEstimateSentLead = lead.status === 'estimate-sent';
  const filteredStatusOptions = isCallBackLead
    ? statusOptions.filter((option) => option.value !== 'won')
    : statusOptions;

  return (
    <div className="min-h-screen bg-background pb-28">
      <div className="max-w-[600px] mx-auto">
        {/* ── Sticky Header ── */}
        <div className="sticky top-0 bg-background/70 backdrop-blur-2xl px-5 pt-14 pb-3 z-10">
          <div className="flex items-start justify-between">
            <button
              onClick={() => navigate('/leads')}
              className="mb-3 text-system-blue active:opacity-70 flex items-center gap-0.5 -ml-1"
            >
              <ChevronLeft className="w-5 h-5" />
              <span className="text-[17px]">Leads</span>
            </button>
            <button
              onClick={() => setIsEditing((v) => !v)}
              className="text-system-blue text-[17px] font-medium active:opacity-70 mt-0.5"
            >
              {isEditing ? 'Done' : 'Edit'}
            </button>
          </div>

          {isEditing ? (
            <input
              value={name}
              onChange={(e) => {
                setName(e.target.value);

              }}
              className="text-[34px] font-bold text-foreground tracking-tight bg-transparent w-full focus:outline-none border-b border-system-blue/50 pb-0.5"
              autoFocus
            />
          ) : (
            <motion.h1
              key="name-display"
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-[34px] font-bold text-foreground tracking-tight"
            >
              {name}
            </motion.h1>
          )}

        </div>

        <div className="px-5 space-y-4 pt-2">
          {/* ── Phone ── */}
          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.05 }}
            className="glass-elevated rounded-2xl overflow-hidden"
          >
            {isEditing ? (
              <div className="flex items-center gap-3 p-4">
                <Phone className="w-5 h-5 text-system-blue flex-shrink-0" />
                <input
                  value={phone}
                  onChange={(e) => {
                    setPhone(e.target.value);

                  }}
                  type="tel"
                  placeholder="Phone number"
                  className="flex-1 bg-transparent text-[17px] text-foreground focus:outline-none placeholder:text-muted-foreground"
                />

              </div>
            ) : (
              <button
                onClick={handleCallNow}
                className="w-full flex items-center gap-3 p-4 active:bg-white/[0.02] transition-colors"
              >
                <Phone className="w-5 h-5 text-system-blue" />
                <span className="text-[17px] text-foreground">{phone}</span>
              </button>
            )}
          </motion.div>

          {/* ── Previous Projects ── */}
          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="glass-elevated rounded-2xl overflow-hidden"
          >
            <div className="px-4 pt-4 pb-1 flex items-center gap-2">
              <Briefcase className="w-4 h-4 text-muted-foreground" />
              <span className="text-[11px] text-muted-foreground uppercase tracking-wider font-medium">
                Previous Projects
              </span>
              {previousProjects.length > 0 && (
                <span className="ml-auto text-[11px] font-semibold text-muted-foreground">
                  {previousProjects.length}
                </span>
              )}
            </div>

            {previousProjects.length === 0 ? (
              <div className="px-4 pb-6 pt-4 text-center">
                <div className="w-12 h-12 rounded-full bg-white/[0.03] flex items-center justify-center mx-auto mb-3">
                  <Briefcase className="w-6 h-6 text-muted-foreground/50" />
                </div>
                <h3 className="text-[15px] font-semibold text-foreground mb-1">No Project History</h3>
                <p className="text-[13px] text-muted-foreground leading-relaxed max-w-[200px] mx-auto">
                  When you complete jobs for this lead, they'll show up here.
                </p>
              </div>
            ) : (
              <div className="px-4 pb-2 divide-y divide-white/[0.04]">
                {previousProjects.map((project) => (
                  <ProjectRow key={project.id} project={project} />
                ))}
              </div>
            )}
          </motion.div>

          {/* ── New Project CTA ── */}
          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.15 }}
          >
            <motion.button
              whileTap={{ scale: 0.97 }}
              onClick={handleNewProject}
              className="w-full py-4 rounded-2xl text-[17px] font-semibold flex items-center justify-center gap-2 text-white"
              style={{
                background: 'linear-gradient(135deg, #0A84FF 0%, #34C759 100%)',
              }}
            >
              <Plus className="w-5 h-5" />
              New Project
            </motion.button>
          </motion.div>

          {/* ── Job Type + Status ── */}
          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="glass-elevated rounded-2xl overflow-hidden divide-y divide-white/[0.04]"
          >
            <div className="p-4">
              <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
                Job Type
              </label>
              <span className="text-[17px] text-foreground">{lead.jobType}</span>
            </div>
            <div className="p-4">
              <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
                Status
              </label>
              {lead.status === 'estimate-sent' ? (
                // Estimate Sent is intentionally removed from the manual status dropdown.
                <span className="text-[17px] text-system-orange font-medium">Estimate Sent</span>
              ) : (
                <select
                  value={lead.status}
                  onChange={(e) => handleStatusChange(e.target.value as LeadStatus)}
                  className="w-full bg-transparent text-[17px] text-foreground appearance-none focus:outline-none cursor-pointer"
                >
                  {filteredStatusOptions.map((o) => (
                    <option key={o.value} value={o.value}>
                      {o.label}
                    </option>
                  ))}
                </select>
              )}
            </div>
          </motion.div>

          {/* ── Follow-up ── */}
          {lead.followUpSequence?.active && (
            <motion.div
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.25 }}
              className="glass-elevated rounded-2xl p-4"
            >
              <div className="flex items-center justify-between mb-3">
                <h3 className="font-semibold text-[15px] text-system-blue">Follow-up Active</h3>
                <div className="flex items-center gap-3">
                  <button
                    onClick={() => setShowPauseConfirm(true)}
                    className="text-system-blue text-[13px] font-medium flex items-center gap-1"
                  >
                    <Pause className="w-3.5 h-3.5" />
                    Pause
                  </button>
                  <button
                    onClick={() => setShowStopConfirm(true)}
                    className="text-system-red text-[13px] font-medium flex items-center gap-1"
                  >
                    <StopCircle className="w-3.5 h-3.5" />
                    Stop
                  </button>
                </div>
              </div>
              <div className="space-y-2 text-[15px]">
                {[
                  { label: 'Day 2', sent: lead.followUpSequence.day2Sent },
                  { label: 'Day 5', sent: lead.followUpSequence.day5Sent },
                  { label: 'Day 10', sent: lead.followUpSequence.day10Sent },
                ].map((d) => (
                  <div
                    key={d.label}
                    className={`flex items-center gap-2 ${d.sent ? 'text-system-green' : 'text-muted-foreground'
                      }`}
                  >
                    <span className="font-medium">{d.label}:</span>
                    <span>{d.sent ? '✓ Sent' : '⏳ Scheduled'}</span>
                  </div>
                ))}
              </div>
            </motion.div>
          )}

          {/* ── Details Accordion ── */}
          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
          >
            <button
              onClick={() => setShowDetails(!showDetails)}
              className="w-full flex items-center justify-between p-4 glass-elevated rounded-2xl"
            >
              <span className="font-medium text-[17px] text-foreground">Details</span>
              {showDetails ? (
                <ChevronUp className="w-5 h-5 text-muted-foreground" />
              ) : (
                <ChevronDown className="w-5 h-5 text-muted-foreground" />
              )}
            </button>

            <AnimatePresence>
              {showDetails && (
                <motion.div
                  key="details"
                  initial={{ opacity: 0, height: 0 }}
                  animate={{ opacity: 1, height: 'auto' }}
                  exit={{ opacity: 0, height: 0 }}
                  className="mt-3 space-y-3 overflow-hidden"
                >
                  {[
                    {
                      label: 'Email',
                      val: email,
                      set: setEmail,
                      type: 'email',
                      ph: 'Email (optional)',
                    },
                    {
                      label: 'Address',
                      val: address,
                      set: setAddress,
                      type: 'text',
                      ph: 'Address (optional)',
                    },
                  ].map((f) => (
                    <div key={f.label}>
                      <div className="mb-1 flex items-center justify-between">
                        <label className="block text-[11px] text-muted-foreground uppercase tracking-wider">
                          {f.label}
                        </label>
                      </div>
                      <input
                        type={f.type}
                        value={f.val}
                        onChange={(e) => {
                          f.set(e.target.value);
                        }}
                        placeholder={f.ph}
                        className="w-full p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground text-[17px]"
                      />
                    </div>
                  ))}
                  <div>
                    <div className="mb-1 flex items-center justify-between">
                      <label className="block text-[11px] text-muted-foreground uppercase tracking-wider">
                        Notes
                      </label>
                    </div>
                    <textarea
                      value={notes}
                      onChange={(e) => {
                        setNotes(e.target.value);
                      }}
                      placeholder="Add notes..."
                      rows={3}
                      className="w-full p-4 glass-elevated rounded-2xl resize-none focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground text-[17px]"
                    />
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </motion.div>

          {/* ── Bottom Actions ── */}
          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.35 }}
            className="space-y-3 pt-2"
          >
            <motion.button
              whileTap={{ scale: 0.97 }}
              onClick={handleCallNow}
              className="w-full bg-system-blue text-white py-4 rounded-2xl text-[17px] font-semibold flex items-center justify-center gap-2"
            >
              <Phone className="w-5 h-5" />
              Call Now
            </motion.button>
            <motion.button
              whileTap={{ scale: 0.97 }}
              onClick={handleSendText}
              className="w-full glass-prominent text-foreground py-4 rounded-2xl text-[17px] font-semibold flex items-center justify-center gap-2"
            >
              <MessageSquare className="w-5 h-5" />
              Send Text
            </motion.button>

            {isCallBackLead && (
              // Callback leads use this dedicated action to start the paid automation workflow.
              <motion.button
                whileTap={{ scale: 0.97 }}
                onClick={() => setShowEstimateConfirm(true)}
                className="w-full bg-system-yellow text-black py-4 rounded-2xl text-[17px] font-semibold"
              >
                Estimate Sent?
              </motion.button>
            )}

            {isEstimateSentLead && (
              // Only estimate-sent leads can be converted to won jobs.
              <motion.button
                whileTap={{ scale: 0.97 }}
                onClick={handleMarkAsWon}
                className="w-full bg-system-green text-white py-4 rounded-2xl text-[17px] font-semibold"
              >
                Mark as Won
              </motion.button>
            )}

            <button
              onClick={() => setShowDeleteConfirm(true)}
              className="w-full text-system-red py-3 rounded-2xl text-[15px] font-medium border border-system-red/30 active:opacity-70"
            >
              <span className="inline-flex items-center justify-center gap-1.5">
                <Trash2 className="w-4 h-4" />
                Delete Lead
              </span>
            </button>
          </motion.div>
        </div>
      </div>

      <EstimateSentConfirmDialog
        clientName={lead.name}
        open={showEstimateConfirm}
        onOpenChange={setShowEstimateConfirm}
        onConfirm={handleEstimateSentConfirm}
      />
      <ActionConfirmDialog
        open={showPauseConfirm}
        onOpenChange={setShowPauseConfirm}
        title={`Pause follow-ups for ${lead.name}?`}
        description="You can resume anytime."
        confirmLabel="Pause"
        onConfirm={handlePauseFollowUps}
      />
      <ActionConfirmDialog
        open={showStopConfirm}
        onOpenChange={setShowStopConfirm}
        title={`Stop all follow-ups for ${lead.name}?`}
        description="This can't be undone."
        confirmLabel="Stop"
        destructive
        onConfirm={handleStopFollowUps}
      />
      <ActionConfirmDialog
        open={showDeleteConfirm}
        onOpenChange={setShowDeleteConfirm}
        title={`Delete ${lead.name} from your leads?`}
        description="This can't be undone."
        confirmLabel="Delete"
        destructive
        onConfirm={handleDeleteLead}
      />
      <ActionConfirmDialog
        open={showColdConfirm}
        onOpenChange={setShowColdConfirm}
        title={`Mark ${lead.name} as cold?`}
        description="Follow-ups will stop."
        confirmLabel="Confirm"
        onConfirm={handleConfirmMarkCold}
      />

      <AnimatePresence>
        {showWonCelebration && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 bg-black/80 px-5 flex items-center justify-center"
          >
            <motion.div
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: 20, opacity: 0 }}
              className="w-full max-w-[420px] glass-elevated rounded-3xl p-6 text-center"
            >
              <div className="w-16 h-16 rounded-full bg-system-green/20 flex items-center justify-center mx-auto mb-4">
                <CheckCircle2 className="w-9 h-9 text-system-green" />
              </div>
              <h2 className="text-[32px] font-bold text-foreground tracking-tight">Job Won! 🎉</h2>
              <p className="text-[15px] text-muted-foreground mt-2 mb-6">
                {lead.name} — {lead.jobType}
              </p>

              <motion.button
                whileTap={{ scale: 0.97 }}
                onClick={handleSetupProjectNow}
                className="w-full bg-system-blue text-white py-4 rounded-2xl text-[17px] font-semibold"
              >
                Set Up Project →
              </motion.button>
              <button
                onClick={handleSetupProjectLater}
                className="mt-4 text-[15px] text-muted-foreground active:opacity-70"
              >
                I&apos;ll do this later
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
