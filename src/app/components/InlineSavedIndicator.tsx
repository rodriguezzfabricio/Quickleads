import { AnimatePresence, motion } from 'motion/react';

export function InlineSavedIndicator({ visible }: { visible: boolean }) {
  return (
    <AnimatePresence>
      {visible && (
        <motion.span
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="text-[12px] text-muted-foreground"
        >
          ✓ Saved
        </motion.span>
      )}
    </AnimatePresence>
  );
}
