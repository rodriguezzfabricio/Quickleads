import { Job } from '../types';
import { PhaseProgress } from './PhaseProgress';
import { format } from 'date-fns';
import { motion } from 'motion/react';

interface JobCardProps {
  job: Job;
  onClick?: () => void;
}

const statusAccent = {
  'on-track': 'bg-system-green',
  'needs-attention': 'bg-system-orange',
  'behind': 'bg-system-red',
};

const statusTint = {
  'on-track': 'rgba(74, 158, 126, 0.12)',
  'needs-attention': 'rgba(255, 159, 10, 0.12)',
  'behind': 'rgba(255, 69, 58, 0.12)',
};

const statusPill = {
  'on-track': { bg: 'rgba(74, 158, 126, 0.28)', text: '#4A9E7E', label: 'On Track' },
  'needs-attention': { bg: 'rgba(255, 159, 10, 0.28)', text: '#FF9F0A', label: 'Needs Attention' },
  'behind': { bg: 'rgba(255, 69, 58, 0.28)', text: '#FF453A', label: 'Behind Schedule' },
};

export function JobCard({ job, onClick }: JobCardProps) {
  const pill = statusPill[job.status];

  return (
    <motion.button
      onClick={onClick}
      whileTap={{ scale: 0.97 }}
      transition={{ type: 'spring', stiffness: 400, damping: 20 }}
      style={{ backgroundColor: statusTint[job.status] }}
      className="w-full rounded-2xl overflow-hidden text-left backdrop-blur-xl border border-white/[0.08]"
    >
      <div className="flex">
        <div className={`w-1 ${statusAccent[job.status]} shrink-0`} />
        <div className="flex-1 p-4">
          <h3 className="font-semibold text-[17px] text-foreground mb-1">{job.clientName}</h3>
          <div className="flex items-center gap-2 mb-3">
            <span className="text-muted-foreground text-[15px]">{job.jobType}</span>
            <span
              className="px-2.5 py-0.5 rounded-full text-[12px] font-semibold"
              style={{ backgroundColor: pill.bg, color: pill.text }}
            >
              {pill.label}
            </span>
          </div>
          <div className="mb-3">
            <PhaseProgress currentPhase={job.currentPhase} />
          </div>
          <div className="text-[12px] text-muted-foreground">
            Est. {format(job.estimatedCompletion, 'MMM d, yyyy')}
          </div>
        </div>
      </div>
    </motion.button>
  );
}