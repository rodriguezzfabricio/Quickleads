import { Home, Users, Briefcase } from 'lucide-react';
import { Link, useLocation } from 'react-router';

export function BottomNav() {
  const location = useLocation();

  const isActive = (path: string) => {
    if (path === '/') return location.pathname === '/';
    return location.pathname.startsWith(path);
  };

  const tabs = [
    { path: '/', label: 'Home', icon: Home },
    { path: '/leads', label: 'Leads', icon: Users },
    { path: '/jobs', label: 'Jobs', icon: Briefcase },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 glass-nav safe-area-inset-bottom z-50">
      <div className="flex items-center justify-around h-[82px] max-w-[600px] mx-auto pb-1">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const active = isActive(tab.path);
          return (
            <Link
              key={tab.path}
              to={tab.path}
              className={`flex flex-col items-center justify-center flex-1 h-full gap-[2px] transition-all duration-300 ${active ? 'text-system-blue' : 'text-[rgba(235,235,245,0.35)]'
                }`}
            >
              <Icon className="w-[22px] h-[22px]" strokeWidth={active ? 2.2 : 1.6} />
              <span className={`text-[10px] ${active ? 'font-semibold' : 'font-medium'}`}>
                {tab.label}
              </span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}