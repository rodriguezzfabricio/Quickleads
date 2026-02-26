import { useMemo, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router';
import { motion, AnimatePresence } from 'motion/react';
import { ChevronLeft } from 'lucide-react';
import { format } from 'date-fns';
import { useLeads } from '../state/LeadsContext';

function formatDuration(seconds: number) {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins} min ${secs.toString().padStart(2, '0')} sec`;
}

export function DailySweepReviewScreen() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const { unknownCalls, skipUnknownCall } = useLeads();
  const [initialCallCount] = useState(unknownCalls.length);

  const forcedPlatform = searchParams.get('platform');
  const isIOS = useMemo(() => {
    if (forcedPlatform === 'ios') return true;
    if (forcedPlatform === 'android') return false;
    return /iPad|iPhone|iPod/.test(window.navigator.userAgent);
  }, [forcedPlatform]);

  const handleSaveAsLead = (phone: string, callId: string) => {
    // After review, route to lead capture with phone prefilled.
    skipUnknownCall(callId);
    navigate(`/lead-capture?phone=${encodeURIComponent(phone)}`);
  };

  return (
    <div className="min-h-screen bg-background px-5 pt-14 pb-24">
      <div className="max-w-[600px] mx-auto">
        <button
          onClick={() => navigate('/leads')}
          className="mb-6 text-system-blue flex items-center gap-0.5 -ml-1 active:opacity-70"
        >
          <ChevronLeft className="w-5 h-5" />
          <span className="text-[17px]">Leads</span>
        </button>

        <h1 className="text-[34px] font-bold text-foreground tracking-tight">
          Today&apos;s Calls — {format(new Date(), 'MMM d, yyyy')}
        </h1>
        <p className="text-[15px] text-muted-foreground mt-2 mb-5">
          {unknownCalls.length} calls from numbers not in your leads
        </p>

        {unknownCalls.length > 0 && (
          <div className="space-y-3">
            <AnimatePresence>
              {unknownCalls.map((call) => (
                <motion.div
                  key={call.id}
                  initial={{ opacity: 0, y: 8 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, x: 20 }}
                  className="glass-elevated rounded-2xl p-4"
                >
                  <p className="text-[20px] font-bold text-foreground">{call.phone}</p>
                  <p className="text-[14px] text-muted-foreground mt-1">
                    {format(call.calledAt, 'h:mm a')}
                  </p>
                  {!isIOS && (
                    <div className="flex items-center gap-3 mt-2 text-[13px] text-muted-foreground">
                      {call.durationSeconds ? <span>{formatDuration(call.durationSeconds)}</span> : null}
                      {call.direction ? (
                        <span>{call.direction === 'incoming' ? '↙ Incoming' : '↗ Outgoing'}</span>
                      ) : null}
                    </div>
                  )}

                  <div className="mt-4 flex items-center gap-2">
                    <button
                      onClick={() => handleSaveAsLead(call.phone, call.id)}
                      className="flex-1 min-h-14 bg-system-blue text-white rounded-xl text-[15px] font-semibold"
                    >
                      Save as Lead
                    </button>
                    <button
                      onClick={() => skipUnknownCall(call.id)}
                      className="min-h-14 px-5 glass rounded-xl text-[15px] font-medium text-muted-foreground"
                    >
                      Skip
                    </button>
                  </div>
                </motion.div>
              ))}
            </AnimatePresence>
          </div>
        )}

        {unknownCalls.length === 0 && initialCallCount > 0 && (
          <div className="glass-elevated rounded-2xl p-5 mt-4 text-center">
            <p className="text-[17px] font-semibold text-foreground">All caught up! ✓</p>
          </div>
        )}

        {unknownCalls.length === 0 && initialCallCount === 0 && (
          <div className="glass-elevated rounded-2xl p-5 mt-4 text-center">
            <p className="text-[17px] text-foreground">No new calls today. You&apos;re all set.</p>
            <button
              onClick={() => navigate('/leads')}
              className="mt-4 px-4 py-2 rounded-xl bg-system-blue text-white text-[14px] font-semibold"
            >
              Dismiss
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
