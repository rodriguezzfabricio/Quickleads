import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Settings, TrendingUp, Users, Briefcase, Trophy, X } from 'lucide-react';
import { LeadActionCard } from '../components/LeadActionCard';
import { JobCard } from '../components/JobCard';
import { LeadStatus } from '../types';
import { motion } from 'motion/react';
import { useLeads } from '../state/LeadsContext';

export function HomeScreen() {
  const navigate = useNavigate();
  const { leads, jobs, wonLeadsWithoutProject, markEstimateSent } = useLeads();
  const [dismissedWonReminder, setDismissedWonReminder] = useState(false);

  const urgentLeads = leads.filter(l => l.status === 'call-back-now');
  const followingUpLeads = leads.filter(l => l.status === 'estimate-sent' && l.followUpSequence?.active);
  const wonLeads = leads.filter(l => l.status === 'won');
  const totalActiveLeads = urgentLeads.length + followingUpLeads.length;

  const handleJobClick = (jobId: string) => navigate(`/jobs/${jobId}`);
  const handleLeadClick = (leadId: string) => navigate(`/leads/${leadId}`);
  const handleFilterClick = (status: LeadStatus) => navigate(`/leads?status=${status}`);
  const showWonReminder = wonLeadsWithoutProject.length > 0 && !dismissedWonReminder;

  const handleWonReminderClick = () => {
    if (wonLeadsWithoutProject.length === 1) {
      navigate(`/leads/${wonLeadsWithoutProject[0].id}`);
      return;
    }
    navigate('/leads?status=won');
  };

  return (
    <div className="pb-24 min-h-screen">
      {/* Header */}
      <div className="px-5 pt-14 pb-3">
        <div className="flex items-start justify-between">
          <motion.h1
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-[34px] font-bold text-foreground tracking-tight leading-tight"
          >
            Dashboard
          </motion.h1>
          <button onClick={() => navigate('/settings')} className="text-muted-foreground p-2 active:opacity-70">
            <Settings className="w-[22px] h-[22px]" />
          </button>
        </div>
        <p className="text-[15px] text-muted-foreground mt-1">
          {followingUpLeads.length} follow-up{followingUpLeads.length !== 1 ? 's' : ''} running
        </p>
      </div>

      {/* Health-style Metric Tiles */}
      <div className="px-5 mb-6">
        <div className="grid grid-cols-3 gap-2">
          <motion.button
            onClick={() => navigate('/leads')}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.05 }}
            whileTap={{ scale: 0.96 }}
            className="glass-elevated rounded-2xl p-3 text-left"
          >
            <Users className="w-5 h-5 text-system-blue mb-2" />
            <p className="text-[28px] font-bold text-foreground leading-none">{totalActiveLeads}</p>
            <p className="text-[11px] text-muted-foreground mt-1 uppercase tracking-wider">Active</p>
          </motion.button>

          <motion.button
            onClick={() => handleFilterClick('won')}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            whileTap={{ scale: 0.96 }}
            className="glass-elevated rounded-2xl p-3 text-left"
          >
            <Trophy className="w-5 h-5 text-system-green mb-2" />
            <p className="text-[28px] font-bold text-foreground leading-none">{wonLeads.length}</p>
            <p className="text-[11px] text-muted-foreground mt-1 uppercase tracking-wider">Won</p>
          </motion.button>

          <motion.button
            onClick={() => navigate('/jobs')}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.15 }}
            whileTap={{ scale: 0.96 }}
            className="glass-elevated rounded-2xl p-3 text-left"
          >
            <Briefcase className="w-5 h-5 text-system-orange mb-2" />
            <p className="text-[28px] font-bold text-foreground leading-none">{jobs.length}</p>
            <p className="text-[11px] text-muted-foreground mt-1 uppercase tracking-wider">Jobs</p>
          </motion.button>
        </div>
      </div>

      {/* Lead Action Feed */}
      <div className="px-5 space-y-3">
        {urgentLeads.length > 0 && (
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.2 }}>
            <h2 className="text-[13px] font-semibold text-system-red uppercase tracking-wider mb-3 flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-system-red animate-pulse" />
              Call Back Now
            </h2>
            <div className="space-y-2">
              {urgentLeads.map((lead, i) => (
                <motion.div key={lead.id} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.25 + i * 0.05 }}>
                  <LeadActionCard
                    lead={lead}
                    variant="urgent"
                    onClick={() => handleLeadClick(lead.id)}
                    // This action starts the automated follow-up sequence from the card.
                    onEstimateSent={markEstimateSent}
                  />
                </motion.div>
              ))}
            </div>
          </motion.div>
        )}

        {followingUpLeads.length > 0 && (
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.35 }} className={urgentLeads.length > 0 ? 'mt-6' : ''}>
            <h2 className="text-[13px] font-semibold text-system-blue uppercase tracking-wider mb-3 flex items-center gap-2">
              <TrendingUp className="w-3.5 h-3.5" />
              Auto Follow-up
            </h2>
            <div className="space-y-2">
              {followingUpLeads.map((lead, i) => (
                <motion.div key={lead.id} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 + i * 0.05 }}>
                  <LeadActionCard lead={lead} variant="following-up" onClick={() => handleLeadClick(lead.id)} />
                </motion.div>
              ))}
            </div>
          </motion.div>
        )}

        {wonLeads.length > 0 && (
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.5 }} className="mt-6">
            <h2 className="text-[13px] font-semibold text-system-green uppercase tracking-wider mb-3">✓ Won</h2>
            <div className="space-y-2">
              {wonLeads.slice(0, 2).map((lead) => (
                <LeadActionCard key={lead.id} lead={lead} variant="won" onClick={() => handleLeadClick(lead.id)} />
              ))}
            </div>
          </motion.div>
        )}

        {leads.filter(l => l.status === 'cold').length > 0 && (
          <button onClick={() => handleFilterClick('cold')} className="w-full text-center text-[13px] text-muted-foreground py-3 active:opacity-70">
            View {leads.filter(l => l.status === 'cold').length} Cold Leads
          </button>
        )}
      </div>

      {showWonReminder && (
        <div className="px-5 mt-4">
          <motion.div
            whileTap={{ scale: 0.98 }}
            onClick={handleWonReminderClick}
            role="button"
            tabIndex={0}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') handleWonReminderClick();
            }}
            className="w-full text-left bg-system-yellow/20 border border-system-yellow/30 rounded-2xl p-4 cursor-pointer"
          >
            <div className="flex items-start gap-3">
              <div className="flex-1">
                <p className="text-[15px] text-system-yellow font-semibold">
                  You have {wonLeadsWithoutProject.length} won lead{wonLeadsWithoutProject.length === 1 ? '' : 's'} without a project. Tap to set up.
                </p>
              </div>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  // Dismiss for this session; it returns on next app open until resolved.
                  setDismissedWonReminder(true);
                }}
                className="text-system-yellow/80 mt-0.5 active:opacity-70"
              >
                <X className="w-4 h-4" />
              </button>
            </div>
          </motion.div>
        </div>
      )}

      {/* Jobs Section */}
      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.6 }} className="px-5 pt-8 mt-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-[13px] font-semibold text-muted-foreground uppercase tracking-wider">Your Jobs</h2>
          <button onClick={() => navigate('/jobs')} className="text-system-blue text-[15px] font-medium active:opacity-70">See All</button>
        </div>
        <div className="space-y-2">
          {jobs.slice(0, 3).map((job) => (
            <JobCard key={job.id} job={job} onClick={() => handleJobClick(job.id)} />
          ))}
        </div>
      </motion.div>
    </div>
  );
}
