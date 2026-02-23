import { useState, useMemo } from 'react';
import { useNavigate, useSearchParams } from 'react-router';
import { LeadCard } from '../components/LeadCard';
import { mockLeads } from '../data/mockData';
import { LeadStatus } from '../types';
import { motion } from 'motion/react';

const filters = [
  { key: 'all', label: 'All' },
  { key: 'call-back-now', label: 'Callback' },
  { key: 'estimate-sent', label: 'Estimate' },
  { key: 'won', label: 'Won' },
  { key: 'cold', label: 'Cold' },
] as const;

export function LeadsScreen() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const statusFilter = (searchParams.get('status') as LeadStatus | null) || 'all';
  const [leads] = useState(mockLeads);
  const [selectedStatus, setSelectedStatus] = useState<LeadStatus | 'all'>(statusFilter);

  const filteredLeads = useMemo(() => {
    if (selectedStatus === 'all') return leads;
    return leads.filter(lead => lead.status === selectedStatus);
  }, [leads, selectedStatus]);

  return (
    <div className="pb-24">
      <div className="sticky top-0 bg-background/70 backdrop-blur-2xl px-5 pt-14 pb-3 z-10">
        <motion.h1 initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="text-[34px] font-bold mb-4 text-foreground tracking-tight">
          Leads
        </motion.h1>
        {/* Segmented Control */}
        <div className="glass-elevated rounded-xl p-[3px] flex gap-[2px]">
          {filters.map((f) => (
            <button
              key={f.key}
              onClick={() => setSelectedStatus(f.key)}
              className={`flex-1 py-[7px] rounded-[10px] text-[13px] font-medium transition-all duration-300 ${selectedStatus === f.key
                  ? 'glass-prominent text-foreground shadow-sm'
                  : 'text-muted-foreground active:text-foreground/80'
                }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      <div className="px-5 pt-3">
        {filteredLeads.length === 0 ? (
          <div className="text-center py-16">
            <p className="text-muted-foreground text-[17px]">No leads found</p>
            <p className="text-muted-foreground/60 text-[13px] mt-2">Tap + to add a new lead</p>
          </div>
        ) : (
          <div className="space-y-2">
            {filteredLeads.map((lead, i) => (
              <motion.div key={lead.id} initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.04 }}>
                <LeadCard lead={lead} onClick={() => navigate(`/leads/${lead.id}`)} />
              </motion.div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}