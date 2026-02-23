import { Plus } from 'lucide-react';
import { Link } from 'react-router';
import { motion } from 'motion/react';

export function FloatingActionButton() {
  return (
    <motion.div
      whileTap={{ scale: 0.9 }}
      transition={{ type: 'spring', stiffness: 400, damping: 17 }}
      className="fixed bottom-[98px] right-5 z-50"
    >
      <Link
        to="/lead-capture"
        className="w-14 h-14 bg-system-blue glass-elevated rounded-2xl shadow-lg shadow-system-blue/20 flex items-center justify-center transition-shadow hover:shadow-xl hover:shadow-system-blue/30"
      >
        <Plus className="w-7 h-7 text-white" strokeWidth={2.5} />
      </Link>
    </motion.div>
  );
}