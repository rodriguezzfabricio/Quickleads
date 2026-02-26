import { Outlet } from 'react-router';
import { BottomNav } from './BottomNav';

export function Layout() {
  return (
    <div className="min-h-screen bg-background relative">
      <div className="max-w-[600px] mx-auto bg-background min-h-screen relative">
        <Outlet />
        <BottomNav />
      </div>
    </div>
  );
}