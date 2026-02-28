import { useState, useMemo } from 'react';
import { useNavigate, useSearchParams } from 'react-router';
import { LeadCard } from '../components/LeadCard';
import { LeadStatus } from '../types';
import { motion, AnimatePresence } from 'motion/react';
import { UserPlus } from 'lucide-react';
import { useLeads } from '../state/LeadsContext';

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
  const rawStatus = searchParams.get('status');
  const validStatuses: LeadStatus[] = ['call-back-now', 'estimate-sent', 'won', 'cold'];
  const statusFilter = rawStatus && validStatuses.includes(rawStatus as LeadStatus) ? rawStatus as LeadStatus : 'all';
  const { leads, unknownCalls, markEstimateSent } = useLeads();
  const [selectedStatus, setSelectedStatus] = useState<LeadStatus | 'all'>(statusFilter);
  const [expandedId, setExpandedId] = useState<string | null>(null);

  const filteredLeads = useMemo(() => {
    if (selectedStatus === 'all') return leads;
    return leads.filter((lead) => lead.status === selectedStatus);
  }, [leads, selectedStatus]);

  const handleCardClick = (id: string) => {
    if (expandedId === id) {
      navigate(`/leads/${id}`);
    } else {
      setExpandedId(id);
    }
  };

  const handleAddAsClient = (lead: typeof leads[number]) => {
    navigate(
      `/clients/new?name=${encodeURIComponent(lead.name)}&phone=${encodeURIComponent(lead.phone)}`
    );
  };

  return (
    <div className="pb-24">
      <div className="sticky top-0 bg-background/70 backdrop-blur-2xl px-5 pt-14 pb-3 z-10">
        <motion.h1
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-[34px] font-bold mb-4 text-foreground tracking-tight"
        >
          Leads
        </motion.h1>
        {/* Segmented Control */}
        <div className="glass-elevated rounded-xl p-[3px] flex gap-[2px]">
          {filters.map((f) => (
            <button
              key={f.key}
              onClick={() => { setSelectedStatus(f.key); setExpandedId(null); }}
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
        <motion.button
          whileTap={{ scale: 0.98 }}
          onClick={() => navigate('/daily-sweep-review')}
          className="w-full mb-3 glass-elevated rounded-2xl p-3.5 text-left flex items-center justify-between"
        >
          <span className="text-[15px] font-medium text-foreground">Review Calls</span>
          <span className="text-[13px] text-muted-foreground">
            {unknownCalls.length} to review
          </span>
        </motion.button>

        {filteredLeads.length === 0 ? (
          <div className="text-center py-16">
            <p className="text-muted-foreground text-[17px]">No leads found</p>
            <p className="text-muted-foreground/60 text-[13px] mt-2">Tap + to add a new lead</p>
          </div>
        ) : (
          <div className="space-y-2">
            {filteredLeads.map((lead, i) => (
              <motion.div
                key={lead.id}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.04 }}
              >
                <LeadCard
                  lead={lead}
                  onClick={() => handleCardClick(lead.id)}
                  // Callback leads can trigger estimate-sent directly from the card.
                  onEstimateSent={markEstimateSent}
                />

                {/* Expanded quick-actions */}
                <AnimatePresence>
                  {expandedId === lead.id && (
                    <motion.div
                      initial={{ opacity: 0, height: 0 }}
                      animate={{ opacity: 1, height: 'auto' }}
                      exit={{ opacity: 0, height: 0 }}
                      className="overflow-hidden"
                    >
                      <div className="pt-2 pb-1 flex gap-2">
                        <motion.button
                          whileTap={{ scale: 0.96 }}
                          onClick={() => navigate(`/leads/${lead.id}`)}
                          className="flex-1 glass-elevated rounded-2xl py-3 text-[14px] font-medium text-foreground"
                        >
                          View Profile
                        </motion.button>
                        <motion.button
                          whileTap={{ scale: 0.96 }}
                          onClick={() => handleAddAsClient(lead)}
                          className="flex-1 glass-elevated rounded-2xl py-3 text-[14px] font-medium text-system-blue flex items-center justify-center gap-1.5"
                        >
                          <UserPlus className="w-4 h-4" />
                          Add as Client
                        </motion.button>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
