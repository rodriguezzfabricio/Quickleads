import { Home, Users, Briefcase, UserCircle2, Plus } from 'lucide-react';
import { Link, useLocation } from 'react-router';
import { motion } from 'motion/react';

export function BottomNav() {
  const location = useLocation();

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
    <nav className="fixed bottom-0 left-0 right-0 glass-nav safe-area-inset-bottom z-50">
      <div className="flex items-center justify-between h-[82px] max-w-[600px] mx-auto pb-1 px-4">
        <div className="flex flex-1 justify-around">
          {leftTabs.map(renderTab)}
        </div>

        {/* Center Primary Action */}
        <div className="flex items-center justify-center px-4">
          <Link to="/lead-capture">
            <motion.div
              whileTap={{ scale: 0.9 }}
              transition={{ type: 'spring', stiffness: 400, damping: 17 }}
              className="w-[56px] h-[56px] flex items-center justify-center bg-system-blue rounded-[20px] shadow-lg shadow-system-blue/30 -translate-y-5 border-[4px] border-[#0A0A0A]"
            >
              <Plus className="w-8 h-8 text-white" strokeWidth={2.5} />
            </motion.div>
          </Link>
        </div>

        <div className="flex flex-1 justify-around">
          {rightTabs.map(renderTab)}
        </div>
      </div>
    </nav>
  );
}