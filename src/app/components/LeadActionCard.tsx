import { Lead } from '../types';
import { Phone, Clock, CheckCircle2 } from 'lucide-react';
import { motion } from 'motion/react';
import { useState } from 'react';
import { EstimateSentConfirmDialog } from './EstimateSentConfirmDialog';

interface LeadActionCardProps {
  lead: Lead;
  onClick?: () => void;
  variant?: 'urgent' | 'following-up' | 'won';
  onEstimateSent?: (leadId: string) => void;
}

export function LeadActionCard({
  lead,
  onClick,
  variant = 'urgent',
  onEstimateSent,
}: LeadActionCardProps) {
  const [showEstimateConfirm, setShowEstimateConfirm] = useState(false);

  const getTimeAgo = (date: Date) => {
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const days = Math.floor(hours / 24);
    if (hours < 1) return 'just now';
    if (hours < 24) return `${hours}h ago`;
    return `${days}d ago`;
  };

  const handleCallClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    window.location.href = `tel:${lead.phone}`;
  };

  const handleEstimateSentClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    setShowEstimateConfirm(true);
  };

  const handleEstimateSentConfirm = () => {
    onEstimateSent?.(lead.id);
  };

  const getFollowUpProgress = () => {
    if (!lead.followUpSequence?.active) return null;
    const sent = [
      lead.followUpSequence.day2Sent,
      lead.followUpSequence.day5Sent,
      lead.followUpSequence.day10Sent,
    ].filter(Boolean).length;
    return { sent, total: 3 };
  };

  const followUpProgress = getFollowUpProgress();

  const accentColor = variant === 'urgent' ? 'bg-system-red' : variant === 'won' ? 'bg-system-green' : 'bg-system-blue';

  return (
    <>
      <motion.div
        onClick={onClick}
        whileTap={{ scale: 0.97 }}
        transition={{ type: 'spring', stiffness: 400, damping: 20 }}
        className="w-full glass-elevated rounded-2xl overflow-hidden text-left cursor-pointer"
      >
        <div className="flex">
          {/* Colored accent bar */}
          <div className={`w-1 ${accentColor} shrink-0`} />

          <div className="flex-1 p-4">
            {variant === 'urgent' && (
              <>
                <div className="flex items-center gap-2 mb-0.5">
                  <h3 className="font-semibold text-[17px] text-foreground">{lead.name}</h3>
                  <span className="text-[11px] text-system-red font-bold uppercase tracking-wider animate-pulse">
                    Urgent
                  </span>
                </div>
                <p className="text-muted-foreground text-[15px] mb-2">{lead.jobType}</p>
                <div className="flex items-center gap-1.5 text-muted-foreground text-[13px] mb-3">
                  <Clock className="w-3.5 h-3.5" />
                  <span>{getTimeAgo(lead.createdAt)}</span>
                </div>
                <motion.button
                  onClick={handleCallClick}
                  whileTap={{ scale: 0.96 }}
                  className="w-full bg-system-red/90 text-white rounded-xl py-3 px-4 font-semibold text-[15px] flex items-center justify-center gap-2"
                >
                  <Phone className="w-4 h-4" />
                  Call {lead.phone}
                </motion.button>
                {/* Keep "Estimate Sent?" equal prominence to call for callback leads. */}
                <motion.button
                  onClick={handleEstimateSentClick}
                  whileTap={{ scale: 0.96 }}
                  className="mt-2 w-full bg-system-yellow text-black rounded-xl py-3 px-4 font-semibold text-[15px]"
                >
                  Estimate Sent?
                </motion.button>
              </>
            )}

            {variant === 'following-up' && followUpProgress && (
              <>
                <div className="flex items-center justify-between mb-0.5">
                  <h3 className="font-semibold text-[17px] text-foreground">{lead.name}</h3>
                  <span className="text-[11px] text-system-blue font-semibold">
                    {followUpProgress.sent}/{followUpProgress.total}
                  </span>
                </div>
                <p className="text-muted-foreground text-[15px] mb-3">{lead.jobType}</p>

                {/* Follow-up progress bar */}
                <div className="glass rounded-xl p-3 mb-3">
                  <div className="flex items-center gap-1.5 mb-2">
                    {[lead.followUpSequence?.day2Sent, lead.followUpSequence?.day5Sent, lead.followUpSequence?.day10Sent].map((sent, i) => (
                      <div key={i} className="flex-1 flex items-center gap-1">
                        <motion.div
                          initial={{ scaleX: 0 }}
                          animate={{ scaleX: 1 }}
                          transition={{ delay: i * 0.15, type: 'spring', stiffness: 200 }}
                          className={`flex-1 h-1.5 rounded-full origin-left ${sent ? 'bg-system-blue' : 'bg-white/[0.06]'}`}
                        />
                        <CheckCircle2 className={`w-3.5 h-3.5 ${sent ? 'text-system-blue' : 'text-white/15'}`} />
                      </div>
                    ))}
                  </div>
                  <div className="flex justify-between text-[10px] text-muted-foreground">
                    <span>Day 2</span>
                    <span>Day 5</span>
                    <span>Day 10</span>
                  </div>
                </div>

                <p className="text-[12px] text-muted-foreground mb-2">
                  Follow-up 1: Day 2 {lead.followUpSequence?.day2Sent ? '✓ Sent' : '⏳ Scheduled'} ·
                  Follow-up 2: Day 5 {lead.followUpSequence?.day5Sent ? '✓ Sent' : '⏳ Scheduled'} ·
                  Follow-up 3: Day 10 {lead.followUpSequence?.day10Sent ? '✓ Sent' : '⏳ Scheduled'}
                </p>

                <button
                  onClick={handleCallClick}
                  className="w-full glass rounded-xl py-2.5 px-4 font-medium text-[15px] flex items-center justify-center gap-2 text-foreground"
                >
                  <Phone className="w-4 h-4 text-muted-foreground" />
                  {lead.phone}
                </button>
              </>
            )}

            {variant === 'won' && (
              <>
                <div className="flex items-center gap-2 mb-0.5">
                  <h3 className="font-semibold text-[17px] text-foreground">{lead.name}</h3>
                  <span className="text-[11px] text-system-green font-semibold uppercase flex items-center gap-1">
                    <CheckCircle2 className="w-3 h-3" />
                    Won
                  </span>
                </div>
                <p className="text-muted-foreground text-[15px]">{lead.jobType}</p>
              </>
            )}
          </div>
        </div>
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
