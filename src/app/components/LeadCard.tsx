import { Lead } from '../types';
import { Phone } from 'lucide-react';
import { motion } from 'motion/react';

interface LeadCardProps {
  lead: Lead;
  onClick?: () => void;
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

export function LeadCard({ lead, onClick }: LeadCardProps) {
  return (
    <motion.button
      onClick={onClick}
      whileTap={{ scale: 0.97 }}
      transition={{ type: 'spring', stiffness: 400, damping: 20 }}
      className="w-full glass-elevated rounded-2xl p-4 text-left"
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

      {lead.followUpSequence?.active && (
        <div className="mt-3 pt-3 border-t border-white/[0.06]">
          <div className="flex items-center gap-3 text-[12px]">
            {[
              { label: 'Day 2', sent: lead.followUpSequence.day2Sent },
              { label: 'Day 5', sent: lead.followUpSequence.day5Sent },
              { label: 'Day 10', sent: lead.followUpSequence.day10Sent },
            ].map(({ label, sent }) => (
              <span key={label} className={sent ? 'text-system-blue' : 'text-muted-foreground'}>
                {label} {sent ? '✓' : '⏳'}
              </span>
            ))}
          </div>
        </div>
      )}
    </motion.button>
  );
}