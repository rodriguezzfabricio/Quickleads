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

export function JobCard({ job, onClick }: JobCardProps) {
  return (
    <motion.button
      onClick={onClick}
      whileTap={{ scale: 0.97 }}
      transition={{ type: 'spring', stiffness: 400, damping: 20 }}
      className="w-full glass-elevated rounded-2xl overflow-hidden text-left"
    >
      <div className="flex">
        <div className={`w-1 ${statusAccent[job.status]} shrink-0`} />
        <div className="flex-1 p-4">
          <div className="flex items-center gap-2 mb-0.5">
            <h3 className="font-semibold text-[17px] text-foreground">{job.clientName}</h3>
          </div>
          <p className="text-muted-foreground text-[15px] mb-3">{job.jobType}</p>
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