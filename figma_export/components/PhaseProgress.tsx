import { JobPhase } from '../types';
import { motion } from 'motion/react';

interface PhaseProgressProps {
  currentPhase: JobPhase;
  interactive?: boolean;
  onPhaseSelect?: (phase: JobPhase) => void;
}

const phases: { value: JobPhase; label: string }[] = [
  { value: 'demo', label: 'Demo' },
  { value: 'rough', label: 'Rough' },
  { value: 'electrical-plumbing', label: 'Elec' },
  { value: 'finishing', label: 'Finish' },
  { value: 'walkthrough', label: 'Walk' },
  { value: 'complete', label: 'Done' },
];

export function PhaseProgress({ currentPhase, interactive = false, onPhaseSelect }: PhaseProgressProps) {
  const currentIndex = phases.findIndex(p => p.value === currentPhase);

  if (interactive) {
    return (
      <div className="w-full">
        <div className="flex items-center justify-between mb-2">
          {phases.map((phase, index) => (
            <button
              key={phase.value}
              onClick={() => onPhaseSelect?.(phase.value)}
              className={`flex-1 text-center py-2 text-[11px] font-medium transition-colors duration-300 ${index <= currentIndex ? 'text-system-blue' : 'text-muted-foreground'
                } ${interactive ? 'active:opacity-70' : ''}`}
            >
              {phase.label}
            </button>
          ))}
        </div>
        <div className="flex gap-1">
          {phases.map((phase, index) => (
            <motion.div
              key={phase.value}
              initial={{ scaleX: 0 }}
              animate={{ scaleX: 1 }}
              transition={{ delay: index * 0.08, type: 'spring', stiffness: 300, damping: 25 }}
              className={`h-2 flex-1 rounded-full origin-left transition-colors duration-300 ${index <= currentIndex ? 'bg-system-blue' : 'bg-white/[0.06]'
                }`}
            />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="flex items-center gap-1">
      {phases.map((phase, index) => (
        <motion.div
          key={phase.value}
          initial={{ scaleX: 0 }}
          animate={{ scaleX: 1 }}
          transition={{ delay: index * 0.06, type: 'spring', stiffness: 300, damping: 25 }}
          className={`h-1.5 flex-1 rounded-full origin-left ${index <= currentIndex ? 'bg-system-blue' : 'bg-white/[0.06]'
            }`}
        />
      ))}
    </div>
  );
}