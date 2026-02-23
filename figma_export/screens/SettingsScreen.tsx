import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ChevronLeft, Settings as SettingsIcon, Bell, CreditCard, LogOut, ChevronRight } from 'lucide-react';
import { defaultSettings } from '../data/mockData';
import { motion } from 'motion/react';

export function SettingsScreen() {
  const navigate = useNavigate();
  const [settings, setSettings] = useState(defaultSettings);

  return (
    <div className="min-h-screen bg-background pb-24">
      <div className="max-w-[600px] mx-auto">
        <div className="sticky top-0 bg-background/70 backdrop-blur-2xl px-5 pt-14 pb-3 z-10">
          <button onClick={() => navigate('/')} className="mb-3 text-system-blue flex items-center gap-0.5 -ml-1">
            <ChevronLeft className="w-5 h-5" /><span className="text-[17px]">Home</span>
          </button>
          <motion.h1 initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="text-[34px] font-bold text-foreground tracking-tight">Settings</motion.h1>
        </div>

        <div className="px-5 space-y-6 pt-2">
          {/* Business Info */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}>
            <h2 className="text-[11px] font-medium text-muted-foreground mb-2 uppercase tracking-wider px-1">Business</h2>
            <div className="glass-elevated rounded-2xl overflow-hidden divide-y divide-white/[0.04]">
              {[
                { label: 'Business Name', val: settings.businessName, key: 'businessName' },
                { label: 'Your Name', val: settings.contractorName, key: 'contractorName' },
                { label: 'Phone', val: settings.phone, key: 'phone' },
              ].map(f => (
                <div key={f.key} className="p-4">
                  <label className="block text-[11px] text-muted-foreground mb-1">{f.label}</label>
                  <input type="text" value={f.val} onChange={(e) => setSettings({ ...settings, [f.key]: e.target.value })} className="w-full bg-transparent focus:outline-none text-foreground text-[17px]" />
                </div>
              ))}
            </div>
          </motion.div>

          {/* Follow-up */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.05 }}>
            <h2 className="text-[11px] font-medium text-muted-foreground mb-2 uppercase tracking-wider px-1">Follow-up</h2>
            <div className="glass-elevated rounded-2xl overflow-hidden">
              <button onClick={() => navigate('/follow-up-settings')} className="w-full flex items-center justify-between p-4 active:bg-white/[0.02]">
                <div className="flex items-center gap-3">
                  <SettingsIcon className="w-5 h-5 text-muted-foreground" />
                  <span className="text-[17px] text-foreground">Follow-up Sequence</span>
                </div>
                <ChevronRight className="w-5 h-5 text-muted-foreground/50" />
              </button>
            </div>
          </motion.div>

          {/* Notifications */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
            <h2 className="text-[11px] font-medium text-muted-foreground mb-2 uppercase tracking-wider px-1">Preferences</h2>
            <div className="glass-elevated rounded-2xl overflow-hidden">
              <div className="flex items-center justify-between p-4">
                <div className="flex items-center gap-3">
                  <Bell className="w-5 h-5 text-muted-foreground" />
                  <div>
                    <h3 className="text-[17px] text-foreground">Notifications</h3>
                    <p className="text-[13px] text-muted-foreground">Reminders & updates</p>
                  </div>
                </div>
                <button onClick={() => setSettings({ ...settings, notificationsEnabled: !settings.notificationsEnabled })}
                  className={`w-[51px] h-[31px] rounded-full transition-colors duration-300 relative ${settings.notificationsEnabled ? 'bg-system-green' : 'bg-[rgba(120,120,128,0.32)]'}`}>
                  <div className={`w-[27px] h-[27px] bg-white rounded-full shadow-md transition-transform duration-300 absolute top-[2px] ${settings.notificationsEnabled ? 'translate-x-[22px]' : 'translate-x-[2px]'}`} />
                </button>
              </div>
            </div>
          </motion.div>

          {/* Account */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.15 }}>
            <h2 className="text-[11px] font-medium text-muted-foreground mb-2 uppercase tracking-wider px-1">Account</h2>
            <div className="glass-elevated rounded-2xl overflow-hidden divide-y divide-white/[0.04]">
              <button className="w-full flex items-center justify-between p-4 active:bg-white/[0.02]">
                <div className="flex items-center gap-3">
                  <CreditCard className="w-5 h-5 text-muted-foreground" />
                  <span className="text-[17px] text-foreground">Subscription & Billing</span>
                </div>
                <ChevronRight className="w-5 h-5 text-muted-foreground/50" />
              </button>
              <button className="w-full flex items-center gap-3 p-4 active:bg-white/[0.02]">
                <LogOut className="w-5 h-5 text-system-red" />
                <span className="text-[17px] text-system-red">Log Out</span>
              </button>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
