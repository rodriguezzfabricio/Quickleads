import { useState, useMemo } from 'react';
import { useNavigate } from 'react-router';
import { JobCard } from '../components/JobCard';
import { mockJobs } from '../data/mockData';
import { motion } from 'motion/react';

type FilterOption = 'all' | 'needs-attention' | 'behind';

export function JobsScreen() {
  const navigate = useNavigate();
  const [jobs] = useState(mockJobs);
  const [filter, setFilter] = useState<FilterOption>('all');

  const filteredJobs = useMemo(() => {
    if (filter === 'all') return jobs;
    return jobs.filter(job => job.status === filter);
  }, [jobs, filter]);

  return (
    <div className="pb-24">
      <div className="sticky top-0 bg-background/70 backdrop-blur-2xl px-5 pt-14 pb-3 z-10">
        <motion.h1 initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="text-[34px] font-bold mb-4 text-foreground tracking-tight">
          Jobs
        </motion.h1>
        <div className="glass-elevated rounded-xl p-[3px] flex gap-[2px]">
          {([
            { key: 'all', label: 'All' },
            { key: 'needs-attention', label: 'Attention' },
            { key: 'behind', label: 'Behind' },
          ] as const).map((f) => (
            <button
              key={f.key}
              onClick={() => setFilter(f.key)}
              className={`flex-1 py-[7px] rounded-[10px] text-[13px] font-medium transition-all duration-300 ${filter === f.key ? 'glass-prominent text-foreground shadow-sm' : 'text-muted-foreground'
                }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      <div className="px-5 pt-3">
        {filteredJobs.length === 0 ? (
          <div className="text-center py-16"><p className="text-muted-foreground text-[17px]">No jobs found</p></div>
        ) : (
          <div className="space-y-2">
            {filteredJobs.map((job, i) => (
              <motion.div key={job.id} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.04 }}>
                <JobCard job={job} onClick={() => navigate(`/jobs/${job.id}`)} />
              </motion.div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}