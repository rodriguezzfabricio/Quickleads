import { Lead } from '../types';
import { Phone } from 'lucide-react';
import { motion } from 'motion/react';
import { useState } from 'react';
import { EstimateSentConfirmDialog } from './EstimateSentConfirmDialog';

interface LeadCardProps {
  lead: Lead;
  onClick?: () => void;
  onEstimateSent?: (leadId: string) => void;
}

const statusLabels = {
  'call-back-now': 'Callback',
  'estimate-sent': 'Estimate',
  'won': 'Won',
  'cold': 'Cold',
};

const statusStyles = {
  'call-back-now': 'bg-system-red/20 text-system-red',
  'estimate-sent': 'bg-system-orange/20 text-system-orange',
  'won': 'bg-system-green/20 text-system-green',
  'cold': 'bg-white/[0.06] text-muted-foreground',
};

export function LeadCard({ lead, onClick, onEstimateSent }: LeadCardProps) {
  const [showEstimateConfirm, setShowEstimateConfirm] = useState(false);

  const handleEstimateSentClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    setShowEstimateConfirm(true);
  };

  const handleEstimateSentConfirm = () => {
    onEstimateSent?.(lead.id);
  };

  return (
    <>
      <motion.div
        onClick={onClick}
        role="button"
        tabIndex={0}
        onKeyDown={(e) => {
          if ((e.key === 'Enter' || e.key === ' ') && onClick) onClick();
        }}
        whileTap={{ scale: 0.97 }}
        transition={{ type: 'spring', stiffness: 400, damping: 20 }}
        className="w-full glass-elevated rounded-2xl p-4 text-left cursor-pointer"
      >
        <div className="flex items-start justify-between mb-2">
          <div className="flex-1">
            <h3 className="font-semibold text-[17px] mb-0.5 text-foreground">{lead.name}</h3>
            <p className="text-muted-foreground text-[15px] mb-2">{lead.jobType}</p>
            <div className="flex items-center gap-2 text-muted-foreground text-[13px]">
              <Phone className="w-3.5 h-3.5" />
              <span>{lead.phone}</span>
            </div>
          </div>
          <div className={`${statusStyles[lead.status]} px-2.5 py-1 rounded-full text-[11px] font-semibold`}>
            {statusLabels[lead.status]}
          </div>
        </div>

        {lead.status === 'call-back-now' && (
          <motion.button
            whileTap={{ scale: 0.96 }}
            onClick={handleEstimateSentClick}
            className="mt-3 w-full bg-system-yellow text-black py-3 rounded-xl text-[15px] font-semibold"
          >
            Estimate Sent?
          </motion.button>
        )}

        {lead.followUpSequence?.active && (
          <div className="mt-3 pt-3 border-t border-white/[0.06] space-y-1.5 text-[12px] text-muted-foreground">
            {/* Timeline text mirrors the exact promised follow-up sequence. */}
            <p>Follow-up 1: Day 2 {lead.followUpSequence.day2Sent ? '✓ Sent' : '⏳ Scheduled'}</p>
            <p>Follow-up 2: Day 5 {lead.followUpSequence.day5Sent ? '✓ Sent' : '⏳ Scheduled'}</p>
            <p>Follow-up 3: Day 10 {lead.followUpSequence.day10Sent ? '✓ Sent' : '⏳ Scheduled'}</p>
          </div>
        )}
      </motion.div>

      <EstimateSentConfirmDialog
        clientName={lead.name}
        open={showEstimateConfirm}
        onOpenChange={setShowEstimateConfirm}
        onConfirm={handleEstimateSentConfirm}
      />
    </>
  );
}
