import { Home, Users, Briefcase, UserCircle2, Plus, Phone, ClipboardList } from 'lucide-react';
import { Link, useLocation, useNavigate } from 'react-router';
import { motion, AnimatePresence } from 'motion/react';
import { useState } from 'react';

export function BottomNav() {
  const location = useLocation();
  const navigate = useNavigate();
  const [showCreateSheet, setShowCreateSheet] = useState(false);

  const isActive = (path: string) => {
    if (path === '/') return location.pathname === '/';
    return location.pathname.startsWith(path);
  };

  const leftTabs = [
    { path: '/', label: 'Home', icon: Home },
    { path: '/leads', label: 'Leads', icon: Users },
  ];

  const rightTabs = [
    { path: '/clients', label: 'Clients', icon: UserCircle2 },
    { path: '/jobs', label: 'Jobs', icon: Briefcase },
  ];

  const renderTab = (tab: { path: string; label: string; icon: any }) => {
    const Icon = tab.icon;
    const active = isActive(tab.path);
    return (
      <Link
        key={tab.path}
        to={tab.path}
        className={`flex flex-col items-center justify-center flex-1 h-full gap-[2px] transition-all duration-300 ${active ? 'text-system-blue' : 'text-[rgba(235,235,245,0.35)]'
          }`}
      >
        <Icon className="w-[24px] h-[24px]" strokeWidth={active ? 2.2 : 1.6} />
        <span className={`text-[10px] ${active ? 'font-semibold' : 'font-medium'}`}>
          {tab.label}
        </span>
      </Link>
    );
  };

  return (
    <>
      <nav className="fixed bottom-0 left-0 right-0 glass-nav safe-area-inset-bottom z-50">
        <div className="flex items-center justify-between h-[82px] max-w-[600px] mx-auto pb-1 px-4">
          <div className="flex flex-1 justify-around">
            {leftTabs.map(renderTab)}
          </div>

          {/* Center Primary Action */}
          <div className="flex items-center justify-center px-4">
            <button onClick={() => setShowCreateSheet(true)}>
              <motion.div
                whileTap={{ scale: 0.9 }}
                transition={{ type: 'spring', stiffness: 400, damping: 17 }}
                className="w-[56px] h-[56px] flex items-center justify-center bg-system-blue rounded-[20px] shadow-lg shadow-system-blue/30 -translate-y-5 border-[4px] border-[#0A0A0A]"
              >
                <Plus className="w-8 h-8 text-white" strokeWidth={2.5} />
              </motion.div>
            </button>
          </div>

          <div className="flex flex-1 justify-around">
            {rightTabs.map(renderTab)}
          </div>
        </div>
      </nav>

      <AnimatePresence>
        {showCreateSheet && (
          <>
            <motion.button
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowCreateSheet(false)}
              className="fixed inset-0 z-[60] bg-black/60"
            />
            <motion.div
              initial={{ y: 180, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: 180, opacity: 0 }}
              transition={{ type: 'spring', stiffness: 260, damping: 26 }}
              className="fixed bottom-0 left-0 right-0 z-[61] px-4 pb-6"
            >
              <div className="max-w-[600px] mx-auto glass-elevated rounded-t-3xl rounded-b-2xl p-4 border border-white/[0.06]">
                <p className="text-[12px] text-muted-foreground uppercase tracking-wider mb-3">
                  Create
                </p>

                <button
                  onClick={() => {
                    setShowCreateSheet(false);
                    navigate('/lead-capture');
                  }}
                  className="w-full min-h-14 rounded-2xl bg-system-blue/15 border border-system-blue/25 px-4 py-4 text-left flex items-center gap-3 active:opacity-80"
                >
                  <Phone className="w-6 h-6 text-system-blue" />
                  <span className="text-[18px] text-foreground font-semibold">+ New Lead</span>
                </button>

                <button
                  onClick={() => {
                    setShowCreateSheet(false);
                    navigate('/projects/new');
                  }}
                  className="w-full min-h-14 rounded-2xl bg-system-green/15 border border-system-green/25 px-4 py-4 text-left flex items-center gap-3 mt-3 active:opacity-80"
                >
                  <ClipboardList className="w-6 h-6 text-system-green" />
                  <span className="text-[18px] text-foreground font-semibold">+ New Project</span>
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
