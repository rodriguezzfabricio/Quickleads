import { LeadStatus } from '../types';

interface StatusPillProps {
  status: LeadStatus;
  count?: number;
  onClick?: () => void;
}

const statusConfig = {
  'call-back-now': { label: 'Callback', bg: 'bg-system-red/15', text: 'text-system-red' },
  'estimate-sent': { label: 'Estimate', bg: 'bg-system-orange/15', text: 'text-system-orange' },
  won: { label: 'Won', bg: 'bg-system-green/15', text: 'text-system-green' },
  cold: { label: 'Cold', bg: 'bg-white/[0.06]', text: 'text-muted-foreground' },
};

export function StatusPill({ status, count, onClick }: StatusPillProps) {
  const config = statusConfig[status];
  return (
    <button
      onClick={onClick}
      className={`${config.bg} ${config.text} glass rounded-2xl px-4 py-3 min-h-[60px] flex flex-col items-center justify-center gap-1 flex-1 active:opacity-80 transition-opacity`}
    >
      <span className="text-[13px] font-medium">{config.label}</span>
      {count !== undefined && <span className="text-2xl font-bold">{count}</span>}
    </button>
  );
}
