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
} from 'lucide-react';
import { mockLeads } from '../data/mockData';
import { LeadStatus, PreviousProject } from '../types';
import { motion, AnimatePresence } from 'motion/react';
import { format } from 'date-fns';

const statusOptions: { value: LeadStatus; label: string }[] = [
  { value: 'call-back-now', label: 'New / Call Back' },
  { value: 'estimate-sent', label: 'Estimate Sent' },
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
  const lead = mockLeads.find((l) => l.id === id);

  const [isEditing, setIsEditing] = useState(false);
  const [name, setName] = useState(lead?.name || '');
  const [phone, setPhone] = useState(lead?.phone || '');
  const [status, setStatus] = useState<LeadStatus>(lead?.status || 'call-back-now');
  const [showDetails, setShowDetails] = useState(false);
  const [notes, setNotes] = useState(lead?.notes || '');
  const [email, setEmail] = useState(lead?.email || '');
  const [address, setAddress] = useState(lead?.address || '');

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
    navigate(`/lead-capture?name=${encodeURIComponent(name)}&phone=${encodeURIComponent(phone)}`);
  };

  const previousProjects = lead.previousProjects ?? [];

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
              onChange={(e) => setName(e.target.value)}
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
                  onChange={(e) => setPhone(e.target.value)}
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
              <div className="px-4 pb-4 pt-2">
                <p className="text-[15px] text-muted-foreground/60 italic">
                  No previous projects yet
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
              <select
                value={status}
                onChange={(e) => setStatus(e.target.value as LeadStatus)}
                className="w-full bg-transparent text-[17px] text-foreground appearance-none focus:outline-none cursor-pointer"
              >
                {statusOptions.map((o) => (
                  <option key={o.value} value={o.value}>
                    {o.label}
                  </option>
                ))}
              </select>
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
                <button className="text-system-blue text-[13px] font-medium flex items-center gap-1">
                  <Pause className="w-3.5 h-3.5" />
                  Pause
                </button>
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
                      <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
                        {f.label}
                      </label>
                      <input
                        type={f.type}
                        value={f.val}
                        onChange={(e) => f.set(e.target.value)}
                        placeholder={f.ph}
                        className="w-full p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground text-[17px]"
                      />
                    </div>
                  ))}
                  <div>
                    <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
                      Notes
                    </label>
                    <textarea
                      value={notes}
                      onChange={(e) => setNotes(e.target.value)}
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
          </motion.div>
        </div>
      </div>
    </div>
  );
}