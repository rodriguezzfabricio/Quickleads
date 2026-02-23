import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ChevronLeft, Edit2 } from 'lucide-react';
import { defaultSettings } from '../data/mockData';
import { motion } from 'motion/react';

export function FollowUpSettingsScreen() {
  const navigate = useNavigate();
  const [settings, setSettings] = useState(defaultSettings);
  const [editingDay, setEditingDay] = useState<number | null>(null);

  return (
    <div className="min-h-screen bg-background pb-24">
      <div className="max-w-[600px] mx-auto">
        <div className="sticky top-0 bg-background/70 backdrop-blur-2xl px-5 pt-14 pb-3 z-10">
          <button onClick={() => navigate(-1)} className="mb-3 text-system-blue flex items-center gap-0.5 -ml-1">
            <ChevronLeft className="w-5 h-5" /><span className="text-[17px]">Back</span>
          </button>
          <motion.h1 initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="text-[34px] font-bold text-foreground tracking-tight">Follow-up</motion.h1>
        </div>

        <div className="px-5 space-y-4 pt-2">
          {/* Toggle */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="flex items-center justify-between p-4 glass-elevated rounded-2xl">
            <div>
              <h3 className="font-semibold text-[17px] text-foreground">Auto Follow-up</h3>
              <p className="text-[13px] text-muted-foreground mt-0.5">Send follow-ups automatically</p>
            </div>
            <button onClick={() => setSettings({ ...settings, followUpEnabled: !settings.followUpEnabled })}
              className={`w-[51px] h-[31px] rounded-full transition-colors duration-300 relative ${settings.followUpEnabled ? 'bg-system-green' : 'bg-[rgba(120,120,128,0.32)]'}`}>
              <div className={`w-[27px] h-[27px] bg-white rounded-full shadow-md transition-transform duration-300 absolute top-[2px] ${settings.followUpEnabled ? 'translate-x-[22px]' : 'translate-x-[2px]'}`} />
            </button>
          </motion.div>

          {/* Method */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.05 }}>
            <label className="block text-[11px] text-muted-foreground mb-2 uppercase tracking-wider px-1">Send Via</label>
            <div className="glass-elevated rounded-xl p-[3px] flex gap-[2px]">
              {(['sms', 'email', 'both'] as const).map(m => (
                <button key={m} onClick={() => setSettings({ ...settings, followUpMethod: m })}
                  className={`flex-1 py-[7px] rounded-[10px] text-[15px] font-medium transition-all duration-300 ${settings.followUpMethod === m ? 'glass-prominent text-foreground shadow-sm' : 'text-muted-foreground'
                    }`}
                >{m === 'sms' ? 'SMS' : m === 'email' ? 'Email' : 'Both'}</button>
              ))}
            </div>
          </motion.div>

          {/* Templates */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
            <label className="block text-[11px] text-muted-foreground mb-3 uppercase tracking-wider px-1">Templates</label>
            <div className="space-y-3">
              {settings.followUpTemplates.map(t => (
                <div key={t.day} className="glass-elevated rounded-2xl p-4">
                  <div className="flex items-center justify-between mb-2">
                    <h4 className="font-semibold text-[15px] text-system-blue">Day {t.day}</h4>
                    <button onClick={() => setEditingDay(editingDay === t.day ? null : t.day)} className="text-system-blue flex items-center gap-1">
                      <Edit2 className="w-3.5 h-3.5" /><span className="text-[13px]">Edit</span>
                    </button>
                  </div>
                  {editingDay === t.day ? (
                    <textarea defaultValue={t.message} rows={4} className="w-full p-3 glass rounded-xl resize-none focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground text-[15px]"
                      onBlur={(e) => { setSettings({ ...settings, followUpTemplates: settings.followUpTemplates.map(x => x.day === t.day ? { ...x, message: e.target.value } : x) }); setEditingDay(null); }} />
                  ) : (
                    <p className="text-[15px] text-foreground/80 leading-relaxed">{t.message}</p>
                  )}
                </div>
              ))}
            </div>
          </motion.div>

          <div className="glass-elevated rounded-2xl p-4">
            <p className="text-[13px] text-muted-foreground"><strong className="text-system-blue">Note:</strong> Messages sent 9 AM – 6 PM only</p>
          </div>
        </div>
      </div>
    </div>
  );
}
